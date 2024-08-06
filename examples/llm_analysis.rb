#!/usr/bin/env ruby
# frozen_string_literal: true

class LlmAnalysis < Flowbots::Task
  def execute
    Flowbots::UI.info "Starting LLMAnalysisTask"

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
