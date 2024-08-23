#!/usr/bin/env ruby
# frozen_string_literal: true

# This task accumulates filtered segments from multiple batches.
class AccumulateFilteredSegmentsTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the current filtered segments from Redis.
    current_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_filtered_segments") || "[]")

    # Retrieve the accumulated filtered segments from Redis.
    all_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("all_filtered_segments") || "[]")

    # Clean the current filtered segments.
    cleaned_segments = clean_segments(current_filtered_segments)

    # Append the cleaned segments to the accumulated filtered segments.
    all_filtered_segments += cleaned_segments

    # Store the updated accumulated filtered segments in Redis.
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("all_filtered_segments", all_filtered_segments.to_json)

    # Log a message indicating the number of accumulated segments.
    logger.info "Accumulated #{cleaned_segments.length} cleaned segments. Total segments: #{all_filtered_segments.length}"
  end

  private

  # Cleans the filtered segments by removing empty segments, segments with specific keywords, and purely numeric words.
  #
  # @param segments [Array] The array of filtered segments.
  #
  # @return [Array] The cleaned array of filtered segments.
  def clean_segments(segments)
    segments.reject do |segment|
      segment.empty? ||
        segment == %w[layout page] ||
        segment == ["true"] ||
        segment.first == "date" ||
        segment.include?("tags") ||
        segment.include?("title") ||
        segment.include?("toc")
    end.map do |segment|
      segment.reject { |word| word.to_s.match?(/^\d+$/) } # Remove purely numeric words
    end.reject(&:empty?)
  end
end
