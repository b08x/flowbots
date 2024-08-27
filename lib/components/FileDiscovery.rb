# frozen_string_literal: true

module Flowbots
  module FileDiscovery
    FILE_TYPES = {
      text: ['.txt', '.md', '.markdown'],
      pdf: ['.pdf'],
      html: ['.html', '.htm'],
      json: ['.json'],
      audio: ['.mp3', '.wav', '.ogg', '.flac'],
      video: ['.mp4', '.avi', '.mov', '.mkv']
    }

    def self.discover_files(directory)
      files = Hash.new { |h, k| h[k] = [] }

      Dir.glob(File.join(directory, '**', '*')).each do |file|
        next unless File.file?(file)

        extension = File.extname(file).downcase
        FILE_TYPES.each do |type, extensions|
          if extensions.include?(extension)
            files[type] << file
            break
          end
        end
      end

      files
    end

    def self.file_count(files)
      files.transform_values(&:count)
    end
  end
end
