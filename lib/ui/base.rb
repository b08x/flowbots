#!/usr/bin/env ruby
# frozen_string_literal: true

#
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

module Flowbots
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
      CLI::UI::Frame.open("Flowbots", color: :green)
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
end
