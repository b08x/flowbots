#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class ErrorHandlerAgent < WorkflowAgent
    def initialize
      super("error_handler", File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "error_handler.yml"))
    end

    def process_error(error)
      error_details = {
        message: error.message,
        error_code: error.error_code,
        details: error.details,
        backtrace: error.backtrace&.join("\n")
      }

      prompt = generate_error_prompt(error_details)

      begin
        response = process(prompt)
        format_error_report(response, error_details)
      rescue StandardError => e
        Flowbots.logger.error("Error in ErrorHandlerAgent: #{e.message}")
        fallback_error_report(error_details)
      end
    end

    private

    def generate_error_prompt(error_details)
      <<~PROMPT
        Hey there! We've got a bit of a hiccup in our FlowBots system. Could you help me out by crafting a casual yet technically detailed error report? Here's what we're dealing with:

        Error Type: #{error_details[:error_code]}
        Message: #{error_details[:message]}
        Details: #{error_details[:details]}

        If it helps, here's the technical backtrace:
        #{error_details[:backtrace]}

        Could you whip up a report that's easy for our team to understand but still includes all the important technical details? Thanks a bunch!
      PROMPT
    end

    def format_error_report(agent_response, error_details)
      <<~REPORT
        🤖 FlowBot Error Report 🤖

        #{agent_response}

        If you need more information, please check the logs or contact the development team.
        Error Code: #{error_details[:error_code]}
      REPORT
    end

    def fallback_error_report(error_details)
      <<~REPORT
        🚨 FlowBot Error Report (Fallback) 🚨

        Oops! We encountered an error, and we're having trouble generating a detailed report right now. Here's what we know:

        Error Type: #{error_details[:error_code]}
        Message: #{error_details[:message]}

        What happened: #{error_details[:details]}

        We're working on resolving this issue. In the meantime, you might want to:
        1. Check your internet connection
        2. Verify that all required services are running
        3. Try your request again in a few minutes

        If the problem persists, please contact the development team with this error code: #{error_details[:error_code]}

        We apologize for any inconvenience!
      REPORT
    end
  end
end
