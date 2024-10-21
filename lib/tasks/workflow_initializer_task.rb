#!/usr/bin/env ruby
# frozen_string_literal: true

# This task initializes a workflow based on the specified workflow type.
class WorkflowInitializerTask < Jongleur::WorkerTask
  # The batch size for processing files in a batch workflow.
  BATCH_SIZE = 10

  # Executes the workflow initialization task.
  #
  # Determines the workflow type from Redis and initializes either a batch workflow
  # or a single file workflow accordingly.
  #
  # @return [void]
  def execute
    workflow_type = Ohm.redis.get("workflow_type")

    if workflow_type == "topic_model_trainer"
      initialize_batch_workflow
    else
      initialize_single_file_workflow
    end
  end

  private

  # Initializes a batch workflow for topic model training.
  #
  # Retrieves the input folder path from Redis, creates a new workflow,
  # and creates batches of source files based on the specified batch size.
  #
  # @return [void]
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

  # Initializes a single file workflow for text processing.
  #
  # Retrieves the input file path from Redis, creates a new workflow,
  # and associates the input file with the workflow.
  #
  # @return [void]
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

  # Creates batches of source files for a batch workflow.
  #
  # Iterates through the file paths in batches and creates a new batch
  # for each slice of files. Each source file is associated with its
  # corresponding batch and workflow.
  #
  # @param workflow [Workflow] The workflow to associate the batches with.
  # @param file_paths [Array<String>] The list of file paths to create batches from.
  #
  # @return [void]
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
