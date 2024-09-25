#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TopicModelTrainerWorkflowtest
    BATCH_SIZE = 10

    attr_accessor :orchestrator
    attr_reader :input_folder_path

    def initialize(input_folder_path=nil)
      @input_folder_path = input_folder_path || prompt_for_folder
      @orchestrator = WorkflowOrchestrator.new
    end

    def run
      UI.say(:ok, "Setting Up Topic Model Trainer Workflow")
      logger.info "Setting Up Topic Model Trainer Workflow"

      begin
        setup_workflow
        flush_redis_cache
        process_files
        UI.say(:ok, "Topic Model Trainer Workflow completed")
        logger.info "Topic Model Trainer Workflow completed"
      rescue StandardError => e
        UI.say(:error, "Error in Topic Model Trainer Workflow: #{e.message}")
        logger.error "Error in Topic Model Trainer Workflow: #{e.message}"
        logger.error e.backtrace.join("\n")
      end
    end

    private

    def prompt_for_folder
      get_folder_path = `gum file --directory`.chomp.strip
      folder_path = File.join(get_folder_path)

      raise FlowbotError.new("Folder not found", "FOLDERNOTFOUND") unless File.directory?(folder_path)

      folder_path
    end

    def setup_workflow
      workflow_graph = {
        LoadFileObjectsTask: [:PreprocessFileObjectTask],
        PreprocessFileObjectTask: []
      }

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    def flush_redis_cache
      redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.flushdb
      logger.info "Redis cache flushed"
    end

    def process_files
      all_file_paths = Dir.glob(File.join(@input_folder_path, "**{,/*/**}/*.{md,markdown}")).sort
      total_files = all_file_paths.count
      num_batches = (total_files.to_f / BATCH_SIZE).ceil

      num_batches.times do |i|
        batch_start = i * BATCH_SIZE
        batch_files = all_file_paths[batch_start, BATCH_SIZE]

        UI.say(:ok, "Processing batch #{i + 1} of #{num_batches}")
        logger.info "Processing batch #{i + 1} of #{num_batches}"

        process_batch(batch_files)
      end

      train_topic_model
    end

    def process_batch(batch_files)
      batch_files.each do |file_path|
        Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_file_path", file_path)
        @orchestrator.run_workflow
      end
    end

    def train_topic_model
      all_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("all_filtered_segments") || "[]")

      if all_filtered_segments.empty?
        logger.warn "No filtered segments available for topic modeling"
        UI.say(:warn, "No filtered segments available for topic modeling")
        return
      end

      cleaned_segments = clean_segments_for_modeling(all_filtered_segments)

      if cleaned_segments.empty?
        logger.warn "No cleaned segments available for topic modeling after filtering"
        UI.say(:warn, "No cleaned segments available for topic modeling after filtering")
        return
      end

      logger.info "Cleaned segments for topic modeling. Original count: #{all_filtered_segments.length}, Cleaned count: #{cleaned_segments.length}"

      topic_processor = Flowbots::TopicModelProcessor.instance
      topic_processor.train_model(cleaned_segments)
      logger.info "Topic model training completed for all files"
      UI.say(:ok, "Topic model training completed for all files")
    end

    private

    def clean_segments_for_modeling(segments)
      segments.reject do |segment|
        segment.include?("tags") || segment.include?("title") || segment.include?("toc")
      end.map do |segment|
        segment.reject do |word|
          word.to_s.length < 3 || # Remove very short words
            word.to_s.match?(/^\d+$/) || # Remove purely numeric words
            word.to_s.match?(/^[[:punct:]]+$/) # Remove punctuation-only words
        end
      end.reject(&:empty?)
    end
  end
end
