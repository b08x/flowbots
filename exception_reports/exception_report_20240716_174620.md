# 🤖 FlowBot Exception Report 🤖


## Error Summary

A "NameError" has occurred, specifically an "uninitialized constant" error, which means that a constant has been referenced before it has been defined. In this case, the constant is "TextProcessingWorkflow". 

## Backtrace

The error occurs in the "cli.rb" file, in the "process_text(file)" method, when attempting to create a new object of the "TextProcessingWorkflow" class. 

## Relevant Files

The "workflows.rb" file contains the definition of the "Workflows" class, which is used to manage and run workflows. 

The "cli.rb" file contains the definition of the "CLI" class, which is the main entry point for the command-line interface. It includes a method "process_text(file)" that triggers the error when attempting to create an instance of the "TextProcessingWorkflow" class. 

The "thor_ext.rb" file contains extensions for the "Thor" command-line interface framework, providing additional functionality for handling errors and help requests. 

## Suggested Action

Ensure that the "TextProcessingWorkflow" class is defined and available for instantiation in the "cli.rb" file. Review the code for any missing or incorrect import statements, class definitions, or file paths that may be causing the "TextProcessingWorkflow" class to be unavailable.


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
