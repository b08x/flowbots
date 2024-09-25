#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/tasks/filter_segments_task.rb

class FilterSegmentsTask < Jongleur::WorkerTask
  include InputRetrieval

  def execute
    # Retrieve the FileObject using the InputRetrieval module
    file_object = retrieve_input

    # Log a message indicating the start of segment filtering for the current file
    logger.info "Processing FilterSegmentsTask for file: #{file_object.name}"

    # Filter segments based on their word tags and store the filtered segments in Redis
    filtered_segments = filter_segments(file_object)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_filtered_segments", filtered_segments.to_json)

    # Log a message indicating the number of filtered segments
    logger.info "Filtered #{filtered_segments.length} segments"

    # Display the filtered segments to the user
    display_filtered_segments(filtered_segments)
  end

  private

  def retrieve_input
    retrieve_file_object
  end

  def filter_segments(file_object)
    # Retrieve all segments from the FileObject
    segments = file_object.segments

    # Filter segments based on their word tags
    segments.map do |segment|
      filter_segment_words(segment)
    end.compact
  end

  def filter_segment_words(segment)
    # Log a message indicating the processing of the current segment
    logger.debug "Processing segment: #{segment.id}"

    # Retrieve the tagged data for the segment
    tagged = segment.tagged

    # Check if the tagged data is valid
    if tagged.nil? || !tagged.is_a?(Hash) || !tagged["pos"]
      # Log a warning message if the tagged data is invalid
      logger.warn "Segment #{segment.id} has invalid tagged data: #{tagged.inspect}"
      return nil
    end

    # Define the relevant parts of speech (POS) tags for filtering
    relevant_pos = %w[NOUN ADJ VERB]

    # Get the words from the segment's POS tagged data
    words = tagged["pos"].keys

    # Filter words based on the relevant POS tags
    filtered_words = words.select { |word| relevant_pos.include?(tagged["pos"][word]) }

    # Log a message indicating the number of filtered words from the segment
    logger.debug "Filtered #{filtered_words.length} words from segment #{segment.id}"

    # Return the filtered words
    filtered_words
  end

  def display_filtered_segments(filtered_segments)
    # Display the filtered segments in a framed box
    UI.say(:ok, "#{filtered_segments}")
  end
end
