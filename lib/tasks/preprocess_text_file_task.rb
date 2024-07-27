#!/usr/bin/env ruby
# frozen_string_literal: true

class PreprocessTextFileTask < Jongleur::WorkerTask

  def execute
    logger.info "Starting PreprocessTextFileTask"

    textfile = retrieve_current_textfile
    begin
      grammar_processor = Flowbots::GrammarProcessor.new('markdown_text_with_yaml')
      parse_tree = grammar_processor.parse(textfile.content)
    rescue StandardError => e
      Flowbots::UI.exception "#{e.message}"
      exit
    end




    if parse_tree
      content = parse_tree.markdown_content.text_value
      metadata = extract_metadata(parse_tree.yaml_front_matter)
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
    return {} unless yaml_front_matter

    yaml_content = yaml_front_matter.text_value.gsub(/^---\n/, '').gsub(/---\n$/, '')
    YAML.safe_load(yaml_content)
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
