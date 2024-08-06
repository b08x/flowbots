# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots::CLI class, with a message stating that nil cannot be converted into an integer. This issue has caused the program to terminate abruptly.

## Technical Details
```
Backtrace:
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `%'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `sleep'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `loop'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `run'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:42:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:82:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:28:in `run'
/home/b08x/Workspace/flowbots/lib/workflows.rb:33:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:28:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

The error appears to originate from the `Jongleur::API.rb` file, specifically line 153, which indicates an issue with type conversion. 

## Relevant Files
### `WorkflowOrchestrator.rb`
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
    begin
      logger.debug "Printing graph to /tmp"
      Jongleur::API.print_graph("/tmp")

      logger.debug "Starting Jongleur::API.run"
      Jongleur::API.run do |on|
        on.start do |task|
          Flowbots::UI.info "Starting task: #{task}"
        end

        on.finish do |task|
          Flowbots::UI.info "Finished task: #{task}"
        end

        on.error do |task, error|
          logger.error "Error in task #{task}: #{error.message}"
          logger.error error.backtrace.join("\n")
        end

        on.completed do |task_matrix|
          Flowbots::UI.info "Workflow completed"
          logger.debug "Task matrix: #{task_matrix}"
        end
      end
    rescue StandardError => e
      logger.error "Error during workflow execution: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise
    end
  end
end
```

### `text_processing_workflow.rb`
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
      Flowbots::UI.info "Running LLM Analysis workflow"
      # @orchestrator.add_agent("ironically_literal", "assistants/steve.yml", author: "@b08x")
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


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** can't convert nil into Integer

### Backtrace

```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `%'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `sleep'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `loop'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `run'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:42:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:82:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:28:in `run'
/home/b08x/Workspace/flowbots/lib/workflows.rb:33:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:28:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

If you need more information, please check the logs or contact the development team.
