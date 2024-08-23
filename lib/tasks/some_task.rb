#!/usr/bin/env ruby
# frozen_string_literal: true

class SomeTextTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting SomeTextTask"

    @textfile = retrieve_input

    # Task-specific logic here

    logger.info "SomeTextTask completed"
  end

  private

  def retrieve_input
    retrieve_textfile
  end
end
