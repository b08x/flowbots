#!/usr/bin/env ruby
# frozen_string_literal: true

class NlpAnalysisTask < Jongleur::WorkerTask
  def execute
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    text_file = Textfile[textfile_id]

    logger.info "Processing NlpAnalysisTask for file: #{text_file.name}"

    nlp_processor = Flowbots::NLPProcessor.instance

    text_file.retrieve_segments.each do |segment|
      begin
        logger.debug "Processing segment: #{segment.id}"
        processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true)

        logger.debug "Processed tokens: #{processed_tokens.inspect}"

        if processed_tokens.nil? || !processed_tokens.is_a?(Array)
          logger.warn "NLP processing returned invalid result for segment #{segment.id}: #{processed_tokens.inspect}"
          next
        end

        tagged = {
          pos: {},
          dep: {},
          ner: {},
          tag: {}
        }

        processed_tokens.each do |token|
          word = token[:word]
          tagged[:pos][word] = token[:pos]
          tagged[:dep][word] = token[:dep]
          tagged[:ner][word] = token[:ner]
          tagged[:tag][word] = token[:tag]
        end

        segment.update(tagged: tagged)
        logger.debug "Updated segment #{segment.id} with tagged data: #{tagged.inspect}"

        add_words_to_segment(segment, processed_tokens)
      rescue StandardError => e
        logger.error "Error processing segment #{segment.id}: #{e.message}"
        logger.error e.backtrace.join("\n")
      end
    end

    logger.info "Completed NlpAnalysisTask for file: #{text_file.name}"
  end

  private

  def add_words_to_segment(segment, processed_tokens)
    words = processed_tokens.map do |token|
      {
        word: token[:word],
        pos: token[:pos],
        tag: token[:tag],
        dep: token[:dep],
        ner: token[:ner]
      }
    end
    segment.add_words(words)
  end
end
