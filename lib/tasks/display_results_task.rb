#!/usr/bin/env ruby
# frozen_string_literal: true

# This task displays the results of the text processing workflow.
class DisplayResultsTask < Jongleur::WorkerTask
  include Logging

  # Executes the task.
  #
  # @return [void]
  def execute
    logger.info "Starting DisplayResultsTask"

    # Retrieve the Textfile object from Redis.
    textfile = retrieve_current_textfile

    # Retrieve the analysis result from the Textfile.
    analysis_result = textfile.analysis

    # Display the results in a formatted way.
    display_results(textfile, analysis_result)

    logger.info "DisplayResultsTask completed"
  end

  private

  # Retrieves the current Textfile object from Redis.
  #
  # @return [Textfile] The Textfile object representing the current file.
  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  # # Retrieves the analysis result from Redis.
  # #
  # # @return [Hash] The analysis result.
  # def retrieve_analysis_result
  #   JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))
  # end

  # Displays the results of the text processing workflow.
  #
  # @param textfile [Textfile] The Textfile object.
  # @param analysis_result [String] The analysis result.
  #
  # @return [void]
  def display_results(textfile, analysis_result)
    # Format the file information and analysis result.
    file_info = format_file_info(textfile)
    analysis = format_analysis(analysis_result)

    # Display the formatted information in side-by-side boxes.
    puts BoxUI.side_by_side_boxes(
      file_info,
      analysis,
      title1: "File Information",
      title2: "LLM Analysis Result"
    )
  end

  # Formats the file information for display.
  #
  # @param textfile [Textfile] The Textfile object.
  #
  # @return [String] The formatted file information.
  def format_file_info(textfile)
    <<~INFO
      Filename: #{textfile.name}
      Topics: #{textfile.topics.to_a.map(&:name).join(', ')}

      Content Preview:
      #{textfile.content}

      Total Segments: #{textfile.segments.count}
      Total Words: #{textfile.words.count}
    INFO
  end

  # Formats the analysis result for display.
  #
  # @param analysis_result [String] The analysis result.
  #
  # @return [String] The formatted analysis result.
  def format_analysis(analysis_result)
    # If analysis_result is a hash or has a specific structure, format it accordingly
    analysis_result.is_a?(String) ? analysis_result : JSON.pretty_generate(analysis_result)
  end
end
