# https://blueprints.sublayer.com/blueprints/70562717-70c5-4406-a792-358d169f9f0b
module Sublayer
  module Actions
    class WriteFileAction < Base
      # Initializes the action with the contents to write and the target file path
      # @param [String] file_contents the contents to write to the file
      # @param [String] file_path the file path where contents will be written
      def initialize(file_contents:, file_path:)
        @file_contents = file_contents
        @file_path = file_path
      end

      # Writes the contents to the file in binary mode
      # @return [void]
      def call
        File.open(@file_path, 'wb') do |file|
          file.write(@file_contents)
        end
      end
    end
  end
end