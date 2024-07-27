#!/usr/bin/env ruby
# frozen_string_literal: true

class PreprocessTextFileTask < Jongleur::WorkerTask
  def execute
    logger.info "Starting PreprocessTextFileTask"

    textfile = retrieve_current_textfile
    logger.debug "File content: #{textfile.content[0..200]}..." # Log first 200 characters

    begin
      grammar_processor = Flowbots::GrammarProcessor.new('markdown_yaml')
      parse_result = grammar_processor.parse(textfile.content)
      p parse_result
      logger.debug "Parse result: #{parse_result.inspect}"
    rescue StandardError => e
      logger.error "Error in grammar processing: #{e.message}"
      logger.error e.backtrace.join("\n")
      Flowbots::UI.exception("#{e.message}")
      return
    end

    if parse_result
      content = parse_result[:markdown_content]
      metadata = extract_metadata(parse_result[:yaml_front_matter])
      store_preprocessed_data(content, metadata)
      logger.info "Successfully preprocessed file with custom grammar"
    else
      logger.error "Failed to parse the document with custom grammar"
      store_preprocessed_data(textfile.content, {})
    end

    logger.info "PreprocessTextFileTask completed"
  end

  private

  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  def extract_metadata(yaml_front_matter)
    return {} if yaml_front_matter.empty?

    YAML.safe_load(yaml_front_matter)
  rescue StandardError => e
    logger.error "Error parsing YAML front matter: #{e.message}"
    {}
  end

  def store_preprocessed_data(content, metadata)
    redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
    redis.set("preprocessed_content", content)
    redis.set("file_metadata", metadata.to_json)
  end
end
