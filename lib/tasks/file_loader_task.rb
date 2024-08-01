#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class FileLoaderTask < Jongleur::WorkerTask
    include TaskHelper

    def execute
      super do
        @logger.info("Starting file loading process")

        input_file_path = Flowbots.redis.get("input_file_path")
        @logger.debug("Retrieved input file path: #{input_file_path}")

        if input_file_path.nil? || input_file_path.empty?
          @logger.error("Input file path is nil or empty")
          raise StandardError.new("Input file path is missing")
        end

        file_processor = Flowbots::FileLoader.new(input_file_path)
        @logger.debug("FileLoader created")

        text_file_id = file_processor.file_data.id
        @logger.debug("Retrieved text_file_id: #{text_file_id}")

        if text_file_id.nil?
          @logger.error("Failed to load Sourcefile: file ID is nil")
          raise StandardError.new("Failed to load Sourcefile: file ID is nil")
        end

        @logger.info("Successfully loaded Sourcefile with ID: #{text_file_id}")
        Flowbots::UI.say(:ok, "Loaded Sourcefile with ID: #{text_file_id}")

        "Loaded Sourcefile with ID: #{text_file_id}"
      end
    end
  end
end
