#!/usr/bin/env ruby
# frozen_string_literal: true

require "tomoto"

TOPIC_MODEL_PATH = ENV.fetch("TOPIC_MODEL_PATH", nil)

class Topic < Ohm::Model
  attribute :name
  attribute :description
  attribute :vector
  collection :textfiles, :TextFile
  collection :segments, :Segment
  # reference :collection, :Collection # Reference to the parent collection
  unique :name
  index :name
end

module Flowbots
  class TopicModelProcessor < TextProcessor
    attr_accessor :model_path, :model, :model_params

    def initialize
      super
      model_params = {
        k: 20,
        tw: :one,
        min_cf: 3,
        min_df: 2,
        rm_top: 4,
        alpha: 0.1,
        eta: 0.01,
        seed: 42
      }
      @model_path = TOPIC_MODEL_PATH
      @model = nil
      load_model(model_params)
    end

    def process(documents, num_topics=5)
      logger.info "Processing text for topic modeling"
      Flowbots::UI.say(:ok, "Processing documents for topic modeling")

      raise FlowbotError.new("Empty document set provided", "EMPTY_DOCUMENT_SET") if documents.empty?

      ensure_model_exists(documents)

      results = documents.map do |doc|
        infer_topics(doc) unless doc.empty?
      end.compact # Remove any nil results

      logger.debug "Inferred topics for #{results.size} documents"
      logger.debug "Sample result: #{results.first.inspect}" if results.any?

      store_topics(results)

      Flowbots::UI.say(:ok, "Topic inference completed")
      results
    end

    def load_model(model_params)
      @model_params = model_params
      if File.exist?(TOPIC_MODEL_PATH)
        Flowbots::UI.info "Loading existing model from #{TOPIC_MODEL_PATH}"
        begin
          @model = Tomoto::LDA.load(TOPIC_MODEL_PATH)
        rescue StandardError => e
          logger.error "Failed to load existing model: #{e.message}"
          raise FlowbotError.new("Failed to load topic model", "MODEL_LOAD_ERROR", details: e.message)
        end
        logger.debug "Model loading completed"
        Flowbots::UI.say(:ok, "Topic model loading completed")
      else
        logger.info "Creating new model"
        begin
          @model = Tomoto::LDA.new(**@model_params)
        rescue StandardError => e
          logger.error "Failed to load existing model: #{e.message}"
          raise FlowbotError.new("Failed to create topic model", "MODEL_LOAD_ERROR", details: e.message)
        end
        logger.debug "New Model created"
      end
    end

    private

    def ensure_model_exists(documents)
      if @model.nil?
        logger.info "Model doesn't exist. Training new model."
        train_model(documents)
      elsif !model_trained?
        logger.info "Model exists but is not trained. Training model."
        train_model(documents)
      end
    end

    def model_trained?
      !@model.nil? && @model.num_words > 0
    end

    def store_topics(results)
      logger.debug "Entering store_topics method"
      logger.debug "Results: #{results.inspect}"

      results.each_with_index do |result, index|
        logger.debug "Processing result #{index}: #{result.inspect}"

        if result.nil? || !result.is_a?(Hash)
          logger.warn "Skipping nil or non-Hash result at index #{index}"
          next
        end

        most_probable_topic = result[:most_probable_topic]

        unless most_probable_topic.is_a?(Integer)
          logger.warn "Invalid most_probable_topic (#{most_probable_topic.inspect}) at index #{index}. Converting to string."
          most_probable_topic = most_probable_topic.to_s
        end

        topic = Topic.find(name: most_probable_topic.to_s).first || Topic.create(name: most_probable_topic.to_s)

        topic.update(
          description: result[:top_words].to_json,
          vector: result[:topic_distribution].to_json
        )

        logger.debug "Stored topic: #{topic.name}"
      rescue StandardError => e
        logger.error "Error processing result #{index}: #{e.message}"
        logger.error e.backtrace.join("\n")
      end

      logger.info "All topics stored in Ohm model"
      Flowbots::UI.say(:ok, "All topics stored in database")
    rescue StandardError => e
      logger.error "Error in store_topics: #{e.message}"
      logger.error e.backtrace.join("\n")
      Flowbots::UI.say(:error, "Failed to store topics")
      raise FlowbotError.new("Failed to store topics", "TOPIC_STORAGE_ERROR", details: e.message)
    end

    def store_all_topics
      @model.k.times do |k|
        top_words = @model.topic_words(k, top_n: 10).to_h
        topic = Topic.find(name: k.to_s).first || Topic.create(name: k.to_s)

        topic_dist = @model.topic_dist(k)

        topic.update(
          description: top_words.to_json,
          vector: topic_dist.to_json
        )
        logger.debug "Stored topic: #{topic.name}"
      rescue StandardError => e
        logger.error "Error storing topic #{k}: #{e.message}"
        Flowbots::UI.say(:error, "Failed to store topic #{k}")
      end
      logger.info "All topics stored in Ohm model"
      Flowbots::UI.say(:ok, "All topics stored in database")
    rescue StandardError => e
      logger.error "Error in store_all_topics: #{e.message}"
      Flowbots::UI.say(:error, "Failed to store all topics")
      raise FlowbotError.new("Failed to store all topics", "TOPIC_STORAGE_ERROR", details: e.message)
    end
  end
end
