#!/usr/bin/env ruby
# frozen_string_literal: true

require "singleton"
require "mimemagic"
require "pdf-reader"
require "httparty"

module Flowbots
  # This class handles loading and processing text files.
  class FileLoader
    # The Textfile object representing the loaded file.
    attr_accessor :file_data

    # Initializes a new FileLoader instance.
    #
    # @param file_path [String] The path to the file to be loaded.
    #
    # @return [void]
    def initialize(file_path)
      file_type = classify_file(file_path)

      extracted_text = extract_text(file_type, file_path)
      @file_data = store_file_data(file_path, extracted_text)
    end

    private

    # Classifies the file type based on its MIME type.
    #
    # @param file_path [String] The path to the file.
    #
    # @return [Symbol] The file type, e.g., :text, :pdf, :image, etc.
    def classify_file(file_path)
      begin
        mime = MimeMagic.by_magic(file_path)
      rescue StandardError => e
        logger.debug "Unable to determine mime by magic alone, attempting by_path"
        mime = MimeMagic.by_path(file_path)
      end

      case mime&.type
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
      when /^json/
        :json
      else
        :unknown
      end
    end

    # Parses a PDF file and extracts its text content.
    #
    # @param file_path [String] The path to the PDF file.
    #
    # @return [String] The extracted text content.
    def parse_pdf(file_path)
      text = ""
      PDF::Reader.new(file_path).pages.each do |page|
        text << page.text
      end
      text
    end

    # Extracts the text content from a file based on its type.
    #
    # @param file_type [Symbol] The file type.
    # @param file_path [String] The path to the file.
    #
    # @return [String] The extracted text content.
    def extract_text(file_type, file_path)
      case file_type
      # when :json
      #   extract_text_json(file_path)
      when :text
        File.read(file_path)
      when :unknown
        File.read(file_path)
        # extract_text_json(file_path)
      when :pdf
        parse_pdf(file_path)
      else
        raise NotImplementedError, "Unsupported file type: #{@file_type}"
      end
    end

    def extract_text_json(file_path)
      begin
        json_data = JSON.parse(File.read(file_path))
        text = json_data["results"]["channels"][0]['alternatives'][0]['transcript']
        puts json_data
        return text
        exit
      rescue JSON::ParserError => e
        puts "Error parsing JSON: #{e.message}"
        return nil
      rescue StandardError => e
        puts "An error occurred: #{e.message}"
        return nil
      end
    end

    # Stores the file data in the database.
    #
    # @param file_path [String] The path to the file.
    # @param extracted_text [String] The extracted text content.
    #
    # @return [Textfile] The Textfile object representing the stored file data.
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
