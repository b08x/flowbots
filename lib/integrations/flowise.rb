#!/usr/bin/env ruby
# frozen_string_literal: true

require 'faraday'
require 'faraday/multipart'
require 'json'

class FlowiseApiClient
  def initialize(base_url)
    @base_url = base_url
    @conn = Faraday.new(url: @base_url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  def predict(chatflow_id, options = {})
    endpoint = "/api/v1/prediction/#{chatflow_id}"

    payload = {
      workerName: options[:worker_name],
      workerPrompt: options[:worker_prompt]
      # workerPrompt: options[:worker_prompt],
      # promptValues: options[:prompt_values]&.to_json
    }

    if options[:file_path]
      payload[:files] = Faraday::UploadIO.new(options[:file_path], 'application/octet-stream')
    end

    response = @conn.post(endpoint) do |req|
      req.body = payload
    end

    handle_response(response)
  end

  private

  def handle_response(response)
    case response.status
    when 200
      JSON.parse(response.body)
    else
      raise "Flowise API Error: #{response.status} - #{response.body}"
    end
  end
end

# Example usage:
client = FlowiseApiClient.new('http://tinybot.syncopated.net:3002')
result = client.predict('6aeba7f6-cefa-4fa2-9e8a-00c38094e4d5',
  worker_name: 'Tony',
  worker_prompt: 'Behave as a pirate',
  # prompt_values: { key: 'val' },
  file_path: '/home/b08x/Workspace/Notebook/_pdf/WhoseOpinionsDoLanguageModelsReflect.pdf'
)

puts result
