#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  # This class manages workflows in the Flowbots application.
  class Workflows
    # Initializes a new Workflows instance.
    #
    # @return [void]
    def initialize
      @prompt = TTY::Prompt.new
    end

    # Lists available workflows and allows the user to select one.
    #
    # @return [String, nil] The name of the selected workflow, or nil if no workflow is selected.
    def list_and_select
      workflows = get_workflows
      display_workflows(workflows)
      select_workflow(workflows)
    end

    # Runs the specified workflow.
    #
    # @param workflow_name [String] The name of the workflow to run.
    #
    # @return [void]
    # @raise [FileNotFoundError] If the workflow file is not found.
    def run(workflow_name)
      workflow_file = File.join(WORKFLOW_DIR, "#{workflow_name}.rb")

      unless File.exist?(workflow_file)
        logger.error "Workflow file not found: #{workflow_file}"
        raise FileNotFoundError, "Workflow file not found: #{workflow_file}"
      end

      UI.info "Running workflow: #{workflow_name}"

      workflow_class = workflow_name.split("_").map(&:capitalize).join
      workflow = Flowbots.const_get(workflow_class).new

      logger.debug workflow
      workflow.run
    end

    # Class method to load all workflow files from the WORKFLOW_DIR directory.
    # It also checks for user-defined workflows in a custom directory.
    #
    # @return [void]
    def self.load_workflows
      workflows_to_load = {}
      user_workflow_dir = if IN_CONTAINER
                            "/data/app/lib/workflows"
                          else
                            File.expand_path("../workflows/custom", __dir__)
                          end

      Dir["#{File.join(WORKFLOW_DIR, '**') + File::SEPARATOR}*.rb"].sort.each do |file|
        workflows_to_load[File.basename(file)] = file
      end

      if Dir.exist?(user_workflow_dir)
        Dir["#{File.join(user_workflow_dir, '**') + File::SEPARATOR}*.rb"].sort.each do |file|
          workflows_to_load[File.basename(file)] = file
        end
      end
      workflows_to_load.each_value do |file|
        begin
          require file
        rescue StandardError => e
          UI.error "Unable to load workflow #{e.message}"
          logger.fatal "Unable to load workflow #{e.message}"
        end
        UI.info "Loaded workflow file: #{file}"
        logger.debug "Loaded workflow file: #{file}"
      end
    end

    private

    # Retrieves a list of available workflows from the WORKFLOW_DIR directory.
    #
    # @return [Array<Array(String, String)>] An array of arrays, where each inner array contains
    #   the workflow name and its description.
    def get_workflows
      Dir.glob(File.join(WORKFLOW_DIR, "*.rb")).map do |file|
        name = File.basename(file, ".rb")
        description = extract_workflow_description(file)
        [name, description]
      end
    end

    # Displays a list of available workflows in a table format.
    #
    # @param workflows [Array<Array(String, String)>] An array of arrays, where each inner array contains
    #   the workflow name and its description.
    #
    # @return [void]
    def display_workflows(workflows)
      if workflows.empty?
        logger.warn "No workflows found in #{WORKFLOW_DIR}"
        return
      end

      table = TTY::Table.new(
        header: [UI::PASTEL.cyan("Workflow"), UI::PASTEL.cyan("Description")],
        rows: workflows
      )

      puts table.render(:unicode, padding: [0, 1])
    end

    # Prompts the user to select a workflow from the list of available workflows.
    #
    # @param workflows [Array<Array(String, String)>] An array of arrays, where each inner array contains
    #   the workflow name and its description.
    #
    # @return [String, nil] The name of the selected workflow, or nil if no workflow is selected.
    def select_workflow(workflows)
      workflow_names = workflows.map { |w| w[0] }
      @prompt.select("Choose a workflow to run:", workflow_names)
    end

    # Extracts the description of a workflow from its file.
    # The description is assumed to be the first line of the file starting with "# Description:".
    #
    # @param file [String] The path to the workflow file.
    #
    # @return [String] The workflow description, or "No description available" if not found.
    def extract_workflow_description(file)
      first_line = File.open(file, &:readline).strip
      first_line.start_with?("# Description:") ? first_line[14..-1] : "No description available"
    end
  end

  # Custom error class for workflow file not found.
  class FileNotFoundError < StandardError; end
end
