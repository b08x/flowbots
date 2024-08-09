#!/usr/bin/env ruby
# frozen_string_literal: true

# This task preprocesses a text file, extracting metadata and content.
class PreprocessTextFileTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    logger.info "Starting PreprocessTextFileTask"

    @textfile = retrieve_current_textfile

    logger.debug "File content: #{@textfile.content[0..500]}..." # Log first 200 characters

    begin
      grammar_processor = Flowbots::GrammarProcessor.new("markdown_yaml")
      parse_result = grammar_processor.parse(@textfile.content)
      logger.debug "Parse result: #{parse_result.inspect}"

      if parse_result
        content = parse_result[:markdown_content]
        metadata = extract_metadata(parse_result[:yaml_front_matter])
        store_preprocessed_data(content, metadata)
        logger.info "Successfully preprocessed file with custom grammar"
      else
        logger.error "Failed to parse the document with custom grammar"
        @textfile.update(preprocessed_content: "")
        @textfile.update(metadata: {})
        @textfile.save
      end
    rescue StandardError => e
      logger.error "Error in grammar processing: #{e.message}"
      logger.error e.backtrace.join("\n")
      Flowbots::UI.exception("#{e.message}")
      @textfile.update(preprocessed_content: "")
      @textfile.update(metadata: {})
      @textfile.save
    end

    logger.info "PreprocessTextFileTask completed"
  end

  private

  # Normalizes the given text by converting it to lowercase and removing non-alphanumeric characters.
  #
  # @param text [String] The text to normalize.
  #
  # @return [String] The normalized text.
  def normalize_text(text)
    text.downcase.gsub(/[^a-z0-9\s]/i, "")
  end

  # Retrieves the current Textfile object from Redis.
  #
  # @return [Textfile] The Textfile object representing the current file.
  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  # Extracts metadata from the YAML front matter.
  #
  # @param yaml_front_matter [String] The YAML front matter string.
  #
  # @return [Hash] The extracted metadata.
  def extract_metadata(yaml_front_matter)
    return {} if yaml_front_matter.empty?

    begin
      YAML.safe_load(yaml_front_matter)
    rescue StandardError => e
      logger.error "Error parsing YAML front matter: #{e.message}"
      {}
    end
  end

  # Stores the preprocessed content and metadata in the database.
  #
  # @param content [String] The preprocessed content.
  # @param metadata [Hash] The extracted metadata.
  #
  # @return [void]
  def store_preprocessed_data(content, metadata)
    # redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
    @textfile.update(preprocessed_content: content)
    @textfile.update(metadata:)
    @textfile.save
    # redis.set("preprocessed_content", content)
    # redis.set("file_metadata", metadata.to_json)
    logger.debug "Stored preprocessed content (first 100 chars): #{content[0..100]}"
    logger.debug "Stored metadata: #{metadata.inspect}"
  end
end
