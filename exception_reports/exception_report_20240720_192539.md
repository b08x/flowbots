# 🤖 FlowBot Exception Report 🤖


## Summary
An error was encountered when attempting to execute the `say @pastel.green("Workflow completed successfully")` line in the `cli.rb` file. The specific issue is indicated by the "undefined method `green' for nil:NilClass" message, which means that the `@pastel` object is `nil` and does not have a `green` method defined.

## Technical Details
The error occurred within the `workflows` method of the `Flowbots::CLI` class in the `cli.rb` file. The `say @pastel.green("Workflow completed successfully")` line attempts to call the `green` method on the `@pastel` object to display a success message. However, the `@pastel` object is `nil`, meaning it has no value or is undefined, and therefore, the `green` method cannot be called on it.

To resolve this issue, you need to ensure that the `@pastel` object is properly initialized and has a valid value before attempting to access its `green` method. You can add a check to verify if `@pastel` is `nil` before calling the `green` method, or you can initialize `@pastel` with an appropriate value earlier in the code.

## Relevant Files
### cli.rb
```ruby
module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    def self.exit_on_failure?
      true
    end

    # ...

    desc "workflows", "List and select a workflow to run"
    def workflows
      workflows = Workflows.new

      selected_workflow = workflows.list_and_select

      if selected_workflow
        begin
          workflows.run(selected_workflow)
          say @pastel.green("Workflow completed successfully") # Error occurs here
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

### thor_ext.rb
This file contains the `ThorExt` module, which is extended by the `Flowbots::CLI` class in `cli.rb`. It provides additional functionality and error handling for Thor-based CLIs. However, the error does not appear to be directly related to the contents of this file.


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
