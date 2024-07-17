#!/usr/bin/env ruby
# frozen_string_literal: true

class DisplayResultsTask < Jongleur::WorkerTask
  include Logging

  def execute
    logger.info "Starting DisplayResultsTask"

    # raw_text = retrieve_raw_text
    processed_text = retrieve_processed_text
    analysis_result = retrieve_analysis_result

    # Assuming UIBox methods can be called here
    # puts UIBox.comparison_box(analysis_result, processed_text, title1: "Raw Text", title2: "Processed Text")
    puts UIBox.eval_result_box(analysis_result, title: "LLM Analysis Result")

    logger.info "DisplayResultsTask completed"
  end

  private

  def retrieve_raw_text
    # Implement logic to retrieve raw text (e.g., from file or shared storage)
  end

  def retrieve_processed_text
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
  end

  def retrieve_analysis_result
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))
  end
end
