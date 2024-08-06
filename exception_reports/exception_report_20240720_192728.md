# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the "Flowbots::CLI" class, indicating that a folder was not found. 

## Technical Details
```
Class: Flowbots::CLI
Message: Folder not found
```

### Backtrace
```
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:40:in `prompt_for_folder'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:10:in `initialize'
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

### Relevant Files
```
workflows.rb:

#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class Workflows

    def initialize
      @prompt = TTY::Prompt.new
      @pastel = Pastel.new
    end

    ... [remaining code omitted for brevity] ...

  end

  class FileNotFoundError < StandardError; end
end
```

```
cli.rb:

#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    ... [remaining code omitted for brevity] ...

  end
end
```

```
command.rb:

module Sublayer
  module Actions
    class RunTestCommandAction < Base
      def initialize(test_command:)
        @test_command = test_command
      end

      def call
        stdout, stderr, status = Open3.capture3(@test_command)
        [stdout, stderr, status]
      end
    end
  end
end
```

```
thor_ext.rb:

module Flowbots
  module ThorExt
    # Configures Thor to behave more like a typical CLI, with better help and error handling.
    #
    # ... [remaining code omitted for brevity] ...
    module Start
      ... [remaining code omitted for brevity] ...
    end
  end
end
```


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** Folder not found

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:40:in `prompt_for_folder'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:10:in `initialize'
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
