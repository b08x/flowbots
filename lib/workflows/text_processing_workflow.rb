#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TextProcessingWorkflow
    attr_reader :input_file_path, :text_file_id

    def initialize(input_file_path=nil)
      @input_file_path = input_file_path || prompt_for_file # Assign or prompt
      @orchestrator = WorkflowOrchestrator.new
    end

    def run
      Flowbots::UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      setup_workflow
      store_input_file_path

      Flowbots::UI.info "Running Text Processing Workflow"
      @orchestrator.run_workflow

      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
      logger.info "Text Processing Workflow completed"
    end

    private

    def prompt_for_file
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)
      raise FlowbotError.new("File not found", "FILENOTFOUND") unless File.exist?(file_path)

      file_path
    end

    def setup_workflow
      logger.debug "Setting up workflow"

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

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    def store_input_file_path
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("input_file_path", @input_file_path)
      file_loader = Flowbots::FileLoader.new(@input_file_path)
      textfile = file_loader.file_data
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_textfile_id", textfile.id)
    end
  end
end
