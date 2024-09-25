#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # The `BatchProcessor` class provides a mechanism for processing files in batches.
  # It is particularly useful when dealing with a large number of files, as it prevents
  # potential memory issues and allows for more controlled and efficient processing.
  class BatchProcessor
    # @return [String] The path to the folder containing the files to be processed.
    attr_reader :input_folder_path
    # @return [Integer] The number of files to process in each batch.
    attr_reader :batch_size
    # @return [Array<String>] An array of file extensions to process.
    attr_reader :file_types

    # Initializes a new `BatchProcessor` instance.
    #
    # @param input_folder_path [String] The path to the folder containing the files to be processed.
    #   If not provided, it prompts the user to select a folder.
    # @param batch_size [Integer] The number of files to process in each batch. Defaults to 10.
    # @param file_types [Array<String>] An array of file extensions to process.
    #   Defaults to text files: ['.txt', '.md', '.markdown'].
    def initialize(input_folder_path, batch_size=10, file_types=nil)
      @input_folder_path = input_folder_path || prompt_for_folder
      @batch_size = batch_size
      @file_types = file_types || FileDiscovery::FILE_TYPES[:text]
    end

    # Processes the files in batches.
    #
    # This method iterates through the files in the input folder, divides them into batches,
    # and yields each file path to the provided block for processing.
    #
    # @yieldparam file_path [String] The path to the file being processed.
    # @return [void]
    def process_files(&block)
      all_file_paths = discover_files
      total_files = all_file_paths.count
      num_batches = (total_files.to_f / batch_size).ceil

      num_batches.times do |i|
        batch_start = i * batch_size
        batch_files = all_file_paths[batch_start, batch_size]

        UI.say(:ok, "Processing batch #{i + 1} of #{num_batches}")
        logger.info "Processing batch #{i + 1} of #{num_batches}"

        process_batch(batch_files, &block)
      end
    end

    private

    # Prompts the user to select a folder using the `gum file` command.
    #
    # @return [String] The path to the selected folder.
    # @raises [FlowbotError] If the selected folder does not exist.
    def prompt_for_folder
      get_folder_path = `gum file --directory`.chomp.strip
      folder_path = File.join(get_folder_path)

      raise FlowbotError.new("Folder not found", "FOLDERNOTFOUND") unless File.directory?(folder_path)

      folder_path
    end

    # Discovers all files within the input folder that match the specified file types.
    #
    # @return [Array<String>] An array of file paths.
    def discover_files
      Dir.glob(File.join(input_folder_path, "**{,/*/**}/*#{file_types_pattern}")).sort
    end

    # Constructs a regular expression pattern from the `file_types` array.
    #
    # @return [String] The regular expression pattern.
    def file_types_pattern
      ".{#{file_types.join(',')}}"
    end

    # Processes a single batch of files.
    #
    # @param batch_files [Array<String>] An array of file paths for the current batch.
    # @yieldparam file_path [String] The path to the file being processed.
    # @return [void]
    def process_batch(batch_files)
      batch_files.each do |file_path|
        yield(file_path) if block_given? && file_path && File.exist?(file_path)
      rescue StandardError => e
        logger.error "Error processing file #{file_path}: #{e.message}"
        UI.say(:error, "Error processing file #{file_path}: #{e.message}")
      end
    end
  end
end
