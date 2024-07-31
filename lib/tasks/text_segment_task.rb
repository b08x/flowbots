#!/usr/bin/env ruby
# frozen_string_literal: true

class TextSegmentTask < Jongleur::WorkerTask
  def execute
    logger.info "Starting TextSegmentTask"

    file_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_file_id")
    text_file = Sourcefile[file_id]

    preprocessed_content = retrieve_preprocessed_content

    text_segmenter = Flowbots::TextSegmentProcessor.instance
    segments = text_segmenter.process(preprocessed_content, { clean: true })

    store_segments(text_file, segments)

    logger.info "TextSegmentTask completed"
  end

  private

  def retrieve_preprocessed_content
    content = Jongleur::WorkerTask.class_variable_get(:@@redis).get("preprocessed_content")
    if content.nil? || content.empty?
      logger.warn "No preprocessed content found. Falling back to original text file content."
      file_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_file_id")
      text_file = Sourcefile[file_id]
      content = text_file.content
    end
    content
  end

  def store_segments(text_file, segments)
    logger.info "Storing #{segments.length} segments for file: #{text_file.name}"
    text_file.add_segments(segments)
    logger.debug "Segments stored successfully"
  end
end
