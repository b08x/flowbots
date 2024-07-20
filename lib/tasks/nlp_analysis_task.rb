#!/usr/bin/env ruby
# frozen_string_literal: true

class NlpAnalysisTask < Jongleur::WorkerTask
  def execute
    segments = Textfile.latest.retrieve_segments

    logger.debug "Number of segments: #{segments.length}"

    nlp_processor = Flowbots::NLPProcessor.instance

    segments.each do |segment|
      processed_tokens = nlp_processor.process(segment)

      tagged_hash = { tokens: processed_tokens }
      segment.update(tagged: tagged_hash)

      segment.add_words(processed_tokens)
    end
  end
end
