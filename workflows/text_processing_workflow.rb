#!/usr/bin/env ruby
# frozen_string_literal: true

# text_processing_workflow.rb
# Description: A text processing workflow that processes a text file, segments it, and performs topic modeling

require_relative "../lib/modules/Segmentation"
require_relative "../lib/modules/TopicModeling"
require_relative "../lib/modules/TextProcessor"

require_relative "../lib/components/TopicModelManager"



class TextProcessingWorkflow

  def self.description
    description = "This is a test."
  end


  def initialize(input_file_path)
    # logger = Logger.new(STDOUT)
    # logger.level = Logger::INFO
    @orchestrator = WorkflowOrchestrator.new
    @text_processor = TextProcessor.instance
    @input_file_path = input_file_path
    @topic_modeling_task = TopicModeling::TopicModelingTask.new(
      model_path: File.join(ENV.fetch("HOME", nil), "Workspace", "flowbots", "models", "topic_model.lda.bin"),
      redis_client: Jongleur::WorkerTask.class_variable_get(:@@redis)
    )
  end

  def run
    FlowBots::NattyUI.info "Starting Text Processing Workflow"
    setup_workflow
    process_input
    run_topic_modeling
    run_workflow
    display_results
    logger.info "Text Processing Workflow completed"
  end

  private

  def setup_workflow
    logger.debug "Setting up workflow"
    @orchestrator.add_agent("advanced_analysis", "assistants/agileBloomMini.yml", author: "@b08x")

    workflow_graph = {
      LLMAnalysisTask: []
    }

    @orchestrator.define_workflow(workflow_graph)
    logger.debug "Workflow setup completed"
  end

  def process_input
    logger.debug "Processing input file: #{@input_file_path}"
    text = File.read(@input_file_path)
    processed_text = @text_processor.process(text)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("processed_text", processed_text.to_json)
    logger.debug "Input processing completed"
  end

  def run_topic_modeling
    logger.info "Running Topic Modeling"
    @topic_modeling_task.execute
    logger.info "Topic Modeling completed"
  end

  def run_workflow
    logger.info "Running LLM Analysis workflow"
    @orchestrator.run_workflow
  end

  def display_results
    raw_text = File.read(@input_file_path)
    processed_text = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
    analysis_result = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))

    puts UIBox.comparison_box("yer mother was a whore", "But she had a sense of humor about it at least", title1: "Raw Text", title2: "Processed Text")
    puts UIBox.eval_result_box(analysis_result, title: "LLM Analysis Result")
  end
end

class LLMAnalysisTask < Jongleur::WorkerTask
  def execute
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    logger.info "Starting LLMAnalysisTask"

    begin
      agent = WorkflowAgent.new(
        "advanced_analysis",
        File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "assistants/agileBloomMini.yml")
      )

      logger.debug "Created WorkflowAgent instance"

      agent.load_state
      logger.debug "Loaded agent state"

      processed_text = JSON.parse(@@redis.get("processed_text"))
      topics = JSON.parse(@@redis.get("topics"))
      # binding.pry # Breakpoint 5: After retrieving processed text and topics
      logger.debug "Retrieved processed text and topics from Redis"

      logger.debug "Processing with agent"

      begin
        analysis_result = agent.process("#{processed_text.join(' ')}\nTopics: #{topics}")
      rescue Faraday::ForbiddenError => e
        logger.fatal e.message.to_s
        logger.fatal e.backtrace.join("\n").to_s
      end
      # binding.pry # Breakpoint 6: After agent processing
      logger.debug "Agent processing completed"

      agent.save_state
      logger.debug "Saved agent state"

      @@redis.set("analysis_result", analysis_result.to_json)
      logger.debug "Stored analysis result in Redis"

      logger.info "LLMAnalysisTask completed"
    rescue StandardError => e
      logger.error "Error in LLMAnalysisTask: #{e.message}"
      logger.error e.backtrace.join("\n")
      # binding.pry if PRYDEBUG # Breakpoint 7: If an error occurs
      raise
    end
  end
end
