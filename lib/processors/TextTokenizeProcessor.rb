#!/usr/bin/env ruby
# frozen_string_literal: true

require "pragmatic_tokenizer"

module Flowbots
  class TextTokenizeProcessor < TextProcessor
    DEFAULT_OPTIONS = {
      remove_stop_words: true,
      stop_words: ['the'],
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

    attr_accessor :text, :options

    def process(text, opts={})
      @text = text
      @options = DEFAULT_OPTIONS.merge(opts)
      logger.debug "TextTokenize initialized with options: #{@options}"

      logger.info "Starting text tokenizer"
      logger.debug "Input text type: #{@text.class}"

      if @text.instance_of?(Array)
        tokenize_array
      else
        tokenize_string(@text)
      end
    end

    private

    def tokenize_array
      logger.debug "Segmenting array of strings"
      @text.flat_map do |str|
        tokenize_string(str)
      end
    end

    def tokenize_string(str)
      logger.debug "Tokenizing string: #{str}"
      tokenizer = PragmaticTokenizer::Tokenizer.new(**@options)
      result = tokenizer.tokenize(str)
      logger.debug "Tokenization result: #{result}"
      result
    end
  end
end
