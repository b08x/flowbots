#!/usr/bin/env ruby
# frozen_string_literal: true

# text_processing_workflow.rb
# Description: A text processing workflow that processes a text file, segments it, and performs topic modeling

module Flowbots
  class TextProcessingWorkflow
    include Logging

    def initialize(input_file_path)
      @input_file_path = input_file_path
      @orchestrator = WorkflowOrchestrator.new
      @nlp_processor = NLPProcessor.instance
      @topic_modeling_processor = TopicModelProcessor.instance
    end

    def run
      logger.info "Starting Text Processing Workflow"
      Flowbots::UI.say(:ok, "Starting Text Processing Workflow")

      setup_workflow
      process_input
      run_nlp_analysis
      run_topic_modeling
      run_workflow
      display_results

      logger.info "Text Processing Workflow completed"
      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
    end

    private

    def setup_workflow
      logger.debug "Setting up workflow"
      @orchestrator.add_agent("advanced_analysis", "assistants/agileBloomMini.yml", author: "@b08x")

      workflow_graph = {
        NlpAnalysisTask: [:TopicModelingTask],
        TopicModelingTask: [:LlmAnalysisTask],
        LlmAnalysisTask: []
      }

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    def process_input
      logger.debug "Processing input file: #{@input_file_path}"
      text = File.read(@input_file_path)
      processed_text = @nlp_processor.process(text)
      store_processed_text(processed_text)
      logger.debug "Input processing completed"
    end

    def run_nlp_analysis
      logger.info "Running NLP Analysis"
      Flowbots::Task.get_task("nlp_analysis_task").execute
      logger.info "NLP Analysis completed"
    end

    def run_topic_modeling
      logger.info "Running Topic Modeling"
      Flowbots::Task.get_task("topic_modeling_task").execute
      logger.info "Topic Modeling completed"
    end

    def run_workflow
      logger.info "Running LLM Analysis workflow"
      @orchestrator.run_workflow
    end

    def display_results
      raw_text = File.read(@input_file_path)
      processed_text = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
      analysis_result = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))

      puts UIBox.comparison_box(raw_text, processed_text, title1: "Raw Text", title2: "Processed Text")
      puts UIBox.eval_result_box(analysis_result, title: "LLM Analysis Result")
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
