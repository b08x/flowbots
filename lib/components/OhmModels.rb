#!/usr/bin/env ruby
# frozen_string_literal: true

# This file defines the Ohm models used in the Flowbots application.

# The Agent model represents an agent in the Flowbots system.
# It stores information about the agent, such as its name, role, state,
# and collections of messages, episodic memories, semantic memories,
# and reflections.
class Agent < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # @!attribute name
  #   @return [String] The name of the agent.
  attribute :name

  # @!attribute role
  #   @return [String] The role of the agent.
  attribute :role

  # @!attribute state
  #   @return [Hash] The state of the agent, stored as a hash.
  attribute :state, Type::Hash

  # @!attribute messages
  #   @return [Ohm::Collection<Message>] A collection of messages associated with the agent.
  collection :messages, :Message

  # @!attribute episodic_memories
  #   @return [Ohm::Collection<EpisodicMemory>] A collection of episodic memories associated with the agent.
  collection :episodic_memories, :EpisodicMemory

  # @!attribute semantic_memories
  #   @return [Ohm::Collection<SemanticMemory>] A collection of semantic memories associated with the agent.
  collection :semantic_memories, :SemanticMemory

  # @!attribute reflections
  #   @return [Ohm::Collection<Reflection>] A collection of reflections associated with the agent.
  collection :reflections, :Reflection

  # Index on the `name` attribute.
  index :name

  # Index on the `role` attribute.
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

# The Task model represents a task in the Flowbots system.
# It stores information about the task, such as its name, status, result,
# start and end times, predecessors, agent role, and cartridge file.
class Task < Ohm::Model
  # Includes the Ohm::DataTypes, Ohm::Callbacks, and InputRetrieval modules.
  include Ohm::DataTypes
  include Ohm::Callbacks
  include InputRetrieval

  # @!attribute name
  #   @return [String] The name of the task.
  attribute :name

  # @!attribute status
  #   @return [String] The status of the task.
  attribute :status

  # @!attribute result
  #   @return [Object] The result of the task execution.
  attribute :result

  # @!attribute start_time
  #   @return [String] The start time of the task, as a string.
  attribute :start_time

  # @!attribute end_time
  #   @return [String] The end time of the task, as a string.
  attribute :end_time

  # @!attribute predecessors
  #   @return [Array] An array of predecessor tasks.
  attribute :predecessors, Type::Array

  # @!attribute agent_role
  #   @return [String] The role of the agent that will execute the task.
  attribute :agent_role

  # @!attribute cartridge_file
  #   @return [String] The path to the cartridge file associated with the task.
  attribute :cartridge_file

  # Index on the `agent_role` attribute.
  index :agent_role

  # Index on the `cartridge_file` attribute.
  index :cartridge_file

  # Index on the `name` attribute.
  index :name

  # Index on the `status` attribute.
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

# The Cartridge model represents a cartridge in the Flowbots system.
# It stores information about the cartridge, such as its name, path,
# and content.
class Cartridge < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # @!attribute name
  #   @return [String] The name of the cartridge.
  attribute :name

  # @!attribute path
  #   @return [String] The path to the cartridge file.
  attribute :path

  # @!attribute content
  #   @return [Hash] The content of the cartridge, stored as a hash.
  attribute :content, Type::Hash # Store content as a hash to represent YAML structure

  # Index on the `name` attribute.
  index :name

  # Index on the `path` attribute.
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

# The FileObject model represents a file object in the Flowbots system.
# It stores information about the file, such as its name, path, extension,
# content, preprocessed content, metadata, batch, tags, main topics,
# speech acts, transitivity, LLM analysis, topics, segments, and lemmas.
class FileObject < Ohm::Model
  # Includes the Ohm::DataTypes and Ohm::Callbacks modules.
  include Ohm::DataTypes
  include Ohm::Callbacks

  # @!attribute name
  #   @return [String] The name of the file.
  attribute :name

  # @!attribute path
  #   @return [String] The path to the file.
  attribute :path

  # @!attribute extension
  #   @return [String] The file extension.
  attribute :extension

  # @!attribute content
  #   @return [String] The content of the file.
  attribute :content

  # @!attribute preprocessed_content
  #   @return [String] The preprocessed content of the file.
  attribute :preprocessed_content

  # @!attribute metadata
  #   @return [Hash] Metadata associated with the file, stored as a hash.
  attribute :metadata, Type::Hash

  # @!attribute batch
  #   @return [String] The batch the file belongs to.
  attribute :batch

  # @!attribute tagged
  #   @return [Hash] Tags associated with the file, stored as a hash.
  attribute :tagged, Type::Hash

  # @!attribute main_topics
  #   @return [Array] An array of main topics extracted from the file.
  attribute :main_topics, Type::Array

  # @!attribute speech_acts
  #   @return [Array] An array of speech acts identified in the file.
  attribute :speech_acts, Type::Array

  # @!attribute transitivity
  #   @return [Array] An array of transitivity analysis results for the file.
  attribute :transitivity, Type::Array

  # @!attribute llm_analysis
  #   @return [String] The results of LLM analysis performed on the file.
  attribute :llm_analysis

  # @!attribute topics
  #   @return [Ohm::Set<Topic>] A set of topics associated with the file.
  set :topics, :Topic

  # @!attribute segments
  #   @return [Ohm::List<Segment>] A list of segments in the file.
  list :segments, :Segment

  # @!attribute lemmas
  #   @return [Ohm::List<Lemma>] A list of lemmas extracted from the file.
  list :lemmas, :Lemma

  # Unique constraint on the `path` attribute.
  unique :path

  # Index on the `name` attribute.
  index :name

  # Index on the `path` attribute.
  index :path

  # Index on the `batch` attribute.
  index :batch

  # Finds or creates a new FileObject instance based on the file path.
  #
  # @param file_path [String] The path to the file.
  # @param attributes [Hash] A hash of attributes for the new FileObject.
  #
  # @return [FileObject] The found or created FileObject instance.
  #
  # @raise [ArgumentError] If `file_path` is not a string.
  # @raise [FileNotFoundError] If the file is not found at the given path.
  # @raise [FileObjectError] If there is an error creating the FileObject.
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

  # Retrieves the text of all words associated
