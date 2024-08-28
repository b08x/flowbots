#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TextProcessingWorkflow
    attr_reader :pipeline

    def initialize(input_file_path=nil, batch_mode=false)
      @input_file_path = input_file_path || prompt_for_file
      @batch_mode = batch_mode
      @pipeline = UnifiedFileProcessingPipeline.new(
        @input_file_path,
        batch_size: batch_mode ? nil : 1,
        file_types: %w[txt md markdown]
      )
    end

    def run
      UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      begin
        @pipeline.process
        if @batch_mode
          process_batch
        else
          process_single_file
        end
        UI.say(:ok, "Text Processing Workflow completed")
        logger.info "Text Processing Workflow completed"
      rescue StandardError => e
        UI.say(:error, "Error in Text Processing Workflow: #{e.message}")
        logger.error "Error in Text Processing Workflow: #{e.message}"
        logger.error e.backtrace.join("\n")
      end
    end

    private

    def prompt_for_file
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)

      raise FlowbotError.new("File not found", "FILENOTFOUND") unless File.exist?(file_path)

      file_path
    end

    def process_batch
      file_ids = fetch_unprocessed_file_ids
      file_ids.each do |file_id|
        perform_additional_tasks(file_id)
      end
    end

    def process_single_file
      p @input_file_path
      puts "-----"
      file_object = create_or_fetch_file_object(@input_file_path)
      perform_additional_tasks(file_object.id)
    end

    def create_or_fetch_file_object(file_path)
      # Assuming we're using ActiveRecord and there's a FileObject model
      # This method should create a new FileObject or fetch an existing one
      if file_path.is_a?(Hash)
        file_path = file_path[:path]
      end
      FileObject.find_or_create_by_path(path: file_path)
    end

    def fetch_unprocessed_file_ids
      # Assuming we're using ActiveRecord and there's a FileObject model
      # This query fetches all file IDs where llm_analysis is nil or an empty string
      ids = []
      FileObject.all.each {|f| ids << f.id.to_i if f.llm_analysis.nil?}
    end

    def perform_additional_tasks(file_id)
      additional_tasks = {
        TextTaggerTask: [:TopicModelingTask],
        TopicModelingTask: [:LlmAnalysisTask],
        LlmAnalysisTask: [:DisplayResultsTask],
        DisplayResultsTask: []
      }

      @pipeline.orchestrator.define_workflow(additional_tasks)
      @pipeline.orchestrator.run_workflow
    end
  end
end
