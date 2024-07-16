#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TopicModelProcessor < TextProcessor
    private

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
  end
end
