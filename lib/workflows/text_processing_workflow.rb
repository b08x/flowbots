#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class defines a workflow for processing text files, either individually or in batch mode.
  # It utilizes a UnifiedFileProcessingPipeline to handle the initial processing steps and then
  # performs additional tasks like text tagging, topic modeling, LLM analysis, and result display.
  class TextProcessingWorkflow
    # @return [UnifiedFileProcessingPipeline] The pipeline responsible for the initial processing steps.
    attr_reader :pipeline

    # Initializes a new TextProcessingWorkflow instance.
    #
    # @param input_file_path [String, nil] The path to the input file. If nil, the user will be prompted to select a file.
    # @param batch_mode [Boolean] Whether to process files in batch mode (default: false).
    #
    # @return [void]
    def initialize(input_file_path=nil, batch_mode=false)
      @input_file_path = input_file_path || prompt_for_file
      @batch_mode = batch_mode
      @pipeline = UnifiedFileProcessingPipeline.new(
        @input_file_path,
        batch_size: batch_mode ? nil : 1,
        file_types: %w[txt md markdown]
      )
    end

    # Runs the text processing workflow.
    #
    # Sets up the workflow, processes the file(s), and performs additional tasks based on the batch mode.
    #
    # @return [void]
    def run
      UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      begin
        @pipeline.process
        if @batch_mode
          process_batch
        else
          process_single_file
        end
        UI.say(:ok, "Text Processing Workflow completed")
        logger.info "Text Processing Workflow completed"
      rescue StandardError => e
        UI.say(:error, "Error in Text Processing Workflow: #{e.message}")
        logger.error "Error in Text Processing Workflow: #{e.message}"
        logger.error e.backtrace.join("\n")
      end
    end

    private

    # Prompts the user to select a file using the `gum file` command.
    #
    # @return [String] The path to the selected file.
    # @raises [FlowbotError] If the selected file does not exist.
    def prompt_for_file
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)

      raise FlowbotError.new("File not found", "FILENOTFOUND") unless File.exist?(file_path)

      file_path
    end

    # Processes files in batch mode.
    #
    # Fetches unprocessed file IDs and performs additional tasks for each file.
    #
    # @return [void]
    def process_batch
      file_ids = fetch_unprocessed_file_ids
      file_ids.each do |file_id|
        perform_additional_tasks(file_id)
      end
    end

    # Processes a single file.
    #
    # Creates or fetches the FileObject for the input file and performs additional tasks.
    #
    # @return [void]
    def process_single_file
      file_object = create_or_fetch_file_object(@input_file_path)
      perform_additional_tasks(file_object.id)
    rescue ArgumentError => e
      logger.error "Invalid input for file object: #{e.message}"
      UI.say(:error, "Invalid input for file object: #{e.message}")
    rescue FileNotFoundError => e
      logger.error e.message
      UI.say(:error, e.message)
    rescue FileObjectError => e
      logger.error "Error processing file: #{e.message}"
      UI.say(:error, "Error processing file: #{e.message}")
    rescue StandardError => e
      logger.error "Unexpected error in text processing: #{e.message}"
      logger.error e.backtrace.join("\n")
      UI.say(:error, "Unexpected error in text processing. Check logs for details.")
    end

    # Creates or fetches a FileObject for the given file path.
    #
    # @param file_path [String, Hash] The path to the file or a hash containing the path.
    #
    # @return [FileObject] The created or fetched FileObject.
    def create_or_fetch_file_object(file_path)
      FileObject.find_or_create_by_path(file_path)
    rescue ArgumentError => e
      logger.error "Invalid file path: #{e.message}"
      raise FlowbotError.new("Invalid file path", "INVALID_FILE_PATH", details: e.message)
    rescue StandardError => e
      logger.error "Error creating or fetching FileObject: #{e.message}"
      raise FlowbotError.new("Error processing file", "FILE_PROCESSING_ERROR", details: e.message)
    end

    # Fetches the IDs of unprocessed files.
    #
    # @return [Array<Integer>] An array of unprocessed file IDs.
    def fetch_unprocessed_file_ids
      # Assuming we're using ActiveRecord and there's a FileObject model
      # This query fetches all file IDs where llm_analysis is nil or an empty string
      ids = []
      FileObject.all.each { |f| ids << f.id.to_i if f.llm_analysis.nil? }
      ids
    end

    # Performs additional tasks for the given file ID.
    #
    # Defines the workflow for additional tasks and runs the workflow using the orchestrator.
    #
    # @param _file_id [Integer] The ID of the file to process (unused).
    #
    # @return [void]
    def perform_additional_tasks(_file_id)
      additional_tasks = {
        TextTaggerTask: [:TopicModelingTask],
        TopicModelingTask: [:LlmAnalysisTask],
        LlmAnalysisTask: []
      }

      @pipeline.orchestrator.define_workflow(additional_tasks)
      @pipeline.orchestrator.run_workflow
    end
  end
end
