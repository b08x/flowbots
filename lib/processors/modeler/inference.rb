#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TopicModelProcessor < TextProcessor
    private

    def infer_topics(text)
      doc = @model.make_doc(text.split)
      topic_dist, ll = @model.infer(doc)

      return {} if topic_dist.nil?

      most_probable_topic = topic_dist.each_with_index.max_by { |prob, _| prob }[1]
      top_words = @model.topic_words(most_probable_topic, top_n: 10)

      {
        most_probable_topic:,
        topic_distribution: topic_dist.to_a, # Convert to array to ensure it can be serialized to JSON
        top_words:
      }
    end
  end
end
