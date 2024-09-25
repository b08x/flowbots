#!/usr/bin/env ruby
# frozen_string_literal: true

class SomeTextTask < Task
  include InputRetrieval

  def execute
    logger.info "Starting SomeTextTask"

    @FileObject = retrieve_input

    # Task-specific logic here

    logger.info "SomeTextTask completed"
  end

  private

  def retrieve_input
    retrieve_file_object
  end
end
