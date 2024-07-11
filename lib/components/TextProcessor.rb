#!/usr/bin/env ruby
# frozen_string_literal: true

require "ruby-spacy"
require_relative "segmentation"
require "logger"
require "singleton"

class TextProcessor
  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger.info "Initializing TextProcessor"

    load_nlp_model

    @logger.info "TextProcessor initialization completed"
  end

  def process_file(file_path)
    @logger.info "Processing file: #{file_path}"
    text = File.read(file_path)
    process(text)
  end

  def process(text, is_audio_transcription=false)
    @logger.info "Starting text processing"
    @logger.debug "Input text type: #{text.class}"
    @logger.debug "Is audio transcription: #{is_audio_transcription}"

    if is_audio_transcription
      @logger.debug "Preprocessing audio transcription"
      text = preprocess_audio_transcription(text)
    end

    @logger.debug "Segmenting text"
    segments = segment_text(text)
    @logger.debug "Number of segments: #{segments.length}"

    @logger.debug "Processing segments"
    result = process_segments(segments)
    @logger.info "Text processing completed"
    result
  end

  private

  def load_nlp_model(nlp_model="en_core_web_trf")
    @logger.debug "Loading NLP model: #{nlp_model}"
    begin
      @nlp = Spacy::Language.new(nlp_model)
      @logger.debug "NLP model loaded successfully"
    rescue StandardError => e
      @logger.error "Error loading NLP model: #{e.message}"
      @logger.error e.backtrace.join("\n")
      raise
    end
  end

  def preprocess_audio_transcription(text)
    @logger.debug "Audio preprocessing not implemented, returning original text"
    text
  end

  def segment_text(text)
    @logger.debug "Creating TextSegmenter"
    segmenter = TextSegmenter.new(text, { clean: true })
    @logger.debug "Executing segmentation"
    segmenter.execute
  end

  def process_segments(segments)
    @logger.debug "Processing #{segments.length} segments"
    segments.map { |segment| process_sentence(segment) }
  end

  def process_sentence(sentence)
    @logger.debug "Processing sentence of length: #{sentence.length}"

    @logger.debug "Starting NLP processing"
    doc = @nlp.read(sentence)
    @logger.debug "NLP processing completed"

    relevant_tokens = doc.select do |token|
      token.pos_ != "" || token.tag_ != "" || token.dep_ != "" || token.ent_type_ != ""
    end
    @logger.debug "Number of relevant tokens: #{relevant_tokens.length}"

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
    @logger.debug "Number of filtered tokens: #{filtered_tokens.length}"

    result = filtered_tokens.join(" ")
    @logger.debug "Processed sentence result length: #{result.length}"
    result
  end
end
