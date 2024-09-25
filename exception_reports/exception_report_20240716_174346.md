# 🤖 FlowBot Exception Report 🤖


## Error Summary
The application encountered an error due to an uninitialized constant, specifically the "TextProcessingWorkflow" constant, which resulted in the failure to execute the corresponding code.

## Technical Details
### Backtrace
- The error occurred in the `workflows.rb` file, in the `run` method of the `Workflows` class.
- The `const_get` method was called on the `Object` class, which attempted to retrieve the value of the "TextProcessingWorkflow" constant.
- However, this constant was not defined or initialized, leading to the error.

### Relevant Files
- `workflows.rb`: This file contains the `Workflows` class, where the error occurred. It includes methods for listing, selecting, and running workflows.
- `cli.rb`: This file defines the `CLI` class, which includes the `workflows` and `process_text` methods. The `process_text` method attempts to create an instance of the "TextProcessingWorkflow" class, which is where the error occurred.
- `thor_ext.rb`: This file defines the `Start` module within the `ThorExt` module of the `Flowbots` class. It provides configurations for Thor to enhance the CLI behavior.


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
