#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # Base class for all Flowbots errors.
  class FlowbotError < StandardError
    # @return [String] The error code.
    attr_reader :error_code
    # @return [Hash] Additional details about the error.
    attr_reader :details

    # Initializes a new FlowbotError.
    #
    # @param message [String] The error message.
    # @param error_code [String] The error code.
    # @param details [Hash] Additional details about the error.
    def initialize(message, error_code, details={})
      super(message)
      @error_code = error_code
      @details = details
    end
  end

  # Error raised when there is a problem with a workflow.
  class WorkflowError < FlowbotError; end

  # Error raised when there is a problem with an agent.
  class AgentError < FlowbotError; end

  # Error raised when there is a problem with the configuration.
  class ConfigurationError < FlowbotError; end

  # Error raised when there is a problem with an API call.
  class APIError < FlowbotError; end

  class FileNotFoundError < StandardError; end

  class FileObjectError < StandardError; end
end
