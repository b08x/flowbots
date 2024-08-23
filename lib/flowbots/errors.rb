#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class FlowbotError < StandardError
    attr_reader :error_code, :details

    def initialize(message, error_code, details={})
      super(message)
      @error_code = error_code
      @details = details
    end
  end

  class WorkflowError < FlowbotError; end
  class AgentError < FlowbotError; end
  class ConfigurationError < FlowbotError; end
  class APIError < FlowbotError; end
end
