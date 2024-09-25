# 🤖 FlowBot Exception Report 🤖


## Error Summary:
An uninitialized constant error was encountered in the TextProcessingWorkflow. 

## Technical Details:

### Backtrace:
- The error occurred in the `workflows.rb` file, specifically in the `run` method of the `Workflows` class.
- The `const_get` method was called on the `Object` class, but it failed to find the constant "TextProcessingWorkflow".

### Relevant Files:

#### `workflows.rb`:
- This file contains the `Workflows` class, which includes the `run` method that triggered the error. 
- The `run` method attempts to instantiate a `TextProcessingWorkflow` object but fails due to the uninitialized constant error.

#### `cli.rb`:
- This file defines the `CLI` class, which includes the `process_text` method. 
- The `process_text` method calls the `run` method of the `Workflows` class, passing the selected workflow as an argument. 

## Suggested Action Items:
- Ensure that the "TextProcessingWorkflow" class is defined and accessible in the appropriate namespace. 
- Verify the class name and module structure match the convention Ruby uses for constant lookup. 
- Consider referencing the constant using its full name (`::TextProcessingWorkflow`) to resolve any potential autoloading issues. 

Please let me know if there is any additional information or further clarification needed regarding this error report.


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
