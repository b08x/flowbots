#!/usr/bin/env ruby
# frozen_string_literal: true

# This task displays the results of the text processing workflow.
class DisplayResultsTask < Task
  include InputRetrieval

  # Executes the task to display the results of the text processing workflow.
  #
  # Retrieves the processed Textfile object and its LLM analysis results.
  # Formats and displays the file information and analysis results in a user-friendly format.
  #
  # @return [void]
  def execute
    logger.info "Starting DisplayResultsTask"

    textfile = retrieve_input
    analysis_result = textfile.llm_analysis

    display_results(textfile, analysis_result)

    logger.info "DisplayResultsTask completed"
  end

  private

  # Retrieves the input for the task, which is the current FileObject.
  #
  # @return [FileObject] The current FileObject.
  def retrieve_input
    retrieve_file_object
  end

  # Displays the results of the text processing workflow.
  #
  # @param textfile [Textfile] The processed Textfile object.
  # @param analysis_result [String, Hash] The LLM analysis results.
  #
  # @return [void]
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

  # Formats the file information for display.
  #
  # @param textfile [Textfile] The processed Textfile object.
  #
  # @return [String] The formatted file information.
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

  # Formats the analysis results for display.
  #
  # @param analysis_result [String, Hash] The LLM analysis results.
  #
  # @return [String] The formatted analysis results.
  def format_analysis(analysis_result)
    analysis_result.is_a?(String) ? analysis_result : JSON.pretty_generate(analysis_result)
  end
end
