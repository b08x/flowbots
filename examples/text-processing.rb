# project_root/
# ├── Gemfile
# ├── config/
# │   └── initializers/
# │       └── redis.rb
# ├── lib/
# │   ├── advanced_text_processing.rb
# │   ├── nano_bot_registry.rb
# │   ├── text_preprocessor.rb
# │   ├── topic_modeler.rb
# │   ├── tasks/
# │   │   ├── preprocessing_task.rb
# │   │   ├── topic_modeling_task.rb
# │   │   ├── supplemental_info_task.rb
# │   │   └── language_model_task.rb
# │   └── advanced_text_processing_orchestrator.rb
# ├── spec/
# │   └── # Test files go here
# └── nano_bot_registry/
#     ├── sentiment_analysis_bot.yaml
#     ├── question_answering_bot.yaml
#     └── text_summarization_bot.yaml

# Gemfile
source 'https://rubygems.org'

gem 'jongleur'
gem 'redis'
gem 'nano_bots'
gem 'linguistics'
gem 'ruby-spacy'
gem 'pragmatic_tokenizer'
gem 'flowise'

# config/initializers/redis.rb
require 'redis'
$redis = Redis.new(host: "localhost", port: 6379, db: 15)

# lib/advanced_text_processing.rb
require_relative 'nano_bot_registry'
require_relative 'text_preprocessor'
require_relative 'topic_modeler'
require_relative 'tasks/preprocessing_task'
require_relative 'tasks/topic_modeling_task'
require_relative 'tasks/supplemental_info_task'
require_relative 'tasks/language_model_task'
require_relative 'advanced_text_processing_orchestrator'

# lib/nano_bot_registry.rb
class NanoBotRegistry
  def initialize(registry_path)
    @registry_path = registry_path
  end

  def load_bot(bot_name)
    YAML.safe_load(File.read(File.join(@registry_path, "#{bot_name}.yaml")), permitted_classes: [Symbol])
  end
end

# lib/text_preprocessor.rb
class TextPreprocessor
  # Implementation here
end

# lib/topic_modeler.rb
class TopicModeler
  # Implementation here
end

# lib/tasks/preprocessing_task.rb
class PreprocessingTask < Jongleur::WorkerTask
  # Implementation here
end

# lib/tasks/topic_modeling_task.rb
class TopicModelingTask < Jongleur::WorkerTask
  # Implementation here
end

# lib/tasks/supplemental_info_task.rb
class SupplementalInfoTask < Jongleur::WorkerTask
  attr_accessor :flowise_config

  def execute
    begin
      preprocessed_data = JSON.parse($redis.get("preprocessed_data"))
      topics = JSON.parse($redis.get("topics"))

      flowise_client = Flowise::Client.new(@flowise_config)

      supplemental_info = topics.map do |topic|
        query = "#{topic} #{preprocessed_data['entities'].map { |e| e[:text] }.join(' ')}"
        flowise_client.query_knowledge_base(query)
      end

      $redis.set("supplemental_info", supplemental_info.to_json)
    rescue => e
      logger.error "Error in SupplementalInfoTask: #{e.message}"
      raise
    end
  end
end

# lib/tasks/language_model_task.rb
class LanguageModelTask < Jongleur::WorkerTask
  attr_accessor :bot_name, :registry_path

  def execute
    begin
      preprocessed_data = JSON.parse($redis.get("preprocessed_data"))
      topics = JSON.parse($redis.get("topics"))
      supplemental_info = JSON.parse($redis.get("supplemental_info"))

      registry = NanoBotRegistry.new(@registry_path)
      bot_config = registry.load_bot(@bot_name)

      agent = NanoBot.new(cartridge: bot_config)

      prompt = "Analyze the following text, considering the identified topics and supplemental information:\n\n"
      prompt += "Text: #{preprocessed_data['clean_text']}\n\n"
      prompt += "Topics: #{topics.join(', ')}\n\n"
      prompt += "Supplemental Information: #{supplemental_info.join('\n')}\n\n"
      prompt += "Provide a comprehensive analysis and summary."

      result = agent.request(input: { text: prompt })
      $redis.set("lm_analysis", result)
    rescue => e
      logger.error "Error in LanguageModelTask: #{e.message}"
      raise
    end
  end
end

# lib/advanced_text_processing_orchestrator.rb
class AdvancedTextProcessingOrchestrator
  def initialize(flowise_config)
    @task_params = {}
    @flowise_client = Flowise::Client.new(flowise_config)
  end

  def set_task_params(task_class, params = {})
    @task_params[task_class] = params
  end

  def define_workflow(workflow_definition)
    Jongleur::API.add_task_graph(workflow_definition)
  end

  def run_workflow(input_text)
    $redis.set("input_text", input_text)
    Jongleur::API.run do |on|
      on.task do |task|
        if @task_params.key?(task.class)
          @task_params[task.class].each do |key, value|
            task.send("#{key}=", value) if task.respond_to?("#{key}=")
          end
        end
      end
      on.completed do |task_matrix|
        puts "Advanced text processing completed"
        puts task_matrix
      end
    end
    collect_results
  end

  def trigger_from_external(payload)
    input_text = @flowise_client.trigger_workflow(payload)
    run_workflow(input_text)
  end

  private

  def collect_results
    {
      preprocessed_data: JSON.parse($redis.get("preprocessed_data")),
      topics: JSON.parse($redis.get("topics")),
      supplemental_info: JSON.parse($redis.get("supplemental_info")),
      lm_analysis: $redis.get("lm_analysis")
    }
  end
end

# Example usage (in a separate file or script)
require_relative 'lib/advanced_text_processing'

flowise_config = { api_key: 'your_flowise_api_key', endpoint: 'your_flowise_endpoint' }
orchestrator = AdvancedTextProcessingOrchestrator.new(flowise_config)

orchestrator.set_task_params(PreprocessingTask, {
  preprocessor_options: { clean: true, downcase: true }
})

orchestrator.set_task_params(TopicModelingTask, {
  num_topics: 5,
  topic_modeler_options: { term_weight: :one }
})

orchestrator.set_task_params(SupplementalInfoTask, {
  flowise_config: flowise_config
})

orchestrator.set_task_params(LanguageModelTask, {
  bot_name: 'TextSummarizationBot',
  registry_path: File.join(File.dirname(__FILE__), 'nano_bot_registry')
})

workflow_graph = {
  PreprocessingTask: [:TopicModelingTask],
  TopicModelingTask: [:SupplementalInfoTask],
  SupplementalInfoTask: [:LanguageModelTask]
}

orchestrator.define_workflow(workflow_graph)

# Direct usage
input_text = "The AI revolution is transforming various industries..."
results = orchestrator.run_workflow(input_text)
puts JSON.pretty_generate(results)

# External trigger usage
external_payload = { /* some payload from Flowise */ }
results = orchestrator.trigger_from_external(external_payload)
puts JSON.pretty_generate(results)
