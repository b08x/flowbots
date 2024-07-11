#!/usr/bin/env ruby
# frozen_string_literal: true

require "pry"
require "pry-stack_explorer"

require "pastel"
require "thor"
require "tty-box"
require "tty-prompt"
require "tty-table"

module Flowbots
  autoload :VERSION, "version"
  autoload :ThorExt, "thor_ext"
end

require "helper"
require "cogger"

require "json"
require "redis"
require "yaml"

require "ruby-spacy"
require "nano-bots"
require "jongleur"

CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/", __dir__)
WORKFLOW_DIR = File.expand_path("../lib/workflows/", __dir__)

require_relative "components/orchestrator"
require_relative "components/agent"

require_relative "workflows/text_processing_workflow"

require "ui"

class Jongleur::WorkerTask
  begin
    @@redis = Redis.new(host: "localhost", port: 6379, db: 15)
  rescue Redis::CannotConnectError => e
    handle_error(self.class.name, e)
    exit
  end
end

Flowbots::UI.say(:ok, "Flowbots initialized")

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    def self.exit_on_failure?
      true
    end

    map %w[-v --version] => "version"

    desc "version", "Display flowbots version", hide: true
    def version
      say "flowbots/#{VERSION} #{RUBY_DESCRIPTION}"
    end

    desc "workflows", "List and select a workflow to run"
    def workflows
      prompt = TTY::Prompt.new
      pastel = Pastel.new

      workflows = Dir.glob(File.join(WORKFLOW_DIR, "*.rb")).map do |file|
        name = File.basename(file, ".rb")
        description = extract_workflow_description(file)
        [name, description]
      end

      if workflows.empty?
        say pastel.red("No workflows found in #{WORKFLOW_DIR}")
        exit
      end

      table = TTY::Table.new(
        header: [pastel.cyan("Workflow"), pastel.cyan("Description")],
        rows: workflows
      )

      puts table.render(:unicode, padding: [0, 1])

      workflow_names = workflows.map { |w| w[0] }
      selected = prompt.select("Choose a workflow to run:", workflow_names)

      run_workflow(selected)
    end

    desc "process_text FILE", "Process a text file using the text processing workflow"
    def process_text(file)
      pastel = Pastel.new

      unless File.exist?(file)
        say pastel.red("File not found: #{file}")
        exit
      end

      say pastel.green("Processing file: #{file}")

      begin
        workflow = TextProcessingWorkflow.new(file)
        workflow.run
        say pastel.green("Text processing completed successfully")
      rescue StandardError => e
        say pastel.red("Error processing text: #{e.message}")
        say pastel.red(e.backtrace.join("\n"))
      end
    end

    private

    def extract_workflow_description(file)
      first_line = File.open(file, &:readline).strip
      first_line.start_with?("# Description:") ? first_line[14..-1] : "No description available"
    end

    def run_workflow(workflow_name)
      pastel = Pastel.new
      workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

      unless File.exist?(workflow_file)
        say pastel.red("Workflow file not found: #{workflow_file}")
        exit
      end

      say pastel.green("Running workflow: #{workflow_name}")
      load workflow_file

      # Assume the workflow file defines a class named after the file
      workflow_class = Object.const_get(workflow_name.split("_").map(&:capitalize).join)
      workflow = workflow_class.new
      workflow.run
    rescue StandardError => e
      say pastel.red("Error running workflow: #{e.message}")
      say pastel.red(e.backtrace.join("\n"))
    end
  end
end
