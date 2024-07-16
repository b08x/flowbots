#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class NLPProcessor < TextProcessor
    def process(text)
      logger.info "Starting NLP processing"
      Flowbots::UI.say(:ok, "Starting NLP processing")

      segments = segment_text(text)
      logger.debug "Number of segments: #{segments.length}"

      result = process_segments(segments)
      logger.info "NLP processing completed"
      Flowbots::UI.say(:ok, "NLP processing completed")
      result
    end

    protected

    def load_model
      nlp_model = ENV['SPACY_MODEL']
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

    private

    def process_segments(segments)
      logger.debug "Processing #{segments.length} segments"
      segments.map { |segment| process_sentence(segment) }
    end

    def process_sentence(sentence)
      logger.debug "Processing sentence of length: #{sentence.length}"

      logger.debug "Starting NLP processing"
      doc = @nlp.read(sentence)
      logger.debug "NLP processing completed"

      relevant_tokens = doc.select do |token|
        token.pos_ != "" || token.tag_ != "" || token.dep_ != "" || token.ent_type_ != ""
      end
      logger.debug "Number of relevant tokens: #{relevant_tokens.length}"

      processed_tokens = relevant_tokens.map do |token|
        {
          text: token.text,
          pos: token.pos_,
          tag: token.tag_,
          dep: token.dep_,
          ent_type: token.ent_type_
        }
      end

      filtered_tokens = processed_tokens.select do |token|
        %w[NN JJ RB].include? token[:tag]
      end.map { |token| token[:text] }
      logger.debug "Number of filtered tokens: #{filtered_tokens.length}"

      result = filtered_tokens.join(" ")
      logger.debug "Processed sentence result length: #{result.length}"
      result
    end
  end
end
