#!/usr/bin/env ruby
# frozen_string_literal: true

class TopicModelingTask < Jongleur::WorkerTask
  def execute
    Flowbots::UI.info "Starting TopicModelingTask"
    processed_documents = retrieve_processed_documents
    topic_processor = Flowbots::TopicModelProcessor.instance
    result = topic_processor.process(processed_documents)
    store_topic_result(result)
    logger.info "TopicModelingTask completed"
  end

  private

  def retrieve_processed_documents
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
  end

  def store_topic_result(result)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("topic_result", result.to_json)
  end
end