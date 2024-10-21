#!/usr/bin/env ruby
# frozen_string_literal: true

# This module defines the base class for all tasks in the Flowbots workflow.
module Flowbots
  # The base class for all tasks in the Flowbots workflow.
  #
  # Provides a common framework for task execution, status tracking, and error handling.
  class BaseTask < Jongleur::WorkerTask
    # The OhmTask object associated with this task.
    #
    # @return [OhmTask] The OhmTask object.
    attr_reader :ohm_task

    # Initializes a new BaseTask instance.
    #
    # @param workflow [Workflow] The workflow object associated with this task.
    # @param sourcefile [Sourcefile] The source file object associated with this task.
    def initialize(workflow, sourcefile)
      @ohm_task = OhmTask.create(workflow, sourcefile)
    end

    # Executes the task.
    #
    # Updates the task status to "running", performs the task logic,
    # updates the task status based on the result, and handles any errors.
    #
    # @return [void]
    def execute
      @ohm_task.update_status("running")
      begin
        result = perform
        @ohm_task.update_status("completed", result)
      rescue StandardError => e
        @ohm_task.update_status("failed", e.message)
        raise
      end
    end

    # Performs the task logic.
    #
    # This method must be implemented in subclasses to define the specific
    # actions performed by the task.
    #
    # @return [Object] The result of the task execution.
    def perform
      raise NotImplementedError, "#{self.class.name}#perform must be implemented in subclass"
    end
  end
end
