#!/usr/bin/env ruby
# frozen_string_literal: true

class Agent < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  attribute :name
  attribute :role
  attribute :state
  collection :responses, :AgentResponse
  index :name
  index :role
end

class AgentResponse < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks
  attribute :text
  attribute :tagged, Type::Hash
  reference :agent, :Agent
end

class WorkflowAgent
  def initialize(role, cartridge_file)
    @role = role
    @state = {}
    @bot = NanoBot.new(
      cartridge: cartridge_file
    )
    Flowbots::UI.info "Initialized WorkflowAgent with role: #{role}, cartridge: #{cartridge_file}"
  end

  def process(input)
    logger.debug "Processing input for #{@role}: #{input}"

    pastel = Pastel.new

    @bot.eval(input) do |content, fragment, finished, meta|
      @response = content unless content.nil?
      print pastel.blue(fragment) unless fragment.nil?
      sleep 0.025
    end

    #Flowbots::UI.info(@response)
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
