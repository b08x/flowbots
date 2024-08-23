#!/usr/bin/env ruby
# frozen_string_literal: true

# This task tokenizes the segments of a text file.
class TokenizeSegmentsTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting TokenizeSegmentsTask"

    textfile = retrieve_input
    text_tokenizer = Flowbots::TextTokenizeProcessor.instance

    textfile.retrieve_segments.each do |segment|
      tokens = text_tokenizer.process(segment.text, { clean: true })
      segment.update(tokens:)
    end

    logger.info "TokenizeSegmentsTask completed"
  end

  private

  def retrieve_input
    retrieve_textfile
  end
end
