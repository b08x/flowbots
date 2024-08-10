#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs LLM analysis on a text file using a pre-trained model.
class LlmAnalysisTask < Jongleur::WorkerTask
  # Executes the task.
  #
  # @return [void]
  def execute
    Flowbots::UI.info "Starting LLMAnalysisTask"

    begin
      # Create a new WorkflowAgent instance for the "ironically_literal" agent.
      agent = WorkflowAgent.new(
        "ironically_literal",
        File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "assistants/steve.yml")
      )

      logger.debug "Created WorkflowAgent instance"

      # Load the agent's state from Redis.
      agent.load_state
      logger.debug "Loaded agent state"

      # Retrieve the Textfile object, its content, metadata, and NLP results.
      textfile = retrieve_current_textfile
      content = textfile.preprocessed_content
      metadata = textfile.metadata || {}
      nlp_result = retrieve_nlp_result(textfile)

      # Generate a prompt for the agent based on the retrieved information.
      prompt = generate_analysis_prompt(textfile, content, metadata, nlp_result)
      analysis_result = agent.process(prompt)

      logger.debug "Agent processing completed"

      # Save the agent's state to Redis.
      agent.save_state
      logger.debug "Saved agent state"

      # Store the analysis result in the Textfile.
      store_analysis_result(textfile, analysis_result)

      write_markdown_report(analysis_result)

      logger.debug "Stored analysis result"

      logger.info "LLMAnalysisTask completed"
    rescue StandardError => e
      # Log an error message if an exception occurs during the task execution.
      logger.error "Error in LLMAnalysisTask: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise
    end
  end

  private

  # Retrieves the current Textfile object from Redis.
  #
  # @return [Textfile] The Textfile object representing the current file.
  def retrieve_current_textfile
    textfile_id = Jongleur::WorkerTask.class_variable_get(:@@redis).get("current_textfile_id")
    Textfile[textfile_id]
  end

  # # Retrieves the preprocessed content from Redis.
  # #
  # # @return [String] The preprocessed content.
  # def retrieve_preprocessed_content
  #   Jongleur::WorkerTask.class_variable_get(:@@redis).get("preprocessed_content")
  # end

  # Retrieves the file metadata from Redis.
  #
  # @return [Hash] The file metadata.
  def retrieve_file_metadata
    JSON.parse(Jongleur::WorkerTask.class_variable_get(:@@redis).get("file_metadata") || "{}")
  end

  # Retrieves the NLP results for the segments of the Textfile.
  #
  # @param textfile [Textfile] The Textfile object.
  #
  # @return [Array] An array of NLP results for each segment.
  def retrieve_nlp_result(textfile)
    textfile.retrieve_segments.map do |segment|
      {
        text: segment.text,
        tagged: segment.tagged
      }
    end
  end

  # Generates a prompt for the LLM analysis agent.
  #
  # @param textfile [Textfile] The Textfile object.
  # @param content [String] The preprocessed content of the Textfile.
  # @param metadata [Hash] The metadata of the Textfile.
  # @param nlp_result [Array] The NLP results for the segments of the Textfile.
  #
  # @return [String] The prompt for the agent.
  def generate_analysis_prompt(textfile, content, metadata, nlp_result)
    <<~PROMPT
      Greetings, Language Model! We have an exciting task for you today. We're analyzing a document, and we need your expertise to provide insights. Here's what we have:

      Document Name: #{textfile.name}

      Content:
      #{content}

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

  # Formats the NLP results for display in the prompt.
  #
  # @param nlp_result [Array] The NLP results for the segments of the Textfile.
  #
  # @return [String] The formatted NLP results.
  def format_nlp_result(nlp_result)
    nlp_result.first(10).map do |segment|
      <<~SEGMENT
        Segment: "#{segment[:text]}"
        Parts of Speech: #{segment[:tagged][:pos].to_a.first(5).map { |word, pos| "#{word}(#{pos})" }.join(', ')}
        Named Entities: #{segment[:tagged][:ner].to_a.first(5).map { |word, ner| "#{word}(#{ner})" }.join(', ')}
      SEGMENT
    end.join("\n")
  end

  # Stores the analysis result in the Textfile.
  #
  # @param textfile [Textfile] The Textfile object.
  # @param result [String] The analysis result from the LLM agent.
  #
  # @return [void]
  def store_analysis_result(textfile, result)
    textfile.update(analysis: result)
    # Jongleur::WorkerTask.class_variable_get(:@@redis).set("analysis_result", result.to_json)
  end

  # Writes the exception report to a markdown file.
  #
  # @param report [String] The exception report.
  # @param exception_details [Hash] A hash containing exception details.
  #
  # @return [void]
  def write_markdown_report(result)
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "llm_analysis_task_#{timestamp}.md"
    dir_path = File.expand_path("../../llm_analysis", __dir__)
    FileUtils.mkdir_p(dir_path)
    file_path = File.join(dir_path, filename)

    File.write(file_path, result)
    logger.info("Exception report written to: #{file_path}")
  end
end
