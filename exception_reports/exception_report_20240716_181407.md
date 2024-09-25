# 🤖 FlowBot Exception Report 🤖


## Summary
The error "uninitialized constant TextProcessingWorkflow" occurred in the Flowbots::CLI class. This indicates that the TextProcessingWorkflow class could not be found by the interpreter, resulting in the failure of the object creation using Object.const_get.

## Technical Details

### Backtrace
- The error occurred during the execution of the "run" method in the Workflows class of the "workflows.rb" file.
- The "run" method is invoked by the "workflows" method in the CLI class of the "cli.rb" file.
- The "workflows" method handles the selection and execution of a workflow, including error handling.
- The specific line causing the error is: "workflow = Object.const_get(workflow_class).new(workflow_file)".

### Potential Cause
The most likely cause of the error is that the TextProcessingWorkflow class is not properly defined or is not accessible to the interpreter.

### Suggested Solution
- Check the definition of the TextProcessingWorkflow class and ensure it is located in the expected file and directory.
- Verify that the file containing the TextProcessingWorkflow class is properly included or required in the appropriate location.
- Ensure that the class name and module structure match the file and directory structure, following the Ruby conventions for constant lookup.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant TextProcessingWorkflow

      workflow = Object.const_get(workflow_class).new(workflow_file)
                       ^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:37:in `const_get'
/home/b08x/Workspace/flowbots/lib/workflows.rb:37:in `run'
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
