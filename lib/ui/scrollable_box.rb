#!/usr/bin/env ruby
# frozen_string_literal: true

require "tty-box"
require "tty-screen"

module UI
  module ScrollableBox
    module_function

    def side_by_side_boxes(text1, text2, title1: "Box 1", title2: "Box 2")
      screen_width = TTY::Screen.width / 1.25
      screen_height = TTY::Screen.height
      box_width = (screen_width / 2.5) - 2
      box_height = screen_height - 4 # Leave some space for prompts

      box1 = create_scrollable_box(text1, box_width, box_height, title1)
      box2 = create_scrollable_box(text2, box_width, box_height, title2)

      display_boxes(box1, box2, box_height)
    end

    private

    def self.create_scrollable_box(text, width, height, title)
      lines = text.split("\n")
      total_pages = (lines.length.to_f / (height - 2)).ceil
      {
        title:,
        lines:,
        width:,
        height:,
        total_pages:,
        current_page: 1
      }
    end

    def self.display_boxes(box1, box2, box_height)
      loop do
        system("clear") || system("cls")
        print_boxes(box1, box2, box_height)
        print_navigation_info(box1, box2)

        input = STDIN.getch
        case input.downcase
        when "q"
          break
        when "a"
          box1[:current_page] = [1, box1[:current_page] - 1].max
        when "d"
          box1[:current_page] = [box1[:total_pages], box1[:current_page] + 1].min
        when "j"
          box2[:current_page] = [1, box2[:current_page] - 1].max
        when "l"
          box2[:current_page] = [box2[:total_pages], box2[:current_page] + 1].min
        end
      end
    end

    def self.print_boxes(box1, box2, box_height)
      start_line1 = (box1[:current_page] - 1) * (box_height - 2)
      start_line2 = (box2[:current_page] - 1) * (box_height - 2)

      box1_content = box1[:lines][start_line1, box_height - 2].join("\n")
      box2_content = box2[:lines][start_line2, box_height - 2].join("\n")

      box1_frame = TTY::Box.frame(width: box1[:width], height: box_height, title: { top_left: box1[:title] }) do
        box1_content
      end
      box2_frame = TTY::Box.frame(width: box2[:width], height: box_height, title: { top_left: box2[:title] }) do
        box2_content
      end

      puts box1_frame.split("\n").zip(box2_frame.split("\n")).map { |a, b| "#{a}  #{b}" }.join("\n")
    end

    def self.print_navigation_info(box1, box2)
      puts "Box 1: Page #{box1[:current_page]}/#{box1[:total_pages]} (A/D to navigate)"
      puts "Box 2: Page #{box2[:current_page]}/#{box2[:total_pages]} (J/L to navigate)"
      puts "Press Q to exit"
    end
  end
end
