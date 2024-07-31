#!/usr/bin/env ruby
# frozen_string_literal: true

class Workflow < Ohm::Model
  attribute :name
  attribute :status
  attribute :start_time
  attribute :end_time
  attribute :current_batch_number
  attribute :is_batch_workflow
  attribute :workflow_type

  set :sourcefiles, :Sourcefile
  set :batches, :Batch

  index :workflow_type
end

class Batch < Ohm::Model
  attribute :number
  attribute :status

  reference :workflow, :Workflow
  set :sourcefiles, :Sourcefile

  index :number
  index :workflow_id
end

class Sourcefile < Ohm::Model
  attribute :path
  attribute :name
  attribute :content
  attribute :preprocessed_content
  attribute :metadata

  reference :workflow, :Workflow
  reference :batch, :Batch

  index :path
  index :name
  index :workflow_id
  index :batch_id

  def self.find_or_create_by_path(file_path, attributes = {})
    logger.debug "Finding or creating Sourcefile for path: #{file_path}"
    logger.debug "Attributes: #{attributes.inspect}"

    existing_file = find(path: file_path).first
    if existing_file
      logger.debug "Existing file found: #{existing_file.inspect}"
      return existing_file
    end

    logger.debug "No existing file found, creating new Sourcefile"
    file_name = File.basename(file_path)
    new_attributes = attributes.merge(
      path: file_path,
      name: file_name
    )
    logger.debug "New attributes: #{new_attributes.inspect}"

    begin
      p new_attributes
      p file_name
      new_file = create(new_attributes)
      exit
    rescue StandardError => e
      logger.fatal "#{e.message}"
    end

    logger.debug "New file created: #{new_file.inspect}"
    new_file
  end
end

class Segment < Ohm::Model
  attribute :text
  attribute :tokens
  attribute :tagged

  reference :sourcefile, :Sourcefile
  list :words, :Word
end

class Word < Ohm::Model
  attribute :word
  attribute :pos
  attribute :tag
  attribute :dep
  attribute :ner

  reference :sourcefile, :Sourcefile
  reference :segment, :Segment

  index :word
end

class Topic < Ohm::Model
  attribute :name
  attribute :description
  attribute :vector

  set :sourcefiles, :Sourcefile
end
