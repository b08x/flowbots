#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class provides a base class for text processors in the Flowbots application.
  class TextProcessor
    # Includes the Singleton module to ensure only one instance of the class is created.
    include Singleton

    # Initializes a new TextProcessor instance.
    #
    # @return [void]
    def initialize
      # Logs a message indicating the start of initialization for the current class.
      logger.info "Initializing #{self.class.name}"

      # Displays a success message to the user indicating the initialization of the current class.
      UI.say(:ok, "Initializing #{self.class.name}")

      # Logs a message indicating the completion of initialization for the current class.
      logger.info "#{self.class.name} initialization completed"

      # Displays a success message to the user indicating the completion of initialization for the current class.
      UI.say(:ok, "#{self.class.name} initialization completed")
    end

    # Processes the given text.
    #
    # This method must be implemented in subclasses.
    #
    # @param text [String] The text to be processed.
    #
    # @return [void]
    # @raise [NotImplementedError] If the method is not implemented in a subclass.
    def process(text)
      raise NotImplementedError, "#{self.class.name}#process must be implemented in subclass"
    end
  end
end
