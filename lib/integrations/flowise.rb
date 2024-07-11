#!/usr/bin/env ruby
# frozen_string_literal: true

require "faraday"
require "faraday/multipart"
require "json"

class FlowiseApiClient
  def initialize(base_url)
    @base_url = base_url
    @conn = Faraday.new(url: @base_url) do |faraday|
      faraday.request :multipart
      faraday.request :json
      faraday.adapter Faraday.default_adapter
    end
  end

  def predict(chatflow_id, options={})
    endpoint = "/api/v1/prediction/#{chatflow_id}"

    if options[:file_path]
      # File upload case
      payload = {
        files: Faraday::Multipart::FilePart.new(
          options[:file_path],
          "application/octet-stream",
          File.basename(options[:file_path])
        )
      }
      payload[:workerName] = options[:worker_name] if options[:worker_name]
      payload[:workerPrompt] = options[:worker_prompt] if options[:worker_prompt]
      payload[:promptValues] = options[:prompt_values].to_json if options[:prompt_values]

      response = @conn.post(endpoint) do |req|
        req.headers["Content-Type"] = "multipart/form-data"
        req.body = payload
      end
    else
      # Simple JSON query case
      payload = options.slice(:question, :history, :overrideConfig, :socketIOClientId)

      response = @conn.post(endpoint) do |req|
        req.headers["Content-Type"] = "application/json"
        req.body = payload.to_json
      end
    end

    handle_response(response)
  end

  def upsert_document(chatflow_id, file_path, local_ai_config={})
    endpoint = "/api/v1/vector/upsert/#{chatflow_id}"

    payload = {
      files: Faraday::Multipart::FilePart.new(
        file_path,
        "application/octet-stream",
        File.basename(file_path)
      ),
      localAIApiKey: local_ai_config[:api_key],
      basePath: local_ai_config[:base_path],
      modelName: local_ai_config[:model_name]
    }

    response = @conn.post(endpoint) do |req|
      req.headers["Content-Type"] = "multipart/form-data"
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

# TODO: assign chatflow_ids to names

# Example usage:
client = FlowiseApiClient.new("http://tinybot.syncopated.net:3002")

# # For prediction with file upload
# result = client.predict('6aeba7f6-cefa-4fa2-9e8a-00c38094e4d5',
#   worker_name: 'example',
#   worker_prompt: 'example',
#   prompt_values: { key: 'val' },
#   file_path: '/home/user1/Desktop/example.pdf'
# )
# puts result

# For prediction with simple query
query_result = client.predict(
  "6aeba7f6-cefa-4fa2-9e8a-00c38094e4d5",
  question: "How to connect subjects to objects?"
)
puts query_result

# # For document upsert
# upsert_result = client.upsert_document('73406ff6-bf12-4c09-bd43-485ceb30b8ca',
#   '/home/b08x/Workspace/flowbots/flowbots.json',
#   {
#     base_path: 'http://192.168.36.3:8080/v1',
#     model_name: 'all-MiniLM-L6-v2'
#   }
# )
# puts upsert_result
