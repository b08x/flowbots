#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

# This module provides functionality for parsing Deepgram JSON output.
module DeepGramParsing
  # Parses a Deepgram JSON file.
  #
  # @param file [String] The path to the Deepgram JSON file.
  #
  # @return [void]
  #
  # @raise [NotImplementedError] If the method is not implemented in a subclass.
  def parse_json(file)
    raise NotImplementedError
  end
end

# This class provides methods for parsing and extracting information from Deepgram JSON output.
class Deepgram
  # Includes the DeepGramParsing module.
  include DeepGramParsing

  # Initializes a new Deepgram instance.
  #
  # @param file [String] The path to the Deepgram JSON file.
  def initialize(file)
    @json_data = JSON.parse(File.read(file))
    @paragraphs = []
    @intents = []
    @topics = []
    parse_json
  end

  # Parses the Deepgram JSON data.
  #
  # @return [void]
  def parse_json
    transcript
    paragraphs
    topics
    intents
  end

  # Extracts the transcript from the JSON data.
  #
  # @return [String] The transcript.
  def transcript
    @transcript = @json_data["results"]["channels"][0]["alternatives"][0]["transcript"]
  end

  # Extracts paragraphs from the JSON data.
  #
  # @return [Array<Hash>] An array of paragraphs, each represented as a hash with text, start time, and end time.
  def paragraphs
    @json_data["results"]["channels"][0]["alternatives"][0]["paragraphs"]["paragraphs"].each do |paragraph|
      sentences = paragraph["sentences"].map { |sentence| sentence["text"] }
      start_time = format_timestamp(paragraph["sentences"].first["start"])
      end_time = format_timestamp(paragraph["sentences"].last["end"])
      @paragraphs << { text: sentences.join(" "), start: start_time, end: end_time }
    end
  end

  # Extracts topics from the JSON data.
  #
  # @return [Array<Hash>] An array of topics, each represented as a hash with the topic name.
  def topics
    @json_data["results"]["topics"]["segments"].each do |seg|
      @topics << { topic: seg["topics"][0]["topic"] }
    end
    @topics.uniq!
  end

  # Extracts intents from the JSON data.
  #
  # @return [Array<Hash>] An array of intents, each represented as a hash with the intent name, start time, and end time.
  def intents
    @json_data["results"]["intents"]["segments"].each do |seg|
      start_time = format_timestamp(seg["start"])
      end_time = format_timestamp(seg["end"])
      @intents << { intent: seg["intents"][0]["intent"], start: start_time, end: end_time }
    end
    @intents.uniq!
  end

  private

  # Formats a timestamp from seconds to HH:MM:SS.
  #
  # @param seconds [Float] The timestamp in seconds.
  #
  # @return [String] The formatted timestamp.
  def format_timestamp(seconds)
    hours = (seconds / 3600).to_i unless seconds.nil?
    minutes = ((seconds % 3600) / 60).to_i unless seconds.nil?
    seconds = (seconds % 60).to_i unless seconds.nil?
    format("%02d:%02d:%02d", hours, minutes, seconds) unless seconds.nil?
  rescue StandardError => e
    puts e
  end
end

# Example usage
# Assuming you have a Deepgram JSON file named "deepgram_output.json"
deepgram_output = Deepgram.new(ARGV[0])

puts deepgram_output.paragraphs

# Example usage with a file
# deepgram_output = DeepGram.process_deepgram_file('audio.wav')
# puts deepgram_output

# ---

#  # return each word with confidence score
#  def words_with_confidence(file)
#   `cat #{file} | jq -r '.results.channels[].alternatives[].words[] | { word, confidence }'`
#     .split("\n")
#     .map { |word_data| eval(word_data) } # Use eval to parse the string into a hash
# end

# # return a hash list of each segmented sentence
# def segmented_sentences(file)
#   `cat #{file} | jq -r '.results.channels[].alternatives[].paragraphs.paragraphs[].sentences[] | { text }'`
#     .split("\n")
#     .map { |sentence_data| eval(sentence_data) } # Use eval to parse the string into a hash
# end

# # returns a hash list of paragraphs as an array of setences
# def paragraphs_as_sentences(file)
#   `cat #{file} | jq -r '.results.channels[].alternatives[].paragraphs.paragraphs[] | { paragraph: [.sentences[].text] }'`
#     .split("\n")
#     .map { |paragraph_data| eval(paragraph_data) } # Use eval to parse the string into a hash
# end

# # segments with their labled categories|topics
# def segments_with_topics(file)
#   `cat #{file} | jq -r '.results.topics.segments[] | { text, topics: [.topics[] | { topic: .topic }] }'`
#     .split("\n")
#     .map { |segment_data| eval(segment_data) } # Use eval to parse the string into a hash
# end

# # segments with their labled intents
# def segments_with_intents(file)
#   `cat #{file} | jq -r '.results.intents.segments[] | { text, intents: [.intents[] | { intent: .intent }] }'`
#     .split("\n")
#     .map { |segment_data| eval(segment_data) } # Use eval to parse the string into a hash
# end
