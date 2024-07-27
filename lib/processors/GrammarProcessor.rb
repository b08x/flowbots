#!/usr/bin/env ruby
# frozen_string_literal: true

require "treetop"

module Flowbots
  class GrammarProcessor
    def initialize(grammar_name)
      @grammar_name = grammar_name
      load_grammar
    end

    def parse(text)
      logger.debug "Parsing text: #{text[0..100]}..." # Log first 100 characters of the text
      result = @parser.parse(text)
      if result
        yaml_front_matter = extract_yaml_front_matter(result)
        markdown_content = extract_markdown_content(result)
        logger.debug "Parsing successful. YAML Front Matter: #{yaml_front_matter[0..100]}..."
        logger.debug "Markdown Content: #{markdown_content[0..100]}..."
        {
          yaml_front_matter: yaml_front_matter,
          markdown_content: markdown_content
        }
      else
        logger.error "Parsing failed. Parser errors: #{@parser.failure_reason}"
        nil
      end
    end

    private

    def load_grammar
      begin
        grammar_file = File.join(GRAMMAR_DIR, "#{@grammar_name}")
        logger.debug "Loading grammar file: #{grammar_file}"
        require grammar_file
        logger.debug "Grammar file loaded successfully"

        @parser = MarkdownYamlParser.new
        logger.debug "Parser created: #{@parser.class}"
      rescue StandardError => e
        logger.error "Error loading grammar: #{e.message}"
        logger.error e.backtrace.join("\n")
        raise
      end
    end

    def camelize(string)
      string.split('_').map(&:capitalize).join
    end

    def extract_yaml_front_matter(parse_result)
      yaml_content = parse_result.elements.find { |e| e.respond_to?(:filtered_yaml_content) }
      if yaml_content
        yaml_content.filtered_yaml_content.elements.map(&:text_value).join
      else
        ""
      end
    end

    def extract_markdown_content(parse_result)
      markdown_content = parse_result.elements.find { |e| e.respond_to?(:markdown_content) }
      markdown_content ? markdown_content.text_value : ""
    end
  end
end
