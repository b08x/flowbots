module Flowbots
  class TextProcessingWorkflow
    attr_reader :input_file_path

    def initialize(input_file_path=nil)
      @input_file_path = input_file_path || prompt_for_file
      @orchestrator = WorkflowOrchestrator.new
    end

    def run
      Flowbots::UI.say(:ok, "Setting Up Text Processing Workflow")
      logger.info "Setting Up Text Processing Workflow"

      setup_workflow
      store_input_file_path

      Flowbots::UI.info "Running Text Processing Workflow"
      @orchestrator.run_workflow

      Flowbots::UI.say(:ok, "Text Processing Workflow completed")
      logger.info "Text Processing Workflow completed"
    end

    private

    def prompt_for_file
      get_file_path = `gum file`.chomp.strip
      file_path = File.join(get_file_path)
      raise FlowbotError.new("File not found", "FILENOTFOUND") unless File.exist?(file_path)

      file_path
    end

    def setup_workflow
      logger.debug "Setting up workflow"
      @workflow = @orchestrator.setup_workflow("text_processing")
      logger.debug "Workflow setup completed: #{@workflow.inspect}"
    end

    def store_input_file_path
      logger.debug "Storing input file path: #{@input_file_path}"
      logger.debug "Workflow: #{@workflow.inspect}"

      begin
        sourcefile = Sourcefile.find_or_create_by_path(@input_file_path, workflow: @workflow)
        logger.debug "Sourcefile created or found: #{sourcefile.inspect}"

        if sourcefile.nil?
          raise FlowbotError.new("Failed to create or find Sourcefile", "SOURCEFILE_ERROR")
        end

        @workflow.sourcefiles.add(sourcefile)
        logger.debug "Sourcefile added to workflow"
      rescue StandardError => e
        logger.error "Error storing input file path: #{e.message}"
        logger.error e.backtrace.join("\n")
        raise FlowbotError.new("Error storing input file path: #{e.message}", "STORE_INPUT_ERROR")
      end
    end
  end
end
