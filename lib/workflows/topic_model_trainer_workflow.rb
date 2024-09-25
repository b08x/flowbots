#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class defines a workflow for training a topic model using a collection of text files.
  # It utilizes a UnifiedFileProcessingPipeline to handle the file processing and segment filtering,
  # and then trains a topic model using the filtered segments.
  class TopicModelTrainerWorkflow
    # @return [UnifiedFileProcessingPipeline] The pipeline responsible for file processing and segment filtering.
    attr_reader :pipeline

    # Initializes a new TopicModelTrainerWorkflow instance.
    #
    # @param input_folder_path [String, nil] The path to the folder containing the input files.
    #   If nil, the user will be prompted to select a folder.
    #
    # @return [void]
    def initialize(input_folder_path=nil)
      @input_folder_path = input_folder_path || prompt_for_folder
      @pipeline = UnifiedFileProcessingPipeline.new(@input_folder_path, batch_size: 10, file_types: %w[md markdown])
    end

    # Runs the topic model trainer workflow.
    #
    # Sets up the workflow, processes the files, and trains the topic model.
    #
    # @return [void]
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

    # Trains the topic model using the filtered segments from the processed files.
    #
    # Retrieves the filtered segments from Redis, cleans them, trains the topic model,
    # and logs the progress.
    #
    # @return [void]
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

    # Cleans the segments for topic modeling by removing unwanted segments and words.
    #
    # @param segments [Array<Array<String>>] The segments to clean.
    #
    # @return [Array<Array<String>>] The cleaned segments.
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
