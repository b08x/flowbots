#!/usr/bin/env ruby
# frozen_string_literal: false

require "cli/ui"
require "highline/import"
require "os"
require "pastel"
require "tty-box"
require "tty-prompt"
require "tty-spinner"
require "tty-table"
require "tty-screen"

TITLE_WIDTH = 80

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

module UIBox
  class << self
    def comparison_box(text1, text2, title1: "Text 1", title2: "Text 2")
      
      screen_width = TTY::Screen.width - 2

      text_width = [text1.length, text2.length, 40].max + 4
     

      width = text_width < screen_width ? screen_width : TITLE_WIDTH

      box1 = TTY::Box.frame(width:, title: { top_left: title1 }, padding: 1) { text1 }
      box2 = TTY::Box.frame(width:, title: { top_left: title2 }, padding: 1) { text2 }
      box1 + "\n" + box2
    end

    def eval_result_box(result, title: "Evaluation Result")
      TTY::Box.success(result, title: { top_left: title }, width: 50, padding: 1)
    end

    def error_box(message)
      TTY::Box.error(message, title: { top_left: "Error" }, width: 50, padding: 1)
    end

    def info_box(message, title: "Info")
      TTY::Box.info(message, title: { top_left: title }, width: 50, padding: 1)
    end

    def multi_column_box(data, titles)
      max_widths = data.transpose.map { |col| col.map(&:to_s).map(&:length).max }
      total_width = max_widths.sum + (3 * (max_widths.size - 1)) + 4

      rows = data.map do |row|
        row.zip(max_widths).map { |cell, width| cell.to_s.ljust(width) }.join(" | ")
      end

      header = titles.zip(max_widths).map { |title, width| title.to_s.ljust(width) }.join(" | ")
      separator = max_widths.map { |w| "-" * w }.join("-+-")

      content = [
        header,
        separator,
        rows.join("\n")
      ].join("\n")

      TTY::Box.frame(content, width: total_width, padding: 1)
    end
  end
end
