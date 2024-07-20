#!/usr/bin/env ruby
# frozen_string_literal: true

# text_processing_workflow.rb
# Description: A text processing workflow that processes a text file, segments it, and performs topic modeling

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
        FileLoaderTask: [:TextSegmentTask],
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
    end

  end
end
