#!/usr/bin/env ruby
# frozen_string_literal: true

class Task < Ohm::Model
  # Defines the attributes of a Task model.
  attribute :name
  attribute :status
  attribute :result
  attribute :start_time
  attribute :end_time

  # Defines indexes for efficient retrieval of tasks.
  index :name
  index :status
end

module Flowbots
  # This module encapsulates tasks used in Flowbots workflows.
  class Task
    # Initializes a new Task instance.
    #
    # @param options [Hash] A hash of options for the task.
    #
    # @return [void]
    def initialize(options={})
      @options = options
    end

    # Executes the task.
    #
    # This method must be implemented in subclasses.
    #
    # @return [void]
    # @raise [NotImplementedError] If the method is not implemented in a subclass.
    def execute
      raise NotImplementedError, "#{self.class.name}#execute must be implemented in subclass"
    end

    # Loads all task files from the TASK_DIR directory.
    #
    # @return [void]
    def self.load_tasks
      Dir.glob(File.join(TASK_DIR, "*.rb")).each do |file|
        require_relative file
        logger.debug "Loaded task file: #{file}"
      end
    end
  end

  # Custom error class for task not found.
  class TaskNotFoundError < StandardError; end
end
