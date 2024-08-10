# Flowbots: Prompt Compression and Evaluation Workflow

Flowbots is a Ruby-based workflow orchestration system designed for compressing, testing, and evaluating AI prompts. It uses a combination of nano-bots, Redis for state management, and a series of interconnected tasks to process and analyze prompts.

## Features

- Prompt compression
- Automated test generation and execution
- Evaluation of compressed prompts
- Assessment of test results
- Final report generation in Markdown format
- Workflow orchestration with Jongleur
- State persistence using Redis

## Prerequisites

- Ruby 2.7+
- Redis server
- Nano-bots gem
- Jongleur gem
- dotenv gem
- yad (for GUI input, can be replaced with alternative input method)

## Installation

1. Clone the repository
2. Install dependencies: `bundle install`
3. Set up your environment variables in `docker/.env`

## Usage

Run the main script:

```
ruby path/to/your/script.rb
```

The workflow will guide you through the following steps:
1. Enter a prompt for compression
2. Compress the prompt
3. Generate and run tests for the compressed prompt
4. Evaluate the test results
5. Assess the overall performance
6. Generate a final report

## Components

### WorkflowAgent

Manages individual nano-bot agents for different tasks in the workflow.

### WorkflowOrchestrator

Orchestrates the entire workflow, managing the execution of tasks and the overall flow of the process.

### Tasks

- `CompressionTask`: Compresses the input prompt
- `CompressionTestTask`: Generates tests for the compressed prompt
- `RunRubyTestsTask`: Executes the generated Ruby tests
- `CompressionTestEvalTask`: Evaluates the test results
- `CompressionTestAssessmentTask`: Assesses the overall performance
- `FinalReportTask`: Generates a final report in Markdown format

## Workflow

The workflow is defined in the `workflow_graph` variable, which specifies the order of task execution:

1. CompressionTask
2. CompressionTestTask
3. RunRubyTestsTask
4. CompressionTestEvalTask
5. CompressionTestAssessmentTask
6. FinalReportTask

```mermaid
sequenceDiagram
    participant User
    participant TextProcessingWorkflow
    participant WorkflowOrchestrator
    participant UI
    participant Logger
    participant Redis
    participant FileSystem

    User->>TextProcessingWorkflow: initialize(input_file_path)
    alt input_file_path is nil
        TextProcessingWorkflow->>TextProcessingWorkflow: prompt_for_file()
        TextProcessingWorkflow->>FileSystem: Check file existence
        FileSystem-->>TextProcessingWorkflow: File exists/not exists
        alt File not found
            TextProcessingWorkflow->>TextProcessingWorkflow: Raise FlowbotError
        end
    end
    TextProcessingWorkflow->>WorkflowOrchestrator: new()

    User->>TextProcessingWorkflow: run()
    TextProcessingWorkflow->>UI: say(:ok, "Setting Up Text Processing Workflow")
    TextProcessingWorkflow->>Logger: info("Setting Up Text Processing Workflow")

    TextProcessingWorkflow->>TextProcessingWorkflow: setup_workflow()
    TextProcessingWorkflow->>Logger: debug("Setting up workflow")
    TextProcessingWorkflow->>WorkflowOrchestrator: define_workflow(workflow_graph)
    TextProcessingWorkflow->>Logger: debug("Workflow setup completed")

    TextProcessingWorkflow->>TextProcessingWorkflow: store_input_file_path()
    TextProcessingWorkflow->>Redis: set("input_file_path", @input_file_path)

    TextProcessingWorkflow->>UI: info("Running Text Processing Workflow")
    TextProcessingWorkflow->>WorkflowOrchestrator: run_workflow()

    WorkflowOrchestrator->>FileLoaderTask: execute()
    FileLoaderTask->>PreprocessTextFileTask: execute()
    PreprocessTextFileTask->>TextSegmentTask: execute()
    TextSegmentTask->>TextTokenizeTask: execute()
    TextTokenizeTask->>NlpAnalysisTask: execute()
    NlpAnalysisTask->>TopicModelingTask: execute()
    TopicModelingTask->>LlmAnalysisTask: execute()
    LlmAnalysisTask->>DisplayResultsTask: execute()

    TextProcessingWorkflow->>UI: say(:ok, "Text Processing Workflow completed")
    TextProcessingWorkflow->>Logger: info("Text Processing Workflow completed")
  ```

## Configuration

- Nano-bot cartridges are stored in the `CARTRIDGE_DIR` directory
- Redis is used for state management (configured to use database 15 by default)

## Output

The final output is a Markdown report saved as `final_report.md` in the current directory.

## Error Handling

Each task includes basic error handling, logging errors to a logger instance.

## Extending the Workflow

To add new tasks or modify the workflow:

1. Create a new task class inheriting from `Jongleur::WorkerTask`
2. Add the new task to the `workflow_graph`
3. Create appropriate nano-bot cartridges for new tasks

## Contributing

Contributions to Flowbots are welcome. Please ensure you follow the existing code style and include tests for new features.

## License

[Specify your license here]

# TextProcessingWorkflow

The TextProcessingWorkflow is a key component of the Flowbots system, designed to process and analyze text files. It orchestrates a series of tasks to extract meaningful information from the input text.

## Initialization

The workflow is initialized with an input file path. If not provided, it prompts the user to select a file.

```ruby
def initialize(input_file_path=nil)
  @input_file_path = input_file_path || prompt_for_file
  @orchestrator = WorkflowOrchestrator.new
end
```

## Main Execution

The `run` method is the main entry point for the workflow:

```ruby
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
```

## Workflow Setup

The workflow is set up with a series of tasks, each responsible for a specific part of the text processing:

```ruby
def setup_workflow
  workflow_graph = {
    FileLoaderTask: [:PreprocessTextFileTask],
    PreprocessTextFileTask: [:TextSegmentTask],
    TextSegmentTask: [:TextTokenizeTask],
    TextTokenizeTask: [:NlpAnalysisTask],
    NlpAnalysisTask: [:TopicModelingTask],
    TopicModelingTask: [:LlmAnalysisTask],
    LlmAnalysisTask: [:DisplayResultsTask],
    DisplayResultsTask: []
  }

  @orchestrator.define_workflow(workflow_graph)
end
```

## Task Sequence

1. **FileLoaderTask**: Loads the input file into the system.
2. **PreprocessTextFileTask**: Prepares the text for processing, potentially handling any special formatting or metadata.
3. **TextSegmentTask**: Breaks the text into meaningful segments or chunks.
4. **TextTokenizeTask**: Tokenizes the text segments into individual words or tokens.
5. **NlpAnalysisTask**: Performs Natural Language Processing analysis on the tokenized text.
6. **TopicModelingTask**: Identifies topics or themes within the processed text.
7. **LlmAnalysisTask**: Applies a Large Language Model for deeper analysis or generation tasks.
8. **DisplayResultsTask**: Presents the results of the analysis to the user.

## Data Flow

The workflow uses Redis for temporary storage and passing data between tasks. The input file path and the ID of the processed text file are stored in Redis:

```ruby
def store_input_file_path
  Jongleur::WorkerTask.class_variable_get(:@@redis).set("input_file_path", @input_file_path)
  file_loader = Flowbots::FileLoader.new(@input_file_path)
  textfile = file_loader.file_data
  Jongleur::WorkerTask.class_variable_get(:@@redis).set("current_textfile_id", textfile.id)
end
```

## Error Handling

The workflow includes error handling to manage exceptions that might occur during processing:

```ruby
rescue StandardError => e
  Flowbots::UI.say(:error, "Error in Text Processing Workflow: #{e.message}")
  logger.error "Error in Text Processing Workflow: #{e.message}"
  logger.error e.backtrace.join("\n")
```

## Conclusion

The TextProcessingWorkflow provides a structured approach to analyzing text documents. It combines various NLP techniques, topic modeling, and potentially advanced language model analysis to extract insights from the input text. The modular design allows for easy extension or modification of the processing steps.