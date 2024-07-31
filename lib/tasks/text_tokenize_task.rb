#!/usr/bin/env ruby
# frozen_string_literal: true

class TextTokenizeTask < Jongleur::WorkerTask
  def execute
    segments = Sourcefile.latest.retrieve_segments
    text_tokenizer = Flowbots::TextTokenizeProcessor.instance
    segments.each do |segment|
      tokens = text_tokenizer.process(segment.text, { clean: true })
      segment.update(tokens: tokens)
      segment.save
    end
  end
end
