#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs natural language processing (NLP) analysis on the segments of a text file.
class NlpAnalysisTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the Textfile object from Redis using its ID.
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    text_file = Textfile[textfile_id]

    # Log a message indicating the start of NLP analysis for the current file.
    logger.info "Processing NlpAnalysisTask for file: #{text_file.name}"

    # Get an instance of the NLPProcessor.
    nlp_processor = Flowbots::NLPProcessor.instance

    # Iterate through each segment of the Textfile.
    text_file.retrieve_segments.each do |segment|
      # Log a message indicating the processing of the current segment.
      logger.debug "Processing segment: #{segment.id}"

      # Perform NLP analysis on the segment using the NLPProcessor.
      processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true)

      # Log the processed tokens for debugging purposes.
      logger.debug "Processed tokens: #{processed_tokens.inspect}"

      # Check if the NLP processing returned a valid result.
      if processed_tokens.nil? || !processed_tokens.is_a?(Array)
        # Log a warning message if the result is invalid.
        logger.warn "NLP processing returned invalid result for segment #{segment.id}: #{processed_tokens.inspect}"
        next
      end

      # Create a hash to store the tagged data for the segment.
      tagged = {
        pos: {},
        dep: {},
        ner: {},
        tag: {}
      }

      # Iterate through the processed tokens and populate the tagged data hash.
      processed_tokens.each do |token|
        word = token[:word]
        tagged[:pos][word] = token[:pos]
        tagged[:dep][word] = token[:dep]
        tagged[:ner][word] = token[:ner]
        tagged[:tag][word] = token[:tag]
      end

      # Update the segment with the tagged data.
      segment.update(tagged:)
      logger.debug "Updated segment #{segment.id} with tagged data: #{tagged.inspect}"

      # Add the processed words to the segment.
      add_words_to_segment(segment, processed_tokens)
    rescue StandardError => e
      # Log an error message if an exception occurs during segment processing.
      logger.error "Error processing segment #{segment.id}: #{e.message}"
      logger.error e.backtrace.join("\n")
    end

    # Log a message indicating the completion of NLP analysis for the current file.
    logger.info "Completed NlpAnalysisTask for file: #{text_file.name}"
  end

  private

  # Adds the processed words to the segment.
  #
  # @param segment [Segment] The Segment object.
  # @param processed_tokens [Array] The processed tokens.
  #
  # @return [void]
  def add_words_to_segment(segment, processed_tokens)
    # Create an array of words from the processed tokens.
    words = processed_tokens.map do |token|
      {
        word: token[:word],
        pos: token[:pos],
        tag: token[:tag],
        dep: token[:dep],
        ner: token[:ner]
      }
    end

    # Add the words to the segment.
    segment.add_words(words)
  end
end
