#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "components/ErrorHandlerAgent"
require_relative "components/ErrorHandlerManager"


module Flowbots
  class FlowBotError < StandardError
    attr_reader :error_code, :details

    def initialize(message, error_code, details = {})
      super(message)
      @error_code = error_code
      @details = details
    end
  end

  class WorkflowError < FlowBotError; end
  class AgentError < FlowBotError; end
  class ConfigurationError < FlowBotError; end
  class APIError < FlowBotError; end
  # Add more specific error classes as needed
end
