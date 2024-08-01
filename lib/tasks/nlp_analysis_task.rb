#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class NlpAnalysisTask < Jongleur::WorkerTask
    def perform
      nlp_processor = NLPProcessor.instance

      sourcefile.segments.each do |segment|
        processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true)

        tagged = {
          pos: {}, dep: {}, ner: {}, tag: {}
        }

        processed_tokens.each do |token|
          word = token[:word]
          tagged[:pos][word] = token[:pos]
          tagged[:dep][word] = token[:dep]
          tagged[:ner][word] = token[:ner]
          tagged[:tag][word] = token[:tag]

          Word.create(
            word: word,
            pos: token[:pos],
            tag: token[:tag],
            dep: token[:dep],
            ner: token[:ner],
            sourcefile: sourcefile,
            segment: segment
          )
        end

        segment.update(tagged: tagged)
      end

      "Performed NLP analysis for file: #{sourcefile.path}"
    end
  end

  class Word < Ohm::Model
    attribute :word
    attribute :pos
    attribute :tag
    attribute :dep
    attribute :ner
    reference :sourcefile, 'Flowbots::Sourcefile'
    reference :segment, 'Flowbots::Segment'
  end
end
