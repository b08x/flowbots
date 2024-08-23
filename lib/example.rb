#!/usr/bin/env ruby
# frozen_string_literal: true

lib_dir = File.expand_path(File.join(__dir__, "..", "lib"))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require "nano-bots"
require "jongleur"
require "redis"
require "json"
require "yaml"

require "dotenv"
Dotenv.load(File.join(__dir__, "..", "docker", ".env"))

require "logging"

include Logging

CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges", __dir__)

class Jongleur::WorkerTask
  @@redis = Redis.new(host: "localhost", port: 6379, db: 15)
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
    @bot.eval(input) do |content, fragment, _finished, _meta|
      @response = content unless content.nil?
      print fragment unless fragment.nil?
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

class CompressionTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("compression", "promptCompressor.yml")
    agent.load_state

    puts "Enter prompt to compress:"

    sourcePrompt = `yad --entry`

    result = agent.process("#{sourcePrompt}")

    agent.save_state

    @@redis.set("initial_compression", result.to_json)
  rescue StandardError => e
    logger.error "Error in CompressionTask: #{e.message}"
    raise
  end
end

class CompressionTestTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("testdesign", "promptCompressorTest.yml")
    agent.load_state

    initial_compression = JSON.parse(@@redis.get("initial_compression"))
    test_design = agent.process("#{initial_compression}")

    agent.save_state

    # Save the Ruby test code to a file
    File.write("compressed_prompt_test.rb", test_design)

    @@redis.set("testdesign", test_design.to_json)
  rescue StandardError => e
    logger.error "Error in CompressionTestTask: #{e.message}"
    raise
  end
end

class RunRubyTestsTask < Jongleur::WorkerTask
  def execute
    test_code = JSON.parse(@@redis.get("testdesign"))

    # Save the test code to a temporary file
    File.write("temp_test.rb", test_code)

    # Run the Ruby tests
    result = `ruby temp_test.rb`

    # Store the test results
    @@redis.set("test_results", result)

    # Clean up
    File.delete("temp_test.rb")
  rescue StandardError => e
    logger.error "Error in RunRubyTestsTask: #{e.message}"
    raise
  end
end

class CompressionTestEvalTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("testdesigneval", "promptCompressorTestEval.yml")
    agent.load_state

    test_design = JSON.parse(@@redis.get("testdesign"))
    testeval = agent.process("#{test_design}")

    agent.save_state
    @@redis.set("testeval", testeval.to_json)
  rescue StandardError => e
    logger.error "Error in CompressionTestEvalTask: #{e.message}"
    raise
  end
end

class CompressionTestAssessmentTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("testdesigneval", "promptCompressorAssessment.yml")
    agent.load_state

    test_eval = JSON.parse(@@redis.get("testeval"))
    testassesment = agent.process("#{test_eval}")

    agent.save_state
    @@redis.set("assessment", testassesment.to_json)
  rescue StandardError => e
    logger.error "Error in CompressionTestAssessmentTask: #{e.message}"
    raise
  end
end

class FinalReportTask < Jongleur::WorkerTask
  def execute
    agent = WorkflowAgent.new("finalreport", "finalReportGenerator.yml")
    agent.load_state

    initial_compression = JSON.parse(@@redis.get("initial_compression") || "{}")
    test_design = JSON.parse(@@redis.get("testdesign") || "{}")
    test_results = @@redis.get("test_results") || ""
    test_eval = JSON.parse(@@redis.get("testeval") || "{}")
    assessment = JSON.parse(@@redis.get("assessment") || "{}")

    report_input = {
      initial_compression: initial_compression,
      test_design: test_design,
      test_results: test_results,
      test_eval: test_eval,
      assessment: assessment
    }

    final_report = agent.process(report_input.to_json)

    agent.save_state

    # Save the final report as a Markdown file
    File.write("final_report.md", final_report)

    puts "Final report has been generated and saved as 'final_report.md'"
  rescue StandardError => e
    logger.error "Error in FinalReportTask: #{e.message}"
    logger.error e.backtrace.join("\n")
    raise
  end
end

class WorkflowOrchestrator
  def initialize
    @agents = {}
  end

  def add_agent(role, cartridge_file)
    @agents[role] = WorkflowAgent.new(role, cartridge_file)
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

# Example usage
orchestrator = WorkflowOrchestrator.new
orchestrator.add_agent("CompressionTask", "promptCompressor.yml")
orchestrator.add_agent("CompressionTestTask", "promptCompressorTest.yml")
orchestrator.add_agent("CompressionTestEvalTask", "promptCompressorTestEval.yml")
orchestrator.add_agent("CompressionTestAssessmentTask", "promptCompressorAssessment.yml")

workflow_graph = {
  CompressionTask: [:CompressionTestTask],
  CompressionTestTask: [:RunRubyTestsTask],
  RunRubyTestsTask: [:CompressionTestEvalTask],
  CompressionTestEvalTask: [:CompressionTestAssessmentTask],
  CompressionTestAssessmentTask: [:FinalReportTask],
  FinalReportTask: []
}

orchestrator.define_workflow(workflow_graph)
orchestrator.run_workflow
