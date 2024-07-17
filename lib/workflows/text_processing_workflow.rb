#!/usr/bin/env ruby
# frozen_string_literal: true

# text_processing_workflow.rb
# Description: A text processing workflow that processes a text file, segments it, and performs topic modeling

module Flowbots
  class TextProcessingWorkflow
    include Logging

    attr_accessor :input_file_path

    def initialize(input_file_path = nil)
      @input_file_path = input_file_path || prompt_for_file # Assign or prompt
      @orchestrator = WorkflowOrchestrator.new
      @nlp_processor = NLPProcessor.instance
      @topic_modeling_processor = TopicModelProcessor.instance
    end

    def run
      Flowbots::UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"
      setup_workflow
      process_input

      Flowbots::UI.info "Running Text Processing Workflow"
      @orchestrator.run_workflow

      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
      logger.info "Text Processing Workflow completed"

    end

    private

    def prompt_for_file
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)
      unless File.exist?(file_path)
        raise FlowbotError.new("File not found", "FILENOTFOUND")
      end
      file_path
    end

    def setup_workflow
      logger.debug "Setting up workflow"

      workflow_graph = {
        NlpAnalysisTask: [:TopicModelingTask],
        TopicModelingTask: [:LlmAnalysisTask],
        LlmAnalysisTask: [:DisplayResultsTask],
        DisplayResultsTask: []
      }

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    def process_input
      Flowbots::UI.info "Processing input file: #{@input_file_path}"
      text = File.read(@input_file_path)
      processed_text = @nlp_processor.process(text)
      store_processed_text(processed_text)
      logger.debug "Input processing completed"
    end

    def store_processed_text(text)
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("processed_text", text.to_json)
    end

    def retrieve_processed_text
      JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
    end

    def retrieve_analysis_result
      JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))
    end

    def retrieve_topics
      @topic_modeling_processor.get_topics
    end
  end
end
