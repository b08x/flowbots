#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs topic modeling on a text file using a pre-trained model.
class TopicModelingTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task to perform topic modeling on a FileObject.
  #
  # Retrieves the FileObject from Redis, extracts filtered words from its segments,
  # loads or creates a topic model using the TopicModelProcessor, infers topics
  # for each set of filtered words, stores the topic results in the FileObject,
  # and logs the progress.
  #
  # @return [void]
  def execute
    # Log the start of the task.
    logger.info "Starting TopicModelingTask"

    # Retrieve the FileObject from Redis.
    textfile = retrieve_input
    # Retrieve filtered words from the FileObject's segments.
    filtered_words = retrieve_filtered_words(textfile)

    # Get an instance of the TopicModelProcessor.
    topic_processor = Flowbots::TopicModelProcessor.instance
    # Load or create a topic model.
    topic_processor.load_or_create_model

    # Infer topics for each set of filtered words.
    results = filtered_words.map do |words|
      topic_processor.infer_topics(words.join(" "))
    end

    # Store the topic results in the FileObject.
    store_topic_result(textfile, results)

    # Log the completion of the task.
    logger.info "TopicModelingTask completed"
  end

  private

  # Retrieves the input for the task, which is the current FileObject.
  #
  # @return [FileObject] The current FileObject.
  def retrieve_input
    retrieve_file_object
  end

  # Retrieves filtered words from the segments of the given FileObject.
  #
  # @param textfile [FileObject] The FileObject to retrieve filtered words from.
  #
  # @return [Array<Array<String>>] An array of arrays, where each inner array contains
  #   filtered words from a segment.
  def retrieve_filtered_words(textfile)
    # Retrieve the segments from the FileObject.
    segments = textfile.retrieve_segments
    # Filter words from each segment and flatten the resulting array.
    segments.flat_map { |segment| filter_segment_words(segment) }
  end

  # Filters words from a segment based on their POS tags.
  #
  # @param segment [Segment] The segment to filter words from.
  #
  # @return [Array<String>] An array of filtered words.
  def filter_segment_words(segment)
    # Define the relevant POS tags for filtering.
    relevant_tags = %w[NN JJ RB]
    # Retrieve the POS tagged tokens from the segment.
    tokens = segment.tagged&.[]("pos") || []
    # Select tokens with relevant POS tags and extract their words.
    tokens.select { |token| relevant_tags.include?(token["tag"]) }
      .map { |token| token["word"] }
  end

  # Stores the topic modeling results in the given FileObject.
  #
  # Extracts unique words from the topic results, adds them as topics to the
  # FileObject, and logs the progress.
  #
  # @param textfile [FileObject] The FileObject to store the topic results in.
  # @param result [Array<Hash>] An array of topic modeling results.
  #
  # @return [void]
  def store_topic_result(textfile, result)
    # Extract unique words from the topic results.
    unique_words = result.each_with_object(Set.new) do |hash, words|
      # Add top words from the topic.
      hash[:top_words].keys.each do |key|
        words << key if key.is_a?(String) && key.match?(/^[a-zA-Z]+$/)
      end
      # Add sorted words from the topic.
      hash[:sorted_words].each do |word|
        words << word[0] if word[0].is_a?(String) && word[0].match?(/^[a-zA-Z]+$/)
      end
    end

    # Add the unique words as topics to the FileObject.
    textfile.add_topics(unique_words.to_a)
    # Log the number of topics stored.
    logger.info "Stored #{result.length} topics for Textfile #{textfile.id}"
  end
end
