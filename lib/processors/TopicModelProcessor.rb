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
      @model_path = TOPIC_MODEL_PATH
      @model = nil
      load_or_create_model
    end

    def load_or_create_model
      if File.exist?(@model_path)
        logger.info "Loading existing model from #{@model_path}"
        @model = Tomoto::LDA.load(@model_path)
      else
        logger.info "Creating new model"
        @model = Tomoto::LDA.new(**@model_params)
      end
      logger.debug "Model loaded or created"
    end

    def process(documents, num_topics=5)
      logger.info "Processing documents for topic modeling"
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

    def load_model
      if File.exist?(TOPIC_MODEL_PATH)
        logger.info "Loading existing model from #{TOPIC_MODEL_PATH}"
        begin
          @model = Tomoto::LDA.load(TOPIC_MODEL_PATH)
        rescue StandardError => e
          logger.error "Failed to load existing model: #{e.message}"
          logger.info "Will create new model when processing documents"
          @model = nil
        end
      else
        logger.info "No existing model found. Will create new model when processing documents"
        @model = nil
      end
      logger.debug "Model loading completed"
      Flowbots::UI.say(:ok, "Topic model loading completed")
    rescue StandardError => e
      logger.error "Error in load_model: #{e.message}"
      raise FlowbotError.new("Failed to load topic model", "MODEL_LOAD_ERROR", details: e.message)
    end

    def train_model(documents, iterations=100)
      logger.info "Training topic model"
      Flowbots::UI.say(:ok, "Training topic model")

      @model = Tomoto::LDA.new(**@model_params)

      valid_docs = 0
      total_words = 0

      documents.each do |doc|
        next if doc.strip.empty?

        words = doc.split
        next unless words.any?

        @model.add_doc(words)
        valid_docs += 1
        total_words += words.size
      end

      logger.debug "Valid documents added: #{valid_docs}"
      logger.debug "Total words added: #{total_words}"

      raise FlowbotError.new("No valid words found in the provided documents", "EMPTY_VOCABULARY") if total_words == 0

      @model.burn_in = iterations
      logger.debug "Burn-in set to #{iterations}"

      @model.train(0)

      Flowbots::UI.info "Num docs: #{@model.num_docs}, Vocab size: #{@model.used_vocabs.length}, Num words: #{@model.num_words}"

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

      save_model
      # store_all_topics
    end

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
        most_probable_topic:,
        topic_distribution: topic_dist.to_a, # Convert to array to ensure it can be serialized to JSON
        top_words:
      }
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
        raise FlowbotError.new("Failed to save topic model due to Tomoto gem error: #{e.message}", "TOMOTO_SAVE_ERROR")
      rescue FlowbotError => e
        logger.error e.message
        raise e
      rescue StandardError => e
        logger.error "Unexpected error while saving model: #{e.message}"
        raise FlowbotError.new("Unexpected error while saving topic model: #{e.message}", "SAVE_ERROR")
      end
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
