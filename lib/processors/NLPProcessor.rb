#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class NLPProcessor
    def initialize
      load_model
    end

    def process(segment, options = {})
      logger.debug "Processing segment: #{segment.inspect}"
      logger.debug "Options: #{options.inspect}"

      doc = create_doc(segment)
      result = []

      doc.each do |token|
        token_data = {
          word: token.text,
          pos: token.pos_,
          tag: token.tag_,
          dep: token.dep_,
          ner: token.ent_type_
        }
        result << token_data
      end

      logger.debug "Processed result: #{result.inspect}"
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

    def create_doc(segment)
      logger.debug "Creating doc for segment: #{segment.text.length} characters"
      doc = @nlp.read(segment.tokens.join(" "))
      logger.debug "Doc created successfully"
      doc
    end
  end
end
