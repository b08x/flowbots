#!/usr/bin/env ruby
# frozen_string_literal: true

# This task tokenizes the segments of a text file.
class TokenizeSegmentsTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the current Textfile object from Redis.
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    text_file = Textfile[textfile_id]

    # Get an instance of the TextTokenizeProcessor.
    text_tokenizer = Flowbots::TextTokenizeProcessor.instance

    # Iterate through each segment of the Textfile.
    text_file.retrieve_segments.each do |segment|
      # Tokenize the segment's text using the TextTokenizeProcessor.
      tokens = text_tokenizer.process(segment.text, { clean: true })

      # Update the segment with the tokenized data.
      segment.update(tokens:)

      # Save the updated segment.
      segment.save
    end
  end
end
