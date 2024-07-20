#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TextProcessor
    include Singleton

    def initialize
      logger.info "Initializing #{self.class.name}"
      Flowbots::UI.say(:ok, "Initializing #{self.class.name}")
      logger.info "#{self.class.name} initialization completed"
      Flowbots::UI.say(:ok, "#{self.class.name} initialization completed")
    end

    def process(text)
      raise NotImplementedError, "#{self.class.name}#process must be implemented in subclass"
    end

  end
end
