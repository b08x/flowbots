#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class BaseTask < Jongleur::WorkerTask
    attr_reader :ohm_task

    def initialize(workflow, sourcefile)
      @ohm_task = OhmTask.create(workflow, sourcefile)
    end

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

    def perform
      raise NotImplementedError, "#{self.class.name}#perform must be implemented in subclass"
    end
  end
end
