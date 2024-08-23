#!/usr/bin/env ruby
# frozen_string_literal: true

module UI
  TITLE_WIDTH = 80
  PASTEL = Pastel.new

  module_function

  def prompt
    @prompt ||= TTY::Prompt.new(enable_color: true, active_color: :cyan)
  end

  def say(type, statement)
    type = :ok if type.nil?
    case type
    when :ok
      prompt.ok(statement)
      logger.info statement
    when :warn
      prompt.warn(statement)
      logger.warn statement
    when :error
      prompt.error(statement)
      logger.fatal statement
    else
      puts PASTEL.say(statement)
    end
  end

  def info(text)
    header
    CLI::UI::Frame.open("Information") do
      puts text
    end
  end

  def exception(text)
    CLI::UI::Frame.open("Exception Message", color: :red) do
      puts text
    end
  end

  def header
    CLI::UI::StdoutRouter.enable
    CLI::UI::Frame.open("Flowbots", color: :magenta)
  end

  def footer
    CLI::UI::Frame.close("Alright")
  end

  def main_menu
    choices = [
      { name: "Start Workflow", value: :workflow },
      { name: "Configure Settings", value: :settings },
      { name: "View Logs", value: :logs },
      { name: "Exit", value: :exit }
    ]

    prompt.select("Welcome to Flowbots. What would you like to do?", choices)
  end

  def spinner(text)
    TTY::Spinner.new("[:spinner] #{text}", format: :dots)
  end
end
