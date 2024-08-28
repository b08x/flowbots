# frozen_string_literal: true

# This class performs text tagging on a given text.
class TextTaggerTask < Jongleur::WorkerTask
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the text tagging task.
  #
  # Retrieves the FileObject from Redis, extracts its preprocessed content,
  # performs text tagging using the TextTaggerProcessor, extracts main topics,
  # identifies speech acts, analyzes transitivity, stores the results in the
  # FileObject, and logs the progress.
  #
  # @return [void]
  # @raises [RuntimeError] If the FileObject retrieval fails or the preprocessed
  #   content is empty or nil.
  def execute
    logger.info "Starting TextTaggerTask"

    # Retrieve the FileObject from Redis.
    text_tagger = Flowbots::TextTaggerProcessor.instance
    file_object = retrieve_input

    # Raise an error if the FileObject retrieval fails.
    if file_object.nil?
      logger.error "Failed to retrieve FileObject"
      raise("Failed to retrieve FileObject")
      return
    end

    # Get the preprocessed content from the FileObject.
    preprocessed_content = file_object.preprocessed_content

    # Raise an error if the preprocessed content is empty or nil.
    if preprocessed_content.nil? || preprocessed_content.empty?
      logger.error "Preprocessed content is empty or nil for FileObject: #{file_object.id}"
      raise("Preprocessed content is empty or nil")
      return
    end

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

    # Extract main topics from the preprocessed content.
    begin
      main_topics = text_tagger.extract_main_topics(preprocessed_content)
    rescue StandardError => e
      logger.warn "Error extracting main topics: #{e.message}"
      main_topics = []
    end

    # Identify speech acts in the preprocessed content.
    begin
      speech_acts = text_tagger.identify_speech_acts(preprocessed_content)
    rescue StandardError => e
      logger.warn "Error identifying speech acts: #{e.message}"
      speech_acts = []
    end

    # Analyze transitivity in the preprocessed content.
    begin
      transitivity = text_tagger.analyze_transitivity(preprocessed_content)
    rescue StandardError => e
      logger.warn "Error analyzing transitivity: #{e.message}"
      transitivity = []
    end

    # Store the tagging results in the FileObject.
    store_result(file_object, result, main_topics, speech_acts, transitivity)

    # Log the completion of the task.
    logger.info("Text tagging completed for FileObject: #{file_object.id}")
  end

  private

  # Retrieves the input for the task, which is the current FileObject.
  #
  # @return [FileObject] The current FileObject.
  def retrieve_input
    retrieve_file_object
  end

  # Stores the tagging results in the FileObject.
  #
  # @param file_object [FileObject] The FileObject to store the results in.
  # @param result [Hash] The text tagging results.
  # @param main_topics [Array<String>] The extracted main topics.
  # @param speech_acts [Array<String>] The identified speech acts.
  # @param transitivity [Array<String>] The analyzed transitivity.
  #
  # @return [void]
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
