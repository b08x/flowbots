#!/usr/bin/env ruby
# frozen_string_literal: true

class WorkflowOrchestrator
  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  def initialize
    @tasks = []
    @agents = {}
    @workflow = nil
    @debug_log = []
    logger.level = Logger::DEBUG
  end

  def setup_workflow(workflow_type)
    debug_log("Setting up workflow for type: #{workflow_type}")

    @workflow = Workflow.create(
      name: to_camel_case("#{workflow_type}Workflow"),
      status: "initialized",
      start_time: Time.now.to_s,
      workflow_type: workflow_type,
      is_batch_workflow: (workflow_type == "topic_model_trainer")
    )

    debug_log("Created workflow: #{@workflow.inspect}")

    @tasks = [
      WorkflowInitializerTask,
      LoadTextFilesTask,
      PreprocessTextFileTask,
      TextSegmentTask,
      TokenizeSegmentsTask,
      NlpAnalysisTask,
      TopicModelingTask,
      BatchCompletionTask
    ]

    setup_agents
    define_jongleur_workflow

    debug_log("Workflow setup completed for #{workflow_type}")
    @workflow
  end

  def run_workflow(workflow)
    @workflow = workflow
    debug_log("Starting workflow execution for #{@workflow.name}")

    @workflow.update(status: "running")

    Jongleur::API.run do |on|
      on.start do |task|
        debug_log("Starting task: #{task}")
      end

      on.finish do |task|
        debug_log("Finished task: #{task}")
      end

      on.error do |task, error|
        handle_error(error, task)
      end

      on.completed do |task_matrix|
        debug_log("Workflow completed")
        debug_log("Task matrix: #{task_matrix}")
        @workflow.update(status: "completed", end_time: Time.now.to_s)
      end
    end

    debug_log("Workflow execution finished")
  end

  def self.cleanup
    debug_log("Cleaning up WorkflowOrchestrator")
    Jongleur::API.stop_all_tasks
    debug_log("Cleanup completed")
  end

  private

  def setup_agents
    debug_log("Setting up agents")
    @agents[:task_manager] = WorkflowAgent.new("task_manager", File.join(CARTRIDGE_BASE_DIR, "@b08x", "cartridges", "task_manager.yml"))
    @agents[:exception_handler] = WorkflowAgent.new("exception_handler", File.join(CARTRIDGE_BASE_DIR, "@b08x", "cartridges", "exception_handler.yml"))
    debug_log("Agents setup completed")
  end

  def define_jongleur_workflow
    debug_log("Defining Jongleur workflow")
    workflow_graph = {}

    @tasks.each_with_index do |task, index|
      if index < @tasks.length - 1
        workflow_graph[task] = [@tasks[index + 1]]
      else
        workflow_graph[task] = []
      end
    end

    Jongleur::API.add_task_graph(workflow_graph)
    debug_log("Jongleur workflow defined")
  end

  def handle_error(error, task)
    debug_log("Error in task #{task}: #{error.message}")
    error_input = "Error in task #{task}: #{error.message}"
    error_response = @agents[:exception_handler].process(error_input)
    debug_log("Error handler response: #{error_response}")
  end

  def to_camel_case(string)
    string.split("_").map(&:capitalize).join
  end

  def debug_log(message)
    timestamp = Time.now.strftime("%Y-%m-% d %H:%M:%S")
    log_entry = "#{timestamp} - #{message}"
    @debug_log << log_entry
    logger.debug(log_entry)
  end

  def dump_debug_log
    File.write("workflow_debug_log_#{Time.now.to_i}.txt", @debug_log.join("\n"))
  end
end
