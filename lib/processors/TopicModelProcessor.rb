#!/usr/bin/env ruby
# frozen_string_literal: true

require "tomoto"

TOPIC_MODEL_PATH = ENV.fetch("TOPIC_MODEL_PATH", nil)

module Flowbots
  class TopicModelProcessor < TextProcessor
    attr_accessor :model_path, :model, :model_params

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
      @model_path = TOPIC_MODEL_PATH
      @model = nil
      load_model(@model_params)
    end

    def process(documents, num_topics=5)
      logger.info "Processing text for topic modeling"
      Flowbots::UI.say(:ok, "Processing documents for topic modeling")

      raise FlowbotError.new("Empty document set provided", "EMPTY_DOCUMENT_SET") if documents.empty?

      ensure_model_exists(documents)

      load_model(@model_params)

      results = documents.map do |doc|
        infer_topics(doc) unless doc.empty?
      end.compact # Remove any nil results

      Flowbots::UI.info "Inferred topics for #{results.size} documents"
      Flowbots::UI.info "Sample result: #{results.first.inspect}" if results.any?

      # store_topics(results)

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
  end
end
