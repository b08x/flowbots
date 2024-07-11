#!/usr/bin/env ruby
# frozen_string_literal: true

# text_processing_workflow.rb
# Description: A text processing workflow that processes a text file, segments it, and performs topic modeling
# text_processing_workflow.rb
# Description: A text processing workflow that processes a text file, segments it, and performs topic modeling

require_relative "../components/TextProcessor"
require_relative "../components/TopicModelManager"
require "logger"
require "json"
require "pry"
require "pry-stack_explorer"

class TextProcessingWorkflow
  def initialize(input_file_path)
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @orchestrator = WorkflowOrchestrator.new
    @text_processor = TextProcessor.instance
    @topic_modeler = TopicModelManager.new(
      File.join(
        ENV.fetch("HOME", nil),
        "Workspace",
        "flowbots",
        "models",
        "topic_model.lda.bin"
      )
    )
    @input_file_path = input_file_path
  end

  def run
    @logger.info "Starting Text Processing Workflow"
    setup_workflow
    process_input
    run_workflow
    @logger.info "Text Processing Workflow completed"
  end

  private

  def setup_workflow
    @logger.debug "Setting up workflow"
    @orchestrator.add_agent("advanced_analysis", "agents/advanced_analysis_cartridge.yml", author: "@b08x")

    workflow_graph = {
      TopicModelingTask: [:AdvancedAnalysisTask],
      AdvancedAnalysisTask: []
    }

    @orchestrator.define_workflow(workflow_graph)
    @logger.debug "Workflow setup completed"
  end

  def process_input
    @logger.debug "Processing input file: #{@input_file_path}"
    text = File.read(@input_file_path)
    processed_text = @text_processor.process(text)
    binding.pry # Breakpoint 1: After text processing
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("processed_text", processed_text.to_json)
    @logger.debug "Input processing completed"
  end

  def run_workflow
    @logger.info "Running workflow"
    @orchestrator.run_workflow
  end
end

class TopicModelingTask < Jongleur::WorkerTask
  def execute
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    logger.info "Starting TopicModelingTask"

    begin
      raw_text = @@redis.get("processed_text")
      logger.debug "Retrieved processed text from Redis (length): #{raw_text.length}"

      processed_text = JSON.parse(raw_text)
      binding.pry # Breakpoint 2: After retrieving and parsing text from Redis
      logger.debug "Parsed processed text (length): #{processed_text.length}"

      topic_modeler = TopicModelManager.new(
        File.join(
          ENV.fetch("HOME", nil),
          "Workspace",
          "flowbots",
          "models",
          "topic_model.lda.bin"
        )
      )
      logger.debug "Created TopicModelManager instance"

      modeler = topic_modeler.load_or_create_model
      logger.debug "Loaded or created topic model"

      logger.debug "Inferring topics"
      topics = topic_modeler.infer_topics(processed_text.join(" "), 5)
      binding.pry # Breakpoint 3: After inferring topics
      logger.debug "Topics inferred: #{topics}"

      @@redis.set("topics", topics.to_json)
      logger.debug "Stored topics in Redis"

      logger.info "TopicModelingTask completed"
    rescue StandardError => e
      logger.error "Error in TopicModelingTask: #{e.message}"
      logger.error e.backtrace.join("\n")
      binding.pry # Breakpoint 4: If an error occurs
      raise
    end
  end
end

class AdvancedAnalysisTask < Jongleur::WorkerTask
  def execute
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    logger.info "Starting AdvancedAnalysisTask"

    begin
      agent = WorkflowAgent.new("advanced_analysis", "agents/advanced_analysis_cartridge.yml")
      logger.debug "Created WorkflowAgent instance"

      agent.load_state
      logger.debug "Loaded agent state"

      processed_text = JSON.parse(@@redis.get("processed_text"))
      topics = JSON.parse(@@redis.get("topics"))
      binding.pry # Breakpoint 5: After retrieving processed text and topics
      logger.debug "Retrieved processed text and topics from Redis"

      logger.debug "Processing with agent"
      analysis_result = agent.process("Analyze the following text and topics: #{processed_text.join(' ')}. Topics: #{topics}")
      binding.pry # Breakpoint 6: After agent processing
      logger.debug "Agent processing completed"

      agent.save_state
      logger.debug "Saved agent state"

      @@redis.set("analysis_result", analysis_result.to_json)
      logger.debug "Stored analysis result in Redis"

      logger.info "AdvancedAnalysisTask completed"
    rescue StandardError => e
      logger.error "Error in AdvancedAnalysisTask: #{e.message}"
      logger.error e.backtrace.join("\n")
      binding.pry # Breakpoint 7: If an error occurs
      raise
    end
  end
end
