#!/usr/bin/env ruby
# frozen_string_literal: true

# This task segments the text content of a Textfile into smaller units.
class TextSegmentTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting TextSegmentTask"

    textfile = retrieve_input
    preprocessed_content = textfile.preprocessed_content

    text_segmenter = Flowbots::TextSegmentProcessor.instance
    segments = text_segmenter.process(preprocessed_content, { clean: true })

    store_segments(textfile, segments)

    logger.info "TextSegmentTask completed"
  end

  private

  def retrieve_input
    retrieve_file_object
  end

  def store_segments(textfile, segments)
    logger.info "Storing #{segments.length} segments for file: #{textfile.name}"
    textfile.add_segments(segments)
    logger.debug "Segments stored successfully"
  end
end
