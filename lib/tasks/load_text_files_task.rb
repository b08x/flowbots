#!/usr/bin/env ruby
# frozen_string_literal: true

# Task to load text files and store their IDs in Redis.
class LoadTextFilesTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task to load a text file using the Flowbots::FileLoader.
  #
  # This method retrieves the file path from Redis, loads the file using the
  # `Flowbots::FileLoader`, stores the `Textfile` ID in Redis if successful, and logs
  # the progress or errors.
  #
  # The loading process involves:
  #
  # 1. **Retrieving the file path:** The `retrieve_input` method is called to retrieve the
  #    file path from Redis.
  # 2. **Loading the file:** A new `Flowbots::FileLoader` instance is created with the
  #    retrieved file path. The `file_data` method of the `FileLoader` is called to load
  #    the file data. The loaded data is stored in the `textfile` variable.
  # 3. **Storing the Textfile ID:** If the file was loaded successfully and the `textfile`
  #    variable contains a valid `Textfile` object, the `store_textfile_id` method is
  #    called to store the `Textfile` ID in Redis.
  # 4. **Logging information:** The `logger` object is used to log relevant information
  #    about the loading process, including success messages, error messages, and debug
  #    information.
  #
  # @return [void]
  def execute
    # Log the start of the task.
    logger.info "Starting LoadTextFilesTask"

    # Retrieve the file path from Redis.
    file_path = retrieve_input

    begin
      # Create a new FileLoader instance with the retrieved file path.
      file_loader = Flowbots::FileLoader.new(file_path)
      # Load the file data using the FileLoader.
      textfile = file_loader.file_data

      # Check if the file was loaded successfully and is a Textfile object.
      if textfile && textfile.is_a?(Textfile)
        # Store the Textfile ID in Redis.
        store_textfile_id(textfile.id)
        # Log the successful file loading.
        logger.debug "Loaded file: #{file_path}"
      else
        # Log an error if the Textfile object creation failed.
        logger.error "Failed to create Textfile object for: #{file_path}"
        # Return nil to indicate failure.
        nil
      end
    rescue StandardError => e
      # Log an error message if any exception occurs during file loading.
      logger.error "Error loading file #{file_path}: #{e.message}"
      # Display an error message to the user.
      UI.say(:error, "Failed to load file: #{file_path}")
      # Return nil to indicate failure.
      nil
    end
  end

  private

  # Retrieves the input file path from Redis.
  #
  # This method retrieves the input file path from Redis using the `retrieve_file_path`
  # method from the `InputRetrieval` module.
  #
  # @return [String] The input file path.
  def retrieve_input
    retrieve_file_path
  end

  # Stores the Textfile ID in Redis.
  #
  # This method stores the `Textfile` ID in Redis using the `RedisKeys` class. It sets
  # the value of the `RedisKeys::CURRENT_TEXTFILE_ID` key to the provided `id`.
  #
  # @param id [Integer] The ID of the Textfile.
  #
  # @return [void]
  def store_textfile_id(id)
    RedisKeys.set(RedisKeys::CURRENT_TEXTFILE_ID, id)
  end
end
