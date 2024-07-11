#!/usr/bin/env ruby
# frozen_string_literal: true

require "jongleur"
require "redis"
require "json"
require_relative "text_processor"
require_relative "topic_model_manager"

class WorkflowOrchestrator
  def initialize
    @redis = Redis.new(host: "localhost", port: 6379, db: 15)
    @text_processor = TextProcessor.new
    @topic_model_manager = TopicModelManager.new(
      File.join(
        ENV.fetch("HOME", nil),
        "Workspace",
        "knowlecule",
        "models",
        "topic_model.lda.bin"
      )
    )
  end

  def process_document(text, is_audio_transcription=false)
    setup_workflow
    store_input(text, is_audio_transcription)
    run_workflow
  end

  private

  def setup_workflow
    Jongleur::API.add_task_graph(
      {
        TextProcessingTask: [:TopicModelingTask],
        TopicModelingTask:    [:AdvancedAnalysisTask],
        AdvancedAnalysisTask: []
      }
    )
  end

  def store_input(text, is_audio_transcription)
    @redis.set("input_text", text)
    @redis.set("is_audio_transcription", is_audio_transcription.to_s)
  end

  def run_workflow
    Jongleur::API.run do |on|
      on.completed do |task_matrix|
        puts "Workflow completed"
        puts task_matrix

        if @redis.get("model_trained") == "true"
          puts "Topic model has been trained and approved."
          puts "Topics:"
          puts JSON.parse(@redis.get("topics"))
          puts "Chunked topics:"
          puts JSON.parse(@redis.get("chunked_topics"))
        else
          puts "Topic model training was not completed or approved."
        end

        puts "Analysis Result:"
        puts JSON.parse(@redis.get("analysis_result"))
      end
    end
  end
end

class TextProcessingTask < Jongleur::WorkerTask
  def execute
    text = @@redis.get("input_text")
    is_audio_transcription = @@redis.get("is_audio_transcription") == "true"

    processor = TextProcessor.new
    processed_text = processor.process(text, is_audio_transcription)

    @@redis.set("processed_text", processed_text.to_json)
  end
end

class TopicModelingTask < Jongleur::WorkerTask
  def execute
    processed_text = JSON.parse(@@redis.get("processed_text"))

    model_manager = TopicModelManager.new(
      File.join(
        ENV.fetch("HOME", nil),
        "Workspace",
        "knowlecule",
        "models",
        "topic_model.lda.bin"
      )
    )
    modeler = model_manager.load_or_create_model

    if modeler.num_docs == 0
      model_manager.train_model(processed_text.join(" "))
      topics = model_manager.get_topics(10)

      if HumanReviewInterface.review_topics(topics)
        model_manager.save_model
        @@redis.set("model_trained", "true")
      else
        puts "Topics were not approved. Please adjust the model and try again."
        return
      end
    else
      topics = model_manager.infer_topics(processed_text.join(" "), 5)
    end

    @@redis.set("topics", topics.to_json)

    chunked_topics = assign_topics_to_chunks(processed_text, topics)
    @@redis.set("chunked_topics", chunked_topics.to_json)
  end

  private

  def assign_topics_to_chunks(sentences, topics)
    sentences.map do |sentence|
      {
        text: sentence,
        topics: topics.map { |topic, score| { topic:, score: } }
      }
    end
  end
end

class AdvancedAnalysisTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("advanced_analysis", "advanced_analysis_cartridge.yml")
    agent.load_state

    processed_text = JSON.parse(@@redis.get("processed_text"))
    topics = JSON.parse(@@redis.get("topics"))
    chunked_topics = JSON.parse(@@redis.get("chunked_topics"))

    analysis_result = agent.process("Analyze the following text and topics: #{processed_text.join(' ')}. Topics: #{topics}. Chunked topics: #{chunked_topics}")

    agent.save_state
    @@redis.set("analysis_result", analysis_result.to_json)
  end
end
