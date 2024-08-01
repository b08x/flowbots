#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class PreprocessTextFileTask < Task
    def perform
      grammar_processor = GrammarProcessor.new('markdown_yaml')
      parse_result = grammar_processor.parse(sourcefile.content)

      if parse_result
        sourcefile.update(
          preprocessed_content: parse_result[:markdown_content],
          metadata: extract_metadata(parse_result[:yaml_front_matter])
        )
        "Successfully preprocessed file: #{sourcefile.path}"
      else
        sourcefile.update(
          preprocessed_content: sourcefile.content,
          metadata: {}
        )
        "Failed to parse the document with custom grammar: #{sourcefile.path}"
      end
    end

    private

    def extract_metadata(yaml_front_matter)
      YAML.safe_load(yaml_front_matter)
    rescue StandardError => e
      logger.error "Error parsing YAML front matter: #{e.message}"
      {}
    end
  end
end
