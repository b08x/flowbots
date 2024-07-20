#!/usr/bin/env ruby
# frozen_string_literal: true

class LoadTextFilesTask < Jongleur::WorkerTask
  def execute
    input_folder = Jongleur::WorkerTask.class_variable_get(:@@redis).get("input_folder_path")
    Flowbots::UI.info "#{input_folder}"
    
    text_files = Dir.glob(File.join(input_folder, "**{,/*/**}/*.{md,markdown}"))

    batch_id = Time.now.to_i
    Ohm.redis.call("SET", "current_batch_id", batch_id)

    loaded_files = []

    text_files.each do |file_path|
      begin
        file_loader = Flowbots::FileLoader.new(file_path)
        textfile = file_loader.file_data
        textfile.update(batch: batch_id)
        loaded_files << textfile

        logger.debug "Loaded file: #{file_path}"
      rescue StandardError => e
        logger.error "Error loading file #{file_path}: #{e.message}"
        Flowbots::UI.say(:error, "Failed to load file: #{file_path}")
      end
    end

    logger.info "Loaded #{loaded_files.length} out of #{text_files.length} text files"
    Flowbots::UI.say(:ok, "Loaded #{loaded_files.length} out of #{text_files.length} text files")

    if loaded_files.empty?
      logger.warn "No files were successfully loaded"
      Flowbots::UI.say(:warn, "No files were successfully loaded")
    end
  end
end
