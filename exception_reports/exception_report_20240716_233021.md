# 🤖 FlowBot Exception Report 🤖


## Summary:
The error "Cartridge file not found" occurred when attempting to load the "nlp_techniques_and_tools.yml" cartridge file. This issue arose during the initialization of the WorkflowAgent with the specified role and cartridge file.

## Technical Details:

**Error Class and Message:**
- Class: Flowbots::CLI
- Message: "Cartridge file not found: /home/b08x/Workspace/flowbots/nano-bots/cartridges/@b08x/cartridges/nlp_techniques_and_tools.yml"

**Backtrace:**
```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/controllers/instance.rb:82:in `load_cartridge!'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/controllers/instance.rb:18:in `initialize'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/ports/dsl/nano-bots.rb:15:in `new'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/ports/dsl/nano-bots.rb:15:in `new'
/home/b08x/Workspace/flowbots/lib/components/WorkflowAgent.rb:27:in `initialize'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:94:in `new'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:94:in `perform_nlp_analysis'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:62:in `perform_text_analysis'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:18:in `run'
/home/b08x/Workspace/flowbots/lib/workflows.rb:32:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:27:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:16:in `<main>'
```

**Relevant Files:**

**WorkflowAgent.rb:**
```ruby
class Agent < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  attribute :name
  attribute :role
  attribute :state
  collection :responses, :AgentResponse
  index :name
  index :role
end

class AgentResponse < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  attribute :text
  attribute :tagged, Type::Hash
  reference :agent, :Agent
end

class WorkflowAgent
  def initialize(role, cartridge_file)
    @role = role
    @state = {}
    @bot = NanoBot.new(
      cartridge: cartridge_file
    )
    Flowbots::UI.info "Initialized WorkflowAgent with role: #{role}, cartridge: #{cartridge_file}"
  end

  # ... (remaining code omitted)
end
```

**workflows.rb:**
```ruby
# ... (irrelevant code omitted)

module Flowbots
  class Workflows
    # ... (irrelevant code omitted)

    def run(workflow_name)
      workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

      unless File.exist?(workflow_file)
        logger.error "Workflow file not found: #{workflow_file}"
        raise FileNotFoundError, "Workflow file not found: #{workflow_file}"
      end

      # ... (remaining code omitted)
    end

    # ... (irrelevant code omitted)
  end

  # ... (irrelevant code omitted)
end

# ... (irrelevant code omitted)
```

**cli.rb:**
```ruby
# ... (irrelevant code omitted)

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    # ... (irrelevant code omitted)

    desc "workflows", "List and select a workflow to run"
    def workflows
      # ... (irrelevant code omitted)

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

    # ... (irrelevant code omitted)
  end
end

# ... (irrelevant code omitted)
```


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** Cartridge file not found: "/home/b08x/Workspace/flowbots/nano-bots/cartridges/@b08x/cartridges/nlp_techniques_and_tools.yml"

### Backtrace

```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/controllers/instance.rb:82:in `load_cartridge!'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/controllers/instance.rb:18:in `initialize'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/ports/dsl/nano-bots.rb:15:in `new'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/nano-bots-3.4.0/ports/dsl/nano-bots.rb:15:in `new'
/home/b08x/Workspace/flowbots/lib/components/WorkflowAgent.rb:27:in `initialize'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:94:in `new'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:94:in `perform_nlp_analysis'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:62:in `perform_text_analysis'
/home/b08x/Workspace/flowbots/lib/workflows/tree_of_thoughts_workflow.rb:18:in `run'
/home/b08x/Workspace/flowbots/lib/workflows.rb:32:in `run'
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
