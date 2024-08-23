#!/usr/bin/env ruby
# frozen_string_literal: true

module InputRetrieval
  def retrieve_input
    raise NotImplementedError, "#{self.class} must implement retrieve_input"
  end

  def retrieve_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  def retrieve_file_path
    Jongleur::WorkerTask.class_variable_get(:@@redis).get("input_file_path")
  end
end
