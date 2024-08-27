#!/usr/bin/env ruby
# frozen_string_literal: true

# This task tokenizes the segments of a text file.
class TextTokenizeTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    # Retrieve the segments from the latest FileObject.
    segments = FileObject.latest.retrieve_segments

    # Get an instance of the TextTokenizeProcessor.
    text_tokenizer = Flowbots::TextTokenizeProcessor.instance

    # Iterate through each segment and tokenize its text.
    segments.each do |segment|
      # Tokenize the segment's text using the TextTokenizeProcessor.
      tokens = text_tokenizer.process(segment.text, { clean: true })

      # Update the segment with the tokenized data.
      segment.update(tokens:)

      # Save the updated segment.
      segment.save
    end
  end
end
