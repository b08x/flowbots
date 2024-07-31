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

      ensure_indices
      verify_indices
      setup_workflow
      process_input_file

      Flowbots::UI.info "Running Text Processing Workflow"
      @orchestrator.run_workflow(@workflow)

      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
      logger.info "Text Processing Workflow completed"
    end

    private

    def ensure_indices
      logger.debug "Ensuring indices for Sourcefile and Workflow models"
      Sourcefile.ensure_indices
      Workflow.ensure_indices
      logger.debug "All indices ensured"
    end

    def verify_indices
      logger.debug "Verifying indices for Sourcefile and Workflow models"
      Sourcefile.verify_indices
      Workflow.verify_indices
      logger.debug "All indices verified"
    rescue Ohm::IndexNotFound => e
      logger.error "Index verification failed: #{e.message}"
      raise FlowbotError.new("Database index error: #{e.message}", "INDEX_VERIFICATION_ERROR")
    end

    def prompt_for_file
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)
      raise FlowbotError.new("File not found", "FILENOTFOUND") unless File.exist?(file_path)

      file_path
    end

    def setup_workflow
      logger.debug "Setting up workflow"
      @workflow = Workflow.create(
        name: "TextProcessingWorkflow",
        status: "started",
        start_time: Time.now.to_s,
        is_batch_workflow: false,
        workflow_type: "text_processing"
      )
      logger.debug "Workflow created: #{@workflow.inspect}"
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
  end
end
