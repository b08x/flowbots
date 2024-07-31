#!/usr/bin/env ruby
# frozen_string_literal: true

class AccumulateFilteredSegmentsTask < Jongleur::WorkerTask
  def execute
    current_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_filtered_segments") || "[]")
    all_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("all_filtered_segments") || "[]")

    cleaned_segments = clean_segments(current_filtered_segments)
    all_filtered_segments += cleaned_segments

    Jongleur::WorkerTask.class_variable_get(:@@redis).set("all_filtered_segments", all_filtered_segments.to_json)

    logger.info "Accumulated #{cleaned_segments.length} cleaned segments. Total segments: #{all_filtered_segments.length}"
  end

  private

  def clean_segments(segments)
    segments.reject do |segment|
      segment.empty? ||
      segment == ["layout", "page"] ||
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
