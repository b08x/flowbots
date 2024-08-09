#!/usr/bin/env ruby
# frozen_string_literal: true

# This task loads a text file and stores its ID in Redis.
class FileLoaderTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the input file path from Redis.
    input_file_path = Jongleur::WorkerTask.class_variable_get(:@@redis).get("input_file_path")

    # Create a new FileLoader instance to process the file.
    file_processor = Flowbots::FileLoader.new(input_file_path)

    # Get the ID of the loaded Textfile.
    text_file_id = file_processor.file_data.id

    # If the Textfile ID is nil, raise an error.
    if text_file_id.nil?
      logger.error "Failed to load Textfile with ID: #{text_file_id}"
      raise FlowbotError.new("Textfile not found", "FILENOTFOUND")
    end

    # Log a success message and display it to the user.
    logger.info "Loaded Textfile with ID: #{text_file_id}"
    Flowbots::UI.say(:ok, "Loaded Textfile with ID: #{text_file_id}")
    ui.space
  end
end
