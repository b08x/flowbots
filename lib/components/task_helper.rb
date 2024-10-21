#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # Provides helper methods for tasks in the Flowbots workflow.
  module TaskHelper
    # Includes the TaskHelper module into the base class.
    #
    # @param base [Class] The base class to include the module into.
    #
    # @return [void]
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods for the TaskHelper module.
    module ClassMethods
      # Returns the name of the task class.
      #
      # @return [String] The name of the task class.
      def task_name
        self.name.split('::').last
      end
    end

    # Initializes a new TaskHelper instance.
    #
    # @param args [Array] The arguments passed to the initializer.
    #
    # @return [void]
    def initialize(*args)
      super
      @logger = Logging.logger[self.class.name]
    end

    # Executes the task logic.
    #
    # Logs the start and completion of the task, handles any errors,
    # and yields to the block if provided.
    #
    # @yield [void] The block to execute.
    #
    # @return [Object] The result of the block execution, or nil if no block is provided.
    def execute
      @logger.info("Starting execution of #{self.class.task_name}")
      result = nil
      begin
        result = yield if block_given?
        @logger.info("Successfully completed execution of #{self.class.task_name}")
      rescue StandardError => e
        handle_error(e)
      end
      result
    end

    private

    # Handles errors during task execution.
    #
    # Logs the error message and backtrace, and raises the error.
    #
    # @param error [StandardError] The error that occurred.
    #
    # @return [void]
    def handle_error(error)
      @logger.error("Error in #{self.class.task_name}: #{error.message}")
      @logger.error(error.backtrace.join("\n"))
      raise
    end
  end
end
