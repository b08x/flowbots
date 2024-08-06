# 🤖 FlowBot Exception Report 🤖


## Summary
The error "uninitialized constant TextProcessingWorkflow" occurred in the Flowbots::CLI class. This indicates that the TextProcessingWorkflow class was not properly defined or imported.

## Technical Details
The error occurred in the following code snippet from workflows.rb:
```ruby
workflow = Object.const_get(workflow_class).new(workflow_file)
```
The backtrace indicates that the error occurred during the execution of the `run` method in the `Workflows` class of `workflows.rb`.

## Possible Causes and Solutions:
- **Incorrect Class Definition**: Ensure that the `TextProcessingWorkflow` class is defined correctly and that the class name matches the constant name.
- **Autoloading Issues**: The issue may be related to autoloading, where Rails tries to guess the location of the class based on a set of autoloading paths. Try referencing the class with the full name, e.g., `::TextProcessingWorkflow`.
- **File Not Found**: Verify that the file containing the `TextProcessingWorkflow` class exists and is located in the expected path.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant TextProcessingWorkflow

      workflow = Object.const_get(workflow_class).new(workflow_file)
                       ^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:36:in `const_get'
/home/b08x/Workspace/flowbots/lib/workflows.rb:36:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:27:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

If you need more information, please check the logs or contact the development team.
