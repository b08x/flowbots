#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs text tagging using a pre-trained model.
class TextTaggerTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    logger.info "Starting TextTaggerTask"

    # Get an instance of the TextTaggerProcessor.
    text_tagger = Flowbots::TextTaggerProcessor.instance

    # Retrieve the Textfile object from Redis.
    textfile = retrieve_input_text

    # Get the preprocessed content from the Textfile.
    preprocessed_content = textfile.preprocessed_content

    # Perform text tagging using the TextTaggerProcessor.
    result = text_tagger.process(
      preprocessed_content,
      tagged_text: true,
      nouns: true,
      noun_phrases: true,
      adjectives: true,
      past_tense_verbs: true,
      present_tense_verbs: true
    )

    # Extract additional information using the TextTaggerProcessor.
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

    # Combine all results into a comprehensive result hash.
    comprehensive_result = {
      tagger_analysis: result,
      main_topics:,
      speech_acts:,
      transitivity:
    }

    # Store the comprehensive result in the Textfile.
    store_result(textfile, comprehensive_result)

    logger.info "TextTaggerTask completed"
  end

  private

  # Retrieves the Textfile object from Redis.
  #
  # @return [Textfile] The Textfile object.
  def retrieve_input_text
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  # Stores the result in the Textfile.
  #
  # @param textfile [Textfile] The Textfile object.
  # @param result [Hash] The result hash.
  #
  # @return [void]
  def store_result(textfile, result)
    textfile.update(tagged: result)
    textfile.save
    # Jongleur::WorkerTask.class_variable_get(:@@redis).set("text_tagger_result", result.to_json)
  end
end
