#!/usr/bin/env ruby
# frozen_string_literal: true

require "ohm"
require "ohm/contrib"

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

require_relative "utils/errors"
require "logging"
include Logging
require "ui"

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

# from Monadic-Chat, MonadicApp class:
# return true if we are inside a docker container
def in_container?
  File.file?("/.dockerenv")
end

IN_CONTAINER = in_container?

# Setup Flowbots
Flowbots.setup

# Error classes
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

# Display initialization message
Flowbots::UI.say(:ok, "Flowbots initialized")

# Display welcome message
puts UIBox.info_box("Hey! It's Flowbots!")
sleep 1

print TTY::Cursor.clear_screen_up

require_relative "cli"
