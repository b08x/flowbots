#!/usr/bin/env ruby
# frozen_string_literal: true

# Task to preprocess a FileObject.
class PreprocessFileObjectTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task to preprocess a FileObject.
  #
  # Retrieves the FileObject from Redis, determines the appropriate preprocessing method
  # based on the file extension, preprocesses the file content and metadata, stores
  # the preprocessed data in the FileObject, and logs the progress or errors.
  #
  # @return [void]
  def execute
    # Log the start of the task.
    logger.info "Starting PreprocessFileObjectTask"

    # Retrieve the FileObject from Redis.
    @file_object = retrieve_file_object

    # Check if the FileObject was retrieved successfully.
    if @file_object.nil?
      # Log an error message if the FileObject retrieval failed.
      error_message = "Failed to retrieve FileObject"
      logger.error error_message
      # Raise an error to stop the task execution.
      raise(error_message)
      return
    end

    # Begin error handling block.
    begin
      # Preprocess the file and retrieve the preprocessed content and metadata.
      preprocessed_content, metadata = preprocess_file(@file_object)
      # Store the preprocessed content and metadata in the FileObject.
      store_preprocessed_data(preprocessed_content, metadata)
      # Log a success message with the file name.
      logger.info "Successfully preprocessed file: #{@file_object.name}"
      # Mark the task as complete with a success message.
      complete("Successfully preprocessed file: #{@file_object.name}")
    rescue StandardError => e
      # Log an error message if any exception occurs during preprocessing.
      logger.error "Error in preprocessing file: #{e.message}"
      # Log the backtrace of the exception.
      logger.error e.backtrace.join("\n")
      # Display an exception message to the user.
      Flowbots::UI.exception("#{e.message}")
      # Raise the exception to stop the task execution.
      raise(e.message)
    end

    # Log the completion of the task.
    logger.info "PreprocessFileObjectTask completed"
  end

  private

  # Preprocesses the file based on its extension.
  #
  # @param file_object [FileObject] The FileObject to preprocess.
  #
  # @return [Array(String, Hash)] An array containing the preprocessed content and metadata.
  def preprocess_file(file_object)
    # Determine the preprocessing method based on the file extension.
    case determine_preprocessing_method(file_object)
    when :markdown_yaml
      # Preprocess Markdown files with YAML front matter.
      preprocess_markdown_yaml(file_object)
    when :pdf
      # Preprocess PDF files.
      preprocess_pdf(file_object)
    when :json
      # Preprocess JSON files.
      preprocess_json(file_object)
    else
      # Preprocess plain text files.
      preprocess_plain_text(file_object)
    end
  end

  # Determines the preprocessing method based on the file extension.
  #
  # @param file_object [FileObject] The FileObject to determine the preprocessing method for.
  #
  # @return [Symbol] The symbol representing the preprocessing method.
  def determine_preprocessing_method(file_object)
    # Get the file extension in lowercase.
    case File.extname(file_object.path).downcase
    when ".md", ".markdown"
      # Markdown files with YAML front matter.
      :markdown_yaml
    when ".pdf"
      # PDF files.
      :pdf
    when ".json"
      # JSON files.
      :json
    else
      # Plain text files.
      :plain_text
    end
  end

  # Preprocesses Markdown files with YAML front matter.
  #
  # @param file_object [FileObject] The FileObject to preprocess.
  #
  # @return [Array(String, Hash)] An array containing the preprocessed content and metadata.
  def preprocess_markdown_yaml(file_object)
    # Create a new GrammarProcessor instance for Markdown with YAML front matter.
    grammar_processor = Flowbots::GrammarProcessor.new("markdown_yaml")
    # Parse the file content using the GrammarProcessor.
    parse_result = grammar_processor.parse(file_object.content)

    # Check if the parsing was successful.
    if parse_result
      # Extract the Markdown content and metadata from the parse result.
      content = parse_result[:markdown_content]
      metadata = extract_metadata(parse_result[:yaml_front_matter])
    else
      # Log a warning message if parsing failed.
      logger.warn "Failed to parse Markdown with YAML front matter"
      # Use the original content and an empty metadata hash.
      content = file_object.content
      metadata = {}
    end

    # Return the preprocessed content and metadata.
    [content, metadata]
  end

  # Preprocesses PDF files.
  #
  # @param file_object [FileObject] The FileObject to preprocess.
  #
  # @return [Array(String, Hash)] An array containing the preprocessed content and metadata.
  def preprocess_pdf(file_object)
    # Extract text content from the PDF file.
    content = extract_text_from_pdf(file_object.path)
    # Extract metadata from the PDF file.
    metadata = extract_pdf_metadata(file_object.path)
    # Return the extracted content and metadata.
    [content, metadata]
  end

  # Preprocesses JSON files.
  #
  # @param file_object [FileObject] The FileObject to preprocess.
  #
  # @return [Array(String, Hash)] An array containing the preprocessed content and metadata.
  def preprocess_json(file_object)
    # Parse the JSON content.
    json_data = JSON.parse(file_object.content)
    # Extract the text content or use the entire JSON data as a string.
    content = json_data["text"] || json_data.to_s
    # Extract metadata by removing the "text" key from the JSON data.
    metadata = json_data.except("text")
    # Return the extracted content and metadata.
    [content, metadata]
  end

  # Preprocesses plain text files.
  #
  # @param file_object [FileObject] The FileObject to preprocess.
  #
  # @return [Array(String, Hash)] An array containing the preprocessed content and metadata.
  def preprocess_plain_text(file_object)
    # Return the original content and an empty metadata hash.
    [file_object.content, {}]
  end

  # Extracts metadata from YAML front matter.
  #
  # @param yaml_front_matter [String] The YAML front matter string.
  #
  # @return [Hash] The extracted metadata.
  def extract_metadata(yaml_front_matter)
    # Return an empty hash if the YAML front matter is empty.
    return {} if yaml_front_matter.to_s.empty?

    # Parse the YAML front matter.
    YAML.safe_load(yaml_front_matter)
  rescue StandardError => e
    # Log an error message if parsing fails.
    logger.error "Error parsing YAML front matter: #{e.message}"
    # Return an empty hash in case of an error.
    {}
  end

  # Extracts text content from a PDF file.
  #
  # @param pdf_path [String] The path to the PDF file.
  #
  # @return [String] The extracted text content.
  def extract_text_from_pdf(pdf_path)
    # Require the 'pdf-reader' gem.
    require "pdf-reader"
    # Create a new PDF::Reader instance.
    reader = PDF::Reader.new(pdf_path)
    # Extract text from each page and join them with newlines.
    reader.pages.map(&:text).join("\n")
  end

  # Extracts metadata from a PDF file.
  #
  # @param pdf_path [String] The path to the PDF file.
  #
  # @return [Hash] The extracted metadata.
  def extract_pdf_metadata(pdf_path)
    # Require the 'pdf-reader' gem.
    require "pdf-reader"
    # Create a new PDF::Reader instance.
    reader = PDF::Reader.new(pdf_path)
    # Return the PDF info hash.
    reader.info
  end

  # Stores the preprocessed content and metadata in the FileObject.
  #
  # @param content [String] The preprocessed content.
  # @param metadata [Hash] The extracted metadata.
  #
  # @return [void]
  def store_preprocessed_data(content, metadata)
    # Update the FileObject with the preprocessed content and metadata.
    @file_object.update(preprocessed_content: content, metadata:)
    # Log the stored preprocessed content (first 100 characters).
    logger.debug "Stored preprocessed content (first 100 chars): #{content[0..100]}"
    # Log the stored metadata.
    logger.debug "Stored metadata: #{metadata.inspect}"
  end
end
