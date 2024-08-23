#!/usr/bin/env ruby
# frozen_string_literal: true

require "tty-box"
require "tty-screen"

module UI
  module Box
    module_function

    def comparison_box(text1, text2, title1: "Text 1", title2: "Text 2")
      screen_width = TTY::Screen.width - 2
      text_width = [text1.length, text2.length, 40].max + 4
      width = [text_width, screen_width, TITLE_WIDTH].min

      box1 = TTY::Box.frame(width:, title: { top_left: title1 }, padding: 1) { text1 }
      box2 = TTY::Box.frame(width:, title: { top_left: title2 }, padding: 1) { text2 }
      box1 + "\n" + box2
    end

    def eval_result_box(result, title: "Evaluation Result")
      TTY::Box.success(
        result,
        title: { top_left: title },
        width: 80,
        height: (TTY::Screen.height / 1.25).round,
        padding: 1
      )
    end

    def exception_box(message)
      TTY::Box.error(
        message,
        title: { top_left: "Error" },
        width: [TTY::Screen.width - 2, TITLE_WIDTH].min,
        padding: 1
      )
    end

    def info_box(message, title: "Info")
      TTY::Box.info(message, title: { top_left: title }, width: [TTY::Screen.width - 2, 50].min, padding: 1)
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

      TTY::Box.frame(content, width: [total_width, TTY::Screen.width - 2].min, padding: 1)
    end
  end
end
