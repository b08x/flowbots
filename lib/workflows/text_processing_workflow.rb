#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class represents a workflow for processing text using topic modeling.
  class TextProcessingWorkflow
    # The path to the input file.
    attr_reader :input_file_path

    # The ID of the Textfile object representing the input file.
    attr_reader :text_file_id

    # Initializes a new TextProcessingWorkflow instance.
    #
    # @param input_file_path [String] The path to the input file.
    #
    # @return [void]
    def initialize(input_file_path=nil)
      # Assigns the input file path or prompts the user for it.
      @input_file_path = input_file_path || prompt_for_file

      # Creates a new WorkflowOrchestrator instance.
      @orchestrator = WorkflowOrchestrator.new
    end

    # Runs the text processing workflow.
    #
    # @return [void]
    def run
      # Displays a message indicating the start of the workflow.
      Flowbots::UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      # Sets up the workflow graph and stores the input file path in Redis.
      setup_workflow
      store_input_file_path

      # Displays a message indicating the start of the workflow execution.
      Flowbots::UI.info "Running Text Processing Workflow"

      # Runs the workflow using the WorkflowOrchestrator.
      @orchestrator.run_workflow

      # Displays a message indicating the completion of the workflow.
      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
      logger.info "Text Processing Workflow completed"
    end

    private

    # Prompts the user for the input file path.
    #
    # @return [String] The path to the input file.
    def prompt_for_file
      # Uses the `gum` command to prompt the user for a file.
      get_file_path = `gum file`.chomp.strip

      # Constructs the full file path.
      file_path = File.join(get_file_path)

      # Raises an error if the file does not exist.
      raise FlowbotError.new("File not found", "FILENOTFOUND") unless File.exist?(file_path)

      # Returns the file path.
      file_path
    end

    # Sets up the workflow graph.
    #
    # @return [void]
    def setup_workflow
      # Logs a message indicating the start of workflow setup.
      logger.debug "Setting up workflow"

      # Defines the workflow graph, specifying the order of tasks.
      workflow_graph = {
        FileLoaderTask: [:PreprocessTextFileTask],
        PreprocessTextFileTask: [:TextTaggerTask],
        TextTaggerTask: [:TextSegmentTask],
        TextSegmentTask: [:TextTokenizeTask],
        TextTokenizeTask: [:NlpAnalysisTask],
        NlpAnalysisTask: [:TopicModelingTask],
        TopicModelingTask: [:LlmAnalysisTask],
        LlmAnalysisTask: [:DisplayResultsTask],
        DisplayResultsTask: []
      }

      # Defines the workflow using the WorkflowOrchestrator.
      @orchestrator.define_workflow(workflow_graph)

      # Logs a message indicating the completion of workflow setup.
      logger.debug "Workflow setup completed"
    end

    # Stores the input file path in Redis.
    #
    # @return [void]
    def store_input_file_path
      # Stores the input file path in Redis.
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("input_file_path", @input_file_path)

      # Loads the input file using the FileLoader.
      file_loader = Flowbots::FileLoader.new(@input_file_path)
      textfile = file_loader.file_data

      # Stores the Textfile ID in Redis.
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_textfile_id", textfile.id)
    end
  end
end
