#!/usr/bin/env ruby
# frozen_string_literal: true

class LoadFileObjectTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting LoadFileObjectTask"

    begin
      file_path = retrieve_file_path
      file_object = FileObject.find_or_create_by_path(file_path)

      if file_object.nil?
        error_message = "Failed to create or find FileObject for: #{file_path}"
        logger.error error_message
        raise(error_message)
        return
      end

      store_file_object_id(file_object.id)
      logger.info "Loaded FileObject with ID: #{file_object.id}"
      UI.say(:ok, "Loaded FileObject with ID: #{file_object.id}")
      complete("Successfully loaded FileObject for: #{file_path}")
    rescue ArgumentError => e
      error_message = "Invalid input: #{e.message}"
      logger.error error_message
      raise(error_message)
    rescue StandardError => e
      error_message = "Error loading file: #{e.message}"
      logger.error error_message
      logger.error e.backtrace.join("\n")
      UI.say(:error, "Failed to load file")
      raise(error_message)
    end
  end

  private

  def retrieve_file_path
    RedisKeys.get(RedisKeys::CURRENT_FILE_PATH)
  end

  def store_file_object_id(id)
    RedisKeys.set(RedisKeys::CURRENT_FILE_OBJECT_ID, id)
  end
end
