#!/usr/bin/env ruby
# frozen_string_literal: true

class TrainTopicModelTask < Jongleur::WorkerTask
  def execute
    batch_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_batch_id")
    logger.info "Processing TrainTopicModelTask for batch #{batch_id}"

    filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("filtered_segments") || "[]")

    # Accumulate filtered segments across batches
    all_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("all_filtered_segments") || "[]")
    all_filtered_segments += filtered_segments
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("all_filtered_segments", all_filtered_segments.to_json)

    # Only train the model on the last batch
    if batch_id.end_with?("_#{(Dir.glob(File.join(@input_folder, "*.txt")).count.to_f / Flowbots::TopicModelTrainerWorkflow::BATCH_SIZE).ceil}")
      topic_processor = Flowbots::TopicModelProcessor.instance
      topic_processor.train_model(all_filtered_segments)
      logger.info "Topic model training completed for all batches"
      Flowbots::UI.say(:ok, "Topic model training completed for all batches")
    else
      logger.info "Accumulated filtered segments for batch #{batch_id}"
      Flowbots::UI.say(:ok, "Accumulated filtered segments for batch #{batch_id}")
    end
  end
end
