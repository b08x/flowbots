#!/usr/bin/env ruby
# frozen_string_literal: true

# This task loads a FileObject from the file system and stores its ID in Redis.
class LoadFileObjectTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task to load a FileObject.
  #
  # This method retrieves the file path from Redis, finds or creates a FileObject
  # associated with the path, stores the FileObject ID in Redis,
  # and logs the progress.
  #
  # The loading process involves:
  #
  # 1. **Retrieving the file path:** The `retrieve_file_path` method is called to retrieve the
  #    file path from Redis.
  # 2. **Finding or creating a FileObject:** The `FileObject.find_or_create_by_path` method is
  #    called with the retrieved file path to find an existing FileObject or create a new
  #    one if it doesn't exist. The result is stored in the `file_object` variable.
  # 3. **Handling errors:** If the `file_object` is nil, meaning the FileObject could not be
  #    found or created, an error message is logged and a `RuntimeError` is raised.
  # 4. **Storing the FileObject ID:** If the FileObject was successfully found or created,
  #    the `store_file_object_id` method is called to store the FileObject ID in Redis.
  # 5. **Logging information:** The `logger` object is used to log relevant information
  #    about the loading process, including success messages and error messages.
  #
  # @return [void]
  # @raises [RuntimeError] If the FileObject cannot be created or found,
  #   or if there is an error during file loading.
  def execute
    logger.info "Starting LoadFileObjectTask"

    begin
      # Retrieve the file path from Redis.
      file_path = retrieve_file_path
      # Find or create a FileObject based on the retrieved file path.
      file_object = FileObject.find_or_create_by_path(file_path)

      # Raise an error if the FileObject is not found or created.
      if file_object.nil?
        error_message = "Failed to create or find FileObject for: #{file_path}"
        logger.error error_message
        raise(error_message)
        return
      end

      # Store the FileObject ID in Redis.
      store_file_object_id(file_object.id)
      # Log messages indicating the successful loading of the FileObject.
      logger.info "Loaded FileObject with ID: #{file_object.id}"
      UI.say(:ok, "Loaded FileObject with ID: #{file_object.id}")
      complete("Successfully loaded FileObject for: #{file_path}")
    rescue ArgumentError => e
      # Handle ArgumentError, typically raised for invalid input.
      error_message = "Invalid input: #{e.message}"
      logger.error error_message
      raise(error_message)
    rescue StandardError => e
      # Handle any other StandardError during file loading.
      error_message = "Error loading file: #{e.message}"
      logger.error error_message
      logger.error e.backtrace.join("\n")
      UI.say(:error, "Failed to load file")
      raise(error_message)
    end
  end

  private

  # Retrieves the file path from Redis.
  #
  # This method retrieves the file path from Redis using the `RedisKeys` class. It gets
  # the value of the `RedisKeys::CURRENT_FILE_PATH` key, which represents the current
  # file path being processed.
  #
  # @return [String] The file path retrieved from Redis.
  def retrieve_file_path
    RedisKeys.get(RedisKeys::CURRENT_FILE_PATH)
  end

  # Stores the FileObject ID in Redis.
  #
  # This method stores the FileObject ID in Redis using the `RedisKeys` class. It sets
  # the value of the `RedisKeys::CURRENT_FILE_OBJECT_ID` key to the provided `id`. This
  # key is used to track the currently loaded FileObject.
  #
  # @param id [Integer] The ID of the FileObject to store.
  # @return [void]
  def store_file_object_id(id)
    RedisKeys.set(RedisKeys::CURRENT_FILE_OBJECT_ID, id)
  end
end
