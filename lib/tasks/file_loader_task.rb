#!/usr/bin/env ruby
# frozen_string_literal: true

class FileLoaderTask < Jongleur::WorkerTask
  def execute
    input_file_path = Jongleur::WorkerTask.class_variable_get(:@@redis).get("input_file_path")
    file_processor = Flowbots::FileLoader.new(input_file_path)
    text_file_id = file_processor.file_data.id

    if text_file_id.nil?
      logger.error "Failed to load Sourcefile with ID: #{text_file_id}"
      raise FlowbotError.new("Sourcefile not found", "FILENOTFOUND")
    end

    logger.info "Loaded Sourcefile with ID: #{text_file_id}"
    Flowbots::UI.say(:ok, "Loaded Sourcefile with ID: #{text_file_id}")
    ui.space
  end
end
