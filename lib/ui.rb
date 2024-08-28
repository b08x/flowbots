#!/usr/bin/env ruby
# frozen_string_literal: true

# This task performs LLM analysis on a text file using a pre-trained model.
class LlmAnalysisTask < Jongleur::WorkerTask
  # Includes the InputRetrieval module for retrieving data from Redis.
  include InputRetrieval
  # Executes the task.
  #
  # @return [void]
  def execute
    # Display the Flowbots footer.
    UI.footer

    # Display an information message indicating the start of the task.
    UI.info "Starting LLMAnalysisTask"

    begin
      # Create a new WorkflowAgent instance for the "ironically_literal" agent.
      agent = WorkflowAgent.new(
        "ironically_literal",
        File.join(CARTRIDGE_DIR, "@b08x", "cartridges", "assistants/antisteve.yml")
      )

      # Log a debug message indicating the creation of the WorkflowAgent instance.
      logger.debug "Created WorkflowAgent instance"

      # Load the agent's state from Redis.
      agent.load_state
      # Log a debug message indicating the loading of the agent state.
      logger.debug "Loaded agent state"

      # Retrieve the Textfile object, its content, metadata, and NLP results.
      textfile = retrieve_input
      content = textfile.preprocessed_content
      metadata = textfile.metadata || {}
      nlp_result = retrieve_nlp_result(textfile)

      # Generate a prompt for the agent based on the retrieved information.
      prompt = generate_analysis_prompt(textfile, content, metadata, nlp_result)

      # Process the prompt using the agent and store the result.
      analysis_result = agent.process(prompt)

      # Log a debug message indicating the completion of agent processing.
      logger.debug "Agent processing completed"

      # Save the agent's state to Redis.
      agent.save_state
      # Log a debug message indicating the saving of the agent state.
      logger.debug "Saved agent state"

      # Store the analysis result in the Textfile.
      store_analysis_result(textfile, analysis_result)

      # Write the analysis result to a Markdown file.
      write_markdown(textfile, analysis_result)

      # Log an information message indicating the completion of the task.
      UI.info "LLMAnalysisTask completed"
    rescue StandardError => e
      # Handle any exceptions that occur during the task execution.
      ExceptionHandler.handle_exception(self.class.name, e)
    end
  end

  private

  # Retrieves the input for the task, which is the current FileObject.
  #
  # @return [FileObject] The current FileObject.
  def retrieve_input
    retrieve_file_object
  end

  # Retrieves the NLP result for the given Textfile.
  #
  # @param textfile [Textfile] The Textfile object.
  #
  # @return [Hash] The NLP result.
  def retrieve_nlp_result(textfile)
    # Retrieve the NLP result from the Textfile object.
    textfile.tagged
  end

  # Generates a prompt for the LLM analysis based on the given information.
  #
  # @param textfile [Textfile] The Textfile object.
  # @param content [String] The preprocessed content of the Textfile.
  # @param metadata [Hash] The metadata of the Textfile.
  # @param nlp_result [Hash] The NLP result for the Textfile.
  #
  # @return [String] The generated prompt.
  def generate_analysis_prompt(textfile, content, metadata, nlp_result)
    # Construct the prompt string using the provided information.
    <<~PROMPT
      Filename: #{textfile.name}
      Content:
      #{content}
      Metadata:
      #{metadata.to_json}
      NLP Result:
      #{nlp_result.to_json}

      Please provide an analysis of the text.
    PROMPT
  end

  # Stores the LLM analysis result in the given Textfile.
  #
  # @param textfile [Textfile] The Textfile object.
  # @param analysis_result [String] The LLM analysis result.
  #
  # @return [void]
  def store_analysis_result(textfile, analysis_result)
    # Update the Textfile object with the analysis result.
    textfile.update(llm_analysis: analysis_result)
  end

  # Writes the LLM analysis result to a Markdown file.
  #
  # @param textfile [Textfile] The Textfile object.
  # @param analysis_result [String] The LLM analysis result.
  #
  # @return [void]
  def write_markdown(textfile, analysis_result)
    # Create a Markdown file name based on the Textfile name.
    markdown_file = "#{textfile.name.gsub(/\s+/, '_')}_analysis.md"

    # Write the analysis result to the Markdown file.
    File.write(markdown_file, analysis_result)
  end
end
