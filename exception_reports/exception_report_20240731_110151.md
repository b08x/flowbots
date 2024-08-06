# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots CLI, specifically in the Text Processing Workflow component. The issue is caused by an undefined method 'set' for the Redic class.

## Technical Details
The error message indicates that the 'set' method is not defined for the Redic class. This suggests that the code is attempting to call a method that does not exist for that particular class.

## Relevant Code Snippets
### WorkflowOrchestrator.rb
```ruby
class WorkflowOrchestrator
  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  def initialize
    @agents = {}
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
  end

  # ...

  def run_workflow
    logger.info "Starting workflow execution"
    @running = true

    begin
      # ...

      Flowbots::UI.info "Starting Jongleur::API.run"
      Jongleur::API.run do |on|
        # ...
      end
    rescue Interrupt
      # ...
    rescue StandardError => e
      logger.error "Error during workflow execution: #{e.message}"
      logger.error e.backtrace.join("\n")
      cleanup
      raise
    end
  end

  # ...

end
```

### text_processing_workflow.rb
```ruby
module Flowbots
  class TextProcessingWorkflow
    attr_reader :input_file_path, :text_file_id

    def initialize(input_file_path=nil)
      @input_file_path = input_file_path || prompt_for_file
      @orchestrator = WorkflowOrchestrator.new
    end

    def run
      Flowbots::UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      setup_workflow
      store_input_file_path

      Flowbots::UI.info "Running Text Processing Workflow"
      @orchestrator.run_workflow

      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
      logger.info "Text Processing Workflow completed"
    end

    # ...

    def store_input_file_path
      Jongleur::WorkerTask.class_variable_get(:@@redis).set("input_file_path", @input_file_path)
    end

  end
end
```

### cli.rb
```ruby
module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    # ...

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

## Backtrace
```
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:11:in `setup_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:39:in `setup_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:17:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:76:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** undefined method `set' for #<Redic:0x000072ec14c436a0 @url="redis://localhost:6379/0", @client=#<Redic::Client:0x000072ec14c43470 @semaphore=#<Thread::Mutex:0x000072ec14c433f8>, @connection=false, @uri=#<URI::Generic redis://localhost:6379/0>, @timeout=10000000>, @buffer={}>

    Ohm.redis.set("workflow_type", workflow_type)
             ^^^^
Did you mean?  send

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:11:in `setup_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:39:in `setup_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:17:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:76:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```

If you need more information, please check the logs or contact the development team.
