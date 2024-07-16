#!/usr/bin/env ruby
# frozen_string_literal: true

# The Flowbots::CLI class defines the command-line interface for Flowbots.
module Flowbots
  class CLI < Thor
    # Extend the CLI class with the ThorExt::Start module.
    extend ThorExt::Start

    # Set the exit_on_failure? flag to true, indicating that the CLI should exit on failure.
    def self.exit_on_failure?
      true
    end

    # Map the -v and --version options to the version command.
    map %w[-v --version] => "version"

    # Define the version command.
    desc "version", "Display flowbots version", hide: true
    # Display the Flowbots version.
    def version
      say "flowbots/#{VERSION} #{RUBY_DESCRIPTION}"
    end

    # Define the workflows command.
    desc "workflows", "List and select a workflow to run"
    # List and select a workflow to run.
    def workflows
      # Create a TTY::Prompt object for user interaction.
      prompt = TTY::Prompt.new
      # Create a Pastel object for colored output.
      pastel = Pastel.new

      # Get a list of workflow files.
      workflows = Dir.glob(File.join(WORKFLOW_DIR, "*.rb")).map do |file|
        # Extract the workflow name from the file name.
        name = File.basename(file, ".rb")
        # Extract the workflow description from the file.
        description = extract_workflow_description(file)
        # Return an array containing the workflow name and description.
        [name, description]
      end

      # If no workflows are found, display an error message and exit.
      if workflows.empty?
        say pastel.red("No workflows found in #{WORKFLOW_DIR}")
        exit
      end

      # Create a TTY::Table object to display the list of workflows.
      table = TTY::Table.new(
        header: [pastel.cyan("Workflow"), pastel.cyan("Description")],
        rows: workflows
      )

      # Render the table.
      puts table.render(:unicode, padding: [0, 1])

      # Get a list of workflow names.
      workflow_names = workflows.map { |w| w[0] }
      # Prompt the user to select a workflow.
      selected = prompt.select("Choose a workflow to run:", workflow_names)
      # Run the selected workflow.
      run_workflow(selected)
    end

    # Define the process_text command.
    desc "process_text FILE", "Process a text file using the text processing workflow"
    # Process a text file using the text processing workflow.
    def process_text(file)
      # Create a Pastel object for colored output.
      pastel = Pastel.new

      # Check if the file exists.
      unless File.exist?(file)
        say pastel.red("File not found: #{file}")
        exit
      end

      # Display a message indicating that the file is being processed.
      say pastel.green("Processing file: #{file}")

      # Run the text processing workflow.
      begin
        workflow = TextProcessingWorkflow.new(file)
        workflow.run
        say pastel.green("Text processing completed successfully")
      rescue StandardError => e
        # Handle any errors that occur during processing.
        say pastel.red("Error processing text: #{e.message}")
        say pastel.red(e.backtrace.join("\n"))
      end
    end

    private

    # TODO: Fix this logic....
    # Extract the workflow description from a file.
    def extract_workflow_description(file)
      # Read the first line of the file.
      first_line = File.open(file, &:readline).strip
      # If the first line starts with "# Description:", return the description.
      first_line.start_with?("# Description:") ? first_line[14..-1] : "No description available"
    end

    # Run a workflow.
    def run_workflow(workflow_name)
      # Create a Pastel object for colored output.
      pastel = Pastel.new
      # Get the path to the workflow file.
      workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

      unless File.exist?(workflow_file)
        say pastel.red("Workflow file not found: #{workflow_file}")
        exit
      end

      # Display a message indicating that the workflow is being run.
      say pastel.green("Running workflow: #{workflow_name}")

      # Assume the workflow file defines a class named after the file.
      workflow_class = Object.const_get(workflow_name.split("_").map(&:capitalize).join)

      # Create an instance of the workflow class.
      workflow = workflow_class.new(workflow_file)

      logger.debug workflow
      # Run the workflow.
      workflow.run
    rescue StandardError => e
      # Handle any errors that occur during workflow execution.
      say pastel.red("Error running workflow: #{e.message}")
      say pastel.red(e.backtrace.join("\n"))
    end
  end
end
