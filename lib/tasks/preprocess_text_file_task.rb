#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

class PreprocessTextFileTask < Jongleur::WorkerTask
  include Logging

  def execute
    logger.info "Starting PreprocessTextFileTask"

    textfile = retrieve_current_textfile
    content, metadata = split_content_and_metadata(textfile.content)

    store_preprocessed_data(content, metadata)

    logger.info "PreprocessTextFileTask completed"
  end

  private

  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  def split_content_and_metadata(text)
    if text.start_with?('---')
      parts = text.split('---', 3)
      if parts.length >= 3
        metadata = YAML.safe_load(parts[1])
        content = parts[2].strip
      else
        metadata = {}
        content = text
      end
    else
      metadata = {}
      content = text
    end
    [content, metadata]
  end

  def store_preprocessed_data(content, metadata)
    redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
    redis.set("preprocessed_content", content)
    redis.set("file_metadata", metadata.to_json)
  end
end
