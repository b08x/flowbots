#!/usr/bin/env ruby
# frozen_string_literal: true

lib_dir = File.expand_path(File.join(__dir__, "..", "lib"))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require_relative "ExceptionAgent"

module Flowbots
  # This class handles exceptions in the Flowbots application.
  class ExceptionHandler
    # Class methods for handling exceptions.
    class << self
      # Handles an exception by generating a report and notifying relevant parties.
      #
      # @param classname [String] The name of the class where the exception occurred.
      # @param exception [Exception] The exception object.
      #
      # @return [String] The formatted exception report.
      def handle_exception(classname=nil, exception)
        exception_handler = ExceptionAgent.new

        begin
          report = exception_handler.process_exception(classname, exception)
        rescue APIError => e
          logger.error("API exception in ExceptionAgent: #{e.message}")
          report = exception_handler.fallback_exception_report(classname, exception)
        end

        log_exception(exception)
        notify_exception(report)

        report
      end

      # Logs an exception to the application's logger.
      #
      # @param exception [Exception] The exception object.
      #
      # @return [void]
      def log_exception(exception)
        logger.error("FlowBot exception: #{exception.message}")
        logger.error(exception.backtrace.join("\n")) if exception.backtrace
      end

      # Notifies relevant parties about an exception.
      #
      # @param report [String] The formatted exception report.
      #
      # @return [void]
      def notify_exception(report)
        # Implement notification logic here
        # This could be sending an email, posting to a Slack channel, etc.
        Flowbots::UI.exception report
        logger.warn "Exception Notification:"
        logger.warn report
        logger.info "A detailed Markdown report has been generated in the exception_reports directory."
      end
    end
  end
end
