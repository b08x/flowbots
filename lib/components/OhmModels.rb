#!/usr/bin/env ruby
# frozen_string_literal: true

require "ohm"
require "ohm/contrib"

module OhmIndexManager
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def ensure_indices
      indices.each do |index_name|
        key = "#{self.key}:indices:#{index_name}"
        unless Ohm.redis.call("EXISTS", key) == 1
          logger.info "Creating missing index '#{index_name}' for #{name}"
          Ohm.redis.call("SADD", key, "")
        end
      end
    end

    def verify_indices
      logger.debug "Verifying indices for #{name}"
      indices.each do |index_name|
        key = "#{self.key}:indices:#{index_name}"
        unless Ohm.redis.call("TYPE", key) == "set"
          logger.error "Index '#{index_name}' not found for #{name}"
          raise Ohm::IndexNotFound, "Index '#{index_name}' not found for #{name}"
        end
      end
      logger.debug "All indices verified for #{name}"
    end
  end
end

class Workflow < Ohm::Model
  include OhmIndexManager

  attribute :name
  attribute :status
  attribute :start_time
  attribute :end_time
  attribute :current_batch_number
  attribute :is_batch_workflow
  attribute :workflow_type
  attribute :current_file_id

  set :sourcefiles, :Sourcefile
  set :batches, :Batch

  index :workflow_type
  index :status

  def self.verify_indices
    logger.debug "Verifying Workflow indices"
    %i[workflow_type status].each do |index_name|
      unless Ohm.redis.call("TYPE", "#{key}:indices:#{index_name}") == "set"
        logger.error "Index '#{index_name}' not found for Workflow"
        raise Ohm::IndexNotFound, "Index '#{index_name}' not found for Workflow"
      end
    end
    logger.debug "All Workflow indices verified"
  end
end

class Task < Ohm::Model
  attribute :name
  attribute :status
  attribute :result
  attribute :start_time
  attribute :end_time
  index :name
  index :status
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
  include OhmIndexManager

  attribute :path
  attribute :name
  attribute :content
  attribute :preprocessed_content
  attribute :metadata

  set :workflows, :Workflow
  reference :batch, :Batch

  index :path
  index :name
  index :batch_id

  def self.find_or_create_by_path(file_path, attributes={})
    ensure_indices
    verify_indices
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
      name: file_name,
      content: File.read(file_path)
    )
    logger.debug "New attributes: #{new_attributes.inspect}"

    begin
      new_file = create(new_attributes)
      logger.debug "New file created: #{new_file.inspect}"
      new_file
    rescue Ohm::UniqueIndexViolation => e
      logger.error "Unique index violation: #{e.message}"
      raise FlowbotError.new("Unique index violation: #{e.message}", "UNIQUE_INDEX_ERROR")
    rescue StandardError => e
      logger.error "Error creating Sourcefile: #{e.message}"
      raise FlowbotError.new("Error creating Sourcefile: #{e.message}", "SOURCEFILE_CREATE_ERROR")
    end
  end

  def self.verify_indices
    logger.debug "Verifying Sourcefile indices"
    %i[path name batch_id].each do |index_name|
      unless Ohm.redis.call("TYPE", "#{key}:indices:#{index_name}") == "set"
        logger.error "Index '#{index_name}' not found for Sourcefile"
        raise Ohm::IndexNotFound, "Index '#{index_name}' not found for Sourcefile"
      end
    end
    logger.debug "All Sourcefile indices verified"
  end

  def add_to_workflow(workflow)
    workflows.add(workflow)
    workflow.sourcefiles.add(self)
  end

  def preprocess_content
    # Implement preprocessing logic here
    self.preprocessed_content = content
    save
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
