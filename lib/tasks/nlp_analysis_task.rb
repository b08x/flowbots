#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs natural language processing (NLP) analysis on the segments of a text file.
class NlpAnalysisTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting NlpAnalysisTask"

    textfile = retrieve_input
    nlp_processor = Flowbots::NLPProcessor.instance

    textfile.retrieve_segments.each do |segment|
      processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true)
      update_segment_with_nlp_data(segment, processed_tokens)
    end

    logger.info "NlpAnalysisTask completed"
  end

  private

  def retrieve_input
    retrieve_textfile
  end

  def update_segment_with_nlp_data(segment, processed_tokens)
    tagged = { pos: {}, dep: {}, ner: {}, tag: {} }
    processed_tokens.each do |token|
      word = token[:word]
      tagged[:pos][word] = token[:pos]
      tagged[:dep][word] = token[:dep]
      tagged[:ner][word] = token[:ner]
      tagged[:tag][word] = token[:tag]
    end
    segment.update(tagged:)
    add_words_to_segment(segment, processed_tokens)
  end

  def add_words_to_segment(segment, processed_tokens)
    words = processed_tokens.map do |token|
      { word: token[:word], pos: token[:pos], tag: token[:tag], dep: token[:dep], ner: token[:ner] }
    end
    segment.add_words(words)
  end
end
