#!/usr/bin/env ruby
# frozen_string_literal: true

class TrainTopicModelTask < Jongleur::WorkerTask
  def execute
    tokenized_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("filtered_segments"))
    topic_processor = Flowbots::TopicModelProcessor.instance

    topic_processor.train_model(tokenized_segments)

    logger.info "Topic model training completed"
    Flowbots::UI.say(:ok, "Topic model training completed")
  end
end
