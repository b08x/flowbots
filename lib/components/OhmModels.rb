#!/usr/bin/env ruby
# frozen_string_literal: true

class Topic < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules for data type handling and callback management.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Topic model.
  attribute :name
  attribute :description
  attribute :vector
  reference :textfile, :Textfile
  # reference :collection, :Collection # Reference to the parent collection

  # Defines a unique index for the name attribute.
  unique :name

  # Defines an index for the name attribute.
  index :name
end

class Textfile < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules for data type handling and callback management.
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :name
  attribute :path
  attribute :extension
  attribute :title
  attribute :content
  attribute :preprocessed_content
  attribute :metadata, Type::Hash
  attribute :tagged, Type::Hash
  attribute :analysis

  attribute :batch

  set :topics, :Topic
  list :segments, :Segment
  list :words, :Word

  unique :path

  index :title
  index :path
  index :batch
  index :analysis

  def self.current
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    self[textfile_id]
  end

  def add_segment(text)
    segment = Segment.create(text:, textfile: self)
    segments.push(segment)
    save
    segment
  end

  def add_word(word_data)
    word = Word.create(word_data.merge(textfile: self))
    words.push(word)
    save
    word
  end

  # Finds or creates a Textfile object based on the provided file path and attributes.
  #
  # @param file_path [String] The path to the file.
  # @param attributes [Hash] A hash of attributes for the Textfile object.
  #
  # @return [Textfile] The Textfile object.
  def self.find_or_create_by_path(file_path, attributes={})
    # Finds an existing Textfile object with the given path.
    existing_file = find(path: file_path).first

    # Returns the existing object if found.
    return existing_file if existing_file

    # Extracts the file name, extension, and title from the path.
    file_name = File.basename(file_path)
    extension = File.extname(file_path)
    title = File.basename(file_path, ".*")

    # Creates a new Textfile object with the provided attributes.
    create(
      attributes.merge(
        name: file_name,
        path: file_path,
        extension:,
        title:
      )
    )
  end

  # Retrieves the latest Textfile object from Redis.
  #
  # @param limit [Integer] The maximum number of Textfile objects to retrieve.
  #
  # @return [Textfile, Array] The latest Textfile object or an array of Textfile objects.
  def self.latest(limit=nil)
    # Retrieves the ID of the latest Textfile object from Redis.
    if limit.nil?
      ids = redis.call("ZREVRANGE", key[:latest], 0, 0)
      result = fetch(ids)
      result.empty? ? nil : result.first
    else
      ids = redis.call("ZREVRANGE", key[:latest], 0, limit - 1)
      # Fetches the Textfile objects based on the retrieved IDs.
      fetch(ids)
    end
  end

  # Retrieves Textfile objects for the current batch.
  #
  # @return [Array] An array of Textfile objects for the current batch.
  def self.current_batch
    # Retrieves the current batch ID from Redis.
    batch_id = redis.call("GET", "current_batch_id")

    # Finds Textfile objects with the current batch ID.
    find(batch: batch_id)
  end

  # Adds new topics to the Textfile object.
  #
  # @param new_topics [Array] An array of new topic names.
  #
  # @return [void]
  def add_topics(new_topics)
    # Iterates through each new topic name and creates a new Topic object.
    new_topics.each do |word|
      topics.add(Topic.create(name: word))
    rescue StandardError => e
      logger.warn e.message.to_s
    end

    # Saves the updated Textfile object.
    save
  end

  # Adds new segments to the Textfile object.
  #
  # @param new_segments [Array] An array of new segment texts.
  #
  # @return [void]
  def add_segments(new_segments)
    # Iterates through each new segment text and creates a new Segment object.
    new_segments.each do |segment_text|
      segment = Segment.create(text: segment_text, textfile: self)
      segments.push(segment)
    end

    # Saves the updated Textfile object.
    save
  end

  # Retrieves all segments associated with the Textfile object.
  #
  # @return [Array] An array of Segment objects.
  def retrieve_segments
    segments.to_a
  end

  # Retrieves the text content of all segments associated with the Textfile object.
  #
  # @return [Array] An array of segment texts.
  def retrieve_segment_texts
    retrieve_segments.map(&:text)
  end

  # Retrieves all words associated with the Textfile object.
  #
  # @return [Array] An array of Word objects.
  def retrieve_words
    segments.to_a.flat_map { |segment| segment.words.to_a }
  end

  # Retrieves the text content of all words associated with the Textfile object.
  #
  # @return [Array] An array of word texts.
  def retrieve_word_texts
    retrieve_words.map(&:word)
  end

  protected

  # Callback method executed after saving the Textfile object.
  #
  # @return [void]
  def after_save
    # Adds the Textfile object's ID to the Redis set representing the latest Textfile objects.
    redis.call("ZADD", model.key[:latest], Time.now.to_f, id)
  end

  # Callback method executed after deleting the Textfile object.
  #
  # @return [void]
  def after_delete
    # Removes the Textfile object's ID from the Redis set representing the latest Textfile objects.
    redis.call("ZREM", model.key[:latest], id)
  end
end

class Segment < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules for data type handling and callback management.
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :text
  attribute :tokens, Type::Array
  attribute :tagged, Type::Hash

  list :words, :Word

  reference :textfile, :Textfile
  reference :topic, :Topic

  def add_word(word_data)
    word = Word.create(word_data.merge(segment: self))
    words.push(word)
    save
    word
  end

  # Adds new topics to the Segment object.
  #
  # @param new_topics [Array] An array of new topic names.
  #
  # @return [void]
  def add_topics(new_topics)
    # Iterates through each new topic name and creates a new Topic object.
    new_topics.each do |topic|
      next if Topic.find(name: topic).first

      Topic.create(name: topic, segment: self)
      topics.push(topic)
    end

    # Saves the updated Segment object.
    save
  end

  # Adds new words to the Segment object.
  #
  # @param new_words [Array] An array of new word data.
  #
  # @return [void]
  def add_words(new_words)
    # Iterates through each new word data and creates a new Word object.
    new_words.each do |word_data|
      word = Word.create(word_data.merge(segment: self))
      words.push(word)
    end

    # Saves the updated Segment object.
    save
  end

  # Retrieves all words associated with the Segment object.
  #
  # @return [Array] An array of Word objects.
  def retrieve_words
    words.to_a
  end

  # Retrieves the text content of all words associated with the Segment object.
  #
  # @return [Array] An array of word texts.
  def retrieve_word_texts
    retrieve_words.map(&:word)
  end
end

class Word < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules for data type handling and callback management.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Word model.
  attribute :word
  # attribute :synsets # TOOD: might be Hash type
  attribute :pos
  attribute :tag
  attribute :dep
  attribute :ner

  # Defines references to the parent Textfile and Segment objects.
  reference :Textfile, :Textfile
  reference :segment, :Segment

  # Defines an index for the word attribute.
  index :word
  # collection :vector_data, :VectorData
end
