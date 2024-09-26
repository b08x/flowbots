# 🚨 FlowBot Exception Report (Fallback) 🚨

Oops! We encountered an exception, and we're having trouble generating a detailed report right now. Here's what we know:

## Exception Details

- **Class:** Flowbots::CLI
- **Message:** undefined method `define_workflow' for #<WorkflowOrchestrator:0x00007d271907cd90 @tasks=[], @agents={}>

      @orchestrator.define_workflow(workflow_graph)
                   ^^^^^^^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:51:in `setup_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:17:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:76:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```

We're working on resolving this issue. In the meantime, you might want to:

1. Check your internet connection
2. Verify that all required services are running
3. Try your request again in a few minutes

If the problem persists, please contact the development team with the above information.

We apologize for any inconvenience!