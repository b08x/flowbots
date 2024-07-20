#!/usr/bin/env ruby
# frozen_string_literal: true

require "singleton"
require "mimemagic"
require "pdf-reader"
require "httparty"

module Flowbots
  class FileLoader
    attr_accessor :file_data

    def initialize(file_path)
      file_type = classify_file(file_path)
      extracted_text = extract_text(file_type, file_path)
      @file_data = store_file_data(file_path, extracted_text)
    end

    private

    def classify_file(file_path)
      mime = MimeMagic.by_path(file_path)
      case mime.type
      when /^text/
        :text
      when %r{^application/pdf}
        :pdf
      when /^image/
        :image
      when /^video/
        :video
      when /^audio/
        :audio
      else
        :unknown
      end
    end

    def parse_pdf(file_path)
      text = ""
      PDF::Reader.new(file_path).pages.each do |page|
        text << page.text
      end
      text
    end

    def extract_text(file_type, file_path)
      case file_type
      when :text
        File.read(file_path)
      when :pdf
        parse_pdf(file_path)
      else
        raise NotImplementedError, "Unsupported file type: #{@file_type}"
      end
    end

    def store_file_data(file_path, extracted_text)

      file = Textfile.find_or_create_by_path(
        file_path, attributes = { content: extracted_text }
      )

      return file

      logger.info "Stored file data for: #{file_path}"
      Flowbots::UI.say(:ok, "Stored file data for: #{file_path}")
    end
  end
end
