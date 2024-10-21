#!/usr/bin/env ruby
# frozen_string_literal: true

# This task preprocesses a text file, extracting metadata and cleaning the content.
class PreprocessTextFileTask < Task
  include InputRetrieval

  # Executes the text file preprocessing task.
  #
  # This method retrieves the text file object, parses it using a custom grammar,
  # extracts metadata, updates the text file with preprocessed content and metadata,
  # and logs relevant information.
  #
  # The preprocessing process involves:
  #
  # 1. **Retrieving the text file object:** The `retrieve_input` method is called to retrieve the
  #    text file object from the appropriate source (e.g., Redis).
  # 2. **Parsing the text file:** The `Flowbots::GrammarProcessor` is used to parse the text file
  #    content using a custom grammar (e.g., "markdown_yaml"). The parsing result is stored in
  #    the `parse_result` variable.
  # 3. **Extracting metadata:** If the parsing is successful, the `extract_metadata` method is
  #    called to extract metadata from the YAML front matter of the parsed text file. The
  #    extracted metadata is stored in the `metadata` variable.
  # 4. **Updating the text file:** The `update` method is called on the text file object to
  #    store the preprocessed content (extracted from the parsing result) and the extracted
  #    metadata.
  # 5. **Logging information:** The `logger` object is used to log relevant information about
  #    the preprocessing process, including success messages, error messages, and debug
  #    information.
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
  # This method retrieves the text file object from the appropriate source (e.g., Redis).
  #
  # @return [Textfile] The retrieved text file object.
  def retrieve_input
    retrieve_textfile
  end

  # Extracts metadata from the YAML front matter of the parsed text file.
  #
  # This method extracts metadata from the YAML front matter of the parsed text file.
  # It uses the `YAML.safe_load` method to parse the YAML front matter and returns a hash
  # containing the extracted metadata. If the YAML front matter is empty or an error
  # occurs during parsing, an empty hash is returned.
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
  # This method updates the text file object with the preprocessed content and extracted
  # metadata. It uses the `update` method on the text file object to store the
  # preprocessed content and metadata. It also logs debug information about the stored
  # content and metadata.
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
