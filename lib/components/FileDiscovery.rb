# frozen_string_literal: true

module Flowbots
  # This module provides file discovery utilities for Flowbots.
  module FileDiscovery
    # A constant hash defining file extensions grouped by their types.
    FILE_TYPES = {
      text: [".txt", ".md", ".markdown"],
      pdf: [".pdf"],
      html: [".html", ".htm"],
      json: [".json"],
      audio: [".mp3", ".wav", ".ogg", ".flac"],
      video: [".mp4", ".avi", ".mov", ".mkv"]
    }.freeze

    # Discovers files in the given directory and groups them by type.
    #
    # @param directory [String] The directory to search for files.
    # @return [Hash] A hash where keys are file types and values are arrays of file paths.
    def self.discover_files(directory)
      files = Hash.new { |h, k| h[k] = [] }

      Dir.glob(File.join(directory, "**", "*")).each do |file|
        next unless File.file?(file)

        extension = File.extname(file).downcase
        FILE_TYPES.each do |type, extensions|
          if extensions.include?(extension)
            files[type] << file
            break
          end
        end
      end

      files
    end

    # Counts the number of files for each file type.
    #
    # @param files [Hash] A hash where keys are file types and values are arrays of file paths.
    # @return [Hash] A hash where keys are file types and values are the number of files of that type.
    def self.file_count(files)
      files.transform_values(&:count)
    end
  end
end
