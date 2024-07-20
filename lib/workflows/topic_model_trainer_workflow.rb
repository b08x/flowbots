#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TopicModelTrainerWorkflow
    attr_accessor :orchestrator
    attr_reader :input_folder_path

    def initialize(input_folder_path=nil)
      @input_folder_path = input_folder_path || prompt_for_folder # Assign or prompt
      @orchestrator = WorkflowOrchestrator.new
    end

    def run
      Flowbots::UI.say(:ok, "Setting Up Topic Model Trainer Workflow")
      logger.info "Setting Up Topic Model Trainer Workflow"

      begin
        setup_workflow
        store_input_folder_path
        @orchestrator.run_workflow
        Flowbots::UI.say(:ok, "Topic Model Trainer Workflow completed")
        logger.info "Topic Model Trainer Workflow completed"
      rescue StandardError => e
        Flowbots::UI.say(:error, "Error in Topic Model Trainer Workflow: #{e.message}")
        logger.error "Error in Topic Model Trainer Workflow: #{e.message}"
        logger.error e.backtrace.join("\n")
      ensure
        cleanup
      end
    end

    private

    def prompt_for_folder
      get_folder_path = `gum file --directory`.chomp.strip
      folder_path = File.join(get_folder_path)

      unless File.directory?(folder_path)
        raise FlowbotError.new('Folder not found', 'FOLDERNOTFOUND')
      end

      folder_path
    end

    def setup_workflow
      workflow_graph = {
        LoadTextFilesTask: [:TextSegmentTask],
        TextSegmentTask: [:TokenizeSegmentsTask],
        TokenizeSegmentsTask: [:NlpAnalysisTask],
        NlpAnalysisTask: [:FilterSegmentsTask],
        FilterSegmentsTask: [:TrainTopicModelTask],
        TrainTopicModelTask: []
      }

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    def store_input_folder_path
      Flowbots::UI.info "#{@input_folder_path}"
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("input_folder_path", @input_folder_path)
    end

    def cleanup
      Ohm.redis.call("DEL", "current_batch_id")
      logger.debug "Cleaned up current_batch_id from Redis"
    end
  end
end
