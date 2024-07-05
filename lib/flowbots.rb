#!/usr/bin/env ruby
# frozen_string_literal: true

module Flowbots
  autoload :CLI, "cli"
  autoload :VERSION, "version"
  autoload :ThorExt, "thor_ext"
end

require 'jongleur'
require 'json'
require 'nano-bots'
require 'redis'
require 'yaml'

require "dotenv"
Dotenv.load(File.join(__dir__, "..", "docker", ".env"))

require "logging"

include Logging

CARTRIDGE_DIR = File.expand_path("cartridges", __dir__)

require_relative "components/orchestrator"
require_relative "components/agent"

class Jongleur::WorkerTask
  @@redis = Redis.new(host: "localhost", port: 6379, db: 15)
end

class ResearcherTask < Jongleur::WorkerTask
  def execute
    begin
      agent = WorkflowAgent.new("researcher", "#{CARTRIDGE_DIR}/researcher_cartridge.yml")
      agent.load_state
      result = agent.process("Research on Advancements in Garden Gnome Technology")
      agent.save_state
      @@redis.set("research_result", result.to_json)
    rescue => e
      logger.error "Error in ResearcherTask: #{e.message}"
      raise
    end
  end
end

class WriterTask1 < Jongleur::WorkerTask
  def execute
    begin
      agent = WorkflowAgent.new("writer1", "#{CARTRIDGE_DIR}/writer_cartridge.yml")
      agent.load_state
      research_result = JSON.parse(@@redis.get("research_result"))
      article = agent.process("Write an article based on: #{research_result}")
      agent.save_state
      @@redis.rpush("articles", article)
    rescue => e
      logger.error "Error in WriterTask1: #{e.message}"
      raise
    end
  end
end

class WriterTask2 < Jongleur::WorkerTask
  def execute
    begin
      agent = WorkflowAgent.new("writer2", "#{CARTRIDGE_DIR}/writer_cartridge.yml")
      agent.load_state
      research_result = JSON.parse(@@redis.get("research_result"))
      article = agent.process("Write a fantasy-horror narrative based on: #{research_result}")
      agent.save_state
      @@redis.rpush("articles", article)
    rescue => e
      logger.error "Error in WriterTask2: #{e.message}"
      raise
    end
  end
end

class FinalizeTask < Jongleur::WorkerTask
  def execute
    begin
      agent = WorkflowAgent.new("finalizer", "#{CARTRIDGE_DIR}/finalizer_cartridge.yml")
      articles = @@redis.lrange("articles", 0, -1)
      final_result = agent.process("Summarize and finalize these articles: #{articles.join('\n\n')}")
      puts "Final Result:"
      puts final_result
    rescue => e
      logger.error "Error in FinalizeTask: #{e.message}"
      raise
    end
  end
end

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
    Jongleur::API.print_graph('/tmp')

    Jongleur::API.run do |on|
      on.completed do |task_matrix|
        puts "Workflow completed"
        puts task_matrix
      end
    end
  end
end

# Example usage
orchestrator = WorkflowOrchestrator.new
orchestrator.add_agent('researcher', 'researcher_cartridge.yml')
orchestrator.add_agent('writer1', 'writer_cartridge.yml')
orchestrator.add_agent('writer2', 'writer_cartridge.yml')
orchestrator.add_agent('finalizer', 'finalizer_cartridge.yml')

workflow_graph = {
  ResearcherTask: [:WriterTask1, :WriterTask2],
  WriterTask1: [:FinalizeTask],
  WriterTask2: [:FinalizeTask]
}

orchestrator.define_workflow(workflow_graph)
orchestrator.run_workflow
