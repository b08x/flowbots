# 🤖 FlowBot Exception Report 🤖


## Summary
During the execution of a Ruby on Rails application, the system encountered a "NameError" due to an uninitialized constant. This error occurred when the program attempted to reference the "TextProcessingWorkflow" class, which was not properly defined or imported.

## Technical Details

```ruby
workflow = Object.const_get(workflow_class).new(workflow_file)
```

In the above code snippet, the program is trying to access the "TextProcessingWorkflow" class using the `const_get` method. However, this class is not defined or imported in the current scope, leading to the "uninitialized constant" error.

To resolve this issue, ensure that the "TextProcessingWorkflow" class is properly defined and imported in the relevant files, such as `workflows.rb` and `cli.rb`. Additionally, check the file structure and module organization to ensure they align with the conventions and requirements of Ruby on Rails.

## Backtrace

- `/home/b08x/Workspace/flowbots/lib/workflows.rb:31:in 'const_get'`
- `/home/b08x/Workspace/flowbots/lib/workflows.rb:31:in 'run'`
- `/home/b08x/Workspace/flowbots/lib/cli.rb:26:in 'workflows'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in 'run'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in 'invoke_command'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in 'dispatch'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in 'block in start'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in 'handle_help_switches'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in 'start'`
- `./exe/flowbots:21:in '<main>'`


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
