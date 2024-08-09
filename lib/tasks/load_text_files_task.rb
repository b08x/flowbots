#!/usr/bin/env ruby
# frozen_string_literal: true

# This task loads a text file and stores its ID in Redis.
class LoadTextFilesTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the input file path from Redis.
    file_path = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_file_path")

    # Attempt to load the file and store its ID in Redis.
    begin
      # Create a new FileLoader instance to process the file.
      file_loader = Flowbots::FileLoader.new(file_path)

      # Get the ID of the loaded Textfile.
      textfile = file_loader.file_data

      # Store the Textfile ID in Redis.
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_textfile_id", textfile.id)

      # Log a success message.
      logger.debug "Loaded file: #{file_path}"
    rescue StandardError => e
      # Log an error message if the file loading fails.
      logger.error "Error loading file #{file_path}: #{e.message}"

      # Display an error message to the user.
      Flowbots::UI.say(:error, "Failed to load file: #{file_path}")
    end
  end
end
