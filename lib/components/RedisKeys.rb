#!/usr/bin/env ruby
# frozen_string_literal: true

module RedisKeys
  CURRENT_TEXTFILE_ID = "current_textfile_id"
  INPUT_FILE_PATH = "input_file_path"
  PREPROCESSED_CONTENT = "preprocessed_content"
  FILE_METADATA = "file_metadata"
  CURRENT_BATCH_ID = "current_batch_id"

  def self.get(key)
    Jongleur::WorkerTask.class_variable_get(:@@redis).get(key)
  end

  def self.set(key, value)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set(key, value)
  end
end
