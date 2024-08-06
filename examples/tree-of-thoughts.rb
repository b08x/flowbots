#!/usr/bin/env ruby
# frozen_string_literal: true

require "helper"

require "cogger"
require "jongleur"
require "json"
require "nano-bots"
require "redis"
require "yaml"

require "dotenv"

begin
  Dotenv.load(File.join(__dir__, "..", ".env"))
rescue StandardError => e
  puts "hey"
end

require "logging"

include Logging

CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/", __dir__)

p Dir.new(CARTRIDGE_DIR).entries

require "ui"

class Jongleur::WorkerTask
  begin
    @@redis = Redis.new(host: "localhost", port: 6379, db: 15)
    # @@redis.flushall
    # exit
  rescue Redis::CannotConnectError => e
    handle_error(self.class.name, e)
    exit
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
    Jongleur::API.print_graph("/tmp")

    Jongleur::API.run do |on|
      on.completed do |task_matrix|
        puts "Workflow completed"
        puts task_matrix
      end
    end
  end
end

class WorkflowAgent
  def initialize(role, cartridge_file)
    @role = role
    @state = {}
    @bot = NanoBot.new(
      cartridge: cartridge_file
    )
  end

  def process(input)
    @bot.eval(input) do |content, fragment, finished, meta|
      @response = content unless content.nil?
      print fragment unless fragment.nil?
      sleep 0.325
    end

    update_state(@response)
    @response
  end

  def save_state
    Jongleur::WorkerTask.class_variable_get(:@@redis).hset(
      Process.pid.to_s,
      "agent:#{@role}",
      @state.to_json
    )
  end

  def load_state
    state_json = Jongleur::WorkerTask.class_variable_get(:@@redis).hget(
      Process.pid.to_s,
      "agent:#{@role}"
    )
    @state = JSON.parse(state_json) if state_json
  end

  private

  def update_state(response)
    @state[:last_response] = response
  end
end

class ThoughtGeneratorTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("thought_generator", "thought_generator.yml")
    agent.load_state
    prompt = if @@redis.exists?("current_thoughts")
               "Expand on these thoughts: #{@@redis.get('current_thoughts')}"
             else
               "Generate initial thoughts on semantic and emotional context analysis for threat modeling"
             end
    result = agent.process(prompt)
    agent.save_state
    @@redis.set("new_thoughts", result.to_json)
  end
end

class ThoughtEvaluatorTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("thought_evaluator", "thought_evaluator.yml")
    agent.load_state
    thoughts = JSON.parse(@@redis.get("new_thoughts"))
    result = agent.process("Evaluate and rank these thoughts: #{thoughts}")
    agent.save_state
    @@redis.set("evaluation_results", result.to_json)
  end
end

class ContextAnalyzerTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("context_analyzer", "context_analyzer.yml")
    agent.load_state
    best_thoughts = JSON.parse(@@redis.get("evaluation_results"))
    result = agent.process("Analyze the semantic context based on these thoughts: #{best_thoughts}")
    agent.save_state
    @@redis.set("semantic_analysis", result.to_json)
  end
end

class ThreatIdentifierTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("threat_identifier", "threat_identifier.yml")
    agent.load_state
    semantic_analysis = JSON.parse(@@redis.get("semantic_analysis"))
    result = agent.process("Identify potential threats based on: #{semantic_analysis}")
    agent.save_state
    @@redis.set("threat_identification", result.to_json)
  end
end

class EmotionalAssessorTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("emotional_assessor", "emotional_assessor.yml")
    agent.load_state
    semantic_analysis = JSON.parse(@@redis.get("semantic_analysis"))
    threat_identification = JSON.parse(@@redis.get("threat_identification"))
    result = agent.process("Assess emotional state and intentions based on: #{semantic_analysis} and #{threat_identification}")
    agent.save_state
    @@redis.set("emotional_assessment", result.to_json)
  end
end

class CulturalAnalyzerTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("cultural_analyzer", "cultural_analyzer.yml")
    agent.load_state
    all_data = {
      semantic: JSON.parse(@@redis.get("semantic_analysis")),
      threats: JSON.parse(@@redis.get("threat_identification")),
      emotional: JSON.parse(@@redis.get("emotional_assessment"))
    }
    result = agent.process("Analyze cultural and contextual nuances based on: #{all_data}")
    agent.save_state
    @@redis.set("cultural_analysis", result.to_json)
  end
end

class PromptGeneratorTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("prompt_generator", "prompt_generator.yml")
    agent.load_state
    all_analyses = {
      semantic: JSON.parse(@@redis.get("semantic_analysis")),
      threats: JSON.parse(@@redis.get("threat_identification")),
      emotional: JSON.parse(@@redis.get("emotional_assessment")),
      cultural: JSON.parse(@@redis.get("cultural_analysis"))
    }
    result = agent.process("Generate targeted prompts based on all analyses: #{all_analyses}")
    agent.save_state
    @@redis.set("generated_prompts", result.to_json)
    puts "Generated Prompts:"
    puts result
  end
end

# Workflow definition
workflow_graph = {
  ThoughtGeneratorTask: [:ThoughtEvaluatorTask],
  ThoughtEvaluatorTask: %i[ThoughtGeneratorTask ContextAnalyzerTask],
  ContextAnalyzerTask: %i[ThreatIdentifierTask EmotionalAssessorTask],
  ThreatIdentifierTask: [:EmotionalAssessorTask],
  EmotionalAssessorTask: [:CulturalAnalyzerTask],
  CulturalAnalyzerTask: [:PromptGeneratorTask],
  PromptGeneratorTask: []
}

# Orchestrator setup and execution
orchestrator = WorkflowOrchestrator.new
orchestrator.add_agent("thought_generator", "thought_generator.yml")
orchestrator.add_agent("thought_evaluator", "thought_evaluator.yml")
orchestrator.add_agent("context_analyzer", "context_analyzer.yml")
orchestrator.add_agent("threat_identifier", "threat_identifier.yml")
orchestrator.add_agent("emotional_assessor", "emotional_assessor.yml")
orchestrator.add_agent("cultural_analyzer", "cultural_analyzer.yml")
orchestrator.add_agent("prompt_generator", "prompt_generator.yml")

orchestrator.define_workflow(workflow_graph)

# Run the workflow multiple times to simulate the tree of thoughts expansion
3.times do
  orchestrator.run_workflow
end
