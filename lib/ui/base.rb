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
    box = TTY::Box.frame(width: TITLE_WIDTH, title: {top_left: " Information "}, padding: 1) do
      text
    end
    puts box
  end

  def header
    box = TTY::Box.frame(width: TITLE_WIDTH, title: {top_left: " Flowbots "}, style: {fg: :magenta})
    puts box
  end

  def footer
    box = TTY::Box.frame(width: TITLE_WIDTH, title: {bottom_right: " Alright "})
    puts box
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
