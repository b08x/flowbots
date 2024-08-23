#!/usr/bin/env ruby
# frozen_string_literal: true

# Standard library
require "json"
require "yaml"

# Third-party gems
require "jongleur"
require "nano-bots"
require "ohm"
require "ohm/contrib"
require "parallel"
require "pry"
require "pry-stack_explorer"
require "redis"
require "ruby-spacy"
require "scalpel"
require "thor"
require "treetop"

# Internal requires
require_relative "flowbots/errors"
require_relative "version"
require_relative "thor_ext"
require_relative "logging"

include Logging

require_relative "components/WorkflowOrchestrator"
require_relative "components/ExceptionHandler"
require_relative "components/InputRetrieval"
require_relative "components/RedisKeys"
require_relative "components/OhmModels"
require_relative "components/FileLoader"
require_relative "processors/GrammarProcessor"
require_relative "processors/TextProcessor"
require_relative "processors/TextSegmentProcessor"
require_relative "processors/TextTokenizeProcessor"
require_relative "processors/NLPProcessor"
require_relative "processors/TextTaggerProcessor"
require_relative "processors/TopicModelProcessor"

require_relative "ui"
require_relative "workflows"
require_relative "tasks"

autoload :VERSION, "version"
autoload :ThorExt, "thor_ext"

module Flowbots
  class << self
    attr_reader :redis

    def setup
      setup_redis
      load_components
      ensure_indices
    end

    def setup_redis
      redis_url = ENV['REDIS_URL'] || "redis://localhost:6379/15"
      Ohm.redis = Redic.new(redis_url)
      @redis = Redis.new(url: redis_url)
      Jongleur::WorkerTask.class_variable_set(:@@redis, @redis)
    end

    def load_components
      # Load TaskHelper first
      require_relative 'components/task_helper'

      # Then load all other components, tasks, workflows, etc.
      Dir[File.join(__dir__, 'components', '*.rb')].each { |file| require file unless file.end_with?('task_helper.rb') }
      Dir[File.join(__dir__, 'tasks', '*.rb')].each { |file| require file }
      Dir[File.join(__dir__, 'workflows', '*.rb')].each { |file| require file }
      Dir[File.join(__dir__, 'processors', '*.rb')].each { |file| require file }
    end

    def ensure_indices
      [Sourcefile, Workflow].each do |model|
        model.ensure_indices
      end
    end

    def verify_indices
      [Sourcefile, Workflow].each do |model|
        model.verify_indices
      end
    end

    def shutdown
      Ohm.redis.quit
      @redis.quit
      stop_running_workflows
      logger.info "Flowbots shut down gracefully"
    end

    def stop_running_workflows
      WorkflowOrchestrator.cleanup
      logger.info "All workflows stopped"
    end
  end
end

# Constants
WORKFLOW_DIR = File.expand_path("workflows", __dir__)
TASK_DIR = File.expand_path("tasks", __dir__)
GRAMMAR_DIR = File.expand_path("grammars", __dir__)
CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/", __dir__)

# Define a class to manage Redis connection
class RedisConnection
  # Redis Configuration
  REDIS_CONFIG = {
    host: ENV.fetch("REDIS_HOST", "localhost"),
    port: 6379,
    db: 15
  }.freeze

  def initialize
    @redis = Redis.new(REDIS_CONFIG)
  end

  attr_reader :redis
end

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

module Flowbots
  IN_CONTAINER = File.file?("/.dockerenv")
  BATCH = false

  class << self
    def initialize
      setup_redis
      load_components
      setup_ui
    end

    def shutdown
      Ohm.redis.quit
      stop_running_workflows
      logger.info "Flowbots shut down gracefully"
    end

    private

    def setup_redis
      Ohm.redis = Redic.new("redis://localhost:6379/0")
    rescue Ohm::Error => e
      ExceptionHandler.handle_exception(e)
    end

    def load_components
      Workflows.load_workflows
      Task.load_tasks
    end

    def setup_ui
      CLI::UI::StdoutRouter.enable
    end

    def stop_running_workflows
      logger.info "All workflows stopped"
    end
  end
end

# Initialize Flowbots
Flowbots.initialize

# Display initialization message
UI.say(:ok, "Flowbots initialized")
puts UI::Box.info_box("Hey! It's Flowbots!")

sleep 1

require_relative "cli"
