#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class FlowbotError < StandardError
    attr_reader :code

    def initialize(message, code)
      super(message)
      @code = code
    end
  end
end
