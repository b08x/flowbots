#!/usr/bin/env ruby
# frozen_string_literal: true

class TokenizeSegmentsTask < Jongleur::WorkerTask
  def execute
    workflow_id = Ohm.redis.get("current_workflow_id")
    workflow = Workflow[workflow_id]

    if workflow.is_batch_workflow
      tokenize_batch_files(workflow)
    else
      tokenize_single_file(workflow)
    end
  end

  private

  def tokenize_batch_files(workflow)
    current_batch = workflow.batches.find(number: workflow.current_batch_number).first
    current_batch.sourcefiles.each do |sourcefile|
      tokenize_file_segments(sourcefile)
    end
    logger.info "Tokenized segments for Batch #{current_batch.number}"
  end

  def tokenize_single_file(workflow)
    sourcefile = workflow.sourcefiles.first
    tokenize_file_segments(sourcefile)
    logger.info "Tokenized segments for single file: #{sourcefile.path}"
  end

  def tokenize_file_segments(sourcefile)
    text_tokenizer = Flowbots::TextTokenizeProcessor.instance

    sourcefile.segments.each do |segment|
      tokens = text_tokenizer.process(segment.text, { clean: true })
      segment.update(tokens: tokens)
      logger.debug "Tokenized segment #{segment.id} for file: #{sourcefile.path}"
    end
  end
end
