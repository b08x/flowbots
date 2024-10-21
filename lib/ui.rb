#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/ui.rb

require "highline/import"
require "natty-ui"
require "os"
require "pastel"
require "tty-box"
require "tty-cursor"
require "tty-prompt"
require "tty-screen"
require "tty-spinner"
require "tty-table"

require_relative "ui/base"
require_relative "ui/box"
require_relative "ui/scrollable_box"

# Provides user interface functionality for the Flowbots application.
module UI
  # Starts the main UI loop.
  #
  # Displays the main menu and handles user interactions.
  #
  # @return [void]
  def self.start
    loop do
      header
      case main_menu
      when :workflow
        start_workflow
      when :settings
        open_settings
      when :logs
        view_logs
      when :exit
        say(:ok, "Thank you for using Flowbots. Goodbye!")
        break
      end
    end
  end

  # Starts the workflow selection process.
  #
  # Displays a menu of available workflows and handles user selection.
  #
  # @return [void]
  def self.start_workflow
    workflow_choices = [
      { name: "Text Processing Workflow", value: :text_processing },
      { name: "Topic Model Trainer Workflow", value: :topic_model },
      { name: "Custom Workflow", value: :custom },
      { name: "Back to Main Menu", value: :back }
    ]

    choice = prompt.select("Select a workflow to start:", workflow_choices)

    case choice
    when :text_processing
      run_workflow("Text Processing")
    when :topic_model
      run_workflow("Topic Model Trainer")
    when :custom
      custom_workflow
    when :back
      nil
    end
  end

  # Runs a workflow with a given name.
  #
  # Displays a spinner indicating workflow execution and simulates completion.
  #
  # @param workflow_name [String] The name of the workflow to run.
  #
  # @return [void]
  def self.run_workflow(workflow_name)
    spinner = TTY::Spinner.new("[:spinner] Running #{workflow_name} Workflow...", format: :dots)
    spinner.auto_spin

    # Simulate workflow execution
    sleep(3)

    spinner.success("(#{workflow_name} Workflow completed successfully!)")
  end

  # Creates a custom workflow.
  #
  # Prompts the user for a workflow name and tasks, and displays the created workflow.
  #
  # @return [void]
  def self.custom_workflow
    say(:info, "Custom Workflow Creator")
    workflow_name = prompt.ask("Enter a name for your custom workflow:")
    tasks = []
    loop do
      task = prompt.ask("Enter a task for your workflow (or 'done' to finish):")
      break if task.downcase == "done"

      tasks << task
    end
    say(:ok, "Custom workflow '#{workflow_name}' created with #{tasks.size} tasks.")
    tasks.each_with_index do |task, index|
      say(:info, "Task #{index + 1}: #{task}")
    end
  end

  # Opens the settings menu.
  #
  # Displays a menu of settings categories and handles user selection.
  #
  # @return [void]
  def self.open_settings
    settings_choices = [
      { name: "General Settings", value: :general },
      { name: "Workflow Settings", value: :workflow },
      { name: "API Settings", value: :api },
      { name: "Back to Main Menu", value: :back }
    ]

    loop do
      choice = prompt.select("Select a settings category:", settings_choices)

      case choice
      when :general
        edit_general_settings
      when :workflow
        edit_workflow_settings
      when :api
        edit_api_settings
      when :back
        break
      end
    end
  end

  # Edits general settings.
  #
  # Displays a placeholder message indicating the general settings editor.
  #
  # @return [void]
  def self.edit_general_settings
    # Implement general settings editor
    say(:info, "Editing General Settings")
    # Add more specific setting options here
  end

  # Edits workflow settings.
  #
  # Displays a placeholder message indicating the workflow settings editor.
  #
  # @return [void]
  def self.edit_workflow_settings
    # Implement workflow settings editor
    say(:info, "Editing Workflow Settings")
    # Add more specific setting options here
  end

  # Edits API settings.
  #
  # Displays a placeholder message indicating the API settings editor.
  #
  # @return [void]
  def self.edit_api_settings
    # Implement API settings editor
    say(:info, "Editing API Settings")
    # Add more specific setting options here
  end

  # Views the application logs.
  #
  # Attempts to read the log file and display it in a scrollable box.
  # Handles potential errors during file reading.
  #
  # @return [void]
  def self.view_logs
    log_file = File.join(LOG_DIR, "flowbots-#{current_date}.log")
    begin
      log_content = File.read(log_file)
      ScrollableBox.side_by_side_boxes(
        log_content,
        "Log Analysis Goes Here",
        title1: "Log Viewer",
        title2: "Log Analysis"
      )
    rescue Errno::ENOENT
      say(:error, "Log file not found: #{log_file}")
    rescue StandardError => e
      say(:error, "Error reading log file: #{e.message}")
    end
  end
end
