#!/usr/bin/env ruby
# frozen_string_literal: true

require "engtagger"

module Flowbots
  # This class provides functionality for tagging text using the EngTagger library.
  class TextTaggerProcessor
    # Includes the Singleton module to ensure only one instance of the class is created.
    include Singleton

    # Initializes a new TextTaggerProcessor instance.
    #
    # @return [void]
    def initialize
      # Initializes a logger object.
      logger = Logger.new(STDOUT)

      # Loads the EngTagger library.
      load_engtagger
    end

    # Processes the given text using the EngTagger library and returns a hash of tagged results.
    #
    # @param text [String] The text to be tagged.
    # @param options [Hash] A hash of options for the tagging process.
    #
    # @return [Hash] A hash containing the tagged results.
    def process(text, options={})
      # Logs a message indicating the start of text processing.
      logger.debug "Processing text with TextTaggerProcessor"
      logger.debug "Options: #{options.inspect}"

      # Creates a hash to store the tagged results.
      result = {}

      # Performs various tagging operations based on the provided options.
      result[:tagged_text] = @tgr.add_tags(text) if options[:tagged_text]
      result[:readable_text] = @tgr.get_readable(text) if options[:readable_text]
      result[:words] = @tgr.get_words(text) if options[:words]
      result[:nouns] = @tgr.get_nouns(text) if options[:nouns]
      result[:proper_nouns] = @tgr.get_proper_nouns(result[:tagged_text]) if options[:proper_nouns]
      result[:past_tense_verbs] = @tgr.get_past_tense_verbs(result[:tagged_text]) if options[:past_tense_verbs]
      result[:present_tense_verbs] = @tgr.get_present_verbs(result[:tagged_text]) if options[:present_tense_verbs]
      result[:base_present_verbs] = @tgr.get_base_present_verbs(result[:tagged_text]) if options[:base_present_verbs]
      result[:gerund_verbs] = @tgr.get_gerund_verbs(result[:tagged_text]) if options[:gerund_verbs]
      result[:adjectives] = @tgr.get_adjectives(result[:tagged_text]) if options[:adjectives]
      result[:noun_phrases] = @tgr.get_noun_phrases(result[:tagged_text]) if options[:noun_phrases]
      result[:pronoun_list] = @tgr.get_pronoun_list(result[:tagged_text]) if options[:pronoun_list]

      # Logs the processed results for debugging purposes.
      logger.debug "Processed result: #{result.inspect}"

      # Returns the hash of tagged results.
      result
    end

    # Extracts the main topics from the given text.
    #
    # @param text [String] The text to extract topics from.
    # @param limit [Integer] The maximum number of topics to extract.
    #
    # @return [Array] An array of main topics.
    def extract_main_topics(text, limit=5)
      # Gets the noun phrases from the text using EngTagger.
      noun_phrases = @tgr.get_noun_phrases(text)

      # If noun phrases are found, sorts them by count in descending order and returns the top `limit` phrases.
      return if noun_phrases.nil?

      sorted_phrases = noun_phrases.sort_by { |_, count| -count }
      sorted_phrases.first(limit).map { |phrase, _| phrase }
    end

    # Identifies the speech acts in the given text.
    #
    # @param text [String] The text to analyze.
    #
    # @return [Array] An array of speech act classifications for each sentence.
    def identify_speech_acts(text)
      # Splits the text into sentences and removes empty sentences.
      sentences = text.split(/[.!?]+/).map(&:strip).reject(&:empty?)

      # Iterates through each sentence and classifies its speech act.
      sentences.map do |sent|
        sent_tagged = @tgr.add_tags(sent)
        if sent_tagged.nil?
          # Logs a warning message if the sentence cannot be tagged.
          logger.warn "Failed to tag sentence: #{sent}"
          "unknown"
        elsif sent_tagged.include?("<uh>")
          "interjection"
        elsif sent.end_with?("?")
          "question"
        elsif sent_tagged.start_with?("<md>", "<vb>")
          "request"
        elsif sent.end_with?("!")
          "exclamation"
        else
          "statement"
        end
      end
    end

    # Analyzes the transitivity of sentences in the given text.
    #
    # @param text [String] The text to analyze.
    #
    # @return [Array] An array of hashes containing transitivity information for each sentence.
    def analyze_transitivity(text)
      # Splits the text into sentences and removes empty sentences.
      sentences = text.split(/[.!?]+/).map(&:strip).reject(&:empty?)

      # Iterates through each sentence and analyzes its transitivity.
      sentences.map do |sent|
        sent_tagged = @tgr.add_tags(sent)
        if sent_tagged.nil?
          # Logs a warning message if the sentence cannot be tagged.
          logger.warn "Failed to tag sentence for transitivity analysis: #{sent}"
          { sentence: sent, process: nil, actor: nil, goal: nil }
        else
          # Extracts the process, actor, and goal from the tagged sentence.
          process = sent_tagged.scan(%r{<vb[dgnpz]?>([^<]+)</vb[dgnpz]?>}).flatten.first
          actor = sent_tagged.scan(%r{<nn[ps]?>([^<]+)</nn[ps]?>}).flatten.first
          goal = sent_tagged.scan(%r{<nn[ps]?>([^<]+)</nn[ps]?>}).flatten[1]
          { sentence: sent, process:, actor:, goal: }
        end
      end
    end

    private

    # Loads the EngTagger library.
    #
    # @return [void]
    def load_engtagger
      # Logs a message indicating the start of EngTagger loading.
      logger.debug "Loading EngTagger"

      # Initializes a new EngTagger instance.
      @tgr = EngTagger.new

      # Logs a message indicating successful EngTagger loading.
      logger.debug "EngTagger loaded successfully"
      Flowbots::UI.say(:ok, "EngTagger loaded successfully")
    rescue StandardError => e
      # Logs an error message if EngTagger loading fails.
      logger.error "Error loading EngTagger: #{e.message}"
      logger.error e.backtrace.join("\n")
      Flowbots::UI.say(:error, "Error loading EngTagger: #{e.message}")
      raise
    end
  end
end
