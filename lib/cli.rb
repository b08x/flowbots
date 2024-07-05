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
  end
end
