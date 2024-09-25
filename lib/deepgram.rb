#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

module DeepGramParsing
  def parse_json(file)
    raise NotImplementedError
  end
end

class Deepgram
  include DeepGramParsing

  def initialize(file)
    @json_data = JSON.parse(File.read(file))
    @paragraphs = []
    @intents = []
    @topics = []
    parse_json
  end

  def parse_json
    transcript
    paragraphs
    topics
    intents
  end

  def transcript
    @transcript = @json_data["results"]["channels"][0]["alternatives"][0]["transcript"]
  end

  def paragraphs
    @json_data["results"]["channels"][0]["alternatives"][0]["paragraphs"]["paragraphs"].each do |paragraph|
      sentences = paragraph["sentences"].map { |sentence| sentence["text"] }
      start_time = format_timestamp(paragraph["sentences"].first["start"])
      end_time = format_timestamp(paragraph["sentences"].last["end"])
      @paragraphs << { text: sentences.join(" "), start: start_time, end: end_time }
    end
  end

  def topics
    @json_data["results"]["topics"]["segments"].each do |seg|
      @topics << { topic: seg["topics"][0]["topic"] }
    end
    @topics.uniq!
  end

  def intents
    @json_data["results"]["intents"]["segments"].each do |seg|
      start_time = format_timestamp(seg["start"])
      end_time = format_timestamp(seg["end"])
      @intents << { intent: seg["intents"][0]["intent"], start: start_time, end: end_time }
    end
    @intents.uniq!
  end

  private

  def format_timestamp(seconds)
    puts seconds
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
