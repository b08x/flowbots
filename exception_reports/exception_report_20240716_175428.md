# 🤖 FlowBot Exception Report 🤖


## Summary
The error "undefined method `constantize' for "TextProcessingWorkflow":String" occurred in the `Flowbots::CLI` class when attempting to run the "process_text" command. This error indicates that the program tried to call the "constantize" method on a string object, which is not defined.

## Backtrace
- `cli.rb:26`: The error occurred within the "process_text" command of the `Flowbots::CLI` class. The program attempted to instantiate the "Text_processing_workflow" class by calling "Object.const_get".

- `workflows.rb:31`: The "run" method of the `Workflows` class, located in `workflows.rb`, is called by the "process_text" command. This method is responsible for executing the selected workflow.

## Relevant Code Snippets
**cli.rb**
```ruby
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
```

**workflows.rb**
```ruby
def run(workflow_name)
  workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

  unless File.exist?(workflow_file)
    logger.error "Workflow file not found: #{workflow_file}"
    raise FileNotFoundError, "Workflow file not found: #{workflow_file}"
  end

  logger.info "Running workflow: #{workflow_name}"

  # Corrected line:
  workflow_class = TextProcessingWorkflow # Use the correct class reference

  # Previous incorrect line:
  # workflow_class = workflow_name.split("_").map(&:capitalize).join

  workflow = workflow_class.constantize.new(workflow_file) # Error occurs here

  logger.debug workflow
  workflow.run
end
```

## Possible Cause and Solution
The error indicates that the program expected "TextProcessingWorkflow" to be a class, but it was recognized as a string. This could be due to an incorrect reference to the class.

To resolve this issue, the incorrect line `workflow_class = workflow_name.split("_").map(&:capitalize).join` in `workflows.rb` should be replaced with the correct class reference `workflow_class = TextProcessingWorkflow`. This ensures that "TextProcessingWorkflow" is treated as a class and not a string, allowing the program to instantiate the class correctly.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** undefined method `constantize' for "TextProcessingWorkflow":String

      workflow = workflow_class.constantize.new(workflow_file)
                               ^^^^^^^^^^^^

### Backtrace

```
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
