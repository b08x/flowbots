# topic_model_manager.rb

require_relative "topic_modeler"

class TopicModelManager
  def initialize(model_path)
    @model_path = model_path
    @model = nil
  end

  def load_or_create_model(num_topics=20, term_weight: :one)
    if File.exist?(@model_path)
      @model = TopicModeler.new(num_topics, term_weight:)
      @model.load
    else
      @model = TopicModeler.new(num_topics, term_weight:)
    end
    @model
  end

  def save_model
    @model.save if @model
  end

  def train_model(text, iterations=100)
    @model.add_document(text)
    @model.train(iterations)
  end

  def get_topics(top_n=10)
    @model.get_topics(top_n)
  end

  def infer_topics(text, top_n=5)
    @model.infer_topics(text, top_n)
  end
end

class HumanReviewInterface
  def self.review_topics(topics)
    puts "Please review the following topics:"
    topics.each_with_index do |topic, index|
      puts "Topic #{index + 1}: #{topic}"
    end
    puts "Are these topics relevant? (y/n)"
    response = gets.chomp.downcase
    response == "y"
  end
end
