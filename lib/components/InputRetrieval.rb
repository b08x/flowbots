#!/usr/bin/env ruby
# frozen_string_literal: true

# Module for retrieving input data.
module InputRetrieval
  # Retrieves the input data for a task.
  #
  # This method first attempts to retrieve a FileObject from Redis.
  # If a FileObject is not found, it will attempt to retrieve a file path from Redis.
  #
  # @return [FileObject, String, nil] The retrieved FileObject, file path, or nil if no input is found.
  def retrieve_input
    retrieve_file_object
  end

  # Retrieves the file path from Redis.
  #
  # @return [String] The retrieved file path.
  # @raise [ArgumentError] If the file path is not found in Redis.
  def retrieve_file_path
    file_path = RedisKeys.get(RedisKeys::CURRENT_FILE_PATH)
    if file_path.nil? || file_path.empty?
      logger.error "File path not found in Redis"
      raise ArgumentError, "File path not found"
    end
    file_path
  end

  # Retrieves the FileObject from Redis.
  #
  # @return [FileObject, nil] The retrieved FileObject or nil if no FileObject is found.
  def retrieve_file_object
    file_object_id = RedisKeys.get(RedisKeys::CURRENT_FILE_OBJECT_ID)
    if file_object_id.nil?
      logger.error "No FileObject ID found in Redis"
      return nil
    end

    file_object = FileObject[file_object_id]
    if file_object.nil?
      logger.error "No FileObject found for ID: #{file_object_id}"
      return nil
    end

    file_object
  end
end
