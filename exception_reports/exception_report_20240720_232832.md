# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred due to an attempt to call a method on an object that has not been defined. 

## Technical Details
The specific error message, "undefined method `green' for nil:NilClass", indicates that the code attempted to call the `green` method on an object that was `nil` (null). 

This issue can occur when a method is called on an object that is `nil`, or when attempting to access a property or method of an object using the `[]` notation, and the object is `nil`. 

To resolve this issue, ensure that the object is not `nil` before calling the method or accessing its properties/methods. You can use conditional statements or error handling mechanisms to check for the presence of the object before performing any operations on it. 

## Relevant Code Snippet
```ruby
say @pastel.green("Workflow completed successfully")
```

In the above code, `@pastel` is `nil`, leading to the error. 

## Backtrace
- `/home/b08x/Workspace/flowbots/lib/cli.rb:28:in 'workflows'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in 'run'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in 'invoke_command'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in 'dispatch'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in 'block in start'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in 'handle_help_switches'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in 'start'`
- `./exe/flowbots:16:in '<main>'`


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
