#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class ExceptionAgent < WorkflowAgent
    def initialize
      logger.debug "Initialized ExceptionAgent"
      begin
        super("exception_handler", File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "exception_handler.yml"))
      rescue StandardError => e
        logger.error "#{e.message}"
      ensure
        Flowbots::UI.say(:error, "#{e}")
      end
    end

    def process_exception(classname, exception)
      exception_details = {
        classnme: classname,
        message: exception.message,
        # exception_code: exception.exception_code,
        # details: exception.details,
        backtrace: exception.backtrace&.join("\n")
      }

      prompt = generate_exception_prompt(exception_details)

      begin
        response = process(prompt)
        #TODO: send format_exception_report to notification
        format_exception_report(response, exception_details)
      rescue StandardError => e
        logger.error("exception in ExceptionAgent: #{e.message}")
        fallback_exception_report(exception_details)
      end
    end

    private

    def generate_exception_prompt(exception_details)
      <<~PROMPT
        Hey there! We've got a bit of a hiccup in our FlowBots system. Could you help me out by crafting a casual yet technically detailed exception report? Here's what we're dealing with:

        Class: #{exception_details[:classnme]}
        exception Type: #{exception_details[:exception_code]}
        Message: #{exception_details[:message]}
        Details: #{exception_details[:details]}

        If it helps, here's the technical backtrace:
        #{exception_details[:backtrace]}

        Could you whip up a report that's easy for our team to understand but still includes all the important technical details? Thanks a bunch!
      PROMPT
    end

    def format_exception_report(agent_response, exception_details)
      <<~REPORT
        🤖 FlowBot exception Report 🤖

        #{agent_response}

        If you need more information, please check the logs or contact the development team.
        exception Code: #{exception_details[:exception_code]}
      REPORT
    end

    def fallback_exception_report(exception_details)
      <<~REPORT
        🚨 FlowBot exception Report (Fallback) 🚨

        Oops! We encountered an exception, and we're having trouble generating a detailed report right now. Here's what we know:

        Class: #{exception_details[:classnme]}
        exception Type: #{exception_details[:exception_code]}
        Message: #{exception_details[:message]}

        What happened: #{exception_details[:details]}

        We're working on resolving this issue. In the meantime, you might want to:
        1. Check your internet connection
        2. Verify that all required services are running
        3. Try your request again in a few minutes

        If the problem persists, please contact the development team with this exception code: #{exception_details[:exception_code]}

        We apologize for any inconvenience!
      REPORT
    end
  end
end
