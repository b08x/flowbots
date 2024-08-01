#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TextSegmentTask < Jongleur::WorkerTask
    def perform
      text_segmenter = TextSegmentProcessor.instance
      segments = text_segmenter.process(sourcefile.preprocessed_content, { clean: true })

      segments.each do |segment_text|
        Segment.create(text: segment_text, sourcefile: sourcefile)
      end

      "Created #{segments.length} segments for file: #{sourcefile.path}"
    end
  end

  class Segment < Ohm::Model
    attribute :text
    reference :sourcefile, 'Flowbots::Sourcefile'
    collection :words, 'Flowbots::Word'
  end
end
