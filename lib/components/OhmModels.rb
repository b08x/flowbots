#!/usr/bin/env ruby
# frozen_string_literal: true

class Topic < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :name
  attribute :description
  attribute :vector
  reference :textfile, :Textfile
  # reference :collection, :Collection # Reference to the parent collection
  unique :name
  index :name
end

class Textfile < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :name
  attribute :path
  attribute :extension
  attribute :title
  attribute :content
  attribute :batch

  set :topics, :Topic
  list :segments, :Segment
  list :words, :Word

  unique :title
  unique :path

  index :title
  index :path
  index :batch

  def self.find_or_create_by_path(file_path, attributes = {})
    existing_file = find(path: file_path).first
    return existing_file if existing_file

    file_name = File.basename(file_path)
    extension = File.extname(file_path)
    title = File.basename(file_path, ".*")

    create(attributes.merge(
      name: file_name,
      path: file_path,
      extension: extension,
      title: title
    ))
  end

  def self.latest(limit = nil)
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

  def add_topics(new_topics)
    new_topics.each do |word|
      begin
        topics.add(Topic.create(name: word))
      rescue StandardError => e
        logger.warn "#{e.message}"
      end
    end
    save
  end

  def add_segments(new_segments)
    new_segments.each do |segment_text|
      segment = Segment.create(text: segment_text, textfile: self)
      segments.push(segment)
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

  reference :textfile, :Textfile
  reference :topic, :Topic

  def add_topics(new_topics)
    new_topics.each do |topic|
      next if Topic.find(name: word).first
      topic = Topic.create(name: word, segment: self)
      topics.push(topic)
    end
    save
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
  # attribute :synsets # TOOD: might be Hash type
  attribute :pos
  attribute :tag
  attribute :dep
  attribute :ner

  reference :Textfile, :Textfile
  reference :segment, :Segment

  index :word
  # collection :vector_data, :VectorData
end
