#!/usr/bin/env ruby
# frozen_string_literal: true

class TopicModelingTask < Jongleur::WorkerTask
  def execute
    text_file = Textfile.latest
    filtered_words = retrieve_filtered_words(text_file)

    topic_processor = Flowbots::TopicModelProcessor.instance
    topic_processor.load_or_create_model

    results = filtered_words.map do |words|
      topic_processor.infer_topics(words.join(' '))
    end

    store_topic_result(text_file, results)
  end

  private

  def retrieve_filtered_words(text_file)
    segments = text_file.retrieve_segments

    filtered_words = segments.flat_map do |segment|
      filter_segment_words(segment)
    end

    logger.info "Retrieved #{filtered_words.length} filtered words for topic modeling"
    filtered_words
  end

  def filter_segment_words(segment)
    relevant_tags = ['NN', 'JJ', 'RB']

    tokens = segment.tagged['tokens'] || []

    tokens.select { |token| relevant_tags.include?(token['tag']) }
          .map { |token| token['word'] }
  end

  def store_topic_result(text_file, result)

    unique_words = result.each_with_object(Set.new) do |hash, words|
      hash[:top_words].keys.each do |key|
        # Check if the key is a string and only contains letters
        words << key if key.is_a?(String) && key.match?(/^[a-zA-Z]+$/)
      end
      hash[:sorted_words].each do |word|
        # Check if the key is a string and only contains letters
        words << word[0] if word[0].is_a?(String) && word[0].match?(/^[a-zA-Z]+$/)
      end
    end
    begin
      text_file.add_topics(unique_words.to_a)
    rescue StandardError => e
      logger.warn "#{e.message}"
    end
      # Optionally, you could also associate the topic with relevant segments
      # This depends on how your topic modeling algorithm works
      # and what information it returns in the result

    logger.info "Stored #{result.length} topics for Textfile #{text_file.id}"
  end
end
