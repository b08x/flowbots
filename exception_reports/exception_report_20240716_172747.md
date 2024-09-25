# 🤖 FlowBot Exception Report 🤖


## Summary
The Flowbots application has encountered an error: "uninitialized constant TextProcessingWorkflow". This indicates that the TextProcessingWorkflow class or module has not been properly defined or imported, leading to a failure during the execution of the TextProcessingWorkflow.new(file) method.

## Technical Details

### Backtrace
- The error occurred during the const_get method call in the run method of the Workflows class (workflows.rb, line 29).
- The run method was invoked by the workflows method in the CLI class (cli.rb, line 26).
- The workflows method was called by the dispatch method of Thor::Base (thor/invocation.rb).
- An exception occurred during the handle_help_switches method call in the start method of ThorExt::Start (thor_ext.rb, line 34).

### Relevant Files

**workflows.rb**
The Workflows class, which contains the run method where the error occurred. The run method attempts to get the TextProcessingWorkflow class by converting the workflow name and using Object.const_get.

**cli.rb**
The CLI class, which contains the workflows method that invokes the run method of the Workflows class.

**thor_ext.rb**
The Start module of ThorExt, which contains the start and handle_help_switches methods. The exception was handled by the handle_exception_on_start method.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant TextProcessingWorkflow

      workflow_class = Object.const_get(workflow_name.split("_").map(&:capitalize).join)
                             ^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in `const_get'
/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in `run'
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
