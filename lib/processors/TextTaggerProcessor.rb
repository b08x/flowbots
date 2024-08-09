#!/usr/bin/env ruby
# frozen_string_literal: true

require 'engtagger'

module Flowbots
  class TextTaggerProcessor
    include Singleton
    include Logging

    def initialize
      logger = Logger.new(STDOUT)
      load_engtagger
    end

    def process(text, options = {})
      logger.debug "Processing text with TextTaggerProcessor"
      logger.debug "Options: #{options.inspect}"

      result = {}

      result[:tagged_text] = @tgr.add_tags(text) if options[:tagged_text]
      result[:readable_text] = @tgr.get_readable(text) if options[:readable_text]
      result[:words] = @tgr.get_words(text) if options[:words]
      result[:nouns] = @tgr.get_nouns(text) if options[:nouns]
      result[:proper_nouns] = @tgr.get_proper_nouns(result[:tagged_text]) if options[:proper_nouns]
      result[:past_tense_verbs] = @tgr.get_past_tense_verbs(result[:tagged_text]) if options[:past_tense_verbs]
      result[:present_tense_verbs] = @tgr.get_present_verbs(result[:tagged_text]) if options[:present_tense_verbs]
      result[:base_present_verbs] = @tgr.get_base_present_verbs(result[:tagged_text]) if options[:base_present_verbs]
      result[:gerund_verbs] = @tgr.get_gerund_verbs(result[:tagged_text]) if options[:gerund_verbs]
      result[:adjectives] = @tgr.get_adjectives(result[:tagged_text]) if options[:adjectives]
      result[:noun_phrases] = @tgr.get_noun_phrases(result[:tagged_text]) if options[:noun_phrases]
      result[:pronoun_list] = @tgr.get_pronoun_list(result[:tagged_text]) if options[:pronoun_list]

      logger.debug "Processed result: #{result.inspect}"
      result
    end

    def extract_main_topics(text, limit = 5)
      noun_phrases = @tgr.get_noun_phrases(text)
      unless noun_phrases.nil?
        sorted_phrases = noun_phrases.sort_by { |_, count| -count }
        sorted_phrases.first(limit).map { |phrase, _| phrase }
      end
    end

    def identify_speech_acts(text)
      sentences = text.split(/[.!?]+/).map(&:strip).reject(&:empty?)
      sentences.map do |sent|
        sent_tagged = @tgr.add_tags(sent)
        if sent_tagged.nil?
          logger.warn "Failed to tag sentence: #{sent}"
          'unknown'
        elsif sent_tagged.include?("<uh>")
          'interjection'
        elsif sent.end_with?('?')
          'question'
        elsif sent_tagged.start_with?("<md>") || sent_tagged.start_with?("<vb>")
          'request'
        elsif sent.end_with?('!')
          'exclamation'
        else
          'statement'
        end
      end
    end

    def analyze_transitivity(text)
      sentences = text.split(/[.!?]+/).map(&:strip).reject(&:empty?)
      sentences.map do |sent|
        sent_tagged = @tgr.add_tags(sent)
        if sent_tagged.nil?
          logger.warn "Failed to tag sentence for transitivity analysis: #{sent}"
          { sentence: sent, process: nil, actor: nil, goal: nil }
        else
          process = sent_tagged.scan(/<vb[dgnpz]?>([^<]+)<\/vb[dgnpz]?>/).flatten.first
          actor = sent_tagged.scan(/<nn[ps]?>([^<]+)<\/nn[ps]?>/).flatten.first
          goal = sent_tagged.scan(/<nn[ps]?>([^<]+)<\/nn[ps]?>/).flatten[1]
          { sentence: sent, process: process, actor: actor, goal: goal }
        end
      end
    end

    private

    def load_engtagger
      logger.debug "Loading EngTagger"
      @tgr = EngTagger.new
      logger.debug "EngTagger loaded successfully"
      Flowbots::UI.say(:ok, "EngTagger loaded successfully")
    rescue StandardError => e
      logger.error "Error loading EngTagger: #{e.message}"
      logger.error e.backtrace.join("\n")
      Flowbots::UI.say(:error, "Error loading EngTagger: #{e.message}")
      raise
    end
  end
end
