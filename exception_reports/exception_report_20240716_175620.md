# 🤖 FlowBot Exception Report 🤖


## Issue Summary
The Ruby on Rails application encountered a `NameError` due to an uninitialized constant `TextProcessingWorkflow`. This error occurred during the execution of the `Flowbots::CLI` class in the `cli.rb` file.

## Technical Details

**Backtrace:**
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

**Relevant Files:**
`workflows.rb`:
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class Workflows
    include Logging

    def initialize
      @prompt = TTY::Prompt.new
      @pastel = Pastel.new
    end

    def list_and_select
      workflows = get_workflows
      display_workflows(workflows)
      select_workflow(workflows)
    end

    def run(workflow_name)
      workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

      unless File.exist?(workflow_file)
        logger.error "Workflow file not found: #{workflow_file}"
        raise FileNotFoundError, "Workflow file not found: #{workflow_file}"
      end

      logger.info "Running workflow: #{workflow_name}"

      # workflow_class = Object.const_get(workflow_name.split("_").map(&:capitalize).join)
      workflow_class = workflow_name.split("_").map(&:capitalize).join
      workflow = Object.const_get(workflow_class).new(workflow_file)

      logger.debug workflow
      workflow.run
    end

    # ... [remaining code omitted for brevity]
  end

  class FileNotFoundError < StandardError; end
end
```

`cli.rb`:
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    def self.exit_on_failure?
      true
    end

    # ... [remaining code omitted for brevity]
  end
end
```


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
