#!/usr/bin/env ruby
# frozen_string_literal: true

require "tomoto"

TOPIC_MODEL_PATH = ENV.fetch("TOPIC_MODEL_PATH", nil)

class Topic < Ohm::Model
  attribute :name
  attribute :description
  attribute :vector
  collection :documents, :Document
  collection :chunks, :Chunk
  reference :collection, :Collection # Reference to the parent collection
  unique :name
  index :name
end

module Flowbots
  class TopicModelProcessor < TextProcessor
    def initialize
      super
      @model_params = {
        k: 20,
        tw: :one,
        min_cf: 3,
        min_df: 2,
        rm_top: 4,
        alpha: 0.1,
        eta: 0.01,
        seed: 42
      }
    end

    def process(documents, num_topics=5)
      logger.info "Inferring topics for documents"
      Flowbots::UI.say(:ok, "Inferring topics for documents")

      unless model_trained?
        raise FlowbotError.new(
          "Model is not trained. Please train the model before inferring topics.",
          "MODEL_NOT_TRAINED"
        )
      end
      raise FlowbotError.new("Empty document set provided for inference", "EMPTY_DOCUMENT_SET") if documents.empty?

      train_model(documents) unless model_trained?

      results = documents.map do |doc|
        infer_topics(doc) unless doc.empty?
      end

      store_topics(results)

      logger.debug "Inferred topics for #{results.size} documents"
      Flowbots::UI.say(:ok, "Topic inference completed")
      results
    end

    def train_model(documents, iterations=100)
      logger.info "Training topic model"
      Flowbots::UI.say(:ok, "Training topic model")

      if documents.empty?
        logger.error "No documents provided for training"
        raise FlowbotError.new("No documents provided for training", "EMPTY_DOCUMENT_SET")
      end

      documents.each do |doc|
        if doc.strip.empty?
          logger.warn "Skipping empty document"
          next
        end
        @model.add_doc(doc)
      end

      @model.burn_in = iterations
      logger.debug "Burn-in set to #{iterations}"

      @model.train(0)
      logger.info "Model training completed"
      Flowbots::UI.say(:ok, "Model training completed")

      save_model
      store_all_topics
    end

    def get_topics(top_n=10)
      logger.info "Getting top #{top_n} topics"
      raise FlowbotError.new("Model is not trained. Cannot get topics.", "MODEL_NOT_TRAINED") unless model_trained?

      topics = Topic.all.to_a.map do |topic|
        [topic.name.to_i, JSON.parse(topic.description)]
      end.to_h

      Flowbots::UI.say(:ok, "Retrieved top #{top_n} topics")
      topics
    end

    protected

    def load_model
      if File.exist?(TOPIC_MODEL_PATH)
        logger.info "Loading existing model from #{TOPIC_MODEL_PATH}"
        @model = Tomoto::LDA.load(TOPIC_MODEL_PATH)
      else
        logger.info "Creating new model"
        @model = Tomoto::LDA.new(**@model_params)
      end
      logger.debug "Model loaded or created"
      Flowbots::UI.say(:ok, "Topic model loaded or created")
    end

    private

    def model_trained?
      !@model.nil? && @model.num_words > 0
    end

    def infer_topics(text)
      doc = @model.make_doc(text.split)
      topic_dist, ll = @model.infer(doc)

      return {} if topic_dist.nil?

      most_probable_topic = topic_dist.each_with_index.max_by { |prob, _| prob }[1]
      top_words = @model.topic_words(most_probable_topic, top_n: 10)

      {
        most_probable_topic: most_probable_topic,
        topic_distribution: topic_dist,
        top_words: top_words
      }
    end

    def save_model
      logger.info "Saving model to #{@model_path}"
      @model.save(@model_path)
      logger.debug "Model saved"
      Flowbots::UI.say(:ok, "Topic model saved")
    end

    def store_topics(result)
      p result[1]
      exit
      topic = Topic.find(name: result[:most_probable_topic].to_s).first || Topic.create(name: result[:most_probable_topic].to_s)
      topic.update(
        description: result[:top_words].to_json,
        vector: result[:topic_distribution].to_json
      )
      logger.debug "Stored topic: #{topic.name}"
    end

    def store_all_topics
      @model.k.times do |k|
        top_words = @model.topic_words(k, top_n: 10).to_h
        topic = Topic.find(name: k.to_s).first || Topic.create(name: k.to_s)
        topic.update(
          description: top_words.to_json,
          vector: @model.topic_distribution(k).to_json
        )
        logger.debug "Stored topic: #{topic.name}"
      end
      logger.info "All topics stored in Ohm model"
      Flowbots::UI.say(:ok, "All topics stored in database")
    end
  end
end
