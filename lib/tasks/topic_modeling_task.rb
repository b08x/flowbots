#!/usr/bin/env ruby
# frozen_string_literal: true

class TopicModelingTask < Jongleur::WorkerTask
  def execute
    Flowbots::UI.info "Starting TopicModelingTask"
    segmented_text = retrieve_segmented_text
    topic_processor = Flowbots::TopicModelProcessor.instance
    result = topic_processor.process(segmented_text)
    store_topic_result(result)
    logger.info "TopicModelingTask completed"
  end

  private

  def retrieve_segmented_text
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("segmented_text"))
  end

  def store_topic_result(result)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("topic_result", result.to_json)
  end
end
