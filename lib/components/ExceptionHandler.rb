#!/usr/bin/env ruby
# frozen_string_literal: true

lib_dir = File.expand_path(File.join(__dir__, "..", "lib"))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require_relative "ExceptionAgent"

module Flowbots
  class ExceptionHandler
    class << self
      def handle_exception(classname = nil, exception)
        exception_handler = ExceptionAgent.new

        begin
          report = exception_handler.process_exception(exception)
        rescue APIError => api_exception
          logger.error("API exception in ExceptionAgent: #{api_exception.message}")
          report = exception_handler.fallback_exception_report(exception)
        end

        log_exception(exception)
        notify_exception(report)

        report
      end

      def log_exception(exception)
        logger.error("FlowBot exception: #{exception.message}")
        logger.error(exception.backtrace.join("\n")) if exception.backtrace
      end

      def notify_exception(report)
        # Implement notification logic here
        # This could be sending an email, posting to a Slack channel, etc.
        Flowbots::NattyUI.exception report
        logger.warn "exception Notification:"
        logger.warn report
      end
    end
  end
end
