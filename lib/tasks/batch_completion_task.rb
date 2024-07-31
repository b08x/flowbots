#!/usr/bin/env ruby
# frozen_string_literal: true

class BatchCompletionTask < Jongleur::WorkerTask
  def execute
    workflow_id = Ohm.redis.get("current_workflow_id")
    workflow = Workflow[workflow_id]

    if workflow.is_batch_workflow
      complete_batch(workflow)
    else
      complete_single_file_workflow(workflow)
    end
  end

  private

  def complete_batch(workflow)
    current_batch = workflow.batches.find(number: workflow.current_batch_number).first
    current_batch.update(status: "completed")

    if workflow.current_batch_number < workflow.batches.count
      workflow.update(current_batch_number: workflow.current_batch_number + 1)
      logger.info "Completed Batch #{current_batch.number}, moving to next batch"
    else
      workflow.update(status: "completed", end_time: Time.now.to_s)
      logger.info "All batches completed. Workflow finished."
    end
  end

  def complete_single_file_workflow(workflow)
    workflow.update(status: "completed", end_time: Time.now.to_s)
    logger.info "Single file workflow completed. File: #{workflow.sourcefiles.first.path}"
  end
end
