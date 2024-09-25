#!/usr/bin/env ruby
# frozen_string_literal: true

# Description: Analyze text using NLP, topic modeling, and summarization

module Flowbots
  class TextAnalysisWorkflow
    include Logging

    def initialize
      @orchestrator = WorkflowOrchestrator.new
      setup_agents
      define_workflow
    end

    def run
      logger.info "Starting Text Analysis Workflow"
      Flowbots::UI.say(:ok, "Starting Text Analysis Workflow")

      input_file_path = prompt_for_file
      user_query = prompt_for_query

      input_text = process_input_file(input_file_path)
      result = execute_workflow(input_text, user_query)

      display_results(result)

      logger.info "Text Analysis Workflow completed"
      Flowbots::UI.say(:ok, "Text Analysis Workflow completed")
    end

    private

    def setup_agents
      @orchestrator.add_agent('nlp_expert', 'nlp_techniques_and_tools.yml')
      @orchestrator.add_agent('topic_modeler', 'topic_modeling_expert.yml')
      @orchestrator.add_agent('summarizer', 'text_summarization_expert.yml')
    end

    def define_workflow
      workflow_graph = {
        NlpAnalysisTask: [:TopicModelingTask],
        TopicModelingTask: [:SummaryTask],
        SummaryTask: []
      }
      @orchestrator.define_workflow(workflow_graph)
    end

    def prompt_for_file
      Flowbots::UI.say(:ok, "Please select an input file:")
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)
      unless File.exist?(file_path)
        raise FlowbotError.new("File not found", "FILENOTFOUND")
      end
      file_path
    end

    def prompt_for_query
      Flowbots::UI.say(:ok, "Please enter your query about the text:")
      gets.chomp
    end

    def process_input_file(file_path)
      Flowbots::UI.say(:ok, "Processing input file: #{file_path}")
      File.read(file_path)
    end

    def execute_workflow(input_text, user_query)
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("input_text", input_text)
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("user_query", user_query)

      @orchestrator.run_workflow

      {
        nlp_result: JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("nlp_result")),
        topic_result: JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("topic_result")),
        summary: JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("summary_result"))
      }
    end

    def display_results(result)
      Flowbots::UI.say(:ok, "Analysis Results:")
      puts UIBox.info_box("NLP Analysis", result[:nlp_result])
      puts UIBox.info_box("Topic Modeling", result[:topic_result])
      puts UIBox.eval_result_box(result[:summary], title: "Summary")
    end
  end

  class NlpAnalysisTask < Jongleur::WorkerTask
    def execute
      input_text = Jongleur::WorkerTask.class_variable_get(:@@redis).get("input_text")
      nlp_processor = Flowbots::NLPProcessor.instance
      result = nlp_processor.process(input_text)
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("nlp_result", result.to_json)
    end
  end

  class TopicModelingTask < Jongleur::WorkerTask
    def execute
      input_text = Jongleur::WorkerTask.class_variable_get(:@@redis).get("input_text")
      topic_processor = Flowbots::TopicModelProcessor.instance
      result = topic_processor.process([input_text])
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("topic_result", result.to_json)
    end
  end

  class SummaryTask < Jongleur::WorkerTask
    def execute
      nlp_result = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("nlp_result"))
      topic_result = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("topic_result"))
      user_query = Jongleur::WorkerTask.class_variable_get(:@@redis).get("user_query")

      agent = WorkflowAgent.new("summarizer", File.join(CARTRIDGE_DIR, "text_summarization_expert.yml"))
      input = "NLP Analysis: #{nlp_result}\n\nTopic Modeling: #{topic_result}\n\nUser Query: #{user_query}"
      summary = agent.process(input)

      Jongleur::WorkerTask.class_variable_get(:@@redis).set("summary_result", summary.to_json)
    end
  end
end
