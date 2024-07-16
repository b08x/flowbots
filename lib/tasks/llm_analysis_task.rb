#!/usr/bin/env ruby
# frozen_string_literal: true

class LlmAnalysisTask < Jongleur::WorkerTask
  include Logging

  def execute
    logger.info "Starting LLMAnalysisTask"

    begin
      agent = WorkflowAgent.new(
        "advanced_analysis",
        File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "assistants/agileBloomMini.yml")
      )

      logger.debug "Created WorkflowAgent instance"

      agent.load_state
      logger.debug "Loaded agent state"

      processed_text = retrieve_processed_text
      nlp_result = retrieve_nlp_result
      topic_result = retrieve_topic_result

      input = format_input(processed_text, nlp_result, topic_result)
      analysis_result = agent.process(input)

      logger.debug "Agent processing completed"

      agent.save_state
      logger.debug "Saved agent state"

      store_analysis_result(analysis_result)
      logger.debug "Stored analysis result"

      logger.info "LLMAnalysisTask completed"
    rescue StandardError => e
      logger.error "Error in LLMAnalysisTask: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise
    end
  end

  private

  def retrieve_processed_text
    JSON.parse(@@redis.get("processed_text"))
  end

  def retrieve_nlp_result
    JSON.parse(@@redis.get("nlp_result"))
  end

  def retrieve_topic_result
    JSON.parse(@@redis.get("topic_result"))
  end

  def format_input(processed_text, nlp_result, topic_result)
    "Processed Text: #{processed_text}\n\nNLP Analysis: #{nlp_result}\n\nTopic Analysis: #{topic_result}"
  end

  def store_analysis_result(result)
    @@redis.set("analysis_result", result.to_json)
  end
end
