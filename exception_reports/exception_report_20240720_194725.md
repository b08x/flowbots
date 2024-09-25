# 🤖 FlowBot Exception Report 🤖


## Summary
An error occurred when attempting to execute the `say @pastel.green("Workflow completed successfully")` code in the `cli.rb` file. This error, `undefined method 'green' for nil:NilClass`, indicates that the method or attribute being called on an object has not been defined. 

## Technical Details
The `green` method is undefined for the object `nil`, which is a special type in Ruby representing the absence of a value. This error suggests that `@pastel` is `nil`, indicating that it has not been assigned a value. 

To resolve this issue, ensure that `@pastel` is assigned a valid value before attempting to call the `green` method on it. You can use a conditional statement, such as an `if-else` block, to check if `@pastel` is `nil` before executing the code that references it. 

## Relevant Code Snippet
```ruby
if selected_workflow
  begin
    workflows.run(selected_workflow)
    say @pastel.green("Workflow completed successfully")
  rescue FileNotFoundError => e
    say @pastel.red(e.message)
  rescue StandardError => e
    ExceptionHandler.handle_exception(self.class.name, e)
  end
end
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
