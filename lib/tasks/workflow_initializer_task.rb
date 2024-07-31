#!/usr/bin/env ruby
# frozen_string_literal: true

class WorkflowInitializerTask < Jongleur::WorkerTask
  BATCH_SIZE = 10

  def execute
    workflow_type = Ohm.redis.get("workflow_type")

    if workflow_type == "topic_model_trainer"
      initialize_batch_workflow
    else
      initialize_single_file_workflow
    end
  end

  private

  def initialize_batch_workflow
    input_folder = Ohm.redis.get("input_folder_path")
    all_file_paths = Dir.glob(File.join(input_folder, "**{,/*/**}/*.{md,markdown}")).sort

    workflow = Workflow.create(
      name: "TopicModelTrainerWorkflow",
      status: "started",
      start_time: Time.now.to_s,
      current_batch_number: 1,
      is_batch_workflow: true
    )

    create_batches(workflow, all_file_paths)

    Ohm.redis.set("current_workflow_id", workflow.id)
    logger.info "Initialized Batch Workflow with ID: #{workflow.id}, Total Batches: #{workflow.batches.count}"
  end

  def initialize_single_file_workflow
    input_file_path = Ohm.redis.get("input_file_path")

    workflow = Workflow.create(
      name: "TextProcessingWorkflow",
      status: "started",
      start_time: Time.now.to_s,
      is_batch_workflow: false
    )

    sourcefile = Sourcefile.find_or_create_by_path(input_file_path, workflow: workflow)
    workflow.sourcefiles.add(sourcefile)

    Ohm.redis.set("current_workflow_id", workflow.id)
    Ohm.redis.set("current_file_id", sourcefile.id)
    logger.info "Initialized Single File Workflow with ID: #{workflow.id}, File: #{sourcefile.path}"
  end

  def create_batches(workflow, file_paths)
    file_paths.each_slice(BATCH_SIZE).with_index(1) do |batch_files, batch_number|
      batch = Batch.create(number: batch_number, status: "pending", workflow: workflow)
      batch_files.each do |file_path|
        sourcefile = Sourcefile.find_or_create_by_path(file_path, workflow: workflow, batch: batch)
        batch.sourcefiles.add(sourcefile)
      end
      workflow.batches.add(batch)
    end
  end
end
