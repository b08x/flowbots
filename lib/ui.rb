#!/usr/bin/env ruby
# frozen_string_literal: true

require "cli/ui"
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

module UI
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

  def self.run_workflow(workflow_name)
    spinner = TTY::Spinner.new("[:spinner] Running #{workflow_name} Workflow...", format: :dots)
    spinner.auto_spin

    # Simulate workflow execution
    sleep(3)

    spinner.success("(#{workflow_name} Workflow completed successfully!)")
  end

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

  def self.edit_general_settings
    # Implement general settings editor
    say(:info, "Editing General Settings")
    # Add more specific setting options here
  end

  def self.edit_workflow_settings
    # Implement workflow settings editor
    say(:info, "Editing Workflow Settings")
    # Add more specific setting options here
  end

  def self.edit_api_settings
    # Implement API settings editor
    say(:info, "Editing API Settings")
    # Add more specific setting options here
  end

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
