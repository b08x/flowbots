#!/usr/bin/env ruby
# frozen_string_literal: true

class TextSegmentTask < Jongleur::WorkerTask
  def execute
    Textfile.current_batch.each do |text_file|
      text_segmenter = Flowbots::TextSegmentProcessor.instance
      segments = if text_file.extension == ".pdf"
                   text_segmenter.process(text_file.content, { doc_type: "pdf", clean: true })
                 else
                   text_segmenter.process(text_file.content, { clean: true })
                 end
      text_file.add_segments(segments)
    end
  end
end
