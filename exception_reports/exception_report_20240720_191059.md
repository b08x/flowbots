# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots CLI, specifically in the `initialize` method of the `TopicModelTrainerWorkflow` class. The error message indicates that the wrong number of arguments were passed to a method, with 0 arguments given and 1 argument expected.

## Technical Details

### Backtrace
- `/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:8:in 'initialize'`
- `/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in 'new'`
- `/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in 'run'`
- `/home/b08x/Workspace/flowbots/lib/cli.rb:27:in 'workflows'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in 'run'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in 'invoke_command'`
- `/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in 'dispatch'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in 'block in start'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in 'handle_help_switches'`
- `/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in 'start'`
- `./exe/flowbots:16:in '<main>'`

### Relevant Files

#### workflows.rb
```ruby
# ...

def run(workflow_name)
  workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

  unless File.exist?(workflow_file)
    logger.error "Workflow file not found: #{workflow_file}"
    raise FileNotFoundError, "Workflow file not found: #{workflow_file}"
  end

  Flowbots::UI.info "Running workflow: #{workflow_name}"

  workflow_class = workflow_name.split("_").map(&:capitalize).join
  workflow = Flowbots.const_get(workflow_class).new

  logger.debug workflow
  workflow.run
end

# ...
```

#### cli.rb
```ruby
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
```

#### thor_ext.rb
```ruby
# ...

module Start
  def self.extended(base)
    super
    base.check_unknown_options!
  end

  def start(given_args=ARGV, config={})
    config[:shell] ||= Thor::Base.shell.new
    handle_help_switches(given_args) do |args|
      dispatch(nil, args, nil, config)
    end
  rescue StandardError => e
    handle_exception_on_start(e, config)
  end

private

  def handle_help_switches(given_args)
    yield(given_args.dup)
  rescue Thor::UnknownArgumentError => e
    retry_with_args = []

    if given_args.first == "help"
      retry_with_args = ["help"] if given_args.length > 1
    elsif e.unknown.intersect?(%w[-h --help])
      retry_with_args = ["help", (given_args - e.unknown).first]
    end
    raise unless retry_with_args.any?

    yield(retry_with_args)
  end

# ...
```


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** wrong number of arguments (given 0, expected 1)

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:8:in `initialize'
/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in `new'
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
