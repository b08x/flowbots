#!/usr/bin/env ruby
# frozen_string_literal: true

# This task preprocesses a text file, extracting metadata and cleaning the content.
class PreprocessTextFileTask < Task
  include InputRetrieval

  # Executes the text file preprocessing task.
  #
  # Retrieves the text file object, parses it using a custom grammar,
  # extracts metadata, updates the text file with preprocessed content and metadata,
  # and logs relevant information.
  #
  # @return [String] A success message if the preprocessing is successful, otherwise an error message.
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
  end

  private

  # Retrieves the input text file object.
  #
  # @return [Textfile] The retrieved text file object.
  def retrieve_input
    retrieve_textfile
  end

  # Extracts metadata from the YAML front matter of the parsed text file.
  #
  # @param yaml_front_matter [String] The YAML front matter extracted from the text file.
  #
  # @return [Hash] A hash containing the extracted metadata.
  def extract_metadata(yaml_front_matter)
    return {} if yaml_front_matter.empty?

    YAML.safe_load(yaml_front_matter)
  rescue StandardError => e
    logger.error "Error parsing YAML front matter: #{e.message}"
    {}
  end

  # Stores the preprocessed content and metadata in the text file object.
  #
  # @param content [String] The preprocessed content of the text file.
  # @param metadata [Hash] The extracted metadata.
  #
  # @return [void]
  def store_preprocessed_data(content, metadata)
    @textfile.update(preprocessed_content: content, metadata:)
    logger.debug "Stored preprocessed content (first 100 chars): #{content[0..100]}"
    logger.debug "Stored metadata: #{metadata.inspect}"
  end
end
