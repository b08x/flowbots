#!/usr/bin/env ruby
# frozen_string_literal: true

# This task tokenizes the segments of a text file.
class TokenizeSegmentsTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task to tokenize the segments of a FileObject.
  #
  # Retrieves the FileObject from Redis, tokenizes each segment using the
  # TextTokenizeProcessor, updates the segments with the tokenized data, and
  # logs the progress.
  #
  # @return [void]
  def execute
    # Log the start of the task.
    logger.info "Starting TokenizeSegmentsTask"

    # Retrieve the FileObject from Redis.
    textfile = retrieve_input
    # Get an instance of the TextTokenizeProcessor.
    text_tokenizer = Flowbots::TextTokenizeProcessor.instance

    # Iterate through each segment of the FileObject and tokenize its text.
    textfile.retrieve_segments.each do |segment|
      # Tokenize the segment's text using the TextTokenizeProcessor.
      tokens = text_tokenizer.process(segment.text, { clean: true })
      # Update the segment with the tokenized data.
      segment.update(tokens:)
    end

    # Log the completion of the task.
    logger.info "TokenizeSegmentsTask completed"
  end

  private

  # Retrieves the input for the task, which is the current FileObject.
  #
  # @return [FileObject] The current FileObject.
  def retrieve_input
    retrieve_file_object
  end
end
