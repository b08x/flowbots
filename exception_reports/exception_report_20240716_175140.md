# 🤖 FlowBot Exception Report 🤖


## Summary: 
An uninitialized constant error has occurred in the *cli.rb* file, preventing the successful execution of the code. 

## Technical Details: 
### Error Description: 
The error "uninitialized constant TextProcessingWorkflow" indicates that the code is attempting to reference a constant (in this case, a class or module) named "TextProcessingWorkflow", but it has not been defined or initialized before its usage. 

### Backtrace: 
The backtrace provided gives information about the sequence of method calls that led to the error: 

- The error occurred in the *workflows.rb* file, line 31, within the `const_get` method. 
- This was called from the `run` method in the same file. 
- The `run` method was invoked by the `workflows` method in the *cli.rb* file. 
- Subsequent method calls are listed, leading back to the execution of the code in the *exe/flowbots* file. 

### Relevant Files: 
**workflows.rb:** 
- This file contains the `Workflows` class, which includes methods for listing, selecting, and running workflows. 
- The error occurred when attempting to access the value of the `workflow_class` constant using `Object.const_get`. 

**cli.rb:** 
- This file defines the `CLI` class, which extends `ThorExt::Start`. 
- The `workflows` method in this class creates an instance of `Workflows`, calls `list_and_select`, and then attempts to run the selected workflow using the `run` method. 

## Suggested Action: 
To resolve the issue, ensure that the "TextProcessingWorkflow" constant is defined and initialized before its usage in the *workflows.rb* file. Review the code to identify where this constant should be defined and ensure it is accessible in the scope where it is being referenced.


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
