#!/usr/bin/env ruby
# frozen_string_literal: true

# Add lib directory to load path
lib_dir = File.expand_path(File.join(__dir__, "..", "lib"))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

# Require necessary gems
require "nano-bots"
require "jongleur"
require "redis"
require "json"
require "yaml"

# Load environment variables from .env file
require "dotenv"
Dotenv.load(File.join(__dir__, "..", "docker", ".env"))

# Require logging module
require "logging"

# Include logging module
include Logging

# Define the directory for cartridges
CARTRIDGE_DIR = File.expand_path("../nano-bots/cartridges/@b08x/cartridges/compressor", __dir__)

# Define a Redis connection for Jongleur::WorkerTask
class Jongleur::WorkerTask
  # @return [Redis] The Redis connection for Jongleur::WorkerTask.
  @@redis = Redis.new(host: "localhost", port: 6378, db: 15)
end

# This class represents a workflow agent that can process input using a NanoBot.
class WorkflowAgent
  # Initializes a new WorkflowAgent instance.
  #
  # @param role [String] The role of the agent.
  # @param cartridge_file [String] The path to the cartridge file for the NanoBot.
  #
  # @return [void]
  def initialize(role, cartridge_file)
    cart = File.join(CARTRIDGE_DIR, cartridge_file)
    @role = role
    @state = {}
    @bot = NanoBot.new(
      cartridge: cart
    )
  end

  # Processes the given input using the NanoBot.
  #
  # @param input [String] The input to process.
  #
  # @return [String] The response from the NanoBot.
  def process(input)
    @bot.eval(input) do |content, fragment, _finished, _meta|
      @response = content unless content.nil?
      print fragment unless fragment.nil?
    end

    update_state(@response)
    @response
  end

  # Saves the agent's state to Redis.
  #
  # @return [void]
  def save_state
    Jongleur::WorkerTask.class_variable_get(:@@redis).hset(
      Process.pid.to_s,
      "agent:#{@role}",
      @state.to_json
    )
  end

  # Loads the agent's state from Redis.
  #
  # @return [void]
  def load_state
    state_json = Jongleur::WorkerTask.class_variable_get(:@@redis).hget(
      Process.pid.to_s,
      "agent:#{@role}"
    )
    @state = JSON.parse(state_json) if state_json
  end

  private

  # Updates the agent's state with the given response.
  #
  # @param response [String] The response to update the state with.
  #
  # @return [void]
  def update_state(response)
    @state[:last_response] = response
  end
end

# This task compresses a prompt using a WorkflowAgent.
class CompressionTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  # @raises [StandardError] If an error occurs during the task execution.
  def execute
    # Create a new WorkflowAgent instance for prompt compression.
    agent = WorkflowAgent.new("compression", "promptCompressor.yml")
    # Load the agent's state from Redis.
    agent.load_state

    # Prompt the user to enter a prompt to compress.
    puts "Enter prompt to compress:"

    # Get the prompt from the user using yad.
    sourcePrompt = `yad --entry`

    # Process the prompt using the agent.
    result = agent.process("#{sourcePrompt}")

    # Save the agent's state to Redis.
    agent.save_state

    # Store the compressed prompt in Redis.
    @@redis.set("initial_compression", result.to_json)
  rescue StandardError => e
    # Log an error message if an exception occurs.
    logger.error "Error in CompressionTask: #{e.message}"
    # Re-raise the exception.
    raise
  end
end

# This task designs a test for a compressed prompt using a WorkflowAgent.
class CompressionTestTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  # @raises [StandardError] If an error occurs during the task execution.
  def execute
    # Create a new WorkflowAgent instance for test design.
    agent = WorkflowAgent.new("testdesign", "promptCompressorTest.yml")
    # Load the agent's state from Redis.
    agent.load_state

    # Retrieve the compressed prompt from Redis.
    initial_compression = JSON.parse(@@redis.get("initial_compression"))
    # Process the compressed prompt using the agent to design a test.
    test_design = agent.process("#{initial_compression}")

    # Save the agent's state to Redis.
    agent.save_state

    # Save the Ruby test code to a file.
    File.write("compressed_prompt_test.rb", test_design)

    # Store the test design in Redis.
    @@redis.set("testdesign", test_design.to_json)
  rescue StandardError => e
    # Log an error message if an exception occurs.
    logger.error "Error in CompressionTestTask: #{e.message}"
    # Re-raise the exception.
    raise
  end
end

# This task runs Ruby tests from a file.
class RunRubyTestsTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  # @raises [StandardError] If an error occurs during the task execution.
  def execute
    # Retrieve the test code from Redis.
    test_code = JSON.parse(@@redis.get("testdesign"))

    # Save the test code to a temporary file.
    File.write("temp_test.rb", test_code)

    # Run the Ruby tests using the `ruby` command.
    result = `ruby temp_test.rb`

    # Store the test results in Redis.
    @@redis.set("test_results", result)

    # Clean up the temporary file.
    File.delete("temp_test.rb")
  rescue StandardError => e
    # Log an error message if an exception occurs.
    logger.error "Error in RunRubyTestsTask: #{e.message}"
    # Re-raise the exception.
    raise
  end
end

# This task evaluates a compression test design using a WorkflowAgent.
class CompressionTestEvalTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  # @raises [StandardError] If an error occurs during the task execution.
  def execute
    # Create a new WorkflowAgent instance for test design evaluation.
    agent = WorkflowAgent.new("testdesigneval", "promptCompressorTestEval.yml")
    # Load the agent's state from Redis.
    agent.load_state

    # Retrieve the test design from Redis.
    test_design = JSON.parse(@@redis.get("testdesign"))
    # Process the test design using the agent to evaluate it.
    testeval = agent.process("#{test_design}")

    # Save the agent's state to Redis.
    agent.save_state
    # Store the test evaluation in Redis.
    @@redis.set("testeval", testeval.to_json)
  rescue StandardError => e
    # Log an error message if an exception occurs.
    logger.error "Error in CompressionTestEvalTask: #{e.message}"
    # Re-raise the exception.
    raise
  end
end

# This task assesses a compression test evaluation using a WorkflowAgent.
class CompressionTestAssessmentTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  # @raises [StandardError] If an error occurs during the task execution.
  def execute
    # Create a new WorkflowAgent instance for test design assessment.
    agent = WorkflowAgent.new("testdesigneval", "promptCompressorAssessment.yml")
    # Load the agent's state from Redis.
    agent.load_state

    # Retrieve the test evaluation from Redis.
    test_eval = JSON.parse(@@redis.get("testeval"))
    # Process the test evaluation using the agent to assess it.
    testassesment = agent.process("#{test_eval}")

    # Save the agent's state to Redis.
    agent.save_state
    # Store the test assessment in Redis.
    @@redis.set("assessment", testassesment.to_json)
  rescue StandardError => e
    # Log an error message if an exception occurs.
    logger.error "Error in CompressionTestAssessmentTask: #{e.message}"
    # Re-raise the exception.
    raise
  end
end

# This task generates a final report using a WorkflowAgent.
class FinalReportTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  # @raises [StandardError] If an error occurs during the task execution.
  def execute
    # Create a new WorkflowAgent instance for final report generation.
    agent = WorkflowAgent.new("finalreport", "finalReportGenerator.yml")
    # Load the agent's state from Redis.
    agent.load_state

    # Retrieve the initial compression, test design, test results, test evaluation, and assessment from Redis.
    initial_compression = JSON.parse(@@redis.get("initial_compression") || "{}")
    test_design = JSON.parse(@@redis.get("testdesign") || "{}")
    test_results = @@redis.get("test_results") || ""
    test_eval = JSON.parse(@@redis.get("testeval") || "{}")
    assessment = JSON.parse(@@redis.get("assessment") || "{}")

    # Create a hash containing the report input data.
    report_input = {
      initial_compression:,
      test_design:,
      test_results:,
      test_eval:,
      assessment:
    }

    # Process the report input using the agent to generate the final report.
    final_report = agent.process(report_input.to_json)

    # Save the agent's state to Redis.
    agent.save_state

    # Save the final report as a Markdown file.
    File.write("final_report.md", final_report)

    # Print a message indicating that the final report has been generated.
    puts "Final report has been generated and saved as 'final_report.md'"
  rescue StandardError => e
    # Log an error message if an exception occurs.
    logger.error "Error in FinalReportTask: #{e.message}"
    logger.error e.backtrace.join("\n")
    # Re-raise the exception.
    raise
  end
end

# This class orchestrates a workflow of tasks using Jongleur.
class WorkflowOrchestrator
  # Initializes a new WorkflowOrchestrator instance.
  #
  # @return [void]
  def initialize
    @agents = {}
  end

  # Adds an agent to the orchestrator.
  #
  # @param role [String] The role of the agent.
  # @param cartridge_file [String] The path to the cartridge file for the agent.
  #
  # @return [void]
  def add_agent(role, cartridge_file)
    @agents[role] = WorkflowAgent.new(role, cartridge_file)
  end

  # Defines the workflow using a task graph.
  #
  # @param workflow_definition [Hash] The workflow definition as a hash.
  #
  # @return [void]
  def define_workflow(workflow_definition)
    Jongleur::API.add_task_graph(workflow_definition)
  end

  # Runs the workflow.
  #
  # @return [void]
  def run_workflow
    # Print the task graph to /tmp.
    Jongleur::API.print_graph("/tmp")

    # Run the workflow using Jongleur::API.
    Jongleur::API.run do |on|
      # Print a message when the workflow is completed.
      on.completed do |task_matrix|
        puts "Workflow completed"
        puts task_matrix
      end
    end
  end
end

# Example usage
# Create a new WorkflowOrchestrator instance.
orchestrator = WorkflowOrchestrator.new
# Add agents to the orchestrator.
orchestrator.add_agent("CompressionTask", "promptCompressor.yml")
orchestrator.add_agent("CompressionTestTask", "promptCompressorTest.yml")
orchestrator.add_agent("CompressionTestEvalTask", "promptCompressorTestEval.yml")
orchestrator.add_agent("CompressionTestAssessmentTask", "promptCompressorAssessment.yml")

# Define the workflow graph.
workflow_graph = {
  CompressionTask: [:CompressionTestTask],
  CompressionTestTask: [:RunRubyTestsTask],
  RunRubyTestsTask: [:CompressionTestEvalTask],
  CompressionTestEvalTask: [:CompressionTestAssessmentTask],
  CompressionTestAssessmentTask: [:FinalReportTask],
  FinalReportTask: []
}

# Define the workflow and run it.
orchestrator.define_workflow(workflow_graph)
orchestrator.run_workflow
