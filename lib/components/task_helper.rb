#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  module TaskHelper
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def task_name
        self.name.split('::').last
      end
    end

    def initialize(*args)
      super
      @logger = Logging.logger[self.class.name]
    end

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

    def handle_error(error)
      @logger.error("Error in #{self.class.task_name}: #{error.message}")
      @logger.error(error.backtrace.join("\n"))
      raise
    end
  end
end
