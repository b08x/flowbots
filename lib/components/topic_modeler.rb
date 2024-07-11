#!/usr/bin/env ruby

require 'tomoto'

class TopicModeler
  def initialize(num_topics, term_weight: :one, min_cf: 3, min_df: 2, rm_top: 4, alpha: 0.1, eta: 0.01)
    @model = Tomoto::LDA.new(
      k: 20,
      tw: term_weight,
      min_cf: min_cf,
      min_df: min_df,
      rm_top: rm_top,
      alpha: alpha,
      eta: eta,
      seed: 42
    )
    @save_path = File.join(ENV["HOME"], "Workspace", "knowlecule", "models", "test.lda.bin")
    load if File.exist?(@save_path)
  end

  def add_document(doc)
    doc.split("|").each { |s| @model.add_doc(s.strip) }
  end

  def train(iterations = 100)
    @model.burn_in = iterations
    @model.train(0) 
    puts "Num docs: #{@model.num_docs}, Vocab size: #{@model.used_vocabs.length}, Num words: #{@model.num_words}"
    puts "Removed top words: #{@model.removed_top_words}"
    puts "Training..."
    100.times do |i|
      @model.train(10)
      puts "Iteration: #{i * 10}\tLog-likelihood: #{@model.ll_per_word}"
    end
    puts @model.summary
  end

  def get_topics(top_n = 10)
    # @model.topic_words(top_n: top_n)
    @model.k.times do |k|
      puts "Topic ##{k}"
      @model.topic_words(k).each do |word, prob|
        puts "\t\t#{word}\t#{prob}"
      end
    end    
  end

  def infer_topics(doc, top_n = 5)
    doc_vec = @model.infer(doc.split)
    doc_vec.sort_by { |_, v| -v }.take(top_n).to_h
  end

  # def coherence
  #   @model.coherence
  # end

  # def perplexity
  #   @model.perplexity
  # end

  def save
    puts "Saving..."
    @model.save(@save_path)
  end

  def load
    puts "Loading..."
    @model = Tomoto::LDA.load(@save_path)
  end
  
end
# Example usage:
# modeler = TopicModeler.new(5)
# modeler.add_document("This is a document about Ruby programming")
# modeler.add_document("Machine learning is an interesting field")
# modeler.train
# puts modeler.get_topics
# puts modeler.infer_topics("What are the main topics in Ruby?")