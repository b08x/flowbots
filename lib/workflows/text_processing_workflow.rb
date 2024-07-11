#!/usr/bin/env ruby
# frozen_string_literal: true

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
    @logger.level = Logger::INFO
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
    @orchestrator.add_agent("advanced_analysis", "assistants/agileBloomMini.yml", author: "@b08x")

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
    # binding.pry # Breakpoint 1: After text processing
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
    logger.level = Logger::INFO
    logger.info "Starting TopicModelingTask"

    begin
      raw_text = @@redis.get("processed_text")
      logger.debug "Retrieved processed text from Redis (length): #{raw_text.length}"

      processed_text = JSON.parse(raw_text)
      logger.debug "Parsed processed text (length): #{processed_text.length}"

      topic_modeler = TopicModelManager.new(File.join(ENV["HOME"], "Workspace", "flowbots", "models", "topic_model.lda.bin"))
      logger.debug "Created TopicModelManager instance"

      # Train the model if it's not already trained
      unless topic_modeler.model_trained?
        logger.info "Model is not trained. Training now..."
        begin
          topic_modeler.train_model(processed_text)
          logger.info "Model training completed"
        rescue StandardError => e
          logger.error "Error during model training: #{e.message}"
          raise
        end
      else
        logger.info "Model is already trained"
      end

      logger.debug "Inferring topics"
      begin
        topics_info = topic_modeler.infer_topics(processed_text.join(" "), 5)
        logger.info "Most probable topic: #{topics_info[:most_probable_topic]}"
        logger.info "Top words: #{topics_info[:top_words].map { |word, prob| word }.join(', ')}"
        logger.debug "Full topic distribution: #{topics_info[:topic_distribution]}"

        @@redis.set("topics_info", topics_info.to_json)
        logger.debug "Stored topics info in Redis"
      rescue StandardError => e
        logger.error "Error during topic inference: #{e.message}"
        raise
      end

      logger.info "TopicModelingTask completed"
    rescue StandardError => e
      logger.error "Error in TopicModelingTask: #{e.message}"
      logger.error e.backtrace.join("\n")
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
      agent = WorkflowAgent.new("advanced_analysis", File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "assistants/agileBloomMini.yml"))

      logger.debug "Created WorkflowAgent instance"

      agent.load_state
      logger.debug "Loaded agent state"

      processed_text = JSON.parse(@@redis.get("processed_text"))
      topics = JSON.parse(@@redis.get("topics"))
      # binding.pry # Breakpoint 5: After retrieving processed text and topics
      logger.debug "Retrieved processed text and topics from Redis"

      logger.debug "Processing with agent"
      analysis_result = agent.process("Given the following text and topics: #{processed_text.join(' ')}. Topics: #{topics}\ngenerate a short narrative")
      # binding.pry # Breakpoint 6: After agent processing
      logger.debug "Agent processing completed"

      agent.save_state
      logger.debug "Saved agent state"

      @@redis.set("analysis_result", analysis_result.to_json)
      logger.debug "Stored analysis result in Redis"

      logger.info "AdvancedAnalysisTask completed"
    rescue StandardError => e
      logger.error "Error in AdvancedAnalysisTask: #{e.message}"
      logger.error e.backtrace.join("\n")
      # binding.pry # Breakpoint 7: If an error occurs
      raise
    end
  end
end
