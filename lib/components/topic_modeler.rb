#!/usr/bin/env ruby

require "tomoto"
require "logger"

class TopicModeler
  def initialize(num_topics, term_weight: :one, min_cf: 3, min_df: 2, rm_top: 4, alpha: 0.1, eta: 0.01)
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.info "Initializing TopicModeler"
    @model = Tomoto::LDA.new(
      k: 20,
      tw: term_weight,
      min_cf:,
      min_df:,
      rm_top:,
      alpha:,
      eta:,
      seed: 42
    )
    @logger.debug "LDA model created with parameters: k=20, tw=#{term_weight}, min_cf=#{min_cf}, min_df=#{min_df}, rm_top=#{rm_top}, alpha=#{alpha}, eta=#{eta}"
    @save_path = File.join(ENV.fetch("HOME", nil), "Workspace", "knowlecule", "models", "test.lda.bin")
    @logger.debug "Save path set to: #{@save_path}"
    load if File.exist?(@save_path)
  end

  def add_document(doc)
    @logger.info "Adding document to model"
    @logger.debug "Document: #{doc}"
    doc.split("|").each do |s|
      @logger.debug "Adding segment: #{s.strip}"
      @model.add_doc(s.strip)
    end
    @logger.info "Document added to model"
  end

  def train(iterations=100)
    @logger.info "Starting model training"
    @model.burn_in = iterations
    @logger.debug "Burn-in set to #{iterations}"
    @model.train(0)
    @logger.debug "Initial training completed"
    @logger.info "Num docs: #{@model.num_docs}, Vocab size: #{@model.used_vocabs.length}, Num words: #{@model.num_words}"
    @logger.info "Removed top words: #{@model.removed_top_words}"
    @logger.info "Training..."
    100.times do |i|
      @model.train(10)
      @logger.debug "Iteration: #{i * 10}\tLog-likelihood: #{@model.ll_per_word}"
    end
    @logger.info "Training completed"
    @logger.debug @model.summary
  end

  def get_topics(top_n=10)
    @logger.info "Getting topics"
    @model.k.times do |k|
      @logger.debug "Topic ##{k}"
      @model.topic_words(k).each do |word, prob|
        @logger.debug "\t\t#{word}\t#{prob}"
      end
    end
    @logger.info "Topics retrieved"
  end

  def infer_topics(doc, top_n=5)
    @logger.info "Inferring topics for document"
    @logger.debug "Document: #{doc}"
    doc_vec = @model.infer(doc.split)
    result = doc_vec.sort_by { |_, v| -v }.take(top_n).to_h
    @logger.debug "Inferred topics: #{result}"
    @logger.info "Topic inference completed"
    result
  end

  def save
    @logger.info "Saving model"
    @model.save(@save_path)
    @logger.info "Model saved to #{@save_path}"
  end

  def load
    @logger.info "Loading model"
    @model = Tomoto::LDA.load(@save_path)
    @logger.info "Model loaded from #{@save_path}"
  end
end
