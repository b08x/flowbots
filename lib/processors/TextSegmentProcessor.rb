#!/usr/bin/env ruby
# frozen_string_literal: true

require "lingua"
require "pragmatic_segmenter"

module Flowbots
  # This class provides functionality for segmenting text into smaller units.
  class TextSegmentProcessor < TextProcessor
    # Default options for the segmenter.
    DEFAULT_OPTIONS = { language: "en", doc_type: "none", clean: false }

    # The text to be segmented.
    attr_accessor :text

    # The options for the segmenter.
    attr_accessor :options

    # Initializes a new TextSegmentProcessor instance.
    #
    # @return [void]
    def initialize
      super
    end

    # Segments the given text using the specified options.
    #
    # @param text [String, Array] The text to be segmented.
    # @param opts [Hash] A hash of options for the segmenter.
    #
    # @return [Array] An array of segments.
    def process(text, opts={})
      @text = text
      @options = DEFAULT_OPTIONS.merge(opts)
      logger.debug "TextSegmenter initialized with options: #{@options}"

      logger.info "Starting text segmentation"
      logger.debug "Input text type: #{@text.class}"

      if @text.instance_of?(Array)
        segment_array
      else
        segment_string(@text)
      end
    end

    private

    # Segments an array of text.
    #
    # @return [Array] An array of segments.
    def segment_array
      logger.debug "Segmenting array of strings"
      @text.flat_map do |txt|
        segment_string(txt)
      end
    end

    # Segments a single string.
    #
    # @param txt [String] The text to be segmented.
    #
    # @return [Array] An array of segments.
    def segment_string(txt)
      logger.debug "Segmenting text of length: #{txt.length}"
      ps = PragmaticSegmenter::Segmenter.new(text: txt, **@options)
      segments = ps.segment
      logger.debug "Segmentation result: #{segments.length} segments"
      segments
    end
  end
end
