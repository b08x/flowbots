#!/usr/bin/env ruby
# frozen_string_literal: true

class LlmAnalysisTask < Jongleur::WorkerTask

  def execute
    Flowbots::UI.info "Starting LLMAnalysisTask"

    begin
      agent = WorkflowAgent.new(
        "ironically_literal",
        File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "assistants/steve.yml")
      )

      logger.debug "Created WorkflowAgent instance"

      agent.load_state
      logger.debug "Loaded agent state"

      textfile = retrieve_current_textfile
      content = retrieve_preprocessed_content
      metadata = retrieve_file_metadata
      nlp_result = retrieve_nlp_result(textfile)

      prompt = generate_analysis_prompt(textfile, content, metadata, nlp_result)
      analysis_result = agent.process(prompt)

      logger.debug "Agent processing completed"

      agent.save_state
      logger.debug "Saved agent state"

      store_analysis_result(analysis_result)
      logger.debug "Stored analysis result"

      logger.info "LLMAnalysisTask completed"
    rescue StandardError => e
      logger.error "Error in LLMAnalysisTask: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise
    end
  end

  private

  def retrieve_current_textfile
    file_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_file_id")
    Sourcefile[file_id]
  end

  def retrieve_preprocessed_content
    Jongleur::WorkerTask.class_variable_get(:@@redis).get("preprocessed_content")
  end

  def retrieve_file_metadata
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("file_metadata") || "{}")
  end

  def retrieve_nlp_result(textfile)
    textfile.retrieve_segments.map do |segment|
      {
        text: segment.text,
        tagged: segment.tagged
      }
    end
  end

  def generate_analysis_prompt(textfile, content, metadata, nlp_result)
    <<~PROMPT
      Greetings, Language Model! We have an exciting task for you today. We're analyzing a document, and we need your expertise to provide insights. Here's what we have:

      Document Name: #{textfile.name}

      Content:
      #{content[0..1000]}... (truncated for brevity)

      NLP Analysis:
      #{format_nlp_result(nlp_result)}

      Based on this information, could you please:
      1. Summarize the main points of the document.
      2. Identify any key themes or concepts not captured in the metadata.
      3. Suggest any additional metadata that might be relevant.
      4. Provide any interesting insights or observations about the document's content or structure.
      5. If applicable, note any potential areas for further research or analysis.

      Please structure your response in a clear, concise manner. Thank you!
    PROMPT
  end

  def format_nlp_result(nlp_result)
    nlp_result.first(10).map do |segment|
      <<~SEGMENT
        Segment: "#{segment[:text][0..100]}..."
        Parts of Speech: #{segment[:tagged][:pos].to_a.first(5).map { |word, pos| "#{word}(#{pos})" }.join(", ")}
        Named Entities: #{segment[:tagged][:ner].to_a.first(5).map { |word, ner| "#{word}(#{ner})" }.join(", ")}
      SEGMENT
    end.join("\n")
  end

  def store_analysis_result(result)
    Jongleur::WorkerTask.class_variable_get(:@@redis).set("analysis_result", result.to_json)
  end
end
