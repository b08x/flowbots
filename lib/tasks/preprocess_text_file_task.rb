#!/usr/bin/env ruby
# frozen_string_literal: true

class PreprocessTextFileTask < Jongleur::WorkerTask
  def execute
    workflow_id = Ohm.redis.get("current_workflow_id")
    workflow = Workflow[workflow_id]

    if workflow.is_batch_workflow
      preprocess_batch_files(workflow)
    else
      preprocess_single_file(workflow)
    end
  end

  private

  def preprocess_batch_files(workflow)
    current_batch = workflow.batches.find(number: workflow.current_batch_number).first
    current_batch.sourcefiles.each do |sourcefile|
      preprocess_file(sourcefile)
    end
    logger.info "Preprocessed files for Batch #{current_batch.number}"
  end

  def preprocess_single_file(workflow)
    sourcefile = workflow.sourcefiles.first
    preprocess_file(sourcefile)
    logger.info "Preprocessed single file: #{sourcefile.path}"
  end

  def preprocess_file(sourcefile)
    grammar_processor = Flowbots::GrammarProcessor.new('markdown_yaml')
    parse_result = grammar_processor.parse(sourcefile.content)

    if parse_result
      sourcefile.update(
        preprocessed_content: parse_result[:markdown_content],
        metadata: extract_metadata(parse_result[:yaml_front_matter])
      )
      logger.info "Successfully preprocessed file: #{sourcefile.path}"
    else
      logger.error "Failed to parse the document with custom grammar: #{sourcefile.path}"
      sourcefile.update(
        preprocessed_content: sourcefile.content,
        metadata: {}
      )
    end
  end

  def extract_metadata(yaml_front_matter)
    YAML.safe_load(yaml_front_matter)
  rescue StandardError => e
    logger.error "Error parsing YAML front matter: #{e.message}"
    {}
  end
end
