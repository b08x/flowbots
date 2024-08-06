# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots CLI tool, specifically in the `workflows` method of the `CLI` class. The error message "undefined method `green' for nil:NilClass" indicates that the code is attempting to call the `green` method on an object that is `nil`.

## Technical Details
The relevant code snippet from `cli.rb` is as follows:

```ruby
say @pastel.green("Workflow completed successfully")
```

In this line, `@pastel` is `nil`, and therefore the `green` method cannot be called on it. This results in the "undefined method `green' for nil:NilClass" error.

To resolve this issue, you should ensure that `@pastel` is initialized correctly before attempting to call the `green` method on it. You may need to check the value of `@pastel` before calling the `green` method to ensure it is not `nil`.

## Additional Information
The error occurred during the execution of the `workflows` method, which is defined as follows:

```ruby
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
```

The backtrace and relevant files provide additional context for the error and can be referenced for further investigation.


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
