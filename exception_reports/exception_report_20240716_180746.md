# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the application, causing it to crash. 

## Technical Details
The error "uninitialized constant TextProcessingWorkflow" was raised when attempting to access the "TextProcessingWorkflow" class in the "cli.rb" file. This error indicates that the class is not properly defined or imported. 

## Backtrace
- The error occurred within the "run" method of the "Workflows" class in "workflows.rb".
- This was called from the "workflows" method in the "CLI" class in "cli.rb".
- The "CLI" class is defined in "cli.rb".

## Relevant Files
- "workflows.rb": Contains the "Workflows" class, which includes the "run" method where the error occurred.
- "cli.rb": Contains the "CLI" class, which includes the "workflows" method that called the "run" method.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant TextProcessingWorkflow

      workflow = Object.const_get(workflow_class).new(workflow_file)
                       ^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:34:in `const_get'
/home/b08x/Workspace/flowbots/lib/workflows.rb:34:in `run'
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
