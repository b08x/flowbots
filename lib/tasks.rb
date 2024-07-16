#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class Task < Jongleur::WorkerTask
    include Logging

    def initialize(options={})
      @options = options
    end

    def execute
      raise NotImplementedError, "#{self.class.name}#execute must be implemented in subclass"
    end

    def self.get_task(task_name)
      task_class_name = task_name.split("_").map(&:capitalize).join
      task_class = Flowbots.const_get(task_class_name)
      task_class.new
    rescue NameError
      logger.error "Task not found: #{task_name}"
      raise TaskNotFoundError, "Task not found: #{task_name}"
    end
  end

  class TaskNotFoundError < StandardError; end
end
