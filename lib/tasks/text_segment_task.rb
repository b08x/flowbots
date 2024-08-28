#!/usr/bin/env ruby
# frozen_string_literal: true

# This task segments the text content of a Textfile into smaller units.
class TextSegmentTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task to segment the text content of a FileObject.
  #
  # Retrieves the FileObject from Redis, extracts its preprocessed content,
  # segments the content using the TextSegmentProcessor, stores the segments
  # in the FileObject, and logs the progress.
  #
  # @return [void]
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

  # Retrieves the input for the task, which is the current FileObject.
  #
  # @return [FileObject] The current FileObject.
  def retrieve_input
    retrieve_file_object
  end

  # Stores the given segments in the given FileObject.
  #
  # @param textfile [FileObject] The FileObject to store the segments in.
  # @param segments [Array<String>] The segments to store.
  #
  # @return [void]
  def store_segments(textfile, segments)
    logger.info "Storing #{segments.length} segments for file: #{textfile.name}"
    textfile.add_segments(segments)
    logger.debug "Segments stored successfully"
  end
end
