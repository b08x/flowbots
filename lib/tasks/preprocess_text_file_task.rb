#!/usr/bin/env ruby
# frozen_string_literal: true

class PreprocessTextFileTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting PreprocessTextFileTask"

    @textfile = retrieve_input

    begin
      grammar_processor = Flowbots::GrammarProcessor.new("markdown_yaml")
      parse_result = grammar_processor.parse(@textfile.content)
      logger.debug "Parse result: #{parse_result.inspect}"

      if parse_result
        sourcefile.update(
          preprocessed_content: parse_result[:markdown_content],
          metadata: extract_metadata(parse_result[:yaml_front_matter])
        )
        "Successfully preprocessed file: #{sourcefile.path}"
      else
        logger.error "Failed to parse the document with custom grammar"
        @textfile.update(preprocessed_content: "", metadata: {})
      end
    rescue StandardError => e
      logger.error "Error in grammar processing: #{e.message}"
      logger.error e.backtrace.join("\n")
      UI.exception("#{e.message}")
      @textfile.update(preprocessed_content: "", metadata: {})
    end

    private

  private

  def retrieve_input
    retrieve_textfile
  end

  def extract_metadata(yaml_front_matter)
    return {} if yaml_front_matter.empty?

    YAML.safe_load(yaml_front_matter)
  rescue StandardError => e
    logger.error "Error parsing YAML front matter: #{e.message}"
    {}
  end

  def store_preprocessed_data(content, metadata)
    @textfile.update(preprocessed_content: content, metadata:)
    logger.debug "Stored preprocessed content (first 100 chars): #{content[0..100]}"
    logger.debug "Stored metadata: #{metadata.inspect}"
  end
end
