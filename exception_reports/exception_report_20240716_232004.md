# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots application due to an uninitialized constant, specifically "Flowbots::TreeOfThoughts". This issue has prevented the successful execution of the program.

## Technical Details
```
Class: Flowbots::CLI
Message: uninitialized constant Flowbots::TreeOfThoughts

workflow = Flowbots.const_get(workflow_class).new
^\
Did you mean?  Flowbots::TreeOfThoughtsWorkflow
```

## Backtrace
- /home/b08x/Workspace/flowbots/lib/workflows.rb:29:in `run'
- /home/b08x/Workspace/flowbots/lib/cli.rb:27:in `workflows'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
- /home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
- /home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
- /home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
- /home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
- ./exe/flowbots:16:in `<main>'

## Relevant Files
- workflows.rb
- cli.rb
- thor_ext.rb


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant Flowbots::TreeOfThoughts

      workflow = Flowbots.const_get(workflow_class).new
                         ^^^^^^^^^^
Did you mean?  Flowbots::TreeOfThoughtsWorkflow

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:27:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:16:in `<main>'
```

If you need more information, please check the logs or contact the development team.
