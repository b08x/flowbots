#!/usr/bin/env ruby
# frozen_string_literal: true

class TokenizeSegmentsTask < Jongleur::WorkerTask
  def execute
    text_tokenizer = Flowbots::TextTokenizeProcessor.instance

    Textfile.current_batch.each do |text_file|
      segments = text_file.retrieve_segments
      segments.each do |segment|
        tokens = text_tokenizer.process(segment.text, { clean: true })
        segment.update(tokens: tokens)
        segment.save
      end
    end

    logger.info "Tokenized segments for #{Textfile.current_batch.count} files"
    Flowbots::UI.say(:ok, "Tokenized segments for #{Textfile.current_batch.count} files")
  end
end
