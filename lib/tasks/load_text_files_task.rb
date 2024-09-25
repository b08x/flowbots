#!/usr/bin/env ruby
# frozen_string_literal: true

# Task to load text files and store their IDs in Redis.
class LoadTextFilesTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task to load a text file using the Flowbots::FileLoader.
  #
  # Retrieves the file path from Redis, loads the file using Flowbots::FileLoader,
  # stores the Textfile ID in Redis if successful, and logs the progress or errors.
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
  # @return [String] The input file path.
  def retrieve_input
    retrieve_file_path
  end

  # Stores the Textfile ID in Redis.
  #
  # @param id [Integer] The ID of the Textfile.
  #
  # @return [void]
  def store_textfile_id(id)
    RedisKeys.set(RedisKeys::CURRENT_TEXTFILE_ID, id)
  end
end
