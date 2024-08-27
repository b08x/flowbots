# lib/tasks/text_tagger_task.rb

class TextTaggerTask < Jongleur::WorkerTask
  include InputRetrieval

  def execute
    logger.info "Starting TextTaggerTask"

    text_tagger = Flowbots::TextTaggerProcessor.instance
    file_object = retrieve_input

    if file_object.nil?
      logger.error "Failed to retrieve FileObject"
      raise("Failed to retrieve FileObject")
      return
    end

    preprocessed_content = file_object.preprocessed_content

    if preprocessed_content.nil? || preprocessed_content.empty?
      logger.error "Preprocessed content is empty or nil for FileObject: #{file_object.id}"
      raise("Preprocessed content is empty or nil")
      return
    end

    result = text_tagger.process(
      preprocessed_content,
      tagged_text: true,
      nouns: true,
      noun_phrases: true,
      adjectives: true,
      past_tense_verbs: true,
      present_tense_verbs: true
    )

    begin
      main_topics = text_tagger.extract_main_topics(preprocessed_content)
    rescue StandardError => e
      logger.warn "Error extracting main topics: #{e.message}"
      main_topics = []
    end

    begin
      speech_acts = text_tagger.identify_speech_acts(preprocessed_content)
    rescue StandardError => e
      logger.warn "Error identifying speech acts: #{e.message}"
      speech_acts = []
    end

    begin
      transitivity = text_tagger.analyze_transitivity(preprocessed_content)
    rescue StandardError => e
      logger.warn "Error analyzing transitivity: #{e.message}"
      transitivity = []
    end

    store_result(file_object, result, main_topics, speech_acts, transitivity)

    logger.info("Text tagging completed for FileObject: #{file_object.id}")
  end

  private

  def retrieve_input
    retrieve_file_object
  end

  def store_result(file_object, result, main_topics, speech_acts, transitivity)
    file_object.update(
      tagged: result,
      main_topics:,
      speech_acts:,
      transitivity:
    )
    logger.debug "Stored tagging result for FileObject: #{file_object.id}"
  end
end
