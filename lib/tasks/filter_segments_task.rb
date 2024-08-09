#!/usr/bin/env ruby
# frozen_string_literal: true

# This task filters segments based on their word tags.
class FilterSegmentsTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the Textfile object from Redis using its ID.
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    text_file = Textfile[textfile_id]

    # Log a message indicating the start of segment filtering for the current file.
    logger.info "Processing FilterSegmentsTask for file: #{text_file.name}"

    # Filter segments based on their word tags and store the filtered segments in Redis.
    filtered_segments = filter_segments(text_file)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_filtered_segments", filtered_segments.to_json)

    # Log a message indicating the number of filtered segments.
    logger.info "Filtered #{filtered_segments.length} segments"

    # Display the filtered segments to the user.
    display_filtered_segments(filtered_segments)
  end

  private

  # Filters segments based on their word tags.
  #
  # @param text_file [Textfile] The Textfile object.
  #
  # @return [Array] An array of filtered segments.
  def filter_segments(text_file)
    # Retrieve all segments from the Textfile.
    segments = text_file.retrieve_segments

    # Filter segments based on their word tags.
    segments.map do |segment|
      filter_segment_words(segment)
    end.compact

    # Return the filtered segments.
  end

  # Filters words from a segment based on their tags.
  #
  # @param segment [Segment] The Segment object.
  #
  # @return [Array] An array of filtered words, or nil if the segment has invalid tagged data.
  def filter_segment_words(segment)
    # Log a message indicating the processing of the current segment.
    logger.debug "Processing segment: #{segment.id}"

    # Retrieve the tagged data for the segment.
    tagged = segment.tagged

    # Check if the tagged data is valid.
    if tagged.nil? || !tagged.is_a?(Hash) || !tagged["pos"]
      # Log a warning message if the tagged data is invalid.
      logger.warn "Segment #{segment.id} has invalid tagged data: #{tagged.inspect}"
      return nil
    end

    # Define the relevant parts of speech (POS) tags for filtering.
    relevant_pos = %w[NOUN ADJ VERB]

    # Get the words from the segment's POS tagged data.
    words = tagged["pos"].keys

    # Filter words based on the relevant POS tags.
    filtered_words = words.select { |word| relevant_pos.include?(tagged["pos"][word]) }

    # Log a message indicating the number of filtered words from the segment.
    logger.debug "Filtered #{filtered_words.length} words from segment #{segment.id}"

    # Return the filtered words.
    filtered_words
  end

  # Displays the filtered segments to the user.
  #
  # @param filtered_segments [Array] An array of filtered segments.
  #
  # @return [void]
  def display_filtered_segments(filtered_segments)
    # Display the filtered segments in a framed box.
    ui.framed do
      ui.puts "#{filtered_segments}"
    end
    ui.space
  end
end
