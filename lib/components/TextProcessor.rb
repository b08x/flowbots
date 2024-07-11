#!/usr/bin/env ruby
# frozen_string_literal: true

require "ruby-spacy"
require_relative "segmentation"

class TextProcessor
  def initialize(nlp_model="en_core_web_trf")
    @nlp = Spacy::Language.new(nlp_model)
  end

  def process(text, is_audio_transcription=false)
    text = preprocess_audio_transcription(text) if is_audio_transcription

    segments = segment_text(text)
    process_segments(segments)
  end

  private

  def preprocess_audio_transcription(text)
    # Implement audio transcription specific preprocessing here
    # This could include punctuation correction, spelling fixes, etc.
    # For now, we'll just return the text as-is
    text
  end

  def segment_text(text)
    segmenter = TextSegmenter.new(text, { clean: true })
    segmenter.execute
  end

  def process_segments(segments)
    segments.map { |segment| process_sentence(segment) }
  end

  def process_sentence(sentence)
    doc = @nlp.read(sentence)

    relevant_tokens = doc.select do |token|
      token.pos_ != "" || token.tag_ != "" || token.dep_ != "" || token.ent_type_ != ""
    end

    processed_tokens = relevant_tokens.map do |token|
      {
        text: token.text,
        pos: token.pos_,
        tag: token.tag_,
        dep: token.dep_,
        ent_type: token.ent_type_
      }
    end

    filtered_tokens = processed_tokens.select do |token|
      %w[NN JJ RB].include? token[:tag]
    end.map { |token| token[:text] }

    filtered_tokens.join(" ")
  end
end
