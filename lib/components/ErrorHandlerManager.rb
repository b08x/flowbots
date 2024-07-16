#!/usr/bin/env ruby
# frozen_string_literal: true


module Flowbots
  class ErrorHandlerManager
    class << self
      def handle_error(error)
        error_handler = ErrorHandlerAgent.new

        begin
          report = error_handler.process_error(error)
        rescue APIError => api_error
          logger.error("API Error in ErrorHandlerAgent: #{api_error.message}")
          report = error_handler.fallback_error_report(error)
        end

        log_error(error)
        notify_error(report)

        report
      end

      def log_error(error)
        logger.error("FlowBot Error: #{error.message}")
        logger.error(error.backtrace.join("\n")) if error.backtrace
      end

      def notify_error(report)
        # Implement notification logic here
        # This could be sending an email, posting to a Slack channel, etc.
        logger.warn "Error Notification:"
        logger.warn report
      end
    end
  end
end
