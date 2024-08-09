#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs topic modeling on a text file using a pre-trained model.
class TopicModelingTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the current Textfile object from Redis.
    text_file = retrieve_current_textfile

    # Retrieve filtered words from the Textfile.
    filtered_words = retrieve_filtered_words(text_file)

    # Get an instance of the TopicModelProcessor.
    topic_processor = Flowbots::TopicModelProcessor.instance

    # Load or create the topic model.
    topic_processor.load_or_create_model

    # Infer topics for each set of filtered words.
    results = filtered_words.map do |words|
      topic_processor.infer_topics(words.join(" "))
    end

    # Store the topic modeling results in the Textfile.
    store_topic_result(text_file, results)
  end

  private

  # Retrieves the current Textfile object from Redis.
  #
  # @return [Textfile] The Textfile object representing the current file.
  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  # Retrieves filtered words from the Textfile.
  #
  # @param text_file [Textfile] The Textfile object.
  #
  # @return [Array] An array of filtered words.
  def retrieve_filtered_words(text_file)
    # Retrieve segments from the Textfile.
    segments = text_file.retrieve_segments

    # Filter words from each segment based on their tags.
    filtered_words = segments.flat_map do |segment|
      filter_segment_words(segment)
    end

    # Log the number of filtered words retrieved.
    logger.info "Retrieved #{filtered_words.length} filtered words for topic modeling"

    # Return the filtered words.
    filtered_words
  end

  # Filters words from a segment based on their tags.
  #
  # @param segment [Segment] The Segment object.
  #
  # @return [Array] An array of filtered words.
  def filter_segment_words(segment)
    # Define the relevant tags for filtering.
    relevant_tags = %w[NN JJ RB]

    # Get the tokens from the segment's tagged data.
    tokens = segment.tagged["tokens"] || []

    # Select tokens with relevant tags and extract their words.
    tokens.select { |token| relevant_tags.include?(token["tag"]) }
      .map { |token| token["word"] }
  end

  # Stores the topic modeling results in the Textfile.
  #
  # @param text_file [Textfile] The Textfile object.
  # @param result [Array] The topic modeling results.
  #
  # @return [void]
  def store_topic_result(text_file, result)
    # Create a set of unique words from the topic modeling results.
    unique_words = result.each_with_object(Set.new) do |hash, words|
      hash[:top_words].keys.each do |key|
        # Check if the key is a string and only contains letters.
        words << key if key.is_a?(String) && key.match?(/^[a-zA-Z]+$/)
      end
      hash[:sorted_words].each do |word|
        # Check if the key is a string and only contains letters.
        words << word[0] if word[0].is_a?(String) && word[0].match?(/^[a-zA-Z]+$/)
      end
    end

    # Add the unique words as topics to the Textfile.
    begin
      text_file.add_topics(unique_words.to_a)
    rescue StandardError => e
      logger.warn "#{e.message}"
    end

    # Log the number of topics stored.
    logger.info "Stored #{result.length} topics for Textfile #{text_file.id}"
  end
end
