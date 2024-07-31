#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nano-bots'

class WorkflowAgent
  attr_reader :role, :state

  def initialize(role, cartridge_file)
    @role = role
    @state = {}
    @bot = NanoBot.new(cartridge: cartridge_file)
  end

  def process(input)
    @bot.eval(input) do |content, fragment, finished, meta|
      @response = content unless content.nil?
    end
    update_state(@response)
    @response
  end

  def save_state
    Ohm.redis.hset("workflow_agent_state", @role, @state.to_json)
  end

  def load_state
    state_json = Ohm.redis.hget("workflow_agent_state", @role)
    @state = JSON.parse(state_json) if state_json
  end

  private

  def update_state(response)
    @state[:last_response] = response
  end
end
