# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots application, causing an interruption in the workflow execution. 

## Technical Details

**Error Message:**
> uninitialized constant MarkdownTextYamlParser

**Backtrace:**
- /home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:23:in `load_grammar'
- /home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:10:in `initialize'
- /home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:11:in `new'
- /home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:11:in `execute'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `block (2 levels) in run_descendants'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `fork'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `block in run_descendants'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:158:in `block in each_descendant'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:156:in `each'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:156:in `each_descendant'
- /homeMultiplier: 79:in `block in process_files'
- /home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:72:in `times'
- /home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:72:in `process_files'
- /home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:23:in `run'
- /home/b08x/Workspace/flowbots/lib/cli.rb:56:in `train_topic_model'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
- /home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
- /home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
- /home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
- ./exe/flowbots:23:in `<main>'

## Relevant Files:

**GrammarProcessor.rb:**
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "treetop"

module Flowbots
  class GrammarProcessor
    def initialize(grammar_name)
      @grammar_name = grammar_name
      load_grammar
    end

    def parse(text)
      @parser.parse(text)
    end

    private

    def load_grammar
      begin
        Treetop.load(File.join(GRAMMAR_DIR, "#{@grammar_name}.treetop"))
        parser_class_name = "#{camelize(@grammar_name)}Parser"
        @parser = Object.const_get(parser_class_name).new
      rescue StandardError => e
        Flowbots::ExceptionHandler.handle_exception(self.class.name, e)
      end
    end

    def camelize(string)
      string.split('_').map(&:capitalize).join
    end
  end
end
```

**preprocess_text_file_task.rb:**
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

class PreprocessTextFileTask < Jongleur::WorkerTask

  def execute
    logger.info "Starting PreprocessTextFileTask"

    textfile = retrieve_current_textfile
    begin
      grammar_processor = Flowbots::GrammarProcessor.new('markdown_text_yaml')
      parse_tree = grammar_processor.parse(textfile.content)
    rescue StandardError => e
      Flowbots::UI.exception("#{e.message}")
      exit
    end




    if parse_tree
      content = parse_tree.markdown_content.text_value
      metadata = extract_metadata(parse_tree.yaml_front_matter)
      store_preprocessed_data(content, metadata)
      logger.info "Successfully preprocessed file with custom grammar"
    else
      logger.error "Failed to parse the document with custom grammar"
      store_preprocessed_data(textfile.content, {})
    end

    logger.info "PreprocessTextFileTask completed"
  end

  private

  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  def extract_metadata(yaml_front_matter)
    return {} unless yaml_front_matter

    yaml_content = yaml_front_matter.text_value.gsub(/^---\n/, '').gsub(/---\n$/, '')
    YAML.safe_load(yaml_content)
  rescue StandardError => e
    logger.error "Error parsing YAML front matter: #{e.message}"
    {}
  end

  def store_preprocessed_data(content, metadata)
    redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
    redis.set("preprocessed_content", content)
    redis.set("file_metadata", metadata.to_json)
  end
end
```

**WorkflowOrchestrator.rb:**
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "WorkflowAgent"

class WorkflowOrchestrator
  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  def initialize
    @agents = {}
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
  end

  def add_agent(role, cartridge_file, author: "@b08x")
    logger.debug "Adding agent: #{role}"
    cartridge_path = File.join(CARTRIDGE_BASE_DIR, author, "cartridges", cartridge_file)

    unless File.exist?(cartridge_path)
      logger.error "Cartridge file not found: \"#{cartridge_path}\""
      raise "Cartridge file not found: \"#{cartridge_path}\""
    end

    @agents[role] = WorkflowAgent.new(role, cartridge_path)
    logger.debug "Agent added: #{role}"
  end

  def define_workflow(workflow_definition)
    logger.debug "Defining workflow"
    logger.debug "Workflow definition: #{workflow_definition}"
    Jongleur::API.add_task_graph(workflow_definition)
    logger.debug "Workflow defined"
  end

  def run_workflow
    logger.info "Starting workflow execution"
    @running = true

    begin
      logger.debug "Printing graph to /tmp"
      Jongleur::API.print_graph("/tmp")

      Flowbots::UI.info "Starting Jongleur::API.run"
      Jongleur::API.run do |on|
        on.start do |task|
          ui.framed do
            ui.puts "Starting task: #{task}"
          end
        end

        on.finish do |task|
          ui.framed do
            ui.puts "Finished task: #{task}"
          end
          ui.space
        end

        on.error do |task, error|
          logger.error "Error in task #{task}: #{error.message}"
          logger.error error.backtrace.join("\n")
        end

        on.completed do |task_matrix|
          ui.framed do
            ui.puts "Workflow completed"
            ui.space
            ui.puts "Task matrix: #{task_matrix}"
          end
          @running = false
        end
      end
    rescue Interrupt
      logger.info "Workflow interrupted"
      Flowbots::UI.say(:warn, "Workflow interrupted. Cleaning up...")
      cleanup
    rescue StandardError => e
      logger.error "Error during workflow execution: #{e.message}"
      logger.error e.backtrace.join("\n")
      cleanup
      raise
    end
  end

  def cleanup
    # Perform any necessary cleanup for the workflow
    Jongleur::API.stop_all_tasks
    # Add any other cleanup operations here
  end

end
```

**topic_model_trainer_workflow.rb:**
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TopicModelTrainerWorkflow
    BATCH_SIZE = 10

    attr_accessor :orchestrator
    attr_reader :input_folder_path

    def initialize(input_folder_path=nil)
      @input_folder_path = input_folder_path || prompt_for_folder
      @orchestrator = WorkflowOrchestrator.new
    end

    def run
      Flowbots::UI.say(:ok, "Setting Up Topic Model Trainer Workflow")
      logger.info "Setting Up Topic Model Trainer Workflow"

      begin
        setup_workflow
        flush_redis_cache
        process_files
        Flowbots::UI.say(:ok, "Topic Model Trainer Workflow completed")
        logger.info "Topic Model Trainer Workflow completed"
      rescue StandardError => e
        Flowbots::UI.say(:error, "Error in Topic Model Trainer Workflow: #{e.message}")
        logger.error "Error in Topic Model Trainer Workflow: #{e.message}"
        logger.error e.backtrace.join("\n")
      end
    end

    private

    def prompt_for_folder
      get_folder_path = `gum file --directory`.chomp.strip
      folder_path = File.join(get_folder_path)

      unless File.directory?(folder_path)
        raise FlowbotError.new('Folder not found', 'FOLDERNOTFOUND')
      end

      folder_path
    end

    def setup_workflow
      workflow_graph = {
        LoadTextFilesTask: [:PreprocessTextFileTask],
        PreprocessTextFileTask: [:TextSegmentTask],
        TextSegmentTask: [:TokenizeSegmentsTask],
        TokenizeSegmentsTask: [:NlpAnalysisTask],
        NlpAnalysisTask: [:FilterSegmentsTask],
        FilterSegmentsTask: [:AccumulateFilteredSegmentsTask],
        AccumulateFilteredSegmentsTask: []
      }

      @orchestrator.define_workflow(workflow_graph)
      logger.debug "Workflow setup completed"
    end

    def flush_redis_cache
      redis = Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.flushdb
      logger.».join("\n")
      cleanup
      raise
    end

    def process_files
      all_file_paths = Dir.glob(File.join(@input_folder_path, "**{,/*/**}/*.{md,markdown}")).sort
      total_files = all_file_paths.count
      num_batches = (total_files.to_f / BATCH_SIZE).ceil

      num_batches.times do |i|
        batch_start = i * BATCH_SIZE
        batch_files = all_file_paths[batch_start, BATCH_SIZE]

        Flowbots::UI.say(:ok, "Processing batch #{i + 1} of #{num_batches}")
        logger.info "Processing batch #{i + 1} of #{num_batches}"

        process_batch(batch_files)
      end

      train_topic_model
    end

    def process_batch(batch_files)
      batch_files.each do |file_path|
        Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_file_path", file_path)
        @orchestrator.run_workflow
      end
    end

    def train_topic_model
      all_filtered_segments = JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("all_filtered_segments") || "[]")

      if all_filtered_segments.empty?
        logger.warn "No filtered segments available for topic modeling"
        Flowbots::UI.say(:warn, "No filtered segments available for topic modeling")
        return
      end

      cleaned_segments = clean_segments_for_modeling(all_filtered_segments)

      if cleaned_segments.empty?
        logger.warn "No cleaned segments available for topic modeling after filtering"
        Flowbots::UI.say(:warn, "No cleaned segments available for topic modeling after filtering")
        return
      end

      logger.info "Cleaned segments for topic modeling. Original count: #{all_filtered_segments.length}, Cleaned count: #{cleaned_segments.length}"

      topic_processor = Flowbots::TopicModelProcessor.instance
      topic_processor.train_model(cleaned_segments)
      logger.info "Topic model training completed for all files"
      Flowbots::UI.say(:ok, "Topic model training completed for all files")
    end

    private

    def clean_segments_for_modeling(segments)
     segments.reject do |segment|
       segment.include?("tags") || segment.include?("title") || segment.include?("toc")
     end.map do |segment|
       segment.reject do |word|
         word.to_s.length < 3 || # Remove very short words
         word.to_s.match?(/^\d+$/) || # Remove purely numeric words
         word.to_s.match?(/^[[:punct:]]+$/) # Remove punctuation-only words
       end
     end.reject(&:empty?)
    end
  end
end
```

**cli.rb:**
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
      pastel = Pastel.new

      workflows = Workflows.new

      selected_workflow = workflows.list_and_select

      if selected_workflow
        begin
          workflows.run(selected_workflow)
          say pastel.green("Workflow completed successfully")
        rescue Interrupt
          say pastel.yellow("Workflow interrupted by user")
        rescue FileNotFoundError => e
          say pastel.red(e.message)
        rescue StandardError => e
          ExceptionHandler.handle_exception(self.class.name, e)
        ensure
          Flowbots.shutdown
        end
      end
    end

    desc "train_topic_model FOLDER", "Train a topic model using text files in the specified folder"
    def train_topic_model(folder)
      pastel = Pastel.new

      unless Dir.exist?(folder)
        say pastel.red("Folder not found: #{folder}")
        exit
      end

      say pastel.green("Training topic model using files in: #{folder}")

      begin
        workflow = TopicModelTrainerWorkflow.new(folder)
        workflow.run
        say pastel.green("Topic model training completed successfully")
      rescue StandardError => e
        ExceptionHandler.handle_exception(self.class.name, e)
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

**command.rb:**
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

**thor_ext.rb:**
```ruby
module Flowbots
  module ThorExt
    # Configures Thor to behave more like a typical CLI, with better help and error handling.
    #
    # - Passing -h or --help to a command will show help for that command.


## Exception Details

- **Class:** Flowbots::GrammarProcessor
- **Message:** uninitialized constant MarkdownTextYamlParser

        @parser = Object.const_get(parser_class_name).new
                        ^^^^^^^^^^
Did you mean?  MarkdownWithYamlParser

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:23:in `load_grammar'
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:10:in `initialize'
/home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:11:in `new'
/home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:11:in `execute'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `block (2 levels) in run_descendants'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `fork'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `block in run_descendants'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:158:in `block in each_descendant'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:156:in `each'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:156:in `each_descendant'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:198:in `run_descendants'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:173:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `loop'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `run'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:44:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:88:in `block in process_batch'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:86:in `each'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:86:in `process_batch'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:79:in `block in process_files'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:72:in `times'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:72:in `process_files'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:23:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:56:in `train_topic_model'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```

If you need more information, please check the logs or contact the development team.
