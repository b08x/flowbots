#!/usr/bin/env ruby
# frozen_string_literal: true

require "pragmatic_tokenizer"

module Flowbots
  # This class provides functionality for tokenizing text.
  class TextTokenizeProcessor < TextProcessor
    # Default options for the tokenizer.
    DEFAULT_OPTIONS = {
      remove_stop_words: true,
      stop_words: ["the"],
      punctuation: :semi,
      numbers: :all,
      minimum_length: 0,
      remove_emoji: true,
      remove_emails: true,
      remove_urls: true,
      remove_domains: true,
      expand_contractions: true,
      clean: true,
      mentions: :remove,
      hashtags: :keep_original,
      classic_filter: true,
      downcase: true,
      long_word_split: 20
    }

    # The text to be tokenized.
    attr_accessor :text

    # The options for the tokenizer.
    attr_accessor :options

    # Initializes a new TextTokenizeProcessor instance.
    #
    # @return [void]
    def initialize
      super
    end

    # Tokenizes the given text using the specified options.
    #
    # @param text [String, Array] The text to be tokenized.
    # @param opts [Hash] A hash of options for the tokenizer.
    #
    # @return [Array] An array of tokens.
    def process(text, opts={})
      @text = text
      @options = DEFAULT_OPTIONS.merge(opts)
      logger.debug "TextTokenize initialized with options: #{@options}"

      logger.debug "Input text type: #{@text.class}"

      if @text.instance_of?(Array)
        tokenize_array
      else
        tokenize_string(@text)
      end
    end

    private

    # Tokenizes an array of strings.
    #
    # @return [Array] An array of tokens.
    def tokenize_array
      logger.debug "Segmenting array of strings"
      @text.flat_map do |str|
        tokenize_string(str)
      end
    end

    # Tokenizes a single string.
    #
    # @param str [String] The string to be tokenized.
    #
    # @return [Array] An array of tokens.
    def tokenize_string(str)
      logger.debug "Tokenizing string: #{str}"
      tokenizer = PragmaticTokenizer::Tokenizer.new(**@options)
      result = tokenizer.tokenize(str)
      logger.debug "Tokenization result: #{result}"
      result
    end
  end
end
