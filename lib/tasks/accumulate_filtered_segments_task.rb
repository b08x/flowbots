#!/usr/bin/env ruby
# frozen_string_literal: true

class AccumulateFilteredSegmentsTask < Jongleur::WorkerTask
  include InputRetrieval

  def execute
    logger.info "Starting AccumulateFilteredSegmentsTask"

    # Retrieve the current filtered segments from Redis
    current_filtered_segments = JSON.parse(RedisKeys.get("current_filtered_segments") || "[]")

    # Retrieve the accumulated filtered segments from Redis
    all_filtered_segments = JSON.parse(RedisKeys.get("all_filtered_segments") || "[]")

    # Clean the current filtered segments
    cleaned_segments = clean_segments(current_filtered_segments)

    # Append the cleaned segments to the accumulated filtered segments
    all_filtered_segments += cleaned_segments

    # Store the updated accumulated filtered segments in Redis
    RedisKeys.set("all_filtered_segments", all_filtered_segments.to_json)

    # Log a message indicating the number of accumulated segments
    logger.info "Accumulated #{cleaned_segments.length} cleaned segments. Total segments: #{all_filtered_segments.length}"

    # Update the FileObject with the accumulated segments
    update_file_object(cleaned_segments)

    logger.info "Completed AccumulateFilteredSegmentsTask"
  end

  private

  def retrieve_input
    retrieve_file_object
  end

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

  def update_file_object(cleaned_segments)
    file_object = retrieve_input
    return if file_object.nil?

    file_object.add_segments(cleaned_segments.map { |segment| segment.join(" ") })
    logger.info "Updated FileObject #{file_object.id} with #{cleaned_segments.length} new segments"
  end
end
