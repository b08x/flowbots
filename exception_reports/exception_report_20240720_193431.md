# 🤖 FlowBot Exception Report 🤖


## Summary
An error was encountered when attempting to execute the `say @pastel.green("Workflow completed successfully")` command. The error message "undefined method `green' for nil:NilClass" indicates that the program tried to call the `green` method on an object that was `nil`.

## Technical Details
The error occurred in the `workflows` method of the `Flowbots::CLI` class, specifically on the line `say @pastel.green("Workflow completed successfully")`.

The `@pastel` object is `nil`, which means it has not been initialized or assigned a value. This resulted in the `green` method call failing, as `nil` does not have a `green` method.

To resolve this issue, ensure that the `@pastel` object is properly initialized or assigned a value before attempting to call the `green` method on it.

## Relevant Code Snippet
```ruby
module Flowbots
  class CLI < Thor
    # ...

    desc "workflows", "List and select a workflow to run"
    def workflows
      workflows = Workflows.new

      selected_workflow = workflows.list_and_select

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
    end
    # ...
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
