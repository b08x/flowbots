#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TextProcessingWorkflow
    attr_reader :pipeline

    def initialize(input_file_path=nil)
      @input_file_path = input_file_path || prompt_for_file
      @pipeline = UnifiedFileProcessingPipeline.new(
        @input_file_path,
        batch_size: 1,
        file_types: %w[txt md markdown]
      )
    end

    def run
      UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      begin
        @pipeline.process
        perform_additional_tasks
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

    def perform_additional_tasks
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
