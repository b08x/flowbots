#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class FileLoaderTask < Jongleur::WorkerTask
    include TaskHelper

    def execute
      super do
        @logger.info("Starting file loading process")

        input_file_path = self.class.class_variable_get(:@@redis).get("input_file_path")
        @logger.debug("Retrieved input file path: #{input_file_path}")

        file_processor = Flowbots::FileLoader.new(input_file_path)
        text_file_id = file_processor.file_data.id

        if text_file_id.nil?
          raise StandardError.new("Failed to load Sourcefile: file ID is nil")
        end

        @logger.info("Successfully loaded Sourcefile with ID: #{text_file_id}")
        Flowbots::UI.say(:ok, "Loaded Sourcefile with ID: #{text_file_id}")

        "Loaded Sourcefile with ID: #{text_file_id}"
      end
    end
  end
end
