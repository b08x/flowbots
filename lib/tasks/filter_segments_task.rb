#!/usr/bin/env ruby
# frozen_string_literal: true

# lib/tasks/filter_segments_task.rb

class FilterSegmentsTask < Jongleur::WorkerTask
  include InputRetrieval

  # Executes the segment filtering task.
  #
  # Retrieves the file object, filters segments based on word tags,
  # stores the filtered segments in Redis, logs relevant information,
  # and displays the filtered segments to the user.
  #
  # @return [void]
  def execute
    file_object = retrieve_input

    logger.info "Processing FilterSegmentsTask for file: #{file_object.name}"

    filtered_segments = filter_segments(file_object)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_filtered_segments", filtered_segments.to_json)

    logger.info "Filtered #{filtered_segments.length} segments"

    display_filtered_segments(filtered_segments)
  end

  private

  # Retrieves the input file object.
  #
  # @return [FileObject] The retrieved file object.
  def retrieve_input
    retrieve_file_object
  end

  # Filters segments based on their word tags.
  #
  # @param file_object [FileObject] The file object containing the segments.
  # @return [Array<Array<String>>] An array of filtered segments, where each segment is an array of words.
  def filter_segments(file_object)
    segments = file_object.segments

    segments.map do |segment|
      filter_segment_words(segment)
    end.compact
  end

  # Filters words from a segment based on relevant parts of speech (POS) tags.
  #
  # @param segment [Segment] The segment to filter words from.
  # @return [Array<String>, nil] An array of filtered words or nil if the segment has invalid tagged data.
  def filter_segment_words(segment)

    logger.debug "Processing segment: #{segment.id}"

    tagged = segment.tagged

    if tagged.nil? || !tagged.is_a?(Hash) || !tagged["pos"]
      logger.warn "Segment #{segment.id} has invalid tagged data: #{tagged.inspect}"
      return nil
    end

    relevant_pos = %w[PROPN NOUN]
    relevant_dep = %w[nsubj compound nsubjpass]
    relevant_ner = %w[PERSON ORGANIZATION]

    words = tagged["pos"].keys

    filtered_words = words.select do |word|
      relevant_pos.include?(tagged["pos"][word]) ||
        relevant_dep.include?(tagged["dep"][word]) ||
        relevant_ner.include?(tagged["ner"][word])
    end

    logger.debug "Filtered #{filtered_words.length} words from segment #{segment.id}"

    filtered_words
  end

  # Displays the filtered segments to the user.
  #
  # @param filtered_segments [Array<Array<String>>] An array of filtered segments.
  # @return [void]
  def display_filtered_segments(filtered_segments)
    UI.say(:ok, "#{filtered_segments}")
  end
end
