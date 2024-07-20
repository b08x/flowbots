#!/usr/bin/env ruby
# frozen_string_literal: true

require "lingua"
require "pragmatic_segmenter"

class Segment < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :text
  list :words, :Word

  reference :textfile, :TextFile
  reference :topic, :Topic
end

module Flowbots
  class TextSegmentProcessor < TextProcessor
    DEFAULT_OPTIONS = { language: "en", doc_type: "none", clean: false }

    attr_accessor :text, :options

    # def initialize(text, opts={})
    #   @text = text
    #   @options = DEFAULT_OPTIONS.merge(opts)
    #   logger.debug "TextSegmenter initialized with options: #{@options}"
    # end

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

    def segment_array
      logger.debug "Segmenting array of strings"
      @text.flat_map do |str|
        segment_string(str)
      end
    end

    def segment_string(str)
      logger.debug "Segmenting string of length: #{str.length}"
      ps = PragmaticSegmenter::Segmenter.new(text: str, **@options)
      result = ps.segment
      logger.debug "Segmentation result: #{result.length} segments"
      result
    end
  end
end
#
#
# module Segmentation
#   def segment(text)
#     raise NotImplementedError
#   end
# end
#
# class Segmenter
#   include Segmentation
#
#   def self.segment(text)
#     content = Lingua::EN::Readability.new(text)
#     content
#   end
# end
