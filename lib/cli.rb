require "tty-prompt"
require "thor"

module Flowbots
  class CLI < Thor
    extend ThorExt::Start

    map %w[-v --version] => "version"

    desc "version", "Display flowbots version", hide: true
    def version
      say "flowbots/#{VERSION} #{RUBY_DESCRIPTION}"
    end
    
    desc "select WORKFLOW", "Select a workflow to run"
    def select(workflow_name)
      # TODO: Implement logic to select a workflow by name
      # This might involve:
      #   - Listing available workflows
      #   - Validating the provided workflow name
      #   - Storing the selected workflow for later use
      say "Selected workflow: #{workflow_name}"
    end

    desc "examples", "Select an example to run"
    def examples
      # TODO: Implement logic to select an example by name
      # This might involve:
      #   - Listing available examples
      #   - Validating the provided example name
      #   - Constructing the full path to the example file
      #   - Potentially, executing the example (e.g., if it's a script)
      # Use tty-prompt for example selection
      prompt = TTY::Prompt.new
      example_choice = prompt.select("Choose an example to run:", %w[crazy-story-gen.rb audio-workstation-config.rb multi-agent-workflow-gen.rb tree-of-thoughts.rb])
      puts "You selected: #{example_choice}"
      say "Selected example: #{example_choice}"
    end
    
  end
end
