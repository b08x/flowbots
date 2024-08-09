#!/usr/bin/env ruby
# frozen_string_literal: true

class DisplayResultsTask < Jongleur::WorkerTask
  include Logging

  def execute
    logger.info "Starting DisplayResultsTask"

    textfile = retrieve_current_textfile
    analysis_result = textfile.analysis

    display_results(textfile, analysis_result)

    logger.info "DisplayResultsTask completed"
  end

  private

  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  def retrieve_analysis_result
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))
  end

  def display_results(textfile, analysis_result)
    file_info = format_file_info(textfile)
    analysis = format_analysis(analysis_result)

    puts BoxUI.side_by_side_boxes(file_info, analysis,
                                  title1: "File Information",
                                  title2: "LLM Analysis Result")
  end

  def format_file_info(textfile)
    <<~INFO
      Filename: #{textfile.name}
      Topics: #{textfile.topics.to_a.map(&:name).join(", ")}

      Content Preview:
      #{textfile.content}

      Total Segments: #{textfile.segments.count}
      Total Words: #{textfile.words.count}
    INFO
  end

  def format_analysis(analysis_result)
    # If analysis_result is a hash or has a specific structure, format it accordingly
    analysis_result.is_a?(String) ? analysis_result : JSON.pretty_generate(analysis_result)
  end
end
