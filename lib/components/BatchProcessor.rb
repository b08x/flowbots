#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class BatchProcessor
    attr_reader :input_folder_path, :batch_size, :file_types

    def initialize(input_folder_path, batch_size=10, file_types=nil)
      @input_folder_path = input_folder_path || prompt_for_folder
      @batch_size = batch_size
      @file_types = file_types || FileDiscovery::FILE_TYPES[:text]
    end

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

    def prompt_for_folder
      get_folder_path = `gum file --directory`.chomp.strip
      folder_path = File.join(get_folder_path)

      raise FlowbotError.new("Folder not found", "FOLDERNOTFOUND") unless File.directory?(folder_path)

      folder_path
    end

    def discover_files
      Dir.glob(File.join(input_folder_path, "**{,/*/**}/*#{file_types_pattern}")).sort
    end

    def file_types_pattern
      ".{#{file_types.join(',')}}"
    end

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
