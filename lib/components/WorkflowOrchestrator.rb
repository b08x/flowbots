#!/usr/bin/env ruby
# frozen_string_literal: true

class WorkflowOrchestrator
  include Logging

  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  class << self
    include Logging

    def cleanup
      logger.info("Cleaning up WorkflowOrchestrator")
      # Add any necessary cleanup actions here
      logger.info("Cleanup completed")
    end
  end

  attr_reader :debug_log

  def initialize
    @tasks = []
    @agents = {}
    @workflow = nil
    @debug_log = []
  end

  def setup_workflow(workflow_type)
    @workflow = Workflow.create(
      name: to_camel_case("#{workflow_type}Workflow"),
      status: "initialized",
      start_time: Time.now.to_s,
      workflow_type: workflow_type,
      is_batch_workflow: (workflow_type == "topic_model_trainer")
    )

    logger.debug("Created workflow: #{@workflow.inspect}")

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

    logger.info("Workflow setup completed for #{workflow_type}")
    @workflow
  end

  def run_workflow(workflow)
    @workflow = workflow
    logger.info("Starting workflow execution for #{@workflow.name}")

    @workflow.update(status: "running")

    begin
      ensure_jongleur_initialized

      Jongleur::API.run do |on|
        on.start do |task|
          logger.info("Starting task: #{task.class.name}")
        end

        on.finish do |task|
          logger.info("Finished task: #{task.class.name}")
        end

        on.error do |task, error|
          handle_error(error, task)
        end

        on.completed do |task_matrix|
          logger.info("Workflow completed")
          logger.debug("Task matrix: #{task_matrix}")
          @workflow.update(status: "completed", end_time: Time.now.to_s)
        end
      end

      logger.info("Workflow execution finished")
    rescue StandardError => e
      logger.error("Error during workflow execution: #{e.message}")
      logger.error(e.backtrace.join("\n"))
      @workflow.update(status: "failed", end_time: Time.now.to_s)
      raise
    end
  end

  private

  def setup_agents
    logger.info("Setting up agents")
    @agents[:task_manager] = WorkflowAgent.new("task_manager", File.join(CARTRIDGE_BASE_DIR, "@b08x", "cartridges", "task_manager.yml"))
    @agents[:exception_handler] = WorkflowAgent.new("exception_handler", File.join(CARTRIDGE_BASE_DIR, "@b08x", "cartridges", "exception_handler.yml"))
    logger.info("Agents setup completed")
  end

  def define_jongleur_workflow
    logger.info("Defining Jongleur workflow")
    workflow_graph = {}

    @tasks.each_with_index do |task, index|
      if index < @tasks.length - 1
        workflow_graph[task] = [@tasks[index + 1]]
      else
        workflow_graph[task] = []
      end
    end

    Jongleur::API.add_task_graph(workflow_graph)
    logger.info("Jongleur workflow defined")
  end

  def ensure_jongleur_initialized
    unless Jongleur::API.class_variable_defined?(:@@task_graph)
      logger.warn("Initializing missing @@task_graph in Jongleur::API")
      Jongleur::API.class_variable_set(:@@task_graph, {})
    end

    unless Jongleur::API.class_variable_defined?(:@@task_matrix)
      logger.warn("Initializing missing @@task_matrix in Jongleur::API")
      Jongleur::API.class_variable_set(:@@task_matrix, {})
    end
  end

  def handle_error(error, task)
    logger.error("Error in task #{task}: #{error.message}")
    error_input = "Error in task #{task}: #{error.message}"
    error_response = @agents[:exception_handler].process(error_input)
    logger.info("Error handler response: #{error_response}")
  end

  def to_camel_case(string)
    string.split("_").map(&:capitalize).join
  end

  def log(message, level = :debug)
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    log_entry = "#{timestamp} - #{message}"
    @debug_log << log_entry
    logger.send(level, message)
  end

  def dump_debug_log
    File.write("workflow_debug_log_#{Time.now.to_i}.txt", @debug_log.join("\n"))
  end
end
