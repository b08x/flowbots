#!/usr/bin/env ruby
# frozen_string_literal: true

class PreprocessFileObjectTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting PreprocessFileObjectTask"

    @file_object = retrieve_file_object

    if @file_object.nil?
      error_message = "Failed to retrieve FileObject"
      logger.error error_message
      raise(error_message)
      return
    end

    begin
      preprocessed_content, metadata = preprocess_file(@file_object)
      store_preprocessed_data(preprocessed_content, metadata)
      logger.info "Successfully preprocessed file: #{@file_object.name}"
      complete("Successfully preprocessed file: #{@file_object.name}")
    rescue StandardError => e
      logger.error "Error in preprocessing file: #{e.message}"
      logger.error e.backtrace.join("\n")
      Flowbots::UI.exception("#{e.message}")
      raise(e.message)
    end

    logger.info "PreprocessFileObjectTask completed"
  end

  private

  def preprocess_file(file_object)
    case determine_preprocessing_method(file_object)
    when :markdown_yaml
      preprocess_markdown_yaml(file_object)
    when :pdf
      preprocess_pdf(file_object)
    when :json
      preprocess_json(file_object)
    else
      preprocess_plain_text(file_object)
    end
  end

  def determine_preprocessing_method(file_object)
    case File.extname(file_object.path).downcase
    when ".md", ".markdown"
      :markdown_yaml
    when ".pdf"
      :pdf
    when ".json"
      :json
    else
      :plain_text
    end
  end

  def preprocess_markdown_yaml(file_object)
    grammar_processor = Flowbots::GrammarProcessor.new("markdown_yaml")
    parse_result = grammar_processor.parse(file_object.content)

    if parse_result
      content = parse_result[:markdown_content]
      metadata = extract_metadata(parse_result[:yaml_front_matter])
    else
      logger.warn "Failed to parse Markdown with YAML front matter"
      content = file_object.content
      metadata = {}
    end

    [content, metadata]
  end

  def preprocess_pdf(file_object)
    content = extract_text_from_pdf(file_object.path)
    metadata = extract_pdf_metadata(file_object.path)
    [content, metadata]
  end

  def preprocess_json(file_object)
    json_data = JSON.parse(file_object.content)
    content = json_data["text"] || json_data.to_s
    metadata = json_data.except("text")
    [content, metadata]
  end

  def preprocess_plain_text(file_object)
    [file_object.content, {}]
  end

  def extract_metadata(yaml_front_matter)
    return {} if yaml_front_matter.to_s.empty?

    YAML.safe_load(yaml_front_matter)
  rescue StandardError => e
    logger.error "Error parsing YAML front matter: #{e.message}"
    {}
  end

  def extract_text_from_pdf(pdf_path)
    require "pdf-reader"
    reader = PDF::Reader.new(pdf_path)
    reader.pages.map(&:text).join("\n")
  end

  def extract_pdf_metadata(pdf_path)
    require "pdf-reader"
    reader = PDF::Reader.new(pdf_path)
    reader.info
  end

  def store_preprocessed_data(content, metadata)
    @file_object.update(preprocessed_content: content, metadata:)
    logger.debug "Stored preprocessed content (first 100 chars): #{content[0..100]}"
    logger.debug "Stored metadata: #{metadata.inspect}"
  end
end
