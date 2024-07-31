#!/usr/bin/env ruby
# frozen_string_literal: true

class TextSegmentTask < Jongleur::WorkerTask
  def execute
    workflow_id = Ohm.redis.get("current_workflow_id")
    workflow = Workflow[workflow_id]

    if workflow.is_batch_workflow
      segment_batch_files(workflow)
    else
      segment_single_file(workflow)
    end
  end

  private

  def segment_batch_files(workflow)
    current_batch = workflow.batches.find(number: workflow.current_batch_number).first
    current_batch.sourcefiles.each do |sourcefile|
      segment_file(sourcefile)
    end
    logger.info "Segmented files for Batch #{current_batch.number}"
  end

  def segment_single_file(workflow)
    sourcefile = workflow.sourcefiles.first
    segment_file(sourcefile)
    logger.info "Segmented single file: #{sourcefile.path}"
  end

  def segment_file(sourcefile)
    text_segmenter = Flowbots::TextSegmentProcessor.instance
    segments = text_segmenter.process(sourcefile.preprocessed_content, { clean: true })

    segments.each do |segment_text|
      Segment.create(text: segment_text, sourcefile: sourcefile)
    end

    logger.debug "Created #{segments.length} segments for file: #{sourcefile.path}"
  end
end
