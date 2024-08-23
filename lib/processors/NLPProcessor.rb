#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class provides functionality for performing natural language processing (NLP) analysis on text.
  class NLPProcessor < TextProcessor
    # Initializes a new NLPProcessor instance.
    #
    # @return [void]
    def initialize
      # Loads the NLP model.
      load_model
    end

    # Processes the given segment using the loaded NLP model and returns a hash of processed tokens.
    #
    # @param segment [Segment] The Segment object to be processed.
    # @param options [Hash] A hash of options for the NLP processing.
    #
    # @return [Array] An array of processed tokens, or nil if the processing fails.
    def process(segment, options={})
      # Logs a message indicating the start of NLP processing for the current segment.
      logger.debug "Processing segment: #{segment.inspect}"
      logger.debug "Options: #{options.inspect}"

      # Creates a Spacy::Doc object from the segment's tokens.
      doc = create_doc(segment)

      # Initializes an empty array to store the processed tokens.
      result = []

      # Iterates through each token in the Spacy::Doc object and extracts relevant information.
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

      # Logs the processed result for debugging purposes.
      logger.debug "Processed result: #{result.inspect}"

      # Returns the array of processed tokens.
      result
    end

    private

    # Loads the NLP model from the specified environment variable.
    #
    # @return [void]
    def load_model
      # Retrieves the NLP model name from the environment variable.
      nlp_model = ENV.fetch("SPACY_MODEL", nil)

      # Logs a message indicating the start of NLP model loading.
      logger.debug "Loading NLP model: #{nlp_model}"

      # Attempts to load the NLP model using the Spacy::Language class.
      begin
        @nlp = Spacy::Language.new(nlp_model)

        # Logs a message indicating successful NLP model loading.
        logger.debug "NLP model loaded successfully"
        UI.say(:ok, "NLP model loaded successfully")
      rescue StandardError => e
        # Logs an error message if NLP model loading fails.
        logger.error "Error loading NLP model: #{e.message}"
        logger.error e.backtrace.join("\n")
        UI.say(:error, "Error loading NLP model: #{e.message}")
        raise
      end
    end

    # Creates a Spacy::Doc object from the given segment's tokens.
    #
    # @param segment [Segment] The Segment object.
    #
    # @return [Spacy::Doc] The Spacy::Doc object.
    def create_doc(segment)
      # Logs a message indicating the start of Spacy::Doc creation.
      logger.debug "Creating doc for segment: #{segment.text.length} characters"

      # Creates a Spacy::Doc object from the segment's tokens.
      doc = @nlp.read(segment.tokens.join(" "))

      # Logs a message indicating successful Spacy::Doc creation.
      logger.debug "Doc created successfully"

      # Returns the Spacy::Doc object.
      doc
    end
  end
end
