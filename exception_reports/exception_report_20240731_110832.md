# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots::CLI class, specifically referencing an uninitialized constant in the WorkflowOrchestrator module. This issue has prevented the successful execution of the program.

## Technical Details
```
Class: Flowbots::CLI
Message: uninitialized constant WorkflowOrchestrator::WorkflowAgent

    @agents[:task_manager] = WorkflowAgent.new("task_manager", "task_manager_cartridge.yml")
                             ^^^^^^^^^^^^^
```

## Backtrace
```
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:54:in `setup_agents'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:27:in `setup_workflow'
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

## Relevant Files
### WorkflowOrchestrator.rb
```
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

  # ...
end
```

### text_processing_workflow.rb
```
#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class TextProcessingWorkflow
    attr_reader :input_file_path, :text_file_id

    def initialize(input_file_path=nil)
      @input_file_path = input_file_path || prompt_for_file # Assign or prompt
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
  end
end
```

### cli.rb
```
#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    def self.exit_on_failure?
      true
    end

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


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant WorkflowOrchestrator::WorkflowAgent

    @agents[:task_manager] = WorkflowAgent.new("task_manager", "task_manager_cartridge.yml")
                             ^^^^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:54:in `setup_agents'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:27:in `setup_workflow'
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
