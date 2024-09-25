# 🤖 FlowBot Exception Report 🤖


## Error Report: Flowbots Topic Modeling

**Summary:** 

The Flowbots CLI encountered an error while attempting to process text using the Topic Modeling Workflow. The error message "no implicit conversion of nil into Hash" suggests an issue with data type handling during topic inference or storage. 

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** no implicit conversion of nil into Hash
* **Location:** `TopicModelProcessor.rb:171:in 'store_topics'` 

**Backtrace:** The error originated during the `store_topics` method within the `TopicModelProcessor` class. This method is called after inferring topics for a document and is responsible for storing the inferred topic information.  

**Root Cause Analysis:**

The error message indicates that a `nil` value is being provided where a Hash is expected. Based on the code and backtrace, the most likely causes are:

1. **`infer_topics` returning `nil`:** The `infer_topics` method might be returning `nil` instead of a Hash containing topic information. This could happen if the topic inference process encounters an error or if the input `topic_dist` is unexpectedly `nil`.
2. **Empty `result` array:** The error occurs on  `p result[1]`. This could mean that the `result` array passed to `store_topics` is empty or doesn't have a value at index `1`. 

**Recommended Action:**

1. **Inspect `infer_topics`:** Investigate the `infer_topics` method to determine why it might return `nil`. Review the topic inference logic and ensure it handles cases where no topics are inferred.
2. **Debug `process` method in `TopicModelProcessor`:**  Place a breakpoint before the call to `store_topics` to inspect the `result` array. Verify its structure and contents, specifically ensuring it's populated as expected before accessing `result[1]`. 

**Additional Notes:**

The provided code snippets for other files like `text_processing_workflow.rb`, `cli.rb`, etc., are not directly relevant to the error's root cause. Focusing on the `TopicModelProcessor.rb` and specifically the `infer_topics` and `store_topics` methods will be most helpful in resolving this error. 



## Exception Details

- **Class:** Flowbots::CLI
- **Message:** no implicit conversion of nil into Hash

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/processors/TopicModelProcessor.rb:108:in `load_model'
/home/b08x/Workspace/flowbots/lib/processors/TextProcessor.rb:16:in `initialize'
/home/b08x/Workspace/flowbots/lib/processors/TopicModelProcessor.rb:22:in `initialize'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:127:in `new'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:127:in `block in instance'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:125:in `synchronize'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:125:in `instance'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:15:in `initialize'
/home/b08x/Workspace/flowbots/lib/cli.rb:48:in `new'
/home/b08x/Workspace/flowbots/lib/cli.rb:48:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

### Relevant Files

#### TopicModelProcessor.rb

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "tomoto"

TOPIC_MODEL_PATH = ENV.fetch("TOPIC_MODEL_PATH", nil)

class Topic < Ohm::Model
  attribute :name
  attribute :description
  attribute :vector
  collection :documents, :Document
  collection :chunks, :Chunk
  reference :collection, :Collection # Reference to the parent collection
  unique :name
  index :name
end

module Flowbots
  class TopicModelProcessor < TextProcessor
    def initialize
      super
      @model_params = {
        k: 20,
        tw: :one,
        min_cf: 3,
        min_df: 2,
        rm_top: 4,
        alpha: 0.1,
        eta: 0.01,
        seed: 42
      }
    end

    def process(documents, num_topics=5)
      logger.info "Inferring topics for documents"
      Flowbots::UI.say(:ok, "Inferring topics for documents")

      unless model_trained?
        raise FlowbotError.new(
          "Model is not trained. Please train the model before inferring topics.",
          "MODEL_NOT_TRAINED"
        )
      end
      raise FlowbotError.new("Empty document set provided for inference", "EMPTY_DOCUMENT_SET") if documents.empty?

      train_model(documents) unless model_trained?

      results = documents.map do |doc|
        infer_topics(doc) unless doc.empty?
      end

      store_topics(results)

      logger.debug "Inferred topics for #{results.size} documents"
      Flowbots::UI.say(:ok, "Topic inference completed")
      results
    end

    def train_model(documents, iterations=100)
      logger.info "Training topic model"
      Flowbots::UI.say(:ok, "Training topic model")

      if documents.empty?
        logger.error "No documents provided for training"
        raise FlowbotError.new("No documents provided for training", "EMPTY_DOCUMENT_SET")
      end

      documents.each do |doc|
        if doc.strip.empty?
          logger.warn "Skipping empty document"
          next
        end
        @model.add_doc(doc)
      end

      @model.burn_in = iterations
      logger.debug "Burn-in set to #{iterations}"

      @model.train(0)
      logger.info "Model training completed"
      Flowbots::UI.say(:ok, "Model training completed")

      save_model
      store_all_topics
    end

    def get_topics(top_n=10)
      logger.info "Getting top #{top_n} topics"
      raise FlowbotError.new("Model is not trained. Cannot get topics.", "MODEL_NOT_TRAINED") unless model_trained?

      topics = Topic.all.to_a.map do |topic|
        [topic.name.to_i, JSON.parse(topic.description)]
      end.to_h

      Flowbots::UI.say(:ok, "Retrieved top #{top_n} topics")
      topics
    end

    protected

    def load_model
      if File.exist?(TOPIC_MODEL_PATH)
        logger.info "Loading existing model from #{TOPIC_MODEL_PATH}"
        @model = Tomoto::LDA.load(TOPIC_MODEL_PATH)
      else
        logger.info "Creating new model"
        @model = Tomoto::LDA.new(**@model_params)
      end
      logger.debug "Model loaded or created"
      Flowbots::UI.say(:ok, "Topic model loaded or created")
    end

    private

    def model_trained?
      !@model.nil? && @model.num_words > 0
    end

    def infer_topics(text)
      doc = @model.make_doc(text.split)
      topic_dist, ll = @model.infer(doc)

      return {} if topic_dist.nil?

      most_probable_topic = topic_dist.each_with_index.max_by { |prob, _| prob }[1]
      top_words = @model.topic_words(most_probable_topic, top_n: 10)

      {
        most_probable_topic: most_probable_topic,
        topic_distribution: topic_dist,
        top_words: top_words
      }
    end

    def save_model
      logger.info "Saving model to #{@model_path}"
      @model.save(@model_path)
      logger.debug "Model saved"
      Flowbots::UI.say(:ok, "Topic model saved")
    end

    def store_topics(result)
      p result[1]
      exit
      topic = Topic.find(name: result[:most_probable_topic].to_s).first || Topic.create(name: result[:most_probable_topic].to_s)
      topic.update(
        description: result[:top_words].to_json,
        vector: result[:topic_distribution].to_json
      )
      logger.debug "Stored topic: #{topic.name}"
    end

    def store_all_topics
      @model.k.times do |k|
        top_words = @model.topic_words(k, top_n: 10).to_h
        topic = Topic.find(name: k.to_s).first || Topic.create(name: k.to_s)
        topic.update(
          description: top_words.to_json,
          vector: @model.topic_distribution(k).to_json
        )
        logger.debug "Stored topic: #{topic.name}"
      end
      logger.info "All topics stored in Ohm model"
      Flowbots::UI.say(:ok, "All topics stored in database")
    end
  end
end

```

#### TextProcessor.rb

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mime/types'

require_relative "../modules/Segmentation"

module Flowbots
  class TextProcessor
    include Singleton
    include Logging

    def initialize
      logger.info "Initializing #{self.class.name}"
      Flowbots::UI.say(:ok, "Initializing #{self.class.name}")
      load_model
      logger.info "#{self.class.name} initialization completed"
      Flowbots::UI.say(:ok, "#{self.class.name} initialization completed")
    end

    def process_file(file_path)
      logger.info "Processing file: #{file_path}"
      Flowbots::UI.say(:ok, "Processing file: #{file_path}")

      file_type = classify_file(file_path)
      text = parse_file(file_path, file_type)
      process(text)
    end

    def process(text)
      raise NotImplementedError, "#{self.class.name}#process must be implemented in subclass"
    end

    protected

    def load_model
      raise NotImplementedError, "#{self.class.name}#load_model must be implemented in subclass"
    end

    def segment_text(text)
      logger.debug "Creating TextSegmenter"
      segmenter = TextSegmenter.new(text, { clean: true })
      logger.debug "Executing segmentation"
      segmenter.execute
    end

    private

    def classify_file(file_path)
      extension = File.extname(file_path).downcase
      mime_type = MIME::Types.type_for(file_path).first

      case
      when ['.txt', '.md', '.markdown'].include?(extension)
        :text
      when extension == '.pdf'
        :pdf
      when ['.json', '.jsonl'].include?(extension)
        :json
      when extension == '.html'
        :html
      else
        logger.warn "Unknown file type for #{file_path}. Treating as plain text."
        Flowbots::UI.say(:warn, "Unknown file type. Treating as plain text.")
        :text
      end
    end

    def parse_file(file_path, file_type)
      case file_type
      when :text
        File.read(file_path)
      when :pdf
        parse_pdf(file_path)
      when :json
        parse_json(file_path)
      when :html
        parse_html(file_path)
      else
        File.read(file_path)
      end
    end

    def parse_pdf(file_path)
      # Implement PDF parsing logic here
      # You might want to use a gem like 'pdf-reader'
      raise NotImplementedError, "PDF parsing not implemented"
    end

    def parse_json(file_path)
      JSON.parse(File.read(file_path))
    end

    def parse_html(file_path)
      # Implement HTML parsing logic here
      # You might want to use a gem like 'nokogiri'
      raise NotImplementedError, "HTML parsing not implemented"
    end
  end
end

```

#### text_processing_workflow.rb

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# text_processing_workflow.rb
# Description: A text processing workflow that processes a text file, segments it, and performs topic modeling

module Flowbots
  class TextProcessingWorkflow
    include Logging

    def initialize(input_file_path)
      @input_file_path = input_file_path
      @orchestrator = WorkflowOrchestrator.new
      @nlp_processor = NLPProcessor.instance
      @topic_modeling_processor = TopicModelProcessor.instance
    end

    def run
      logger.info "Starting Text Processing Workflow"
      Flowbots::UI.say(:ok, "Starting Text Processing Workflow")

      setup_workflow
      process_input
      run_nlp_analysis
      run_topic_modeling
      run_workflow
      display_results

      logger.info "Text Processing Workflow completed"
      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
    end

    private

    def setup_workflow
      logger.debug "Setting up workflow"
      @orchestrator.add_agent("advanced_analysis", "assistants/agileBloomMini.yml", author: "@b08x")

      workflow_graph = {
        NlpAnalysisTask: [:TopicModelingTask],
        TopicModelingTask: [:LlmAnalysisTask],
        LlmAnalysisTask: []
      }

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    def process_input
      logger.debug "Processing input file: #{@input_file_path}"
      text = File.read(@input_file_path)
      processed_text = @nlp_processor.process(text)
      store_processed_text(processed_text)
      logger.debug "Input processing completed"
    end

    def run_nlp_analysis
      logger.info "Running NLP Analysis"
      Flowbots::Task.get_task("nlp_analysis_task").execute
      logger.info "NLP Analysis completed"
    end

    def run_topic_modeling
      logger.info "Running Topic Modeling"
      Flowbots::Task.get_task("topic_modeling_task").execute
      logger.info "Topic Modeling completed"
    end

    def run_workflow
      logger.info "Running LLM Analysis workflow"
      @orchestrator.run_workflow
    end

    def display_results
      raw_text = File.read(@input_file_path)
      processed_text = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
      analysis_result = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))

      puts UIBox.comparison_box(raw_text, processed_text, title1: "Raw Text", title2: "Processed Text")
      puts UIBox.eval_result_box(analysis_result, title: "LLM Analysis Result")
    end

    def store_processed_text(text)
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("processed_text", text.to_json)
    end

    def retrieve_processed_text
      JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("processed_text"))
    end

    def retrieve_analysis_result
      JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("analysis_result"))
    end

    def retrieve_topics
      @topic_modeling_processor.get_topics
    end
  end
end

```

#### cli.rb

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    def self.exit_on_failure?
      true
    end

    map %w[-v --version] => "version"

    desc "version", "Display flowbots version", hide: true
    def version
      say "flowbots/#{VERSION} #{RUBY_DESCRIPTION}"
    end

    desc "workflows", "List and select a workflow to run"
    def workflows
      workflows = Workflows.new
      selected_workflow = workflows.list_and_select

      if selected_workflow
        begin
          workflows.run(selected_workflow)
          say @pastel.green("Workflow completed successfully")
        rescue FileNotFoundError => e
          say @pastel.red(e.message)
        rescue StandardError => e
          ExceptionHandler.handle_exception(self.class.name, e)
        end
      end
    end

    desc "process_text FILE", "Process a text file using the text processing workflow"
    def process_text(file)
      pastel = Pastel.new

      unless File.exist?(file)
        say pastel.red("File not found: #{file}")
        exit
      end

      say pastel.green("Processing file: #{file}")

      begin
        workflow = TextProcessingWorkflow.new(file)
        workflow.run
        say pastel.green("Text processing completed successfully")
      rescue StandardError => e
        ExceptionHandler.handle_exception(self.class.name, e)
      end
    end
  end
end

```

#### command.rb

```ruby
module Sublayer
  module Actions
    class RunTestCommandAction < Base
      def initialize(test_command:)
        @test_command = test_command
      end

      def call
        stdout, stderr, status = Open3.capture3(@test_command)
        [stdout, stderr, status]
      end
    end
  end
end
```

#### thor_ext.rb

```ruby
module Flowbots
  module ThorExt
    # Configures Thor to behave more like a typical CLI, with better help and error handling.
    #
    # - Passing -h or --help to a command will show help for that command.
    # - Unrecognized options will be treated as errors (instead of being silently ignored).
    # - Error messages will be printed in red to stderr, without stack trace.
    # - Full stack traces can be enabled by setting the VERBOSE environment variable.
    # - Errors will cause Thor to exit with a non-zero status.
    #
    # To take advantage of this behavior, your CLI should subclass Thor and extend this module.
    #
    #   class CLI < Thor
    #     extend ThorExt::Start
    #   end
    #
    # Start your CLI with:
    #
    #   CLI.start
    #
    # In tests, prevent Kernel.exit from being called when an error occurs, like this:
    #
    #   CLI.start(args, exit_on_failure: false)
    #
    module Start
      def self.extended(base)
        super
        base.check_unknown_options!
      end

      def start(given_args=ARGV, config={})
        config[:shell] ||= Thor::Base.shell.new
        handle_help_switches(given_args) do |args|
          dispatch(nil, args, nil, config)
        end
      rescue StandardError => e
        handle_exception_on_start(e, config)
      end

      private

      def handle_help_switches(given_args)
        yield(given_args.dup)
      rescue Thor::UnknownArgumentError => e
        retry_with_args = []

        if given_args.first == "help"
          retry_with_args = ["help"] if given_args.length > 1
        elsif e.unknown.intersect?(%w[-h --help])
          retry_with_args = ["help", (given_args - e.unknown).first]
        end
        raise unless retry_with_args.any?

        yield(retry_with_args)
      end

      def handle_exception_on_start(error, config)
        return if error.is_a?(Errno::EPIPE)
        raise if ENV["VERBOSE"] || !config.fetch(:exit_on_failure, true)

        message = error.message.to_s
        message.prepend("[#{error.class}] ") if message.empty? || !error.is_a?(Thor::Error)

        config[:shell]&.say_error(message, :red)
        exit(false)
      end
    end
  end
end

```


If you need more information, please check the logs or contact the development team.
