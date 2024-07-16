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

      workflow_class = Object.const_get(workflow_name.split("_").map(&:capitalize).join)
      workflow = workflow_class.new(workflow_file)

      logger.debug workflow
      workflow.run
    end

    private

    def get_workflows
      Dir.glob(File.join(WORKFLOW_DIR, "*.rb")).map do |file|
        name = File.basename(file, ".rb")
        description = extract_workflow_description(file)
        [name, description]
      end
    end

    def display_workflows(workflows)
      if workflows.empty?
        logger.warn "No workflows found in #{WORKFLOW_DIR}"
        return
      end

      table = TTY::Table.new(
        header: [@pastel.cyan("Workflow"), @pastel.cyan("Description")],
        rows: workflows
      )

      puts table.render(:unicode, padding: [0, 1])
    end

    def select_workflow(workflows)
      workflow_names = workflows.map { |w| w[0] }
      @prompt.select("Choose a workflow to run:", workflow_names)
    end

    def extract_workflow_description(file)
      first_line = File.open(file, &:readline).strip
      first_line.start_with?("# Description:") ? first_line[14..-1] : "No description available"
    end
  end

  class FileNotFoundError < StandardError; end
end
