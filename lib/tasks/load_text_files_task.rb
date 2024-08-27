#!/usr/bin/env ruby
# frozen_string_literal: true

class LoadTextFilesTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting LoadTextFilesTask"

    file_path = retrieve_input

    begin
      file_loader = Flowbots::FileLoader.new(file_path)
      textfile = file_loader.file_data

      if textfile && textfile.is_a?(Textfile)
        store_textfile_id(textfile.id)
        logger.debug "Loaded file: #{file_path}"
      else
        logger.error "Failed to create Textfile object for: #{file_path}"
        nil
      end
    rescue StandardError => e
      logger.error "Error loading file #{file_path}: #{e.message}"
      UI.say(:error, "Failed to load file: #{file_path}")
      nil
    end
  end

  private

  def retrieve_input
    retrieve_file_path
  end

  def store_textfile_id(id)
    RedisKeys.set(RedisKeys::CURRENT_TEXTFILE_ID, id)
  end
end
