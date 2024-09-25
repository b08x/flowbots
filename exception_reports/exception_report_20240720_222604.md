# 🤖 FlowBot Exception Report 🤖


## Summary
An error occurred when attempting to execute a method on an object, where the method is not defined for the object. 

## Technical Details
In the provided code, the error is occurring on the following line:

```ruby
say @pastel.green("Workflow completed successfully")
```

The `@pastel` object is `nil`, and the `green` method cannot be called on a `nil` object. This results in the "undefined method `green' for nil:NilClass" error. 

To resolve this issue, ensure that the `@pastel` object is properly initialized and assigned before attempting to call the `green` method on it. 

## Relevant Code Snippet
```ruby
say @pastel.green("Workflow completed successfully")
```


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** undefined method `green' for nil:NilClass

          say @pastel.green("Workflow completed successfully")
                     ^^^^^^
Did you mean?  agree

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/cli.rb:28:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:16:in `<main>'
```

If you need more information, please check the logs or contact the development team.
