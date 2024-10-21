#!/usr/bin/env ruby
# frozen_string_literal: true

class NlpAnalysisTask < Task
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval

  # Executes the task.
  #
  # Retrieves the FileObject from Redis, processes each segment using the NLPProcessor,
  # updates the segments with NLP data, adds lemmas to the FileObject, and logs the progress.
  #
  # @return [void]
  def execute
    # Log the start of the task.
    logger.info "Starting NlpAnalysisTask"

    # Retrieve the FileObject from Redis.
    textfile = retrieve_input
    # Get an instance of the NLPProcessor.
    nlp_processor = Flowbots::NLPProcessor.instance

    # Initialize a hash to store lemma counts.
    lemma_counts = Hash.new(0)

    # Iterate through each segment of the FileObject.
    textfile.retrieve_segments.each do |segment|
      # Process the segment using the NLPProcessor.
      processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true, lemma: true)
      # Update the segment with the processed NLP data.
      update_segment_with_nlp_data(segment, processed_tokens, lemma_counts)
    end

    # Add the accumulated lemmas to the FileObject.
    add_lemmas_to_textfile(textfile, lemma_counts)

    # Log the completion of the task.
    logger.info "NlpAnalysisTask completed"
  end

  private

  # Retrieves the input for the task, which is the current FileObject.
  #
  # @return [FileObject] The current FileObject.
  def retrieve_input
    retrieve_file_object
  end

  # Updates a segment with NLP data.
  #
  # Extracts relevant NLP information from the processed tokens and updates the segment
  # with tagged data, words, and lemma counts.
  #
  # @param segment [Segment] The segment to update.
  # @param processed_tokens [Array<Hash>] An array of processed tokens from the NLPProcessor.
  # @param lemma_counts [Hash] A hash to store lemma counts.
  #
  # @return [void]
  def update_segment_with_nlp_data(segment, processed_tokens, lemma_counts)
    # Initialize a hash to store tagged data.
    tagged = { pos: {}, dep: {}, ner: {}, tag: {} }
    # Iterate through the processed tokens.
    processed_tokens.each do |token|
      # Extract relevant information from the token.
      word = token[:word]
      tagged[:pos][word] = token[:pos]
      tagged[:dep][word] = token[:dep]
      tagged[:ner][word] = token[:ner]
      tagged[:tag][word] = token[:tag]

      # Increment the lemma count for the current lemma and POS tag.
      lemma_key = [token[:lemma], token[:pos]]
      lemma_counts[lemma_key] += 1
    end

    # Update the segment with the tagged data.
    segment.update(tagged:)
    # Add the processed words to the segment.
    add_words_to_segment(segment, processed_tokens)
  end

  # Adds processed words to a segment.
  #
  # Extracts word information from the processed tokens and adds it to the segment's words.
  #
  # @param segment [Segment] The segment to add words to.
  # @param processed_tokens [Array<Hash>] An array of processed tokens from the NLPProcessor.
  #
  # @return [void]
  def add_words_to_segment(segment, processed_tokens)
    # Map the processed tokens to an array of word data.
    words = processed_tokens.map do |token|
      { word: token[:word], pos: token[:pos], tag: token[:tag], dep: token[:dep], ner: token[:ner] }
    end
    # Add the words to the segment.
    segment.add_words(words)
  end

  # Adds lemmas to a FileObject.
  #
  # Converts the lemma counts hash to an array of lemma data and adds it to the FileObject's lemmas.
  #
  # @param textfile [FileObject] The FileObject to add lemmas to.
  # @param lemma_counts [Hash] A hash containing lemma counts.
  #
  # @return [void]
  def add_lemmas_to_textfile(textfile, lemma_counts)
    # Map the lemma counts hash to an array of lemma data.
    lemmas_data = lemma_counts.map do |(lemma, pos), count|
      { lemma:, pos:, count: }
    end
    # Add the lemmas to the FileObject.
    textfile.add_lemmas(lemmas_data)
  end
end
