#!/usr/bin/env ruby
# frozen_string_literal: true

require "ohm"
require "ohm/contrib"

#accessions

class Project < Ohm::Model
  attribute :name
  collection :document_collections, :DocumentCollection
  unique :name
  index :name
end

class DocumentCollection < Ohm::Model
  attribute :name
  attribute :last_updated
  collection :categories, :DocumentCategory
  collection :documents, :Document
  collection :document_links, :DocumentLink
  collection :storage_locations, :StorageLocation
  collection :document_components, :DocumentComponent
  reference :project, :Project
  index :name
end

class DocumentCategory < Ohm::Model
  attribute :name
  attribute :status
  attribute :total_word_count
  attribute :total_document_count
  reference :document_collection, :DocumentCollection
  collection :documents, :Document
  unique :name
  index :name
end

class Document < Ohm::Model
  include Ohm::DataTypes

  attribute :name
  attribute :status
  attribute :word_count
  attribute :file_size
  attribute :file_type
  attribute :last_modified
  attribute :content_hash
  attribute :metadata, Type::Hash
  attribute :tags, Type::Array
  attribute :processing_history, Type::Array
  reference :document_collection, :DocumentCollection
  reference :category, :DocumentCategory
  collection :components, :DocumentComponent
  list :storage_locations, :StorageLocation
  list :document_links, :DocumentLink
  unique :content_hash
  index :name
  index :file_type
  index :status
end

class DocumentLink < Ohm::Model
  attribute :name
  attribute :link_type
  collection :documents, :Document
  reference :document_collection, :DocumentCollection
  index :name
  index :link_type
end

class StorageLocation < Ohm::Model
  attribute :name
  attribute :path
  attribute :total_capacity
  attribute :used_capacity
  attribute :free_capacity
  attribute :access_status
  list :documents, :Document
  reference :document_collection, :DocumentCollection
  unique :path
  index :name
end

class DocumentComponent < Ohm::Model
  attribute :name
  attribute :component_type
  attribute :content
  attribute :word_count
  attribute :status
  attribute :processing_status
  reference :document, :Document
  reference :document_collection, :DocumentCollection
  index :name
  index :component_type
  index :status
end
