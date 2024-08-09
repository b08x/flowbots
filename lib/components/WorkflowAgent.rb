#!/usr/bin/env ruby
# frozen_string_literal: true

# This class represents an agent in a workflow.
# Class representing an individual agent within a workflow in the Flowbots system.
#
# The WorkflowAgent is a key component in the text processing pipeline, responsible
# for performing specific tasks as defined by its role and cartridge configuration.
# It's designed to be flexible, maintainable, and integrated seamlessly with the
# WorkflowOrchestrator.
#
# == Key Features
#
# * Role-based processing: Each agent has a specific role in the workflow.
# * Cartridge-based configuration: Agent behavior is defined by a cartridge file.
# * State management: Agents can save and load state from Redis.
# * Real-time feedback: Provides visual feedback during processing.
# * Logging: Includes logging for monitoring and debugging.
#
# == Relation to Workflow
#
# WorkflowAgent instances are typically:
# 1. Created and managed by the WorkflowOrchestrator.
# 2. Arranged in a sequence to form the text processing pipeline.
# 3. Called upon by the orchestrator to process input and produce output.
# 4. Capable of maintaining state across multiple workflow steps or runs.
#
# == Example Usage
#
#  ```ruby
#   agent = WorkflowAgent.new("preprocessor", "path/to/cartridge.yml")
#   result = agent.process(input_text)
#   agent.save_state
#  ```
#
# == Integration
#
# The WorkflowOrchestrator would typically:
# * Initialize multiple WorkflowAgents for different stages of processing.
# * Call the #process method of each agent in sequence.
# * Manage the flow of data between agents in the workflow.
class WorkflowAgent
  # The base directory for cartridges.
  CARTRIDGE_DIR = File.expand_path("../../nano-bots/cartridges", __dir__)

  # Initializes a new WorkflowAgent instance.
  #
  # @param role [String] The role of the agent.
  # @param cartridge_file [String] The path to the cartridge file.
  #
  # @return [void]
  def initialize(role, cartridge_file)
    @role = role
    @state = {}
    @bot = NanoBot.new(
      cartridge: cartridge_file
    )
    Flowbots::UI.info "Initialized WorkflowAgent with role: #{role}, cartridge: #{cartridge_file}"
  end

  # Processes the given input using the agent's cartridge.
  #
  # @param input [String] The input to process.
  #
  # @return [String] The agent's response.
  def process(input)
    logger.debug "Processing input for #{@role}: #{input}"

    pastel = Pastel.new

    @bot.eval(input) do |content, fragment, finished, meta|
      @response = content unless content.nil?
      print pastel.blue(fragment) unless fragment.nil?
      sleep 0.025
    end

    # Flowbots::UI.info(@response)
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

  # Updates the agent's state with the latest response.
  #
  # @param response [String] The agent's response.
  #
  # @return [void]
  def update_state(response)
    @state[:last_response] = response
  end
end
