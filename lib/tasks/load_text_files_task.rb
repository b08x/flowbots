#!/usr/bin/env ruby
# frozen_string_literal: true

class LoadTextFilesTask < Jongleur::WorkerTask
  def execute
    file_path = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_file_path")

    begin
      file_loader = Flowbots::FileLoader.new(file_path)
      textfile = file_loader.file_data
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_file_id", textfile.id)
      logger.debug "Loaded file: #{file_path}"
    rescue StandardError => e
      logger.error "Error loading file #{file_path}: #{e.message}"
      Flowbots::UI.say(:error, "Failed to load file: #{file_path}")
    end
  end
end
