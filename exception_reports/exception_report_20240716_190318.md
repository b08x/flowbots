# 🤖 FlowBot Exception Report 🤖


# Error Report

## Summary
An error occurred during the execution of the Flowbots::CLI command-line interface (CLI) tool, resulting in the message "can't convert nil into Integer". This indicates that the program attempted to perform an operation that requires an integer value, but the value provided was nil, which cannot be converted to an integer.

## Technical Details

### Backtrace
The error occurred within the Jongleur::API module, specifically in line 153 of the Jongleur::API.rb file:
```ruby
Jongleur::API.rb:153:in `%'
```

### WorkflowOrchestrator.rb
The WorkflowOrchestrator class is responsible for orchestrating the execution of workflows and interacting with the Jongleur::API module. The error may be related to the initialization of the WorkflowAgent objects or the definition and execution of the workflow.

### text_processing_workflow.rb
The TextProcessingWorkflow class appears to be the main entry point for the text processing workflow. It initializes the WorkflowOrchestrator and sets up the workflow graph. The error could be related to the setup of the workflow or the execution of the individual tasks.

### cli.rb
The CLI class is responsible for processing the command-line arguments and invoking the TextProcessingWorkflow. The error may be related to the handling of command-line arguments or the initialization of the TextProcessingWorkflow.

## Suggested Action Items
- Review the code in Jongleur::API.rb, specifically line 153, to ensure that the operation expecting an integer value is receiving a valid input.
- Debug the WorkflowOrchestrator class to ensure that WorkflowAgent objects are initialized correctly and the workflow definition is accurate.
- Examine the TextProcessingWorkflow class to verify that the workflow setup and task execution are performed correctly.
- Investigate the CLI class to ensure proper handling of command-line arguments and initialization of the TextProcessingWorkflow.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** can't convert nil into Integer

### Backtrace

```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `%'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `sleep'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `loop'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `run'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:42:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:82:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:28:in `run'
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
