#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TopicModelingTask < Flowbots::Task
    def execute
      logger.info "Starting TopicModelingTask"
      processed_documents = retrieve_processed_documents
      topic_processor = TopicModelProcessor.instance
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
end
