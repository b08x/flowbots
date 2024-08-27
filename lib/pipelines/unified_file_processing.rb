#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/pipelines/unified_file_processing_pipeline.rb

module Flowbots
  class UnifiedFileProcessingPipeline
    attr_reader :orchestrator, :batch_processor

    def initialize(input_path, batch_size: 10, file_types: %w[md markdown txt pdf json])
      @input_path = input_path
      @batch_size = batch_size
      @file_types = file_types
      @orchestrator = WorkflowOrchestrator.new
      @batch_processor = BatchProcessor.new(@input_path, @batch_size, @file_types)
    end

    def process
      setup_workflow
      flush_redis_cache

      if File.directory?(@input_path)
        process_batch
      else
        process_single_file
      end
    end

    private

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

    def flush_redis_cache
      redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.flushdb
      logger.info "Redis cache flushed"
    end

    def process_batch
      @batch_processor.process_files do |file_path|
        process_file(file_path)
      end
    end

    def process_single_file
      process_file(@input_path)
    end

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
