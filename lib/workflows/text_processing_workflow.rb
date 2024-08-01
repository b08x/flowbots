#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TextProcessingWorkflow
    attr_reader :input_file_path, :workflow

    def initialize(input_file_path=nil)
      @input_file_path = input_file_path || prompt_for_file
      @orchestrator = WorkflowOrchestrator.new
    end

    def run
      Flowbots::UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      Flowbots.ensure_indices
      Flowbots.verify_indices
      setup_workflow
      define_tasks
      process_input_file

      Flowbots::UI.info "Running Text Processing Workflow"
      @orchestrator.run_workflow(@workflow)

      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
      logger.info "Text Processing Workflow completed"
    end

    private

    def setup_workflow
      @workflow = Workflow.create(
        name: "TextProcessingWorkflow",
        status: "started",
        start_time: Time.now.to_s,
        is_batch_workflow: false,
        workflow_type: "text_processing"
      )
      logger.debug "Workflow created: #{@workflow.inspect}"
    end

    def define_tasks
      tasks = [
        'Flowbots::FileLoaderTask',
        'Flowbots::PreprocessTextFileTask',
        'Flowbots::TextSegmentTask',
        'Flowbots::TokenizeSegmentsTask',
        'Flowbots::NlpAnalysisTask',
        'Flowbots::TopicModelingTask',
        'Flowbots::LlmAnalysisTask',
        'Flowbots::DisplayResultsTask'
      ]

      workflow_graph = {}
      tasks.each_with_index do |task, index|
        if index < tasks.length - 1
          workflow_graph[task] = [tasks[index + 1]]
        else
          workflow_graph[task] = []
        end
      end

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Tasks defined and added to workflow"
    end

    def process_input_file
      logger.debug "Processing input file: #{@input_file_path}"
      logger.debug "Workflow: #{@workflow.inspect}"

      begin
        sourcefile = Sourcefile.find_or_create_by_path(@input_file_path)
        logger.debug "Sourcefile created or found: #{sourcefile.inspect}"

        raise FlowbotError.new("Failed to create or find Sourcefile", "SOURCEFILE_ERROR") if sourcefile.nil?

        sourcefile.add_to_workflow(@workflow)
        logger.debug "Sourcefile added to workflow"

        @workflow.update(current_file_id: sourcefile.id)
        logger.debug "Updated workflow with current file ID: #{sourcefile.id}"
      rescue Ohm::IndexNotFound => e
        logger.error "Ohm index not found: #{e.message}"
        raise FlowbotError.new("Database index error: #{e.message}", "OHM_INDEX_ERROR")
      rescue Ohm::Error => e
        logger.error "Ohm error: #{e.message}"
        logger.error "Workflow ID: #{@workflow.id}"
        logger.error "Sourcefile: #{sourcefile.inspect}" if defined?(sourcefile)
        raise FlowbotError.new("Database error: #{e.message}", "OHM_ERROR")
      rescue StandardError => e
        logger.error "Error processing input file: #{e.message}"
        logger.error e.backtrace.join("\n")
        raise FlowbotError.new("Error processing input file: #{e.message}", "FILE_PROCESSING_ERROR")
      end
    end

    def prompt_for_file
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)
      raise FlowbotError.new("File not found", "FILENOTFOUND") unless File.exist?(file_path)

      file_path
    end
  end
end
