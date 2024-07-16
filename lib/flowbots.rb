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

require "helper"
require "ui"

require "tasks"

CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/", __dir__)
WORKFLOW_DIR = File.expand_path("../workflows/", __dir__)
TASK_DIR = File.expand_path("../tasks", __FILE__)

# Configuration for Redis connection
REDIS_CONFIG = {
  host: "#{ENV['REDIS_HOST']}",
  port: 6379,
  db: 15
}

# Define a class to manage Redis connection
class RedisConnection
  def initialize
    @redis = Redis.new(REDIS_CONFIG)
  end

  def redis
    @redis
  end
end

# Orchestrator and Agent are core components of the Flowbots architecture.
require_relative "components/WorkflowOrchestrator"
# require_relative "components/WorkflowAgent"

# require_relative "components/ExceptionAgent"
require_relative "components/ExceptionHandler"

require_relative "processors/TextProcessor"
require_relative "processors/NLPProcessor"
require_relative "processors/TopicModelProcessor"

begin
  Ohm.redis = Redic.new("redis://localhost:6379/0")
rescue Ohm::Error => e
  Flowbots::ExceptionHandler.handle_exception(e)
end


module Flowbots
  class FlowbotError < StandardError
    attr_reader :error_code, :details

    def initialize(message, error_code, details = {})
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

# Load workflows
def load_workflow_files
  workflows_to_load = {}
  base_workflow_dir = File.expand_path("../lib/workflows/", __dir__)
  user_workflow_dir = if IN_CONTAINER
                        "/data/app/lib/workflows"
                      else
                        File.expand_path("../workflows/custom", __dir__)
                      end

  Dir["#{File.join(base_workflow_dir, '**') + File::SEPARATOR}*.rb"].sort.each do |file|
    workflows_to_load[File.basename(file)] = file
  end

  if Dir.exist?(user_workflow_dir)
    Dir["#{File.join(user_workflow_dir, '**') + File::SEPARATOR}*.rb"].sort.each do |file|
      workflows_to_load[File.basename(file)] = file
    end
  end

  workflows_to_load.each do |_workflow_name, file|
    require_relative file
  end
end

load_workflow_files

def load_tasks
  Dir.glob(File.join(TASK_DIR, '*.rb')).each do |file|
    require_relative file
    logger.debug "Loaded task file: #{file}"
  end
end

# Load tasks
load_tasks

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

require "cli"
