#!/usr/bin/env ruby
# frozen_string_literal: true

class NlpAnalysisTask < Jongleur::WorkerTask
  def execute
    logger.info "Starting NLPAnalysisTask"
    processed_text = retrieve_processed_text
    nlp_processor = Flowbots::NLPProcessor.instance
    result = nlp_processor.process(processed_text)
    store_nlp_result(result)
    logger.info "NLPAnalysisTask completed"
  end

  private

  def retrieve_processed_text
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
  end

  def store_nlp_result(result)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("nlp_result", result.to_json)
  end
end
