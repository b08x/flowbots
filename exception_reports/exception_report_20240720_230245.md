# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots CLI tool, specifically in the `workflows` method of the `CLI` class. The error message indicates that there is an undefined method `green` being called on `nil`, resulting in a `NoMethodError`.

## Technical Details
The backtrace provides information about the sequence of method calls leading up to the error:
- `workflows`: The `workflows` method in the `CLI` class is where the error occurred.
- `run`: The `run` method in the `Thor::Command` module was called from `workflows`.
- `invoke_command`: The `invoke_command` method in the `Thor::Invocation` module was called from `run`.
- `dispatch`: The `dispatch` method in the `Thor` module was called from `invoke_command`.
- `start`: The `start` method in the `ThorExt` module, which is extended by the `CLI` class, was called from `dispatch`.
- `handle_help_switches`: The `handle_help_switches` method in the `ThorExt` module was called from `start`.
- `dispatch`: The `dispatch` method in the `Thor` module was called from `handle_help_switches`.

The relevant code in the `workflows` method is as follows:
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

The error occurred on the line `say @pastel.green("Workflow completed successfully")`. Specifically, the error message `undefined method `green' for nil:NilClass` indicates that the `green` method was called on `nil`.

## Possible Cause and Solution
This error typically occurs when attempting to call a method on an object that is `nil`. In this case, it seems that `@pastel` is `nil`. To resolve the issue, ensure that `@pastel` is properly initialized before calling the `green` method on it.


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
