#!/usr/bin/env ruby
# frozen_string_literal: true

require "pry"
require "pry-stack_explorer"
require "thor"
require "json"
require "redis"
require "yaml"
require "ruby-spacy"
require "nano-bots"
require "jongleur"

module Flowbots
  autoload :VERSION, "version"
  autoload :ThorExt, "thor_ext"
end

require "ohm"
require "ohm/contrib"

require "logging"

include Logging

# require "helper"
require "ui"

WORKFLOW_DIR = File.expand_path("workflows", __dir__)
TASK_DIR = File.expand_path("tasks", __dir__)
GRAMMAR_DIR = File.expand_path("grammars", __dir__)


require "workflows"
require "tasks"

CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/", __dir__)

# Configuration for Redis connection
REDIS_CONFIG = {
  host: "#{ENV.fetch('REDIS_HOST', nil)}",
  port: 6379,
  db: 15
}

# Define a class to manage Redis connection
class RedisConnection
  def initialize
    @redis = Redis.new(REDIS_CONFIG)
  end

  attr_reader :redis
end

# Orchestrator and Agent are core components of the Flowbots architecture.
require_relative "components/WorkflowOrchestrator"
require_relative "components/ExceptionHandler"

require_relative "components/OhmModels"
require_relative "components/FileLoader"

require_relative "processors/GrammarProcessor"
require_relative "processors/TextProcessor"
require_relative "processors/TextSegmentProcessor"
require_relative "processors/TextTokenizeProcessor"
require_relative "processors/NLPProcessor"
require_relative "processors/TopicModelProcessor"

begin
  Ohm.redis = Redic.new("redis://localhost:6379/0")
rescue Ohm::Error => e
  Flowbots::ExceptionHandler.handle_exception(e)
end

module Flowbots

  def self.shutdown
    # Perform any necessary cleanup
    Ohm.redis.quit
    stop_running_workflows
    logger.info "Flowbots shut down gracefully"
  end

  def self.stop_running_workflows
    WorkflowOrchestrator.stop_all
    logger.info "All workflows stopped"
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

# from Monadic-Chat, MonadicApp class:
# return true if we are inside a docker container
def in_container?
  File.file?("/.dockerenv")
end

IN_CONTAINER = in_container?

Flowbots::Workflows.load_workflows
Flowbots::Task.load_tasks

# UI provides user interface elements.
require "ui"

# Jongleur::WorkerTask is a class that defines a task to be executed by Jongleur.
class Jongleur::WorkerTask
  # Initialize a Redis connection.
  begin
    redis_connection = RedisConnection.new
    @@redis = redis_connection.redis
  rescue Redis::CannotConnectError => e
    puts "heeeey! Unable to connect to redis\n"
    exit
  end
end

# Display a message indicating that Flowbots has been initialized.
Flowbots::UI.say(:ok, "Flowbots initialized")

# Display a welcome message.
puts UIBox.info_box("Hey! It's Flowbots!")
sleep 1

print TTY::Cursor.clear_screen_up

require "cli"
