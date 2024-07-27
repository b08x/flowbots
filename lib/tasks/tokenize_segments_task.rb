#!/usr/bin/env ruby
# frozen_string_literal: true

class TokenizeSegmentsTask < Jongleur::WorkerTask
  def execute
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    text_file = Textfile[textfile_id]

    text_tokenizer = Flowbots::TextTokenizeProcessor.instance

    text_file.retrieve_segments.each do |segment|
      tokens = text_tokenizer.process(segment.text, { clean: true })
      segment.update(tokens: tokens)
      segment.save
    end
  end
end
