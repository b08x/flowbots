#!/usr/bin/env ruby
# frozen_string_literal: false

require "cli/ui"
require "highline/import"
require "natty-ui"
require "os"
require "pastel"
require "tty-box"
require "tty-prompt"
require "tty-screen"
require "tty-spinner"
require "tty-table"

TITLE_WIDTH = 80

module Flowbots
  module UI
    module_function

    def prompt
      @prompt = TTY::Prompt.new(enable_color: true, active_color: :cyan)
      @pastel = Pastel.new
    end

    def say(type, statement)
      prompt
      type = :ok if type.nil?
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

    def info(text)
      header
      ui.framed do
        ui.info "Agent Response" do
          ui.puts text, glyph: "💡"
        end
      end
    end

    def exception(text)
      ui.framed do
        ui.failed "Exception Message" do
          ui.puts text, glyph: "💡"
        end
      end
    end

    def response(response)
      ui.space
      ui.h1 "UI: Text Line Animation"
      ui.space

      response.each_line do |line|
        input = line.chomp
        unless input.nil?
          input.each_char do |char|
            print "\e[34m#{char}\e[0m"
            ui.message char
            sleep 0.02
          end
          puts "\n"
        end
        res = line.chomp
        unless res.nil?
          puts "\e[32m#{res.strip.chomp}\e[0m"
          puts "\n"
        end
        cap = line.chomp
        puts "\e[33m#{cap.strip.chomp}\e[0m\n" unless cap.nil?
      end
      puts "\n"
      sleep 3
      ui.space
    end

    def header
      ui.space
      ui.h1 "UI: Message Types"
      ui.space
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

    def exception(message)
      screen_width = TTY::Screen.width - 2

      text_width = [message.length, 40].max + 4

      width = text_width < screen_width ? screen_width : TITLE_WIDTH
      TTY::Box.error(message, title: { top_left: "Error" }, width: width, padding: 1)
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

#
# TEXT = <<~TEXT.tr("\n", ' ')
#   Lorem [[yellow]]ipsum[[/]] dolor sit amet, consectetur adipisicing elit, sed
#   do eiusmod tempor incididunt ut labore et dolore [[red]]magna[[/]] aliqua.
#   Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
#   aliquip ex ea commodo [[bold]]consequat[[/]].
# TEXT
#
#
#
# ui.framed do
#   ui.info 'Informative Message', TEXT
#   ui.warning 'Warning Message' do
#     ui.puts TEXT
#     ui.framed { ui.puts IMPORTANT }
#   end
#   ui.error 'Error Message', TEXT
#   ui.failed 'Fail Message', TEXT
#   ui.message '[[italic #fad]]Custom Message', TEXT, glyph: '💡'
# end
#
# ui.space
