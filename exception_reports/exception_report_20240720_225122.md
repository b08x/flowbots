# 🤖 FlowBot Exception Report 🤖


## Summary
An error was encountered when attempting to execute the 'workflows' method within the Flowbots::CLI class. The specific issue is an undefined method 'green' for nil:NilClass error, indicating that the 'green' method is not defined for the object.

## Technical Details

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

### Relevant Files

#### cli.rb
```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    def self.exit_on_failure?
      true
    end

    map %w[-v --version] => "version"

    desc "version", "Display flowbots version", hide: true
    def version
      say "flowbots/#{VERSION} #{RUBY_DESCRIPTION}"
    end

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

    desc "process_text FILE", "Process a text file using the text processing workflow"
    def process_text(file)
      pastel = Pastel.new

      unless File.exist?(file)
        say pastel.red("File not found: #{file}")
        exit
      end

      say pastel.green("Processing file: #{file}")

      begin
        workflow = TextProcessingWorkflow.new(file)
        workflow.run
        say pastel.green("Text processing completed successfully")
      rescue StandardError => e
        ExceptionHandler.handle_exception(self.class.name, e)
      end
    end
  end
end
```

#### thor_ext.rb
```ruby
module Flowbots
  module ThorExt
    # Configures Thor to behave more like a typical CLI, with better help and error handling.
    #
    # - Passing -h or --help to a command will show help for that command.
    # - Unrecognized options will be treated as errors (instead of being silently ignored).
    # - Error messages will be printed in red to stderr, without stack trace.
    # - Full stack traces can be enabled by setting the VERBOSE environment variable.
    # - Errors will cause Thor to exit with a non-zero status.
    #
    # To take advantage of this behavior, your CLI should subclass Thor and extend this module.
    #
    #   class CLI < Thor
    #     extend ThorExt::Start
    #   end
    #
    # Start your CLI with:
    #
    #   CLI.start
    #
    # In tests, prevent Kernel.exit from being called when an error occurs, like this:
    #
    #   CLI.start(args, exit_on_failure: false)
    #
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

      def handle_exception_on_start(error, config)
        return if error.is_a?(Errno::EPIPE)
        raise if ENV["VERBOSE"] || !config.fetch(:exit_on_failure, true)

        message = error.message.to_s
        message.prepend("[#{error.class}] ") if message.empty? || !error.is_a?(Thor::Error)

        config[:shell]&.say_error(message, :red)
        exit(false)
      end
    end
  end
end
```

## Possible Cause
The error typically occurs when attempting to call a method or access an attribute of an object that has not been defined or is nil. In this case, it seems that the `@pastel` object is nil, resulting in the 'green' method being undefined.


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
