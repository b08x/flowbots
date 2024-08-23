#!/usr/bin/env ruby
# frozen_string_literal: true

# This task loads a text file and stores its ID in Redis.
class FileLoaderTask < Task
  def execute
    logger.info "Starting FileLoaderTask"

    input_file_path = retrieve_input

    file_processor = Flowbots::FileLoader.new(input_file_path)
    text_file = file_processor.file_data

    if text_file.nil? || text_file.id.nil?
      logger.error "Failed to load Textfile"
      raise FlowbotError.new("Textfile not found", "FILENOTFOUND")
    end

    store_textfile_id(text_file.id)

    logger.info "Loaded Textfile with ID: #{text_file.id}"
    Flowbots::UI.say(:ok, "Loaded Textfile with ID: #{text_file.id}")
  end

  private

  def retrieve_input
    retrieve_file_path
  end

  def store_textfile_id(id)
    RedisKeys.set(RedisKeys::CURRENT_TEXTFILE_ID, id)
  end
end
