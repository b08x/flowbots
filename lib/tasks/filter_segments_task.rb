#!/usr/bin/env ruby
# frozen_string_literal: true

class FilterSegmentsTask < Jongleur::WorkerTask
  def execute
    filtered_segments = []

    Textfile.current_batch.each do |text_file|
      segments = text_file.retrieve_segments
      segments.each do |segment|
        filtered_words = filter_segment_words(segment)
        filtered_segments << filtered_words if filtered_words.any?
      end
    end

    Jongleur::WorkerTask.class_variable_get(:@@redis).set("filtered_segments", filtered_segments.to_json)
    logger.info "Filtered #{filtered_segments.length} segments for topic modeling"
    Flowbots::UI.say(:ok, "Filtered #{filtered_segments.length} segments for topic modeling")
  end

  private

  def filter_segment_words(segment)
    relevant_pos = ['NOUN', 'ADJ', 'VERB']

    tagged = segment.tagged
    words = tagged[:pos].keys

    words.select { |word| relevant_pos.include?(tagged[:pos][word]) }
  end
end
