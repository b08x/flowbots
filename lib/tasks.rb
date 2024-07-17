#!/usr/bin/env ruby
# frozen_string_literal: true

class Task < Ohm::Model
  attribute :name
  attribute :status
  attribute :result
  attribute :start_time
  attribute :end_time
  index :name
  index :status
end

module Flowbots
  class Task

    def initialize(options={})
      @options = options
    end

    def execute
      raise NotImplementedError, "#{self.class.name}#execute must be implemented in subclass"
    end

    def self.load_tasks
      Dir.glob(File.join(TASK_DIR, '*.rb')).each do |file|
        require_relative file
        logger.debug "Loaded task file: #{file}"
      end
    end

  end

  class TaskNotFoundError < StandardError; end
end
