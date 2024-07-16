#!/usr/bin/env ruby
# frozen_string_literal: true

require "pry"
require "pry-stack_explorer"

# Thor is a library for creating command-line interfaces.
require "thor"

# The Flowbots module encapsulates the core functionality of the application.
module Flowbots
  # The VERSION constant holds the current version of Flowbots.
  autoload :VERSION, "version"
  # The ThorExt module provides extensions to the Thor library.
  autoload :ThorExt, "thor_ext"
end

# Helper functions and utilities.
require "helper"

# Cogger is a logging library.
require "cogger"

# JSON, Redis, and YAML are used for data serialization and storage.
require "json"
require "redis"
require "yaml"

# Ruby-Spacy is a library for natural language processing.
require "ruby-spacy"
# Nano-bots is a library for building workflow components.
require "nano-bots"
# Jongleur is a library for managing asynchronous tasks.
require "jongleur"

# The CARTRIDGE_DIR constant defines the path to the directory containing workflow cartridges.
CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/", __dir__)
# The WORKFLOW_DIR constant defines the path to the directory containing workflow definitions.
WORKFLOW_DIR = File.expand_path("../workflows/", __dir__)

# Orchestrator and Agent are core components of the Flowbots architecture.
require_relative "components/WorkflowOrchestrator"
require_relative "components/WorkflowAgent"

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


# from Monadic-Chat, MonadicApp class:
# return true if we are inside a docker container
def in_container?
  File.file?("/.dockerenv")
end

IN_CONTAINER = in_container?

# Load workflows
def load_workflow_files
  workflows_to_load = {}
  base_workflow_dir = File.expand_path("../workflows/", __dir__)
  user_workflow_dir = if IN_CONTAINER
                        "/data/app/workflows"
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

# UI provides user interface elements.
require "ui"

# Jongleur::WorkerTask is a class that defines a task to be executed by Jongleur.
class Jongleur::WorkerTask
  # Initialize a Redis connection.
  begin
    @@redis = Redis.new(host: "localhost", port: 6379, db: 15)
  rescue Redis::CannotConnectError => e
    ErrorManager.handle_error(self.class.name, e)
    exit
  end
end

# Display a message indicating that Flowbots has been initialized.
Flowbots::UI.say(:ok, "Flowbots initialized")

# Display a welcome message.
puts UIBox.info_box("Hey! It's FlowBots!")
sleep 1

require "cli"
