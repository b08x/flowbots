#!/usr/bin/env ruby
# frozen_string_literal: true

class NlpAnalysisTask < Jongleur::WorkerTask
  def execute
    nlp_processor = Flowbots::NLPProcessor.instance

    Textfile.current_batch.each do |text_file|
      segments = text_file.retrieve_segments

      logger.debug "Number of segments for #{text_file.name}: #{segments.length}"

      segments.each do |segment|
        processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true)
        segment.update(tagged: processed_tokens)
        add_words_to_segment(segment, processed_tokens)
      end
    end
  end

  private

  def add_words_to_segment(segment, processed_tokens)
    words = processed_tokens[:pos].keys
    word_data = words.map do |word|
      {
        word: word,
        pos: processed_tokens[:pos][word],
        tag: processed_tokens[:tag][word],
        dep: processed_tokens[:dep][word],
        ner: processed_tokens[:ner][word]
      }
    end
    segment.add_words(word_data)
  end
end
