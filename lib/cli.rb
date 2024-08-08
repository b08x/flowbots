#!/usr/bin/env ruby
# frozen_string_literal: true

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
      pastel = Pastel.new

      workflows = Workflows.new

      selected_workflow = workflows.list_and_select

      return unless selected_workflow

      begin
        workflows.run(selected_workflow)
        say pastel.green("Workflow completed successfully")
      rescue Interrupt
        say pastel.yellow("Workflow interrupted by user")
      rescue FileNotFoundError => e
        say pastel.red(e.message)
      rescue StandardError => e
        ExceptionHandler.handle_exception(self.class.name, e)
      ensure
        Flowbots.shutdown
      end
    end

    desc "train_topic_model FOLDER", "Train a topic model using text files in the specified folder"
    def train_topic_model(folder)
      pastel = Pastel.new

      unless Dir.exist?(folder)
        say pastel.red("Folder not found: #{folder}")
        exit
      end

      say pastel.green("Training topic model using files in: #{folder}")

      begin
        workflow = TopicModelTrainerWorkflow.new(folder)
        workflow.run
        say pastel.green("Topic model training completed successfully")
      rescue StandardError => e
        ExceptionHandler.handle_exception(self.class.name, e)
      end
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
        ExceptionHandler.handle_exception(self.class.name, e)
      end
    end
  end
end
