#!/usr/bin/env ruby
# frozen_string_literal: true

class TextTaggerTask < Jongleur::WorkerTask
  def execute
    logger.info "Starting TextTaggerTask"

    text_tagger = Flowbots::TextTaggerProcessor.instance

    # input_text = Jongleur::WorkerTask.class_variable_get(:@@redis).get("preprocessed_content")
    textfile = retrieve_input_text

    preprocessed_content = textfile.preprocessed_content

    result = text_tagger.process(preprocessed_content,
      tagged_text: true,
      nouns: true,
      noun_phrases: true,
      adjectives: true,
      past_tense_verbs: true,
      present_tense_verbs: true,
    )

    begin
      main_topics = text_tagger.extract_main_topics(preprocessed_content)
    rescue StandardError => e
      logger.warn "#{e.message}"
    end

    begin
      speech_acts = text_tagger.identify_speech_acts(preprocessed_content)
    rescue StandardError => e
      logger.warn "#{e.message}"
    end

    begin
      transitivity = text_tagger.analyze_transitivity(preprocessed_content)
    rescue StandardError => e
      logger.warn "#{e.message}"
    end

    comprehensive_result = {
      tagger_analysis: result,
      main_topics: main_topics,
      speech_acts: speech_acts,
      transitivity: transitivity
    }

    store_result(textfile, comprehensive_result)

    logger.info "TextTaggerTask completed"
  end

  private

  def retrieve_input_text
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    textfile = Textfile[textfile_id]
    textfile
  end

  def store_result(textfile, result)
    textfile.update(tagged: result)
    textfile.save
    # Jongleur::WorkerTask.class_variable_get(:@@redis).set("text_tagger_result", result.to_json)
  end
end
