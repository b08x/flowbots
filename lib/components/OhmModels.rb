#!/usr/bin/env ruby
# frozen_string_literal: true

class Task < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  include InputRetrieval

  attribute :name
  attribute :status
  attribute :result
  attribute :start_time
  attribute :end_time
  attribute :predecessors, Type::Array

  index :name
  index :status

  def self.create_with_timestamp(attributes={})
    new_task = create(attributes.merge(start_time: Time.now.to_s))
    new_task.save
    new_task
  end

  def complete(result=nil)
    update(status: "completed", result:, end_time: Time.now.to_s)
  end

  def fail(error_message)
    update(status: "failed", result: error_message, end_time: Time.now.to_s)
  end

  def duration
    return nil if start_time.nil? || end_time.nil?

    start = Time.parse(start_time)
    finish = Time.parse(end_time)
    (finish - start).to_i
  end

  def execute
    raise NotImplementedError, "#{self.class.name}#execute must be implemented in subclass"
  end

  def retrieve_input
    file_object_id = RedisKeys.get(RedisKeys::CURRENT_FILE_OBJECT_ID)
    FileObject[file_object_id]
  end

  def self.pending
    find(status: "pending")
  end

  def self.completed
    find(status: "completed")
  end

  def self.failed
    find(status: "failed")
  end

  def self.in_progress
    find(status: "in_progress")
  end
end

# lib/models/file_object.rb

class FileObject < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :name
  attribute :path
  attribute :extension
  attribute :content
  attribute :preprocessed_content
  attribute :metadata, Type::Hash
  attribute :batch
  attribute :tagged, Type::Hash
  attribute :main_topics, Type::Array
  attribute :speech_acts, Type::Array
  attribute :transitivity, Type::Array
  attribute :llm_analysis

  set :topics, :Topic
  list :segments, :Segment
  list :lemmas, :Lemma

  unique :path

  index :name
  index :path
  index :batch

  def self.find_or_create_by_path(file_path, attributes={})
    existing_file = find(path: file_path).first
    return existing_file if existing_file

    file_name = File.basename(file_path)
    extension = File.extname(file_path)

    create(
      attributes.merge(
        name: file_name,
        path: file_path,
        extension:,
        content: File.read(file_path)
      )
    )
  end

  def add_segment(text)
    segment = Segment.create(text:, file_object: self)
    segments.push(segment)
    save
    segment
  end

  def add_segments(new_segments)
    new_segments.each do |segment_text|
      add_segment(segment_text)
    end
  end

  def add_lemma(lemma_data)
    lemma = Lemma.create(lemma_data.merge(file_object: self))
    lemmas.push(lemma)
    save
    lemma
  end

  def add_lemmas(lemmas_data)
    new_lemmas = lemmas_data.map do |lemma_data|
      lemma = Lemma.create(lemma_data.merge(file_object: self))
      lemmas.push(lemma)
      lemma
    end
    save
    new_lemmas
  end

  def add_topics(new_topics)
    new_topics.each do |word|
      topics.add(Topic.create(name: word))
    rescue StandardError => e
      logger.warn e.message.to_s
    end
    save
  end

  def retrieve_segments
    segments.to_a
  end

  def retrieve_segment_texts
    retrieve_segments.map(&:text)
  end

  def retrieve_words
    segments.to_a.flat_map { |segment| segment.words.to_a }
  end

  def retrieve_word_texts
    retrieve_words.map(&:word)
  end

  def self.latest(limit=nil)
    if limit.nil?
      ids = redis.call("ZREVRANGE", key[:latest], 0, 0)
      result = fetch(ids)
      result.empty? ? nil : result.first
    else
      ids = redis.call("ZREVRANGE", key[:latest], 0, limit - 1)
      fetch(ids)
    end
  end

  def self.current_batch
    batch_id = redis.call("GET", "current_batch_id")
    find(batch: batch_id)
  end

  protected

  def after_save
    redis.call("ZADD", model.key[:latest], Time.now.to_f, id)
  end

  def after_delete
    redis.call("ZREM", model.key[:latest], id)
  end
end

class Segment < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :text
  attribute :tokens, Type::Array
  attribute :tagged, Type::Hash

  list :words, :Word

  reference :file_object, :FileObject
  reference :topic, :Topic

  def add_word(word_data)
    word = Word.create(word_data.merge(segment: self))
    words.push(word)
    save
    word
  end

  def add_words(new_words)
    new_words.each do |word_data|
      word = Word.create(word_data.merge(segment: self))
      words.push(word)
    end
    save
  end

  def retrieve_words
    words.to_a
  end

  def retrieve_word_texts
    retrieve_words.map(&:word)
  end
end

class Word < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :word
  attribute :pos
  attribute :tag
  attribute :dep
  attribute :ner

  reference :file_object, :FileObject
  reference :segment, :Segment

  index :word
end

class Lemma < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :lemma
  attribute :pos
  attribute :count, Type::Integer

  reference :file_object, :FileObject

  index :lemma
  index :pos
end

class Topic < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :name
  attribute :description
  attribute :vector

  reference :file_object, :FileObject

  unique :name
  index :name
end
