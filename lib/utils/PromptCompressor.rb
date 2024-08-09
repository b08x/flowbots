#!/usr/bin/env ruby
# frozen_string_literal: true

# Create a class to encapsulate the compression workflow
class TextCompressor
  def initialize
    # Initialize the spaCy English language model
    @nlp = Spacy::load("en_core_web_sm")
  end

  def compress(text)
    # Tokenize the prompt
    tokens = @nlp(text)

    # Remove stop words and punctuation
    tokens = tokens.select { |token| !token.is_stop? && !token.is_punc? }

    # Lemmatize the tokens
    tokens = tokens.map { |token| token.lemma }

    # Join the tokens into a string
    compressed_text = tokens.join(" ")

    # Return the compressed prompt
    compressed_text
  end
end

# Create an instance of the PromptCompressor class
compressor = PromptCompressor.new

# Compress a prompt
compressed_prompt = compressor.compress("This is a sample prompt.")
