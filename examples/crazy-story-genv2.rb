#!/usr/bin/env ruby
# frozen_string_literal: true

lib_dir = File.expand_path(File.join(__dir__, "..", "lib"))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require "flowbots"

# # Centralized error handling with detailed logging
def handle_error(task_name, error)
  logger = Cogger::Client.new
  logger.error "Error in #{task_name}: #{error.message}\nBacktrace:\n#{error.backtrace.join("\n")}"
  raise # Re-raise to halt the workflow
end

class ResearcherTask < Jongleur::WorkerTask
  def execute
    # spinner = Flowbots::UI.spinner("ResearcherTask")
    # spinner.auto_spin

    agent = WorkflowAgent.new("researcher", "#{CARTRIDGE_DIR}/researcher.yml")
    agent.load_state

    result = agent.process("Documentation-Driven Development for Stateful Multi-Agent Workflows")
    agent.save_state
    @@redis.set("research_result", result.to_json)

    # spinner.stop("research task completed")
    #
    # result.split(". ").each do |word|
    #   print word unless word.nil?
    #   sleep 0.25
    # end

    puts "\n\n"

    sleep 3
  rescue StandardError => e
    handle_error("ResearcherTask", e)
    raise
  end
end

class WriterTask1 < Jongleur::WorkerTask
  def execute
    # spinner = Flowbots::UI.spinner("WriterTask2")
    # spinner.auto_spin

    agent = WorkflowAgent.new("writer1", "#{CARTRIDGE_DIR}/writer.yml")
    agent.load_state
    research_result = JSON.parse(@@redis.get("research_result"))
    article = agent.process("#{research_result}")
    agent.save_state
    @@redis.rpush("articles", article)

    # spinner.stop("first draft completed")

    puts "\n\n---\n\n"

    sleep 1
  rescue StandardError => e
    handle_error("WriterTask1", e)
    raise
  end
end

class WriterTask2 < Jongleur::WorkerTask
  def execute
    # spinner = Flowbots::UI.spinner("WriterTask2")
    # spinner.auto_spin

    agent = WorkflowAgent.new("writer2", "#{CARTRIDGE_DIR}/writer.yml")
    agent.load_state
    research_result = JSON.parse(@@redis.get("research_result"))
    article = agent.process("Generate a contrasting narrative based on: #{research_result}")
    agent.save_state
    @@redis.rpush("articles", article)

    # spinner.stop("contrasting statement task completed")

    puts "\n\n---\n\n"

    sleep 1
  rescue StandardError => e
    handle_error("WriterTask2", e)
    raise
  end
end

class EditorTask < Jongleur::WorkerTask
  @desc = "this is task D"
  def execute
    agent = WorkflowAgent.new("editor", "#{CARTRIDGE_DIR}/editor.yml")
    articles = @@redis.lrange("articles", 0, -1)

    # spinner = Flowbots::UI.spinner("EditorTask")
    # spinner.auto_spin

    final_result = agent.process("Braid the articles: #{articles.join('\n\n')}")

    # spinner.stop("research task completed")

    puts "\n\n---\n\n"

    puts final_result
  rescue StandardError => e
    handle_error("EditorTask", e)
    raise
  end
end

clear = `tput clear cup 5`
puts clear

# Example usage
orchestrator = WorkflowOrchestrator.new
orchestrator.add_agent("researcher", "researcher.yml")
orchestrator.add_agent("writer1", "writer.yml")
orchestrator.add_agent("writer2", "writer.yml")
orchestrator.add_agent("editor", "editor.yml")

workflow_graph = {
  ResearcherTask: %i[WriterTask1 WriterTask2],
  WriterTask1: [],
  WriterTask2: [:EditorTask]
}

orchestrator.define_workflow(workflow_graph)

orchestrator.run_workflow
