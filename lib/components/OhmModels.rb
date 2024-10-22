#!/usr/bin/env ruby
# frozen_string_literal: true

# This file defines the Ohm models used in the Flowbots application.
class Agent < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Agent model.
  attribute :name
  attribute :role
  attribute :state, Type::Hash
  collection :messages, :Message
  collection :episodic_memories, :EpisodicMemory
  collection :semantic_memories, :SemanticMemory
  collection :reflections, :Reflection
  index :name
  index :role

  # Store an episodic memory for the agent.
  #
  # @param content [String] The content of the episodic memory.
  #
  # @return [EpisodicMemory] The created episodic memory.
  def store_episodic_memory(content)
    EpisodicMemory.create(agent: self, content: content, timestamp: Time.now)
  end

  # Update the agent's semantic memory.
  #
  # @param content [String] The content of the semantic memory.
  #
  # @return [SemanticMemory] The created semantic memory.
  def update_semantic_memory(content)
    SemanticMemory.create(agent: self, content: content, timestamp: Time.now)
  end

  # Record a reflection for the agent.
  #
  # @param content [String] The content of the reflection.
  #
  # @return [Reflection] The created reflection.
  def reflect(content)
    Reflection.create(agent: self, content: content, timestamp: Time.now)
  end

  # Retrieve memories based on type and query.
  #
  # @param type [Symbol] The type of memory to retrieve (:episodic, :semantic, :reflection).
  # @param query [String] The query to search for.
  #
  # @return [Object] The retrieved memory object, or nil if no match is found.
  def retrieve_memories(type, query)
    case type
    when :episodic
      episodic_memories.find(content: query).first
    when :semantic
      semantic_memories.find(content: query).first
    when :reflection
      reflections.find(content: query).first
    end
  end
end

# Defines the Task model.
class Task < Ohm::Model
  # Includes the Ohm::DataTypes, Ohm::Callbacks, and InputRetrieval modules.
  include Ohm::DataTypes
  include Ohm::Callbacks
  include InputRetrieval

  # Defines attributes for the Task model.
  attribute :name
  attribute :status
  attribute :result
  attribute :start_time
  attribute :end_time
  attribute :predecessors, Type::Array

  attribute :agent_role
  attribute :cartridge_file

  index :agent_role
  index :cartridge_file

  index :name
  index :status

  # Creates a new Task instance with a timestamp.
  #
  # @param attributes [Hash] A hash of attributes for the new Task.
  #
  # @return [Task] The created Task instance.
  def self.create_with_timestamp(attributes = {})
    new_task = create(attributes.merge(start_time: Time.now.to_s))
    new_task.save
    new_task
  end

  # Completes the task and updates its status and result.
  #
  # @param result [Object] The result of the task execution.
  #
  # @return [void]
  def complete(result = nil)
    update(status: "completed", result:, end_time: Time.now.to_s)
  end

  # Fails the task and updates its status and result with an error message.
  #
  # @param error_message [String] The error message.
  #
  # @return [void]
  def fail(error_message)
    update(status: "failed", result: error_message, end_time: Time.now.to_s)
  end

  # Returns the duration of the task in seconds.
  #
  # @return [Integer] The duration of the task in seconds, or nil if start_time or end_time is nil.
  def duration
    return nil if start_time.nil? || end_time.nil?

    start = Time.parse(start_time)
    finish = Time.parse(end_time)
    (finish - start).to_i
  end

  # Executes the task.
  #
  # This method must be implemented in subclasses to define the specific
  # actions performed by the task.
  #
  # @return [void]
  def execute
    raise NotImplementedError, "#{self.class.name}#execute must be implemented in subclass"
  end

  # Retrieves the input file object from Redis.
  #
  # @return [FileObject] The retrieved file object.
  def retrieve_input
    file_object_id = RedisKeys.get(RedisKeys::CURRENT_FILE_OBJECT_ID)
    FileObject[file_object_id]
  end

  # Finds all pending tasks.
  #
  # @return [Array<Task>] An array of pending tasks.
  def self.pending
    find(status: "pending")
  end

  # Finds all completed tasks.
  #
  # @return [Array<Task>] An array of completed tasks.
  def self.completed
    find(status: "completed")
  end

  # Finds all failed tasks.
  #
  # @return [Array<Task>] An array of failed tasks.
  def self.failed
    find(status: "failed")
  end

  # Finds all tasks in progress.
  #
  # @return [Array<Task>] An array of tasks in progress.
  def self.in_progress
    find(status: "in_progress")
  end
end

# Defines the Cartridge model.
class Cartridge < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Cartridge model.
  attribute :name
  attribute :path
  attribute :content, Type::Hash # Store content as a hash to represent YAML structure
  index :name
  index :path

  # Load the cartridge content from the file.
  #
  # @return [Hash] The loaded cartridge content as a hash.
  def load_content
    YAML.safe_load(File.read(path)) # Use YAML.safe_load for secure parsing
  end

  # Evaluate the cartridge content (implementation depends on the cartridge format).
  #
  # @param input [String] The input to evaluate.
  #
  # @return [String] The result of the evaluation.
  def evaluate(input)
    # Access settings from the loaded YAML hash
    provider = content['provider']
    settings = content['provider']['settings']

    # Example: If the cartridge is for Cohere
    if provider['id'] == 'cohere'
      # Use the Cohere API to generate text based on settings
      response = Cohere.generate(
        model: settings['model'],
        prompt: input,
        temperature: settings['temperature'],
        k: settings['k'],
        p: settings['p'],
        # ... other settings
      )
      return response.text
    end

    # ... (Implement evaluation logic for other providers)
  end
end

# Defines the FileObject model.
class FileObject < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the FileObject model.
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

  # Finds or creates a new FileObject instance based on the file path.
  #
  # @param file_path [String] The path to the file.
  # @param attributes [Hash] A hash of attributes for the new FileObject.
  #
  # @return [FileObject] The found or created FileObject instance.
  def self.find_or_create_by_path(file_path, attributes = {})
    raise ArgumentError, "file_path must be a String, got #{file_path.class}" unless file_path.is_a?(String)

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
  rescue Errno::ENOENT
    raise FileNotFoundError, "File not found: #{file_path}"
  rescue StandardError => e
    raise FileObjectError, "Error creating FileObject: #{e.message}"
  end

  # Adds a new segment to the FileObject.
  #
  # @param text [String] The text of the new segment.
  #
  # @return [Segment] The created segment.
  def add_segment(text)
    segment = Segment.create(text:, file_object: self)
    segments.push(segment)
    save
    segment
  end

  # Adds multiple segments to the FileObject.
  #
  # @param new_segments [Array<String>] An array of segment texts.
  #
  # @return [void]
  def add_segments(new_segments)
    new_segments.each do |segment_text|
      add_segment(segment_text)
    end
  end

  # Adds a new lemma to the FileObject.
  #
  # @param lemma_data [Hash] A hash containing lemma data.
  #
  # @return [Lemma] The created lemma.
  def add_lemma(lemma_data)
    lemma = Lemma.create(lemma_data.merge(file_object: self))
    lemmas.push(lemma)
    save
    lemma
  end

  # Adds multiple lemmas to the FileObject.
  #
  # @param lemmas_data [Array<Hash>] An array of lemma data hashes.
  #
  # @return [Array<Lemma>] An array of created lemmas.
  def add_lemmas(lemmas_data)
    new_lemmas = lemmas_data.map do |lemma_data|
      lemma = Lemma.create(lemma_data.merge(file_object: self))
      lemmas.push(lemma)
      lemma
    end
    save
    new_lemmas
  end

  # Adds multiple topics to the FileObject.
  #
  # @param new_topics [Array<String>] An array of topic names.
  #
  # @return [void]
  def add_topics(new_topics)
    new_topics.each do |word|
      topics.add(Topic.create(name: word))
    rescue StandardError => e
      logger.warn e.message.to_s
    end
    save
  end

  # Retrieves all segments associated with the FileObject.
  #
  # @return [Array<Segment>] An array of segments.
  def retrieve_segments
    segments.to_a
  end

  # Retrieves the text of all segments associated with the FileObject.
  #
  # @return [Array<String>] An array of segment texts.
  def retrieve_segment_texts
    retrieve_segments.map(&:text)
  end

  # Retrieves all words associated with the FileObject.
  #
  # @return [Array<Word>] An array of words.
  def retrieve_words
    segments.to_a.flat_map { |segment| segment.words.to_a }
  end

  # Retrieves the text of all words associated with the FileObject.
  #
  # @return [Array<String>] An array of word texts.
  def retrieve_word_texts
    retrieve_words.map(&:word)
  end

  # Retrieves the latest FileObject from Redis.
  #
  # @param limit [Integer] The maximum number of FileObjects to retrieve.
  #
  # @return [FileObject, Array<FileObject>] The latest FileObject or an array of FileObjects.
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

  # Retrieves all FileObjects from the current batch.
  #
  # @return [Array<FileObject>] An array of FileObjects from the current batch.
  def self.current_batch
    batch_id = redis.call("GET", "current_batch_id")
    find(batch: batch_id)
  end

  protected

  # Adds the FileObject's ID to the Redis set for latest FileObjects.
  #
  # @return [void]
  def after_save
    redis.call("ZADD", model.key[:latest], Time.now.to_f, id)
  end

  # Removes the FileObject's ID from the Redis set for latest FileObjects.
  #
  # @return [void]
  def after_delete
    redis.call("ZREM", model.key[:latest], id)
  end
end

# Defines the Segment model.
class Segment < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Segment model.
  attribute :text
  attribute :tokens, Type::Array
  attribute :tagged, Type::Hash

  list :words, :Word

  reference :file_object, :FileObject
  reference :topic, :Topic

  # Adds a new word to the Segment.
  #
  # @param word_data [Hash] A hash containing word data.
  #
  # @return [Word] The created word.
  def add_word(word_data)
    word = Word.create(word_data.merge(segment: self))
    words.push(word)
    save
    word
  end

  # Adds multiple words to the Segment.
  #
  # @param new_words [Array<Hash>] An array of word data hashes.
  #
  # @return [void]
  def add_words(new_words)
    new_words.each do |word_data|
      word = Word.create(word_data.merge(segment: self))
      words.push(word)
    end
    save
  end

  # Retrieves all words associated with the Segment.
  #
  # @return [Array<Word>] An array of words.
  def retrieve_words
    words.to_a
  end

  # Retrieves the text of all words associated with the Segment.
  #
  # @return [Array<String>] An array of word texts.
  def retrieve_word_texts
    retrieve_words.map(&:word)
  end
end

# Defines the Word model.
class Word < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Word model.
  attribute :word
  attribute :pos
  attribute :tag
  attribute :dep
  attribute :ner

  reference :file_object, :FileObject
  reference :segment, :Segment

  index :word
end

# Defines the Lemma model.
class Lemma < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Lemma model.
  attribute :lemma
  attribute :pos
  attribute :count, Type::Integer

  reference :file_object, :FileObject

  index :lemma
  index :pos
end

# Defines the Topic model.
class Topic < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # Defines attributes for the Topic model.
  attribute :name
  attribute :description
  attribute :vector

  reference :file_object, :FileObject

  unique :name
  index :name
end