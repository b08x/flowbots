# 🤖 FlowBot Exception Report 🤖


## Summary
An uninitialized constant error occurred during the execution of the Flowbots CLI tool.

## Technical Details
The error was raised when attempting to instantiate the `TextProcessingWorkflow` class, which is likely due to an incorrect class name or a missing class definition in the `flowbots/lib/cli.rb` file.

## Backtrace
- `Flowbots::CLI.process_text` called `TextProcessingWorkflow.new` with the `file` argument.
- The `Flowbots::CLI` class is defined in `/home/b08x/Workspace/flowbots/lib/cli.rb`.

## Suggested Action
Verify the class name and ensure the `TextProcessingWorkflow` class is defined correctly in the `flowbots/lib/cli.rb` file.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant Flowbots::CLI::TextProcessingWorkflow

        workflow = TextProcessingWorkflow.new(file)
                   ^^^^^^^^^^^^^^^^^^^^^^
Did you mean?  Flowbots::TextProcessor

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/cli.rb:50:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

If you need more information, please check the logs or contact the development team.
