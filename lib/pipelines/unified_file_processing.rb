#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class defines a pipeline for processing files, either individually or in batches.
  # It utilizes a WorkflowOrchestrator to manage the execution of tasks related to file processing.
  class UnifiedFileProcessingPipeline
    # @return [WorkflowOrchestrator] The orchestrator responsible for managing the workflow.
    attr_reader :orchestrator
    # @return [BatchProcessor] The batch processor for handling multiple files.
    attr_reader :batch_processor

    # Initializes a new UnifiedFileProcessingPipeline instance.
    #
    # @param input_path [String] The path to the file or directory to be processed.
    # @param batch_size [Integer] The number of files to process in each batch (default: 10).
    # @param file_types [Array<String>] An array of file extensions to process (default: ['md', 'markdown', 'txt', 'pdf', 'json']).
    #
    # @return [void]
    def initialize(input_path, batch_size: 10, file_types: %w[md markdown txt pdf json])
      @input_path = input_path
      @batch_size = batch_size
      @file_types = file_types
      @orchestrator = WorkflowOrchestrator.new
      @batch_processor = BatchProcessor.new(@input_path, @batch_size, @file_types)
    end

    # Processes the file(s) specified in the input path.
    #
    # @return [void]
    def process
      setup_workflow
      # flush_redis_cache

      if File.directory?(@input_path)
        process_batch
      else
        process_single_file
      end
    end

    private

    # Sets up the workflow by defining the task graph and adding agents to the orchestrator.
    #
    # @return [void]
    def setup_workflow
      workflow_graph = {
        LoadFileObjectTask: [:PreprocessFileObjectTask],
        PreprocessFileObjectTask: [:TextSegmentTask],
        TextSegmentTask: [:TokenizeSegmentsTask],
        TokenizeSegmentsTask: [:NlpAnalysisTask],
        NlpAnalysisTask: [:FilterSegmentsTask],
        FilterSegmentsTask: [:AccumulateFilteredSegmentsTask],
        AccumulateFilteredSegmentsTask: []
      }

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    # Flushes the Redis cache.
    #
    # @return [void]
    def flush_redis_cache
      redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.flushdb
      logger.info "Redis cache flushed"
    end

    # Processes a batch of files using the batch processor.
    #
    # @return [void]
    def process_batch
      @batch_processor.process_files do |file_path|
        process_file(file_path)
      end
    end

    # Processes a single file.
    #
    # @return [void]
    def process_single_file
      process_file(@input_path)
    end

    # Processes a single file by setting the current file path in Redis and running the workflow.
    #
    # @param file_path [String] The path to the file to be processed.
    #
    # @return [void]
    def process_file(file_path)
      RedisKeys.set(RedisKeys::CURRENT_FILE_PATH, file_path)

      logger.info "Processing file: #{file_path}"

      result = @orchestrator.run_workflow

      if result.nil?
        logger.warn "Workflow returned nil for file: #{file_path}"
      else
        logger.info "Successfully processed file: #{file_path}"
      end
    rescue StandardError => e
      logger.error "Error processing file #{file_path}: #{e.message}"
      logger.error e.backtrace.join("\n")
      UI.say(:error, "Error processing file #{file_path}: #{e.message}")
    ensure
      # Clear the current file path and file object ID from Redis after processing
      # RedisKeys.set(RedisKeys::CURRENT_FILE_PATH, nil)
      # RedisKeys.set(RedisKeys::CURRENT_FILE_OBJECT_ID, nil)
      puts "HEEEEEEEEEEEEY!"
    end
  end
end
