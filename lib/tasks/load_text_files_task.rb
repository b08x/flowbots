#!/usr/bin/env ruby
# frozen_string_literal: true

class LoadTextFilesTask < Jongleur::WorkerTask
  def execute
    workflow_id = Ohm.redis.get("current_workflow_id")
    workflow = Workflow[workflow_id]

    if workflow.is_batch_workflow
      load_batch_files(workflow)
    else
      load_single_file(workflow)
    end
  end

  private

  def load_batch_files(workflow)
    current_batch = workflow.batches.find(number: workflow.current_batch_number).first
    current_batch.update(status: "processing")

    current_batch.sourcefiles.each do |sourcefile|
      load_file(sourcefile)
    end

    Ohm.redis.set("current_batch_id", current_batch.id)
    logger.info "Loaded files for Batch #{current_batch.number}"
  end

  def load_single_file(workflow)
    sourcefile = workflow.sourcefiles.first
    load_file(sourcefile)
    logger.info "Loaded single file: #{sourcefile.path}"
  end

  def load_file(sourcefile)
    file_loader = Flowbots::FileLoader.new(sourcefile.path)
    sourcefile.update(content: file_loader.file_data.content)
    logger.debug "Loaded file: #{sourcefile.path}"
  end
end
