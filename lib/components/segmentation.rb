#!/usr/bin/env ruby
# frozen_string_literal: true

require "lingua"
require "pragmatic_segmenter"

class TextSegmenter
  DEFAULT_OPTIONS = { language: "en", doc_type: "none", clean: false }

  attr_accessor :text, :options

  def initialize(text, opts={})
    @text = text
    @options = DEFAULT_OPTIONS.merge(opts)
  end

  def execute
    ps = PragmaticSegmenter::Segmenter.new(text: @text, **@options)
    ps.segment
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
