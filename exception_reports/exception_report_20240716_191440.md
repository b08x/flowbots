# 🤖 FlowBot Exception Report 🤖


## Summary
The error "can't convert nil into Integer" was raised during the execution of the Flowbots CLI application. This indicates that a value of nil was encountered where an integer value was expected, resulting in a TypeError.

## Technical Details
The backtrace indicates that the error occurred within the Jongleur::API module, specifically in the run method of the WorkflowOrchestrator class. The WorkflowOrchestrator class appears to be responsible for defining and executing workflows, which are defined using a task graph.

The relevant code snippet from the WorkflowOrchestrator class is as follows:

```ruby
def run_workflow
  logger.info "Starting workflow execution"
  begin
    logger.debug "Printing graph to /tmp"
    Jongleur::API.print_graph("/tmp")

    logger.debug "Starting Jongleur::API.run"
    Jongleur::API.run do |on|
      # ...
    end
  rescue StandardError => e
    logger.error "Error during workflow execution: #{e.message}"
    logger.error e.backtrace.join("\n")
    raise
  end
end
```

The error appears to be raised during the execution of Jongleur::API.run, which is called within the run_workflow method. However, without further information about the specific operations performed within Jongleur::API.run, it is difficult to pinpoint the exact cause of the error.

## Suggested Action Items
- Review the Jongleur::API module, specifically the run method, to identify any operations that may involve integer values.
- Inspect the values being passed to the run method or used within the method to ensure that they are not nil when an integer is expected.
- Consider adding additional logging statements or debugging tools to narrow down the specific line or operation causing the error.


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
