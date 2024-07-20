#!/usr/bin/env ruby
# frozen_string_literal: true

class NlpAnalysisTask < Jongleur::WorkerTask
  def execute
    Flowbots::UI.info "Starting NLPAnalysisTask"
    segmented_text = retrieve_segmented_text
    nlp_processor = Flowbots::NLPProcessor.instance
    result = nlp_processor.process(segmented_text)
    store_nlp_result(result)
    logger.info "NLPAnalysisTask completed"
  end

  private

  def retrieve_segmented_text
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("segmented_text"))
  end

  def store_nlp_result(result)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("nlp_result", result.to_json)
  end
end
