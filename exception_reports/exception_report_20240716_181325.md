# 🤖 FlowBot Exception Report 🤖


## Summary
An uninitialized constant error has occurred in the Flowbots CLI.

## Technical Details
The error message "uninitialized constant TextProcessingWorkflow" indicates that the TextProcessingWorkflow class is not properly defined or imported. This issue is likely related to the autoloading of the class or module. 

### Backtrace
- `/home/b08x/Workspace/flowbots/lib/workflows.rb:37:in 'const_get'`
- `/home/b08x/Workspace/flowbots/lib/workflows.rb:37:in 'run'`
- `/home/b08x/Workspace/flowbots/lib/cli.rb:26:in 'workflows'`

### Relevant Files
**workflows.rb**
```ruby
module Flowbots
  class Workflows
    include Logging

    def initialize
      @prompt = TTY::Prompt.new
      @pastel = Pastel.new
      load_workflows
    end

    # ...

    def run(workflow_name)
      # ...

      workflow_class = workflow_name.split('_').map(&:capitalize).join
      workflow = Object.const_get(workflow_class).new(workflow_file)

      # ...
    end

    # ...
  end

  class FileNotFoundError < StandardError; end
end
```

**cli.rb**
```ruby
module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    # ...

    desc "process_text FILE", "Process a text file using the text processing workflow"
    def process_text(file)
      pastel = Pastel.new

      # ...

      begin
        workflow = TextProcessingWorkflow.new(file)
        workflow.run
        # ...
      rescue StandardError => e
        ExceptionHandler.handle_exception(self.class.name, e)
      end
    end
  end
end
```

To resolve the issue, ensure that the TextProcessingWorkflow class is properly defined and imported. Check the file structure, module hierarchy, and autoloading configuration.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant TextProcessingWorkflow

      workflow = Object.const_get(workflow_class).new(workflow_file)
                       ^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:37:in `const_get'
/home/b08x/Workspace/flowbots/lib/workflows.rb:37:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:26:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

If you need more information, please check the logs or contact the development team.
