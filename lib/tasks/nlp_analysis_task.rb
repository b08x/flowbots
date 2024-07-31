#!/usr/bin/env ruby
# frozen_string_literal: true

class NlpAnalysisTask < Jongleur::WorkerTask
  def execute
    workflow_id = Ohm.redis.get("current_workflow_id")
    workflow = Workflow[workflow_id]

    if workflow.is_batch_workflow
      analyze_batch_files(workflow)
    else
      analyze_single_file(workflow)
    end
  end

  private

  def analyze_batch_files(workflow)
    current_batch = workflow.batches.find(number: workflow.current_batch_number).first
    current_batch.sourcefiles.each do |sourcefile|
      analyze_file_segments(sourcefile)
    end
    logger.info "Performed NLP analysis for Batch #{current_batch.number}"
  end

  def analyze_single_file(workflow)
    sourcefile = workflow.sourcefiles.first
    analyze_file_segments(sourcefile)
    logger.info "Performed NLP analysis for single file: #{sourcefile.path}"
  end

  def analyze_file_segments(sourcefile)
    nlp_processor = Flowbots::NLPProcessor.instance

    sourcefile.segments.each do |segment|
      processed_tokens = nlp_processor.process(segment, pos: true, dep: true, ner: true, tag: true)

      tagged = {
        pos: {}, dep: {}, ner: {}, tag: {}
      }

      processed_tokens.each do |token|
        word = token[:word]
        tagged[:pos][word] = token[:pos]
        tagged[:dep][word] = token[:dep]
        tagged[:ner][word] = token[:ner]
        tagged[:tag][word] = token[:tag]

        Word.create(
          word: word,
          pos: token[:pos],
          tag: token[:tag],
          dep: token[:dep],
          ner: token[:ner],
          sourcefile: sourcefile,
          segment: segment
        )
      end

      segment.update(tagged: tagged)
      logger.debug "Analyzed segment #{segment.id} for file: #{sourcefile.path}"
    end
  end
end
