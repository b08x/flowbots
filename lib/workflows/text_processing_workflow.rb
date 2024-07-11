#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../components/TextProcessor"
require_relative "../components/TopicModelManager"

class TextProcessingWorkflow
  def initialize
    @orchestrator = WorkflowOrchestrator.new
    @text_processor = TextProcessor.new
    @topic_modeler = TopicModelManager.new(
      File.join(
        ENV.fetch("HOME", nil),
        "Workspace",
        "flowbots",
        "models",
        "topic_model.lda.bin"
      )
    )
  end

  def run
    setup_workflow
    process_input
    run_workflow
  end

  private

  def setup_workflow
    @orchestrator.add_agent("advanced_analysis", "agents/advanced_analysis_cartridge.yml", author: "@b08x")

    workflow_graph = {
      TextProcessingTask: [:TopicModelingTask],
      TopicModelingTask: [:AdvancedAnalysisTask],
      AdvancedAnalysisTask: []
    }

    @orchestrator.define_workflow(workflow_graph)
  end

  def process_input
    prompt = TTY::Prompt.new
    input_text = prompt.multiline("Enter the text to process:")

    if input_text.class == Array
      input_text = input_text.join(" ")
    end

    processed_text = @text_processor.process(input_text)

    Jongleur::WorkerTask.class_variable_get(:@@redis).set("processed_text", processed_text.to_json)
  end

  def run_workflow
    @orchestrator.run_workflow
  end
end

class TextProcessingTask < Jongleur::WorkerTask
  def execute
    text = JSON.parse(@@redis.get("processed_text"))
    processor = TextProcessor.new
    processed_text = processor.process(text)
    puts "Processed text: #{processed_text}"
    @@redis.set("segmented_text", processed_text.to_json)
  end
end

class TopicModelingTask < Jongleur::WorkerTask
  def execute
    segmented_text = JSON.parse(@@redis.get("segmented_text"))
    topic_modeler = TopicModelManager.new(
      File.join(
        ENV.fetch("HOME", nil),
        "Workspace",
        "flowbots",
        "models",
        "topic_model.lda.bin"
      )
    )
    modeler = topic_modeler.load_or_create_model

    topics = topic_modeler.infer_topics(segmented_text.join(" "), 5)
    puts "Inferred topics: #{topics}"
    @@redis.set("topics", topics.to_json)
  end
end

class AdvancedAnalysisTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("advanced_analysis", "agents/advanced_analysis_cartridge.yml")
    agent.load_state

    processed_text = JSON.parse(@@redis.get("segmented_text"))
    topics = JSON.parse(@@redis.get("topics"))

    analysis_result = agent.process("Analyze the following text and topics: #{processed_text.join(' ')}. Topics: #{topics}")

    agent.save_state
    @@redis.set("analysis_result", analysis_result.to_json)

    puts "Analysis Result:"
    puts analysis_result
  end
end
