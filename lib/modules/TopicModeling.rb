#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/modules/topic_modeling.rb

module TopicModeling
  class TopicModelingTask < Jongleur::WorkerTask
    def initialize(model_path:, redis_client: nil)
      @model_path = model_path
      @redis_client = redis_client
      # logger = Logger.new(STDOUT)
      # logger.level = Logger::INFO
    end

    def execute
      logger.info "Starting TopicModelingTask"

      begin
        raw_text = get_processed_text
        logger.debug "Retrieved processed text from Redis (length): #{raw_text.length}"

        processed_text = JSON.parse(raw_text)
        logger.debug "Parsed processed text (length): #{processed_text.length}"

        topic_modeler = TopicModelManager.new(@model_path)
        logger.debug "Created TopicModelManager instance"

        # Train the model if it's not already trained
        unless topic_modeler.model_trained?
          logger.info "Model is not trained. Training now..."
          begin
            topic_modeler.train_model(processed_text)
            logger.info "Model training completed"
          rescue StandardError => e
            logger.error "Error during model training: #{e.message}"
            raise
          end
        else
          logger.info "Model is already trained"
        end

        logger.debug "Inferring topics"
        begin
          topics_info = topic_modeler.infer_topics(processed_text.join(" "), 5)
          logger.info "Most probable topic: #{topics_info[:most_probable_topic]}"
          logger.info "Top words: #{topics_info[:top_words].map { |word, prob| word }.join(', ')}"
          logger.debug "Full topic distribution: #{topics_info[:topic_distribution]}"

          store_topics_info(topics_info)
          logger.debug "Stored topics info in Redis"
        rescue StandardError => e
          logger.error "Error during topic inference: #{e.message}"
          raise
        end

        logger.info "TopicModelingTask completed"
      rescue StandardError => e
        logger.error "Error in TopicModelingTask: #{e.message}"
        logger.error e.backtrace.join("\n")
        raise
      end
    end

    private

    def get_processed_text
      redis = @redis_client || Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.get("processed_text")
    end

    def store_topics_info(topics_info)
      redis = @redis_client || Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.set("topics_info", topics_info.to_json)
    end
  end
end
