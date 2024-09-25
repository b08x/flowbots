#!/usr/bin/env ruby
# frozen_string_literal: true

$:.push File.expand_path(File.dirname(__FILE__) + "/../lib")

require "ohm"
require "pastel"

PASTEL = Pastel.new

@@word_buckets = [
  "collection" => {
    attributes: %w[name description],
    indexed: ["name"],
    collections: ["documents"],
    references: []
  },
  "document" => {
    attributes: %w[name content created_at],
    indexed: ["name"],
    collections: %w[segments words],
    references: ["collection"]
  },
  "segment" => {
    attributes: %w[text start_position end_position],
    indexed: ["text"],
    collections: ["words"],
    references: ["document"]
  },
  "word" => {
    attributes: %w[word frequency],
    indexed: ["word"],
    references: ["segment"]
  }
]

def get_object_bucket(object_bucket)
  @@word_buckets.find { |bucket| bucket[0] == object_bucket }
end

def get_object_attributes(object_bucket)
  get_object_bucket(object_bucket)[1][:attributes]
end

def get_object_indexed_attributes(object_bucket)
  get_object_bucket(object_bucket)[1][:indexed]
end

def get_object_collections(object_bucket)
  get_object_bucket(object_bucket)[1][:collections]
end

def get_object_references(object_bucket)
  get_object_bucket(object_bucket)[1][:references]
end

def get_object_by_name(object_bucket, object_name)
  object_class = Object.const_get(object_bucket.capitalize)
  object_class.find(name: object_name).first
end

def get_objects_by_collection(object_bucket, collection_name)
  object_class = Object.const_get(object_bucket.capitalize)
  object_class.all.select { |object| object.collection.name == collection_name }
end

def get_objects_by_reference(object_bucket, reference_name, reference_value)
  object_class = Object.const_get(object_bucket.capitalize)
  object_class.all.select { |object| object.send(reference_name).name == reference_value }
end

def get_objects_by_regex(object_bucket, regex)
  object_class = Object.const_get(object_bucket.capitalize)
  object_class.all.select { |object| object.name =~ regex }
end

def get_objects_by_query(object_bucket, query)
  object_class = Object.const_get(object_bucket.capitalize)
  object_class.all.select { |object| query.all? { |key, value| object.send(key) == value } }
end

def get_objects(object_bucket, object_name, query=nil)
  if object_name
    object = get_object_by_name(object_bucket, object_name)
    return [object] if object
  end

  return get_objects_by_query(object_bucket, query) if query

  if get_object_references(object_bucket).any?
    reference_name = get_object_references(object_bucket).first
    reference_value = object_name
    return get_objects_by_reference(object_bucket, reference_name, reference_value)
  end

  if get_object_collections(object_bucket).any?
    collection_name = get_object_collections(object_bucket).first
    return get_objects_by_collection(object_bucket, collection_name)
  end

  get_objects_by_regex(object_bucket, ".*")
end

def format_output(objects)
  objects.map do |object|
    {
      name: object.name,
      attributes: object.attributes.to_h.reject { |key, _| key == "id" }
    }
  end
end

def main
  object_bucket = ARGV[0]
  object_name = ARGV[1]
  query = ARGV[2..-1]&.map { |arg| arg.split("=") }&.to_h

  objects = get_objects(object_bucket, object_name, query)

  puts format_output(objects).to_json
end

main
