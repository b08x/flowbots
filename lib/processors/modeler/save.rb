#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TopicModelProcessor < TextProcessor
    private

    def save_model
      logger.info "Attempting to save model to #{TOPIC_MODEL_PATH}"
      Flowbots::UI.say(:ok, "Attempting to save topic model")

      begin
        # Check if the directory exists, create it if it doesn't
        dir = File.dirname(TOPIC_MODEL_PATH)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)

        # Check if we have write permissions
        unless File.writable?(dir)
          raise FlowbotError.new(
            "No write permission for directory: #{dir}",
            "PERMISSION_ERROR"
          )
        end

        # Check available disk space (example threshold: 100MB)
        available_space = `df -k #{dir} | awk '{print $4}' | tail -n 1`.to_i * 1024
        if available_space < 100_000_000 # 100MB in bytes
          raise FlowbotError.new(
            "Insufficient disk space. Only #{available_space / 1_000_000}MB available.",
            "DISK_SPACE_ERROR"
          )
        end

        # Attempt to save the model
        @model.save(TOPIC_MODEL_PATH)

        logger.info "Model successfully saved to #{TOPIC_MODEL_PATH}"
        Flowbots::UI.say(:ok, "Topic model saved successfully")
      rescue Tomoto::Error => e
        logger.error "Tomoto gem error while saving model: #{e.message}"
        raise FlowbotError.new(
          "Failed to save topic model due to Tomoto gem error: #{e.message}",
          "TOMOTO_SAVE_ERROR"
        )
      rescue FlowbotError => e
        logger.error e.message
        raise e
      rescue StandardError => e
        logger.error "Unexpected error while saving model: #{e.message}"
        raise FlowbotError.new("Unexpected error while saving topic model: #{e.message}", "SAVE_ERROR")
      end
    end
  end
end
