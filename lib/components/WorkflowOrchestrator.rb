#!/usr/bin/env ruby
# frozen_string_literal: true

class WorkflowOrchestrator
  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  def initialize
    @tasks = []
    @agents = {}
    logger.level = Logger::DEBUG
  end

  def setup_workflow(workflow_type)
    logger.debug "Setting up workflow for type: #{workflow_type}"

    workflow = Workflow.create(
      name: to_camel_case("#{workflow_type}Workflow"),
      status: "initialized",
      start_time: Time.now.to_s,
      workflow_type:,
      is_batch_workflow: (workflow_type == "topic_model_trainer")
    )

    logger.debug "Created workflow: #{workflow.inspect}"
    logger.debug "Workflow class: #{workflow.class}"
    logger.debug "Workflow id: #{workflow.id}"

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

    logger.debug "Workflow setup completed for #{workflow_type}"
    workflow
  end

  def run_workflow(workflow)
    logger.info "Starting workflow execution"

    workflow.update(status: "running")

    if workflow.is_batch_workflow
      run_batch_workflow
    else
      run_single_file_workflow
    end

    workflow.update(status: "completed", end_time: Time.now.to_s)
    logger.info "Workflow completed"
  end

  def self.cleanup
    logger.info "Cleaning up WorkflowOrchestrator"
    # Implement any necessary cleanup logic here
    # Ohm.redis.call("FLUSHDB")
    logger.info "Cleanup completed"
  end

  private

  def setup_agents
    @agents[:task_manager] =
      WorkflowAgent.new("task_manager", File.join(CARTRIDGE_BASE_DIR, "@b08x", "cartridges", "task_manager.yml"))
    @agents[:exception_handler] =
      WorkflowAgent.new(
        "exception_handler",
        File.join(CARTRIDGE_BASE_DIR, "@b08x", "cartridges", "exception_handler.yml")
      )
    # Add more agents as needed
  end

  def run_batch_workflow
    while @workflow.status != "completed"
      @tasks.each do |task_class|
        logger.debug "task class: #{task_class}"
        task = task_class.new
        run_task_with_agent(task)
        break if @workflow.reload.status == "completed"
      end
    end
  end

  def run_single_file_workflow
    @tasks.each do |task_class|
      task = task_class.new
      run_task_with_agent(task)
    end
  end

  def run_task_with_agent(task)
    task_input = prepare_task_input(task)
    agent_response = @agents[:task_manager].process(task_input)

    if should_run_task?(agent_response)
      begin
        task.execute(@workflow)
      rescue StandardError => e
        handle_error(e, task)
      end
    else
      logger.info "Task #{task.class.name} skipped based on agent decision"
    end
  end

  def prepare_task_input(task)
    "Task: #{task.class.name}, Workflow: #{@workflow.name}, Status: #{@workflow.status}"
  end

  def should_run_task?(agent_response)
    agent_response.downcase.include?("run task")
  end

  def handle_error(error, task)
    error_input = "Error in task #{task.class.name}: #{error.message}"
    error_response = @agents[:exception_handler].process(error_input)

    logger.error "Error in task #{task.class.name}: #{error.message}"
    logger.info "Error handler response: #{error_response}"
  end

  def to_camel_case(string)
    string.split("_").map(&:capitalize).join
  end
end
