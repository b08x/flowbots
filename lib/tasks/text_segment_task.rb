#!/usr/bin/env ruby
# frozen_string_literal: true

class TextSegmentTask < Jongleur::WorkerTask
  def execute
    Flowbots::UI.info "Starting Text Segment Task"
    text = retrieve_textfile_text
    text_segmenter = Flowbots::TextSegmentProcessor.instance
    result = text_segmenter.process(text, { clean: true })
    store_segmented_text(result)
    Flowbots::UI.info "Text Segment Task completed"
  end

  private

  def retrieve_textfile_text
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("textfile_text"))
  end

  def store_segmented_text(result)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("segmented_text", result.to_json)
  end
end
