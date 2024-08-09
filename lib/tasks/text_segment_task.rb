#!/usr/bin/env ruby
# frozen_string_literal: true

# This task segments the text content of a Textfile into smaller units.
class TextSegmentTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    logger.info "Starting TextSegmentTask"

    # Retrieve the Textfile object from Redis.
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    text_file = Textfile[textfile_id]

    # Retrieve the preprocessed content from the Textfile.
    preprocessed_content = text_file.preprocessed_content

    # Get an instance of the TextSegmentProcessor.
    text_segmenter = Flowbots::TextSegmentProcessor.instance

    # Segment the preprocessed content using the TextSegmentProcessor.
    segments = text_segmenter.process(preprocessed_content, { clean: true })

    # Store the segmented content in the Textfile.
    store_segments(text_file, segments)

    logger.info "TextSegmentTask completed"
  end

  private

  # Retrieves the preprocessed content from Redis.
  #
  # @return [String] The preprocessed content.
  def retrieve_preprocessed_content
    content = Jongleur::WorkerTask.class_variable_get(:@@redis).get("preprocessed_content")
    if content.nil? || content.empty?
      logger.warn "No preprocessed content found. Falling back to original text file content."
      textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
      text_file = Textfile[textfile_id]
      content = text_file.content
    end
    content
  end

  # Stores the segmented content in the Textfile.
  #
  # @param text_file [Textfile] The Textfile object.
  # @param segments [Array] The segmented content.
  #
  # @return [void]
  def store_segments(text_file, segments)
    logger.info "Storing #{segments.length} segments for file: #{text_file.name}"
    text_file.add_segments(segments)
    logger.debug "Segments stored successfully"
  end
end
