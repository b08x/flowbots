#!/usr/bin/env ruby
# frozen_string_literal: true

require "tomoto"
require "logger"

class TopicModelManager
  attr_reader :model

  def initialize(model_path, num_topics=20, term_weight: :one, min_cf: 3, min_df: 2, rm_top: 4, alpha: 0.1, eta: 0.01)
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.info "Initializing TopicModelManager"
    @model_path = model_path
    @model = nil
    @model_params = {
      k: num_topics,
      tw: term_weight,
      min_cf:,
      min_df:,
      rm_top:,
      alpha:,
      eta:,
      seed: 42
    }
    load_or_create_model
  end

  def load_or_create_model
    if File.exist?(@model_path)
      @logger.info "Loading existing model from #{@model_path}"
      @model = Tomoto::LDA.load(@model_path)
    else
      @logger.info "Creating new model"
      @model = Tomoto::LDA.new(**@model_params)
    end
    @logger.debug "Model loaded or created"
  end

  def train_model(documents, iterations=100)
    @logger.info "Training model"
    if documents.empty?
      @logger.error "No documents provided for training"
      raise "No documents provided for training"
    end

    documents.each do |doc|
      if doc.strip.empty?
        @logger.warn "Skipping empty document"
        next
      end
      @model.add_doc(doc)
    end

    if @model.num_words == 0
      @logger.error "No valid words found in the provided documents"
      raise "No valid words found in the provided documents"
    end

    @logger.debug "Documents added to model. Vocab size: #{@model.used_vocabs.length}, Total words: #{@model.num_words}"

    @model.burn_in = iterations
    @logger.debug "Burn-in set to #{iterations}"

    @model.train(iterations)
    @logger.info "Model training completed"

    save_model
  end

  def save_model
    @logger.info "Saving model to #{@model_path}"
    @model.save(@model_path)
    @logger.debug "Model saved"
  end

  def infer_topics(text, num_topics=5)
    @logger.info "Inferring topics for document"
    unless model_trained?
      @logger.error "Model is not trained. Cannot infer topics."
      raise "Model is not trained. Please train the model before inferring topics."
    end

    if text.strip.empty?
      @logger.error "Empty text provided for inference"
      raise "Empty text provided for inference"
    end

    @logger.debug "Inferring topics for text: #{text[0..100]}..." # Log only first 100 chars
    doc_vec = @model.infer(text.split)
    result = doc_vec.sort_by { |_, v| -v }.take(num_topics).to_h
    @logger.debug "Inferred topics: #{result}"
    result
  end

  def get_topics(top_n=10)
    @logger.info "Getting top #{top_n} topics"
    unless model_trained?
      @logger.error "Model is not trained. Cannot get topics."
      raise "Model is not trained. Please train the model before getting topics."
    end

    @model.k.times.map do |k|
      topic_words = @model.topic_words(k).take(top_n).to_h
      [k, topic_words]
    end.to_h
  end

  # Define model_trained? as a lambda outside the methods
  def model_trained?
    !@model.nil? && @model.num_words > 0
  end
end
