#!/usr/bin/env ruby
# frozen_string_literal: true

class WorkflowOrchestrator
  def initialize
    @agents = {}
  end

  def add_agent(role, cartridge_file)
    cartridge_path = File.join(CARTRIDGE_DIR, cartridge_file)

    raise "Cartridge file not found: \"#{cartridge_path}\"" unless File.exist?(cartridge_path)

    @agents[role] = WorkflowAgent.new(role, cartridge_path)
  end

  def define_workflow(workflow_definition)
    Jongleur::API.add_task_graph(workflow_definition)
  end

  def run_workflow
    Jongleur::API.print_graph("/tmp")

    Jongleur::API.run do |on|
      on.completed do |task_matrix|
        puts "Workflow completed"
        puts task_matrix
      end
    end
  end
end
