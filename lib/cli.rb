#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class provides a command-line interface (CLI) for interacting with the Flowbots application.
  class CLI < Thor
    # Extends the ThorExt::Start module to provide enhanced CLI behavior.
    extend ThorExt::Start

    # Defines whether the CLI should exit with a non-zero status code when an error occurs.
    #
    # @return [Boolean] True if the CLI should exit on errors, false otherwise.
    def self.exit_on_failure?
      true
    end

    # Maps aliases for commands.
    #
    # @return [void]
    map %w[-v --version] => "version"

    # Defines a description for the `version` command.
    #
    # @return [void]
    desc "version", "Display flowbots version", hide: true

    # Displays the Flowbots version and Ruby environment information.
    #
    # @return [void]
    def version
      say "flowbots/#{VERSION} #{RUBY_DESCRIPTION}"
    end

    # Defines a description for the `workflows` command.
    #
    # @return [void]
    desc "workflows", "List and select a workflow to run"

    # Lists available workflows, allows the user to select one, and runs it.
    #
    # @return [void]
    def workflows
      pastel = Pastel.new

      # Create a new Workflows instance.
      workflows = Workflows.new

      # List and select a workflow from the available options.
      selected_workflow = workflows.list_and_select

      # Exit if no workflow is selected.
      return unless selected_workflow

      # Run the selected workflow and handle potential errors.
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
        # Shut down Flowbots after the workflow execution.
        Flowbots.shutdown
      end
    end

    # Defines a description for the `train_topic_model` command.
    #
    # @return [void]
    desc "train_topic_model FOLDER", "Train a topic model using text files in the specified folder"

    # Trains a topic model using text files in the specified folder.
    #
    # @param folder [String] The path to the folder containing the text files.
    #
    # @return [void]
    def train_topic_model(folder)
      pastel = Pastel.new

      # Check if the specified folder exists.
      unless Dir.exist?(folder)
        say pastel.red("Folder not found: #{folder}")
        exit
      end

      # Display a message indicating the start of topic model training.
      say pastel.green("Training topic model using files in: #{folder}")

      # Train the topic model and handle potential errors.
      begin
        workflow = TopicModelTrainerWorkflow.new(folder)
        workflow.run
        say pastel.green("Topic model training completed successfully")
      rescue StandardError => e
        ExceptionHandler.handle_exception(self.class.name, e)
      end
    end

    # Defines a description for the `process_text` command.
    #
    # @return [void]
    desc "process_text FILE", "Process a text file using the text processing workflow"

    # Processes a text file using the text processing workflow.
    #
    # @param file [String] The path to the text file.
    #
    # @return [void]
    def process_text(file)
      pastel = Pastel.new

      # Check if the specified file exists.
      unless File.exist?(file)
        say pastel.red("File not found: #{file}")
        exit
      end

      # Display a message indicating the start of text processing.
      say pastel.green("Processing file: #{file}")

      # Process the text file and handle potential errors.
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
