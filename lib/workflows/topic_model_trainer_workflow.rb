#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/workflows/topic_model_trainer_workflow.rb

module Flowbots
  class TopicModelTrainerWorkflow
    attr_reader :pipeline

    def initialize(input_folder_path=nil)
      @input_folder_path = input_folder_path || prompt_for_folder
      @pipeline = UnifiedFileProcessingPipeline.new(@input_folder_path, batch_size: 10, file_types: %w[md markdown])
    end

    def run
      UI.say(:ok, "Setting Up Topic Model Trainer Workflow")
      logger.info "Setting Up Topic Model Trainer Workflow"

      begin
        @pipeline.process
        train_topic_model
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
