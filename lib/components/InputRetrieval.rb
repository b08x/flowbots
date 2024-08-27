#!/usr/bin/env ruby
# frozen_string_literal: true

module InputRetrieval
  def retrieve_input
    retrieve_file_object
  end

  def retrieve_file_path
    file_path = RedisKeys.get(RedisKeys::CURRENT_FILE_PATH)
    if file_path.nil? || file_path.empty?
      logger.error "File path not found in Redis"
      raise ArgumentError, "File path not found"
    end
    file_path
  end

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
