#!/usr/bin/env ruby
# frozen_string_literal: true

module Sublayer
  module Actions
    class WriteXMLFileAction < Base
      require "builder"

      def initialize(data:, file_path:)
        @data = data
        @file_path = file_path
      end

      def call
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

        # Assuming @data is a hash and converting it into XML format
        xml.data do
          @data.each do |key, value|
            xml.tag!(key, value)
          end
        end

        File.binwrite(@file_path, xml.target!)
      end
    end
  end
end
