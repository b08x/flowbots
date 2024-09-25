#!/usr/bin/env ruby
# frozen_string_literal: true

# Module for managing Redis keys used in the Flowbots application.
module RedisKeys
  # Redis key for storing the ID of the current FileObject.
  CURRENT_FILE_OBJECT_ID = "current_file_object_id"
  # Redis key for storing the path of the current file.
  CURRENT_FILE_PATH = "current_file_path"
  # Redis key for storing the currently filtered segments.
  CURRENT_FILTERED_SEGMENTS = "current_filtered_segments"
  # Redis key for storing all filtered segments.
  ALL_FILTERED_SEGMENTS = "all_filtered_segments"
  # Redis key for storing the ID of the current batch.
  CURRENT_BATCH_ID = "current_batch_id"

  # Retrieves the value associated with the given key from Redis.
  #
  # @param key [String] The Redis key.
  # @return [String, nil] The value associated with the key, or nil if the key does not exist.
  def self.get(key)
    Jongleur::WorkerTask.class_variable_get(:@@redis).get(key)
  end

  # Sets the value associated with the given key in Redis.
  #
  # @param key [String] The Redis key.
  # @param value [String] The value to set.
  # @return [String] The value that was set.
  def self.set(key, value)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set(key, value)
  end
end
