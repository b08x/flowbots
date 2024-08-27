#!/usr/bin/env ruby
# frozen_string_literal: true

# This task displays the results of the text processing workflow.
class DisplayResultsTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting DisplayResultsTask"

    textfile = retrieve_input
    analysis_result = textfile.llm_analysis

    display_results(textfile, analysis_result)

    logger.info "DisplayResultsTask completed"
  end

  private

  def retrieve_input
    retrieve_file_object
  end

  def display_results(textfile, analysis_result)
    file_info = format_file_info(textfile)
    analysis = format_analysis(analysis_result)

    puts UI::ScrollableBox.side_by_side_boxes(
      file_info,
      analysis,
      title1: "File Information",
      title2: "LLM Analysis Result"
    )
  end

  def format_file_info(textfile)
    <<~INFO
      Filename: #{textfile.name}
      Topics: #{textfile.topics.to_a.map(&:name).join(', ')}

      Content Preview:
      #{textfile.content}

      Total Segments: #{textfile.segments.count}
      Total Words: #{textfile.lemmas.count}
    INFO
  end

  def format_analysis(analysis_result)
    analysis_result.is_a?(String) ? analysis_result : JSON.pretty_generate(analysis_result)
  end
end
