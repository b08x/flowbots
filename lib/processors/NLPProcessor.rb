#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class NLPProcessor < TextProcessor
    def initialize
      load_model
    end

    def process(segment)
      result = process_sentence(segment)
      result
    end

    private

    def load_model
      nlp_model = ENV.fetch("SPACY_MODEL", nil)
      logger.debug "Loading NLP model: #{nlp_model}"
      begin
        @nlp = Spacy::Language.new(nlp_model)
        logger.debug "NLP model loaded successfully"
        Flowbots::UI.say(:ok, "NLP model loaded successfully")
      rescue StandardError => e
        logger.error "Error loading NLP model: #{e.message}"
        logger.error e.backtrace.join("\n")
        Flowbots::UI.say(:error, "Error loading NLP model: #{e.message}")
        raise
      end
    end

    def process_sentence(segment)
      logger.debug "Processing segment of length: #{segment.text.length}"

      logger.debug "Starting NLP processing"
      doc = @nlp.read(segment.tokens.join(" "))
      logger.debug "NLP processing completed"

      processed_tokens = doc.map do |token|
        {
          word: token.text,
          pos: token.pos_,
          tag: token.tag_,
          dep: token.dep_,
          ner: token.ent_type_
        }
      end

    end
  end
end
