#!/usr/bin/env ruby
# frozen_string_literal: true

module RedisKeys
  CURRENT_FILE_OBJECT_ID = "current_file_object_id"
  CURRENT_FILE_PATH = "current_file_path"
  CURRENT_FILTERED_SEGMENTS = "current_filtered_segments"
  ALL_FILTERED_SEGMENTS = "all_filtered_segments"
  CURRENT_BATCH_ID = "current_batch_id"

  def self.get(key)
    Jongleur::WorkerTask.class_variable_get(:@@redis).get(key)
  end

  def self.set(key, value)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set(key, value)
  end
end
