#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mimemagic'

require_relative "../modules/Segmentation"

module Flowbots
  class TextProcessor
    include Singleton

    def initialize
      logger.info "Initializing #{self.class.name}"
      Flowbots::UI.say(:ok, "Initializing #{self.class.name}")
      logger.info "#{self.class.name} initialization completed"
      Flowbots::UI.say(:ok, "#{self.class.name} initialization completed")
    end

    def process_file(file_path)
      logger.info "Processing file: #{file_path}"
      Flowbots::UI.say(:ok, "Processing file: #{file_path}")

      file_type = classify_file(file_path)
      text = parse_file(file_path, file_type)
      process(text)
    end

    def process(text)
      raise NotImplementedError, "#{self.class.name}#process must be implemented in subclass"
    end

    protected

    def segment_text(text)
      logger.debug "Creating TextSegmenter"
      segmenter = TextSegmenter.new(text, { clean: true })
      logger.debug "Executing segmentation"
      segmenter.execute
    end

    private

    def classify_file(file_path)
      extension = File.extname(file_path).downcase
      mime_type = MIME::Types.type_for(file_path).first

      case
      when ['.txt', '.md', '.markdown'].include?(extension)
        :text
      when extension == '.pdf'
        :pdf
      when ['.json', '.jsonl'].include?(extension)
        :json
      when extension == '.html'
        :html
      else
        logger.warn "Unknown file type for #{file_path}. Treating as plain text."
        Flowbots::UI.say(:warn, "Unknown file type. Treating as plain text.")
        :text
      end
    end

    def parse_file(file_path, file_type)
      case file_type
      when :text
        File.read(file_path)
      when :pdf
        parse_pdf(file_path)
      when :json
        parse_json(file_path)
      when :html
        parse_html(file_path)
      else
        File.read(file_path)
      end
    end

    def parse_pdf(file_path)
      # Implement PDF parsing logic here
      # You might want to use a gem like 'pdf-reader'
      raise NotImplementedError, "PDF parsing not implemented"
    end

    def parse_json(file_path)
      JSON.parse(File.read(file_path))
    end

    def parse_html(file_path)
      # Implement HTML parsing logic here
      # You might want to use a gem like 'nokogiri'
      raise NotImplementedError, "HTML parsing not implemented"
    end
  end
end
