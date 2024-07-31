#!/usr/bin/env ruby
# frozen_string_literal: true

class TopicModelingTask < Jongleur::WorkerTask
  def execute
    workflow_id = Ohm.redis.get("current_workflow_id")
    workflow = Workflow[workflow_id]

    if workflow.is_batch_workflow
      model_batch_topics(workflow)
    else
      model_single_file_topics(workflow)
    end
  end

  private

  def model_batch_topics(workflow)
    current_batch = workflow.batches.find(number: workflow.current_batch_number).first
    documents = current_batch.sourcefiles.map { |sf| prepare_document(sf) }

    topic_processor = Flowbots::TopicModelProcessor.instance
    topic_processor.load_or_create_model
    results = topic_processor.infer_topics(documents)

    store_batch_topics(current_batch, results)
    logger.info "Modeled topics for Batch #{current_batch.number}"
  end

  def model_single_file_topics(workflow)
    sourcefile = workflow.sourcefiles.first
    document = prepare_document(sourcefile)

    topic_processor = Flowbots::TopicModelProcessor.instance
    topic_processor.load_or_create_model
    result = topic_processor.infer_topics([document]).first

    store_file_topics(sourcefile, result)
    logger.info "Modeled topics for single file: #{sourcefile.path}"
  end

  def prepare_document(sourcefile)
    sourcefile.segments.map(&:text).join(' ')
  end

  def store_batch_topics(batch, results)
    batch.sourcefiles.zip(results).each do |sourcefile, result|
      store_file_topics(sourcefile, result)
    end
  end

  def store_file_topics(sourcefile, result)
    result[:top_words].each do |word, score|
      topic = Topic.find(name: word).first || Topic.create(name: word)
      topic.sourcefiles.add(sourcefile)
    end

    sourcefile.update(
      metadata: sourcefile.metadata.merge(
        topics: result[:top_words],
        topic_distribution: result[:topic_distribution]
      )
    )
    logger.debug "Stored topics for file: #{sourcefile.path}"
  end
end
