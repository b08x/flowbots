#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "WorkflowAgent"

class WorkflowOrchestrator
  CARTRIDGE_BASE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  def initialize
    @agents = {}
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
  end

  def add_agent(role, cartridge_file, author: "@b08x")
    logger.debug "Adding agent: #{role}"
    cartridge_path = File.join(CARTRIDGE_BASE_DIR, author, "cartridges", cartridge_file)

    unless File.exist?(cartridge_path)
      logger.error "Cartridge file not found: \"#{cartridge_path}\""
      raise "Cartridge file not found: \"#{cartridge_path}\""
    end

    @agents[role] = WorkflowAgent.new(role, cartridge_path)
    logger.debug "Agent added: #{role}"
  end

  def define_workflow(workflow_definition)
    logger.debug "Defining workflow"
    logger.debug "Workflow definition: #{workflow_definition}"
    Jongleur::API.add_task_graph(workflow_definition)
    logger.debug "Workflow defined"
  end

  def run_workflow
    logger.info "Starting workflow execution"
    begin
      logger.debug "Printing graph to /tmp"
      Jongleur::API.print_graph("/tmp")


      Flowbots::UI.info "Starting Jongleur::API.run"
      Jongleur::API.run do |on|
        on.start do |task|
          ui.framed do
            ui.puts "Starting task: #{task}"
          end
        end

        on.finish do |task|
          ui.framed do
            ui.puts "Finished task: #{task}"
          end
          ui.space
        end

        on.error do |task, error|
          logger.error "Error in task #{task}: #{error.message}"
          logger.error error.backtrace.join("\n")
        end

        on.completed do |task_matrix|
          ui.framed do
            ui.puts "Workflow completed"
            ui.space
            ui.puts "Task matrix: #{task_matrix}"
          end
          return "next"
        end
      end
    rescue StandardError => e
      logger.error "Error during workflow execution: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise
    end
  end
end
