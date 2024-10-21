#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/helper.rb

require "kramdown"
require "tty-cursor"
require "tty-prompt"

PASTEL = Pastel.new

# Provides helper methods for cursor positioning and terminal interaction.
class Cursor
  class << self
    # Returns the current cursor position.
    #
    # @return [Hash] A hash containing the row and column of the cursor.
    def pos
      res = +""
      $stdin.raw do |stdin|
        $stdout << "\e[6n"
        $stdout.flush
        while (c = stdin.getc) != "R"
          res << c if c
        end
      end
      m = res.match(/(?<row>\d+);(?<column>\d+)/)
      { row: Integer(m[:row]), column: Integer(m[:column]) }
    end
  end
end

# Extends the TTY::Prompt class with custom functionality.
module TTY
  # A custom prompt class with enhanced features.
  class PromptX < Prompt
    # The prefix used for the prompt.
    #
    # @return [String] The prompt prefix.
    attr_reader :prefix

    # Initializes a new PromptX instance.
    #
    # @param active_color [Symbol] The color for the active prompt.
    # @param prefix [String] The prefix for the prompt.
    # @param history [Boolean] Whether to enable history for the prompt.
    def initialize(active_color:, prefix:, history: true)
      # Define an interrupt handler to handle Ctrl+C.
      @interrupt = lambda do
        print TTY::Cursor.clear_screen_down
        print "\e[2J\e[f"
        res = TTY::Prompt.new.yes?("Quit the app?")
        exit if res
      end

      # Initialize the superclass with the provided options.
      super(active_color: active_color, prefix: prefix, interrupt: @interrupt)
      @history = history
      @prefix = prefix
    end

    # Reads a line of input from the user.
    #
    # @param text [String] The text to display before the input field.
    #
    # @return [String] The input string entered by the user.
    def readline(text = "")
      puts @prefix
      begin
        Readline.readline(text, @history)
      rescue Interrupt
        @interrupt.call
      end
    end
  end

  # Provides functionality for converting Markdown to terminal-friendly output.
  module Markdown
    # A converter class for converting Kramdown::Document trees to terminal output.
    class Converter < ::Kramdown::Converter::Base
      # Converts a paragraph element to terminal output.
      #
      # @param ell [Kramdown::Element] The paragraph element to convert.
      # @param opts [Hash] Options for the conversion.
      #
      # @return [Array<String>] The converted paragraph text.
      def convert_p(ell, opts)
        indent = SPACE * @current_indent
        result = []

        # Add indentation unless the parent element is a blockquote or list item.
        result << indent unless %i[blockquote li].include?(opts[:parent].type)

        # Set the indentation level for the current element.
        opts[:indent] = @current_indent
        # Reset indentation to 0 if the parent element is a blockquote.
        opts[:indent] = 0 if opts[:parent].type == :blockquote

        # Convert the inner content of the paragraph element.
        content = inner(ell, opts)

        # Define a regular expression to match symbols that should not be followed by a newline.
        symbols = %q{[-!$%^&*()_+|~=`{}\[\]:";'<>?,.\/]}
        # Remove newlines that are not preceded or followed by symbols.
        # result << content.join.gsub(/(?<!#{symbols})\n(?!#{symbols})/m) { " " }.gsub(/ +/) { " " }
        # Remove newlines that are not preceded or followed by symbols.
        result << content.join.gsub(/(?<!#{symbols})\n(?!#{symbols})/m) { "" }
        # Add a newline if the last element does not end with a newline.
        result << NEWLINE unless result.last.to_s.end_with?(NEWLINE)
        result
      end
    end
  end
end

# Defines a custom error class for monadic errors.
class MonadicError < StandardError
end
