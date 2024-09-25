# Workflows

Flowbots uses a flexible workflow system to orchestrate various text processing and analysis tasks. The two main workflows defined in the project are:

1. TextProcessingWorkflow
2. TopicModelTrainerWorkflow

## TextProcessingWorkflow

This workflow is designed to process a single text file through a series of tasks.

```mermaid
stateDiagram-v2
    [*] --> Initialized
    Initialized --> PromptingForFile: No file path provided
    PromptingForFile --> FileSelected: User selects file
    Initialized --> FileSelected: File path provided
    FileSelected --> ProcessingFile: Start processing
    ProcessingFile --> TextTagging: File processed
    TextTagging --> TopicModeling: Tagging complete
    TopicModeling --> LlmAnalysis: Modeling complete
    LlmAnalysis --> DisplayingResults: Analysis complete
    DisplayingResults --> [*]: Workflow complete

    state ProcessingFile {
        [*] --> LoadingFile
        LoadingFile --> PreprocessingFile
        PreprocessingFile --> SegmentingText
        SegmentingText --> TokenizingText
        TokenizingText --> [*]
    }

    DisplayingResults --> ErrorState: Error occurs
    ProcessingFile --> ErrorState: Error occurs
    TextTagging --> ErrorState: Error occurs
    TopicModeling --> ErrorState: Error occurs
    LlmAnalysis --> ErrorState: Error occurs
    ErrorState --> [*]: Log error and exit
```

#### Key Steps:

1. **File Loading**: Loads the input file into the system.
2. **Preprocessing**: Extracts metadata and preprocesses the text content.
3. **Text Segmentation**: Splits the text into manageable segments.
4. **Tokenization**: Breaks down segments into individual tokens.
5. **NLP Analysis**: Performs part-of-speech tagging, dependency parsing, and named entity recognition.
6. **Topic Modeling**: Infers topics from the processed text.
7. **LLM Analysis**: Uses a language model to generate insights about the text.
8. **Result Display**: Presents the analysis results to the user.

## TopicModelTrainerWorkflow

This workflow is designed to process multiple files in batches and train a topic model.

#### Key Steps:

1. **Batch Processing**: Processes files in batches of a defined size.
2. **File Loading**: Loads each file in the batch.
3. **Preprocessing**: Extracts metadata and preprocesses each file's content.
4. **Text Segmentation**: Splits each file's content into segments.
5. **Tokenization**: Breaks down segments into tokens.
6. **NLP Analysis**: Performs NLP tasks on the tokenized segments.
7. **Filtering**: Filters segments based on predefined criteria.
8. **Accumulation**: Accumulates filtered segments across all processed files.
9. **Topic Model Training**: Trains a topic model using the accumulated segments.

## Workflow Execution

Both workflows use the `WorkflowOrchestrator` class to manage task execution. The orchestrator:

1. Initializes the workflow and its tasks.
2. Sets up the task graph based on the workflow definition.
3. Executes tasks in the defined order.
4. Manages data flow between tasks using Redis for temporary storage.
5. Handles errors and exceptions during workflow execution.

## Workflow Flexibility

The workflow system is designed to be flexible and extensible:

- New workflows can be easily added by creating new workflow classes.
- Existing workflows can be modified by adding, removing, or reordering tasks.
- Tasks are modular and can be reused across different workflows.

This flexibility allows Flowbots to adapt to various text processing and analysis needs.

```mermaid
sequenceDiagram
    participant User
    participant TextProcessingWorkflow
    participant UnifiedFileProcessingPipeline
    participant WorkflowOrchestrator
    participant TextTaggerTask
    participant TopicModelingTask
    participant LlmAnalysisTask
    participant DisplayResultsTask
    participant Logger
    participant UI

    User->>TextProcessingWorkflow: Initialize with file path
    alt No file path provided
        TextProcessingWorkflow->>User: Prompt for file
        User->>TextProcessingWorkflow: Provide file path
    end
    TextProcessingWorkflow->>UnifiedFileProcessingPipeline: Initialize
    TextProcessingWorkflow->>Logger: Log workflow start
    TextProcessingWorkflow->>UI: Display workflow start message
    TextProcessingWorkflow->>UnifiedFileProcessingPipeline: Process
    UnifiedFileProcessingPipeline-->>TextProcessingWorkflow: Processing complete
    TextProcessingWorkflow->>WorkflowOrchestrator: Define additional tasks
    TextProcessingWorkflow->>WorkflowOrchestrator: Run workflow
    WorkflowOrchestrator->>TextTaggerTask: Execute
    TextTaggerTask-->>WorkflowOrchestrator: Task complete
    WorkflowOrchestrator->>TopicModelingTask: Execute
    TopicModelingTask-->>WorkflowOrchestrator: Task complete
    WorkflowOrchestrator->>LlmAnalysisTask: Execute
    LlmAnalysisTask-->>WorkflowOrchestrator: Task complete
    WorkflowOrchestrator->>DisplayResultsTask: Execute
    DisplayResultsTask-->>WorkflowOrchestrator: Task complete
    WorkflowOrchestrator-->>TextProcessingWorkflow: Workflow complete
    TextProcessingWorkflow->>Logger: Log workflow completion
    TextProcessingWorkflow->>UI: Display completion message
    TextProcessingWorkflow-->>User: Workflow finished
```

```mermaid
sequenceDiagram
    actor User
    participant CLI
    participant TextProcessingWorkflow
    participant WorkflowOrchestrator
    participant FileLoaderTask
    participant PreprocessTextFileTask
    participant TextSegmentTask
    participant TokenizeSegmentsTask
    participant NlpAnalysisTask
    participant TopicModelingTask
    participant LlmAnalysisTask
    participant DisplayResultsTask
    participant Redis
    participant Textfile

    User->>CLI: process_text(file)
    activate CLI
    CLI->>TextProcessingWorkflow: new(input_file_path)
    activate TextProcessingWorkflow
    TextProcessingWorkflow->>WorkflowOrchestrator: define_workflow()
    TextProcessingWorkflow->>WorkflowOrchestrator: run_workflow()
    activate WorkflowOrchestrator
    WorkflowOrchestrator->>FileLoaderTask: execute()
    activate FileLoaderTask
    FileLoaderTask->>Redis: set("current_textfile_id", id)
    FileLoaderTask->>Textfile: create
    deactivate FileLoaderTask
    WorkflowOrchestrator->>PreprocessTextFileTask: execute()
    activate PreprocessTextFileTask
    PreprocessTextFileTask->>Textfile: update(preprocessed_content, metadata)
    deactivate PreprocessTextFileTask
    WorkflowOrchestrator->>TextSegmentTask: execute()
    activate TextSegmentTask
    TextSegmentTask->>Textfile: add_segments()
    deactivate TextSegmentTask
    WorkflowOrchestrator->>TokenizeSegmentsTask: execute()
    activate TokenizeSegmentsTask
    TokenizeSegmentsTask->>Textfile: update segments
    deactivate TokenizeSegmentsTask
    WorkflowOrchestrator->>NlpAnalysisTask: execute()
    activate NlpAnalysisTask
    NlpAnalysisTask->>Textfile: update segments with NLP data
    deactivate NlpAnalysisTask
    WorkflowOrchestrator->>TopicModelingTask: execute()
    activate TopicModelingTask
    TopicModelingTask->>Textfile: add_topics()
    deactivate TopicModelingTask
    WorkflowOrchestrator->>LlmAnalysisTask: execute()
    activate LlmAnalysisTask
    LlmAnalysisTask->>Textfile: update(analysis)
    deactivate LlmAnalysisTask
    WorkflowOrchestrator->>DisplayResultsTask: execute()
    activate DisplayResultsTask
    DisplayResultsTask->>Textfile: retrieve data
    DisplayResultsTask-->>User: display results
    deactivate DisplayResultsTask
    deactivate WorkflowOrchestrator
    TextProcessingWorkflow-->>CLI: workflow completed
    deactivate TextProcessingWorkflow
    CLI-->>User: display completion message
    deactivate CLI
```
