#!/usr/bin/env ruby
# frozen_string_literal: true

class TextSegmentTask < Jongleur::WorkerTask
  def execute
    text_file = Textfile.latest
    text_segmenter = Flowbots::TextSegmentProcessor.instance
    if text_file.extension == ".pdf"
      segments = text_segmenter.process(text_file.content, { doc_type: "pdf", clean: true })
    else
      segments = text_segmenter.process(text_file.content, { clean: true })
    end
    text_file.add_segments(segments)
  end
end
