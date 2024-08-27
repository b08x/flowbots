#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs natural language processing (NLP) analysis on the segments of a text file.
class NlpAnalysisTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting NlpAnalysisTask"

    textfile = retrieve_input
    nlp_processor = Flowbots::NLPProcessor.instance

    lemma_counts = Hash.new(0)

    textfile.retrieve_segments.each do |segment|
      processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true, lemma: true)
      update_segment_with_nlp_data(segment, processed_tokens, lemma_counts)
    end

    add_lemmas_to_textfile(textfile, lemma_counts)

    logger.info "NlpAnalysisTask completed"
  end

  private

  def retrieve_input
    retrieve_file_object
  end

  def update_segment_with_nlp_data(segment, processed_tokens, lemma_counts)
    tagged = { pos: {}, dep: {}, ner: {}, tag: {} }
    processed_tokens.each do |token|
      word = token[:word]
      tagged[:pos][word] = token[:pos]
      tagged[:dep][word] = token[:dep]
      tagged[:ner][word] = token[:ner]
      tagged[:tag][word] = token[:tag]

      lemma_key = [token[:lemma], token[:pos]]
      lemma_counts[lemma_key] += 1
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

  def add_lemmas_to_textfile(textfile, lemma_counts)
    lemmas_data = lemma_counts.map do |(lemma, pos), count|
      { lemma:, pos:, count: }
    end
    textfile.add_lemmas(lemmas_data)
  end
end
