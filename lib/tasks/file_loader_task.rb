#!/usr/bin/env ruby
# frozen_string_literal: true

# This task loads a text file and stores its ID in Redis.
class FileLoaderTask < Task
  # Executes the task to load a FileObject and store its ID in Redis.
  #
  # Retrieves the input file path, processes the file using Flowbots::FileLoader,
  # stores the FileObject ID in Redis, and logs the progress.
  #
  # @return [void]
  # @raises [FlowbotError] If the FileObject is not found or its ID is nil.
  def execute
    logger.info "Starting FileLoaderTask"

    input_file_path = retrieve_input

    file_processor = Flowbots::FileLoader.new(input_file_path)
    text_file = file_processor.file_data

    if text_file.nil? || text_file.id.nil?
      logger.error "Failed to load FileObject"
      raise FlowbotError.new("FileObject not found", "FILENOTFOUND")
    end

    store_FileObject_id(text_file.id)

    logger.info "Loaded FileObject with ID: #{text_file.id}"
    UI.say(:ok, "Loaded FileObject with ID: #{text_file.id}")
  end

  private

  # Retrieves the input file path from Redis.
  #
  # @return [String] The input file path.
  def retrieve_input
    retrieve_file_path
  end

  # Stores the FileObject ID in Redis.
  #
  # @param id [Integer] The ID of the FileObject.
  #
  # @return [void]
  def store_FileObject_id(id)
    RedisKeys.set(RedisKeys::CURRENT_FileObject_ID, id)
  end
end
