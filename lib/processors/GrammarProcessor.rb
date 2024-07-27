#!/usr/bin/env ruby
# frozen_string_literal: true

require "treetop"

module Flowbots
  class GrammarProcessor
    def initialize(grammar_name)
      @grammar_name = grammar_name
      load_grammar
    end

    def parse(text)
      @parser.parse(text)
    end

    private

    def load_grammar
      Treetop.load(File.join(GRAMMAR_DIR, "#{@grammar_name}.treetop"))
      parser_class_name = "#{@grammar_name.camelize}Parser"
      @parser = Object.const_get(parser_class_name).new
    end
  end
end
