#!/usr/bin/env ruby
# frozen_string_literal: true

require "jongleur"
require "json"
require "parallel"
require "pry"
require "pry-stack_explorer"
require "redis"
require "ruby-spacy"
require "thor"
require "treetop"
require "yaml"

module Flowbots
  autoload :VERSION, "version"
  autoload :ThorExt, "thor_ext"
end

require_relative "utils/errors"

require "logging"

include Logging

# require "helper"
require "ui"

# from Monadic-Chat, MonadicApp class:
# return true if we are inside a docker container
def in_container?
  File.file?("/.dockerenv")
end

IN_CONTAINER = in_container?

WORKFLOW_DIR = File.expand_path("workflows", __dir__)
TASK_DIR = File.expand_path("tasks", __dir__)
GRAMMAR_DIR = File.expand_path("grammars", __dir__)
CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/", __dir__)

# Orchestrator and Agent are core components of the Flowbots architecture.
require_relative "components/WorkflowOrchestrator"
require_relative "components/WorkflowAgent"

require_relative "components/ExceptionHandler"
require_relative "components/ExceptionAgent"

require_relative "components/OhmModels"
require_relative "components/FileLoader"

require_relative "processors/GrammarProcessor"
require_relative "processors/TextProcessor"
require_relative "processors/TextSegmentProcessor"
require_relative "processors/TextTokenizeProcessor"
require_relative "processors/NLPProcessor"
require_relative "processors/TopicModelProcessor"

module Flowbots
  def self.init_redis
    setup_redis
    ensure_indices
  end

  def self.shutdown
    # Perform any necessary cleanup
    Ohm.redis.quit
    stop_running_workflows
    logger.info "Flowbots shut down gracefully"
  end

  def self.stop_running_workflows
    WorkflowOrchestrator.cleanup
    logger.info "All workflows stopped"
  end

  def self.setup_redis
    Ohm.redis = Redic.new(
      "redis://#{ENV.fetch(
        'REDIS_HOST',
        'localhost'
      )}:#{ENV.fetch(
        'REDIS_PORT',
        6379
      )}/#{ENV.fetch('REDIS_DB', 15)}"
    )
  end

  def self.ensure_indices
    [Sourcefile, Workflow].each do |model|
      model.ensure_indices
    end
  end

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

  # Add more specific error classes as needed
end

Flowbots.init_redis

require "workflows"
require "tasks"

Flowbots::Workflows.load_workflows
Flowbots::Task.load_tasks

# Display a message indicating that Flowbots has been initialized.
Flowbots::UI.say(:ok, "Flowbots initialized")

# Display a welcome message.
puts UIBox.info_box("Hey! It's Flowbots!")
sleep 1

print TTY::Cursor.clear_screen_up

require "cli"
