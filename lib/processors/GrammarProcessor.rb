#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class handles parsing text using a specified grammar.
  class GrammarProcessor
    # Initializes a new GrammarProcessor instance.
    #
    # @param grammar_name [String] The name of the grammar to use for parsing.
    #
    # @return [void]
    def initialize(grammar_name)
      @grammar_name = grammar_name
      load_grammar
    end

    # Parses the given text using the specified grammar.
    #
    # @param text [String] The text to parse.
    #
    # @return [Hash, nil] A hash containing the parsed YAML front matter and Markdown content,
    #   or nil if parsing fails.
    def parse(text)
      logger.debug "Parsing text: #{text[0..100]}..." # Log first 100 characters of the text
      result = @parser.parse(text)
      if result
        yaml_front_matter = extract_yaml_front_matter(result)
        markdown_content = extract_markdown_content(result)
        logger.debug "Parsing successful."
        logger.debug "YAML Front Matter: #{yaml_front_matter.inspect}"
        logger.debug "Markdown Content: #{markdown_content[0..100].inspect}..." # Log first 100 characters
        {
          yaml_front_matter:,
          markdown_content:
        }
      else
        logger.error "Parsing failed. Parser errors: #{@parser.failure_reason}"
        logger.error "Failure index: #{@parser.index}"
        logger.error "Failure line and column: #{@parser.failure_line}:#{@parser.failure_column}"
        logger.error "Context: #{text[@parser.index, 50]}" # Log 50 characters of context around failure point
        nil
      end
    end

    private

    # Loads the grammar file and creates a parser instance.
    #
    # @return [void]
    def load_grammar
      grammar_file = File.join(GRAMMAR_DIR, "#{@grammar_name}.treetop")
      logger.debug "Loading grammar file: #{grammar_file}"
      Treetop.load(grammar_file)
      logger.debug "Grammar file loaded successfully"

      parser_class_name = "#{@grammar_name.split('_').map(&:capitalize).join}Parser"
      @parser = Object.const_get(parser_class_name).new
      logger.debug "Parser created: #{@parser.class}"
    rescue StandardError => e
      logger.error "Error loading grammar: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise
    end

    # Extracts the YAML front matter from the parse result.
    #
    # @param parse_result [Treetop::Runtime::SyntaxNode] The parse result.
    #
    # @return [String] The extracted YAML front matter.
    def extract_yaml_front_matter(parse_result)
      yaml_front_matter = parse_result.elements[0].text_value
      yaml_content = yaml_front_matter.gsub(/\A---\n/, "").gsub(/\n---\n\z/, "")
      yaml_content.strip
    end

    # Extracts the Markdown content from the parse result.
    #
    # @param parse_result [Treetop::Runtime::SyntaxNode] The parse result.
    #
    # @return [String] The extracted Markdown content.
    def extract_markdown_content(parse_result)
      markdown_content = parse_result.elements[1].text_value
      markdown_content.strip
    end
  end
end
