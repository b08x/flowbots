#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/modules/topic_modeling.rb

class TopicModelingLogger
  def initialize(logger)
    @logger = logger
  end

  def info(message)
    @logger.info(message)
  end

  def debug(message)
    @logger.debug(message)
  end

  def error(message)
    @logger.error(message)
  end
end

module TopicModeling
  class TopicModelingTask < Jongleur::WorkerTask
    attr_reader :model_path, :redis_client, :logger

    def initialize(model_path:, redis_client: nil, logger: Logger.new(STDOUT))
      @model_path = model_path
      @redis_client = redis_client
      @logger = TopicModelingLogger.new(logger)
    end

    def execute
      @logger.info "Starting TopicModelingTask"

      begin
        raw_text = get_processed_text
        @logger.debug "Retrieved processed text from Redis (length): #{raw_text.length}"

        processed_text = JSON.parse(raw_text)
        @logger.debug "Parsed processed text (length): #{processed_text.length}"

        topic_modeler = TopicModelManager.new(@model_path)
        @logger.debug "Created TopicModelManager instance"

        train_model(processed_text) if !topic_modeler.model_trained?

        @logger.debug "Inferring topics"
        topics_info = infer_topics(processed_text)
        store_topics_info(topics_info)

        @logger.info "TopicModelingTask completed"
      rescue StandardError => e
        @logger.error "Error in TopicModelingTask: #{e.message}"
        @logger.error e.backtrace.join("\n")
        raise
      end
    end

    private

    def get_processed_text
      redis = @redis_client || Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.get("processed_text")
    end

    def train_model(processed_text)
      @logger.info "Model is not trained. Training now..."
      begin
        topic_modeler = TopicModelManager.new(@model_path)
        topic_modeler.train_model(processed_text)
        @logger.info "Model training completed"
      rescue StandardError => e
        @logger.error "Error during model training: #{e.message}"
        raise
      end
    end

    def infer_topics(processed_text)
      topic_modeler = TopicModelManager.new(@model_path)
      @logger.debug "Inferring topics"
      begin
        topics_info = topic_modeler.infer_topics(processed_text.join(" "), 5)
        @logger.info "Most probable topic: #{topics_info[:most_probable_topic]}"
        @logger.info "Top words: #{topics_info[:top_words].map { |word, prob| word }.join(', ')}"
        @logger.debug "Full topic distribution: #{topics_info[:topic_distribution]}"
      rescue StandardError => e
        @logger.error "Error during topic inference: #{e.message}"
        raise
      end
      topics_info
    end

    def store_topics_info(topics_info)
      redis = @redis_client || Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.set("topics_info", topics_info.to_json)
      @logger.debug "Stored topics info in Redis"
    end
  end
end
