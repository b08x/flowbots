#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "WorkflowAgent"

# Orchestrates the execution of workflows in the Flowbots application.
#
# The WorkflowOrchestrator is responsible for managing the lifecycle of a workflow,
# from defining its structure to executing its tasks and handling their results.
# It acts as a central coordinator, ensuring that agents are properly initialized,
# tasks are executed in the correct order, and errors are handled gracefully.
class WorkflowOrchestrator
  # The base directory for cartridges.
  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  # Initializes a new WorkflowOrchestrator instance.
  #
  # @return [void]
  def initialize
    # A hash to store the registered agents, keyed by their roles.
    @agents = {}
  end

  # Adds an agent to the orchestrator.
  #
  # @param role [String] The role of the agent in the workflow.
  # @param cartridge_file [String] The name of the cartridge file defining the agent's behavior.
  # @param author [String] The author of the cartridge (default: "@b08x").
  #
  # @return [void]
  # @raise [RuntimeError] If the specified cartridge file is not found.
  def add_agent(role, cartridge_file, author: "@b08x")
    logger.debug "Adding agent: #{role}"
    cartridge_path = File.join(CARTRIDGE_BASE_DIR, author, "cartridges", cartridge_file)

    raise "Cartridge file not found: \"#{cartridge_path}\"" unless File.exist?(cartridge_path)

    @agents[role] = WorkflowAgent.new(role, cartridge_path)
    logger.debug "Agent added: #{role}"
  end

  # Defines the workflow structure using a task graph.
  #
  # The workflow definition is a hash that outlines the tasks to be executed
  # and their dependencies. It is used by the Jongleur library to create
  # a task graph that represents the workflow.
  #
  # @param workflow_definition [Hash] The workflow definition in a format understood by Jongleur.
  #
  # @return [void]
  def define_workflow(workflow_definition)
    logger.debug "Defining workflow"
    logger.debug "Workflow definition: #{workflow_definition}"
    Jongleur::API.add_task_graph(workflow_definition)
    logger.debug "Workflow defined"
  end

  # Runs the defined workflow.
  #
  # This method initiates the workflow execution, managing the lifecycle of tasks
  # and handling any errors that occur during the process. It uses the Jongleur
  # library to execute the tasks in the defined order and provides hooks for
  # monitoring the progress and handling events.
  #
  # @return [void]
  def run_workflow
    logger.info "Starting workflow execution"
    @running = true

    begin
      logger.debug "Printing graph to /tmp"
      Jongleur::API.print_graph("/tmp")

      UI.info "Starting Jongleur::API.run"
      Jongleur::API.run do |on|
        # Event handler for task start.
        on.start do |task|
          ui.framed do
            ui.puts "Starting task: #{task}"
          end
        end

        # Event handler for task finish.
        on.finish do |task|
          ui.framed do
            ui.puts "Finished task: #{task}"
          end
          ui.space
        end

        # Event handler for task errors.
        on.error do |task, error|
          logger.error "Error in task #{task}: #{error.message}"
          logger.error error.backtrace.join("\n")
        end

        # Event handler for workflow completion.
        on.completed do |task_matrix|
          puts "Workflow completed"
          logger.info "Task matrix: #{task_matrix}"
          @running = false
          begin
            return "next" if BATCH
          rescue StandardError
            logger.warn "Not a batch job"
            return "next"
          end
        end
      end
    rescue Interrupt
      logger.info "Workflow interrupted"
      UI.say(:warn, "Workflow interrupted. Cleaning up...")
      cleanup
    rescue StandardError => e
      logger.error "Error during workflow execution: #{e.message}"
      logger.error e.backtrace.join("\n")
      cleanup
      raise
    end
  end

  # Performs cleanup operations for the workflow.
  #
  # This method is called after the workflow has finished or has been interrupted.
  # It ensures that any resources held by the workflow are released and that the
  # system is in a clean state for the next workflow execution.
  #
  # @return [void]
  def cleanup
    # Perform any necessary cleanup for the workflow
    Jongleur::API.trap_quit_signals
    # Add any other cleanup operations here
  end
end
