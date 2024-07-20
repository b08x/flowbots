#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class NLPProcessor < TextProcessor
    def initialize
      load_model
    end

    def process(segment, options = {})
      doc = create_doc(segment)
      result = {}
      result[:pos] = process_pos(doc) if options[:pos]
      result[:dep] = process_dep(doc) if options[:dep]
      result[:ner] = process_ner(doc) if options[:ner]
      result[:tag] = process_tag(doc) if options[:tag]
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
      logger.debug "Processing segment of length: #{segment.text.length}"
      logger.debug "Starting NLP processing"
      doc = @nlp.read(segment.tokens.join(" "))
      logger.debug "NLP processing completed"
      doc
    end

    def process_pos(doc)
      doc.map { |token| [token.text, token.pos_] }.to_h
    end

    def process_dep(doc)
      doc.map { |token| [token.text, token.dep_] }.to_h
    end

    def process_ner(doc)
      doc.map { |token| [token.text, token.ent_type_] }.to_h
    end

    def process_tag(doc)
      doc.map { |token| [token.text, token.tag_] }.to_h
    end
  end
end
