# 🤖 FlowBot Exception Report 🤖


## Error Summary:
An error has occurred in the Flowbots::CLI class, specifically in the Jongleur::API.rb file on line 153. The error message indicates that there is an issue with converting nil into an Integer.

## Technical Details:

```ruby
TypeError (can't convert nil into Integer)
```

This error is occurring during the execution of the following code block:

```ruby
class WorkflowOrchestrator
  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  def initialize
    @agents = {}
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
  end

  # ...

  def run_workflow
    logger.info "Starting workflow execution"
    begin
      # ...
      Jongleur::API.run do |on|
        # ...
      end
    rescue StandardError => e
      logger.error "Error during workflow execution: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise
    end
  end
end
```

The error is raised when attempting to execute the `Jongleur::API.run` method within the `run_workflow` method of the `WorkflowOrchestrator` class. The backtrace indicates that the issue occurs specifically in the `Jongleur::API.rb` file on line 153, which suggests that there may be an issue with the `run` method implementation in that file.

## Suggested Action Items:
- Review the `run` method in the `Jongleur::API.rb` file, specifically around line 153, to identify any potential issues with converting nil to an Integer.
- Consider adding additional error handling or input validation to the `run` method to prevent or catch similar issues in the future.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** can't convert nil into Integer

### Backtrace

```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `%'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `sleep'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `loop'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `run'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:42:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:82:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:28:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:50:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

If you need more information, please check the logs or contact the development team.
