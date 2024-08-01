#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  module Flowbots::OhmIndexManager
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
end

class Workflow < Ohm::Model
  include Ohm::DataTypes
  include Flowbots::OhmIndexManager

  attribute :name
  attribute :status
  attribute :start_time, Type::Time
  attribute :end_time, Type::Time
  attribute :current_batch_number
  attribute :is_batch_workflow
  attribute :workflow_type
  attribute :current_file_id

  set :sourcefiles, :Sourcefile
  set :batches, :Batch

  index :workflow_type
  index :status
  index :current_file_id
end

class OhmTask < Ohm::Model
  include Ohm::DataTypes
  include Flowbots::OhmIndexManager

  attribute :name
  attribute :status
  attribute :result
  attribute :start_time, Type::Time
  attribute :end_time, Type::Time

  reference :workflow, :Workflow
  reference :sourcefile, :Sourcefile

  index :name
  index :status
  index :workflow_id
  index :sourcefile_id

  def self.create(workflow, sourcefile)
    task = new
    task.init(workflow, sourcefile)
    task
  end

  def init(workflow, sourcefile)
    self.name = self.class.name
    self.status = "pending"
    self.start_time = Time.now
    self.workflow = workflow
    self.sourcefile = sourcefile
    save
  end

  def update_status(new_status, result=nil)
    self.status = new_status
    self.result = result if result
    self.end_time = Time.now if %w[completed failed].include?(new_status)
    save
  end
end

class Batch < Ohm::Model
  include Ohm::DataTypes
  include Flowbots::OhmIndexManager

  attribute :number
  attribute :status

  reference :workflow, :Workflow
  set :sourcefiles, :Sourcefile

  index :number
  index :workflow_id
end

class Sourcefile < Ohm::Model
  include Ohm::DataTypes
  include Flowbots::OhmIndexManager

  attribute :path
  attribute :name
  attribute :content
  attribute :preprocessed_content
  attribute :metadata, Type::Hash

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
  include Flowbots::OhmIndexManager

  attribute :text
  attribute :tokens
  attribute :tagged

  reference :sourcefile, :Sourcefile
  list :words, :Word
end

class Word < Ohm::Model
  include Flowbots::OhmIndexManager

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
  include Flowbots::OhmIndexManager

  attribute :name
  attribute :description
  attribute :vector

  set :sourcefiles, :Sourcefile
end
