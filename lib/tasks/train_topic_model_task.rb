#!/usr/bin/env ruby
# frozen_string_literal: true

# This task trains a topic model using filtered segments from multiple batches.
class TrainTopicModelTask < Jongleur::WorkerTask
  # Executes the task to train a topic model using accumulated filtered segments.
  #
  # Retrieves the current batch ID and filtered segments from Redis. Accumulates
  # filtered segments across batches and trains the topic model only on the last
  # batch. Logs and displays progress messages.
  #
  # @return [void]
  def execute
    # Retrieve the current batch ID from Redis.
    batch_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_batch_id")
    logger.info "Processing TrainTopicModelTask for batch #{batch_id}"

    # Retrieve filtered segments from Redis.
    filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("filtered_segments") || "[]")

    # Accumulate filtered segments across batches.
    all_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("all_filtered_segments") || "[]")
    all_filtered_segments += filtered_segments
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("all_filtered_segments", all_filtered_segments.to_json)

    # Only train the model on the last batch.
    if batch_id.end_with?(
      "_#{(Dir.glob(
        File.join(
          @input_folder,
          '*.txt'
        )
      ).count.to_f / Flowbots::TopicModelTrainerWorkflow::BATCH_SIZE).ceil}"
    )
      # Create an instance of the TopicModelProcessor.
      topic_processor = Flowbots::TopicModelProcessor.instance

      # Train the topic model using the accumulated filtered segments.
      topic_processor.train_model(all_filtered_segments)

      # Log and display a success message.
      logger.info "Topic model training completed for all batches"
      UI.say(:ok, "Topic model training completed for all batches")
    else
      # Log and display a message indicating that filtered segments have been accumulated.
      logger.info "Accumulated filtered segments for batch #{batch_id}"
      UI.say(:ok, "Accumulated filtered segments for batch #{batch_id}")
    end
  end
end
