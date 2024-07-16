#!/usr/bin/env ruby
# frozen_string_literal: true

# class Collection < Ohm::Model
#   attribute :name
#   collection :documents, :Document
#   collection :topics, :Topic
#   unique :name
#   index :name
# end
#
# class Unprocessed < Ohm::Model
#   reference :collection, :Collection
#   reference :document, :Document
#   index :document
# end
#
# class Document < Ohm::Model
#   attribute :name
#   attribute :path
#   attribute :parentFolder
#   attribute :extension
#   attribute :title
#   attribute :content
#
#   set :topics, :Topic
#
#   collection :chunks, :Chunk
#
#   reference :collection, :Collection # Reference to the parent collection
#
#   unique :title
#   unique :path
#
#   index :title
#   index :path
# end
#
# class Chunk < Ohm::Model
#   attribute :text
#   attribute :tokenized_text
#   attribute :tagged_text
#   collection :words, :Word
#   reference :document, :Document
#   reference :topic, :Topic
#   list :vector_data, :VectorData
# end
#
# class Word < Ohm::Model
#   attribute :word
#   attribute :synsets # TOOD: might be Hash type
#   attribute :part_of_speech
#   attribute :named_entity
#   reference :chunk, :Chunk
#   collection :vector_data, :VectorData
# end
#
# class Topic < Ohm::Model
#   attribute :name
#   attribute :description
#   attribute :vector
#   collection :documents, :Document
#   collection :chunks, :Chunk
#   reference :collection, :Collection # Reference to the parent collection
#   unique :name
#   index :name
# end
#
# class VectorData < Ohm::Model
#   attribute :vector
#   reference :chunk, :Chunk
#   reference :topic, :Topic
# end
