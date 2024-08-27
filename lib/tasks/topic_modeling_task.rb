#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs topic modeling on a text file using a pre-trained model.
class TopicModelingTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting TopicModelingTask"

    textfile = retrieve_input
    filtered_words = retrieve_filtered_words(textfile)

    topic_processor = Flowbots::TopicModelProcessor.instance
    topic_processor.load_or_create_model

    results = filtered_words.map do |words|
      topic_processor.infer_topics(words.join(" "))
    end

    store_topic_result(textfile, results)

    logger.info "TopicModelingTask completed"
  end

  private

  def retrieve_input
    retrieve_file_object
  end

  def retrieve_filtered_words(textfile)
    segments = textfile.retrieve_segments
    segments.flat_map { |segment| filter_segment_words(segment) }
  end

  def filter_segment_words(segment)
    relevant_tags = %w[NN JJ RB]
    tokens = segment.tagged&.[]("pos") || []
    tokens.select { |token| relevant_tags.include?(token["tag"]) }
      .map { |token| token["word"] }
  end

  def store_topic_result(textfile, result)
    unique_words = result.each_with_object(Set.new) do |hash, words|
      hash[:top_words].keys.each do |key|
        words << key if key.is_a?(String) && key.match?(/^[a-zA-Z]+$/)
      end
      hash[:sorted_words].each do |word|
        words << word[0] if word[0].is_a?(String) && word[0].match?(/^[a-zA-Z]+$/)
      end
    end

    textfile.add_topics(unique_words.to_a)
    logger.info "Stored #{result.length} topics for Textfile #{textfile.id}"
  end
end
