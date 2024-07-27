#!/usr/bin/env ruby
# frozen_string_literal: true

class FilterSegmentsTask < Jongleur::WorkerTask
  def execute
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    text_file = Textfile[textfile_id]

    logger.info "Processing FilterSegmentsTask for file: #{text_file.name}"

    filtered_segments = text_file.retrieve_segments.map do |segment|
      filter_segment_words(segment)
    end.compact

    Flowbots::UI.info "Filtered #{filtered_segments.length} segments"

    ui.framed do
      ui.puts "#{filtered_segments}"
    end
    ui.space

    Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_filtered_segments", filtered_segments.to_json)
  end

  private

  def filter_segment_words(segment)
    logger.debug "Processing segment: #{segment.id}"

    tagged = segment.tagged
    if tagged.nil? || !tagged.is_a?(Hash) || !tagged["pos"]
      logger.warn "Segment #{segment.id} has invalid tagged data: #{tagged.inspect}"
      return nil
    end

    relevant_pos = ['NOUN', 'ADJ', 'VERB']

    words = tagged["pos"].keys
    filtered_words = words.select { |word| relevant_pos.include?(tagged["pos"][word]) }

    logger.debug "Filtered #{filtered_words.length} words from segment #{segment.id}"

    filtered_words
  end
end
