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
    end

    def load_or_create_model
      if File.exist?(@model_path)
        load_existing_model
      else
        create_new_model
      end
    end

    def train_model(documents, iterations=100)
      ensure_model_exists

      logger.info "Training topic model"
      Flowbots::UI.say(:ok, "Training topic model")

      documents.each do |doc|
        words = doc.split if doc.instance_of?(String)
        words = doc if doc.instance_of?(Array)
        @model.add_doc(words) if words.any?
      end

      @model.burn_in = iterations
      @model.train(0)

      ui.info "Removed Top Words" do
        ui.puts "#{@model.removed_top_words}"
        ui.puts "Training..."
        ui.framed do
          100.times do |i|
            @model.train(10)
            ui.puts "Iteration: #{i * 10}\tLog-likelihood: #{@model.ll_per_word}"
          end
        end
        ui.framed do
          ui.puts @model.summary
        end
      end

      ui.space

      if @model.num_words == 0
        raise FlowbotError.new("No valid words found in the provided documents", "EMPTY_VOCABULARY")
      end

      ui.info "Vocab" do
        ui.puts "Documents added to model. Vocab size: #{@model.used_vocabs.length}, Total words: #{@model.num_words}"
      end

      logger.info "Model training completed"
      Flowbots::UI.say(:ok, "Model training completed")

      save_model
    end

    def infer_topics(document)
      ensure_model_exists

      doc = @model.make_doc(document.split)
      topic_dist, _ = @model.infer(doc)

      return {} if topic_dist.nil?

      most_probable_topic = topic_dist.each_with_index.max_by { |prob, _| prob }[1]
      top_words = @model.topic_words(most_probable_topic, top_n: 10)

      {
        most_probable_topic: most_probable_topic,
        topic_distribution: topic_dist.to_a,
        top_words: top_words
      }
    end

    private

    def ensure_model_exists
      load_or_create_model if @model.nil?
    end

    def load_existing_model
      Flowbots::UI.info "Loading existing model from #{@model_path}"
      begin
        @model = Tomoto::LDA.load(@model_path)
        logger.debug "Model loading completed"
        Flowbots::UI.say(:ok, "Topic model loading completed")
      rescue StandardError => e
        logger.error "Failed to load existing model: #{e.message}"
        raise FlowbotError.new("Failed to load topic model", "MODEL_LOAD_ERROR", details: e.message)
      end
    end

    def create_new_model
      logger.info "Creating new model"
      begin
        @model = Tomoto::LDA.new(**@model_params)
        logger.debug "New Model created"
      rescue StandardError => e
        logger.error "Failed to create new model: #{e.message}"
        raise FlowbotError.new("Failed to create topic model", "MODEL_CREATE_ERROR", details: e.message)
      end
    end

    def save_model
      logger.info "Attempting to save model to #{TOPIC_MODEL_PATH}"
      Flowbots::UI.say(:ok, "Attempting to save topic model")

      begin
        # Check if the directory exists, create it if it doesn't
        dir = File.dirname(TOPIC_MODEL_PATH)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        # Check if we have write permissions
        unless File.writable?(dir)
          raise FlowbotError.new(
            "No write permission for directory: #{dir}",
            "PERMISSION_ERROR"
          )
        end

        # Check available disk space (example threshold: 100MB)
        available_space = `df -k #{dir} | awk '{print $4}' | tail -n 1`.to_i * 1024
        if available_space < 100_000_000 # 100MB in bytes
          raise FlowbotError.new(
            "Insufficient disk space. Only #{available_space / 1_000_000}MB available.",
            "DISK_SPACE_ERROR"
          )
        end

        # Attempt to save the model
        @model.save(TOPIC_MODEL_PATH)

        logger.info "Model successfully saved to #{TOPIC_MODEL_PATH}"
        Flowbots::UI.say(:ok, "Topic model saved successfully")
      rescue Tomoto::Error => e
        logger.error "Tomoto gem error while saving model: #{e.message}"
        raise FlowbotError.new(
          "Failed to save topic model due to Tomoto gem error: #{e.message}",
          "TOMOTO_SAVE_ERROR"
        )
      rescue FlowbotError => e
        logger.error e.message
        raise e
      rescue StandardError => e
        logger.error "Unexpected error while saving model: #{e.message}"
        raise FlowbotError.new("Unexpected error while saving topic model: #{e.message}", "SAVE_ERROR")
      end
    end
  end
end
