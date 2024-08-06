# 🤖 FlowBot Exception Report 🤖


## Summary
The error "uninitialized constant TextProcessingWorkflow" occurred in the Flowbots::CLI class. This indicates that the TextProcessingWorkflow class is not properly defined or imported.

## Technical Details
The issue arises in the `run` method of the `Workflows` class, where the `workflow_class` variable is used without being properly defined or imported. The full backtrace is provided for reference.

## Suggested Action
To resolve this issue, ensure that the TextProcessingWorkflow class is defined and accessible in the scope of the `run` method. This may involve importing the necessary module or class definition.

## Relevant Code Snippets
**workflows.rb**
```ruby
module Flowbots
  class Workflows
    include Logging

    # ...

    def run(workflow_name)
      workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

      # ...

      workflow_class = workflow_name.split('_').map(&:capitalize).join
      workflow = Object.const_get(workflow_class).new(workflow_file)

      # ...
    end

    # ...
  end
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
- **Message:** uninitialized constant TextProcessingWorkflow

      workflow = Object.const_get(workflow_class).new(workflow_file)
                       ^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:31:in `const_get'
/home/b08x/Workspace/flowbots/lib/workflows.rb:31:in `run'
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
