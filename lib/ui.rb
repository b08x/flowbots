#!/usr/bin/env ruby
# frozen_string_literal: false

require "os"
require "highline/import"
require "tty-prompt"
require "tty-spinner"
require "pastel"
require "cli/ui"

module Flowbots
  module UI
    module_function

    def prompt
      @prompt = TTY::Prompt.new(enable_color: true, active_color: :cyan)
      @pastel = Pastel.new
    end

    def spinner(task)
      spinner = TTY::Spinner.new("[:spinner] #{task}", format: :toggle)
    end

    def spinners(task)
      spinners = TTY::Spinner::Multi.new "[:spinner] #{task}", format: :pulse
    end

    def say(type="", statement)
      prompt
      case type
      when :ok
        @prompt.ok(statement)
        logger.info statement
      when :warn
        @prompt.warn(statement)
        logger.warn statement
      when :error
        @prompt.error(statement)
        logger.fatal statement
      else
        @pastel.say(statement)
      end
    end
  end
end
