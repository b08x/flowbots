# Flowbots

Flowbots is an advanced text processing and analysis system that combines the power of [ruby-nano-bots](https://github.com/icebaker/ruby-nano-bots.git), [workflow orchestration](https://gitlab.com/RedFred7/Jongleur.git), and natural language processing to provide a flexible and powerful tool for document analysis and topic modeling.

## Features

- Text processing workflows for individual files and batch processing
- Advanced NLP methods including tokenization, part-of-speech tagging, and named entity recognition
- Topic modeling with dynamic model training and inference
- Flexible workflow system using Jongleur for task orchestration
- Redis-based data persistence using Ohm models
- Custom nano-bot cartridges for specialized AI-powered tasks
- Robust error handling and logging system

## System Architecture

### Class Diagram

```mermaid
classDiagram
    class CLI {
        +version()
        +workflows()
        +train_topic_model(folder)
        +process_text(file)
    }

    class Workflows {
        -prompt: TTY::Prompt
        +list_and_select()
        +run(workflow_name)
        -get_workflows()
        -display_workflows(workflows)
        -select_workflow(workflows)
        -extract_workflow_description(file)
    }

    class WorkflowOrchestrator {
        -agents: Map
        +add_agent(role, cartridge_file)
        +define_workflow(workflow_definition)
        +run_workflow()
    }

    class WorkflowAgent {
        -role: String
        -state: Map
        -bot: NanoBot
        +process(input)
        +save_state()
        +load_state()
    }

    class Task {
        <<abstract>>
        +execute()
    }

    class TextProcessingWorkflow {
        -input_file_path: String
        -orchestrator: WorkflowOrchestrator
        +run()
    }

    class TopicModelTrainerWorkflow {
        -input_folder_path: String
        -orchestrator: WorkflowOrchestrator
        +run()
    }

    class TextProcessor {
        <<abstract>>
        +process(text)
    }

    class NLPProcessor {
        -nlp_model: Object
        +process(segment, options)
    }

    class TopicModelProcessor {
        -model_path: String
        -model: Object
        -model_params: Map
        +load_or_create_model()
        +train_model(documents, iterations)
        +infer_topics(document)
    }

    class FileLoader {
        -file_data: Textfile
        +initialize(file_path)
    }

    class Textfile {
        +path: String
        +name: String
        +content: String
        +preprocessed_content: String
        +metadata: Map
        +topics: Set~Topic~
        +segments: List~Segment~
        +lemmas: List~Lemma~
    }

    class Segment {
        +text: String
        +tokens: List
        +tagged: Map
        +words: List~Word~
    }

    class Word {
        +word: String
        +pos: String
        +tag: String
        +dep: String
        +ner: String
    }

    class Topic {
        +name: String
        +description: String
        +vector: List
    }

    CLI --> Workflows : uses
    Workflows --> TextProcessingWorkflow : runs
    Workflows --> TopicModelTrainerWorkflow : runs
    TextProcessingWorkflow --> WorkflowOrchestrator : uses
    TopicModelTrainerWorkflow --> WorkflowOrchestrator : uses
    WorkflowOrchestrator --> WorkflowAgent : manages
    WorkflowOrchestrator --> Task : executes
    Task <|-- FileLoaderTask
    Task <|-- PreprocessTextFileTask
    Task <|-- TextSegmentTask
    Task <|-- TokenizeSegmentsTask
    Task <|-- NlpAnalysisTask
    Task <|-- TopicModelingTask
    Task <|-- LlmAnalysisTask
    Task <|-- DisplayResultsTask
    TextProcessor <|-- NLPProcessor
    TextProcessor <|-- TopicModelProcessor
    NlpAnalysisTask --> NLPProcessor : uses
    TopicModelingTask --> TopicModelProcessor : uses
    FileLoaderTask --> FileLoader : uses
    Textfile "1" *-- "many" Segment
    Segment "1" *-- "many" Word
    Textfile "1" *-- "many" Topic
    Textfile "1" *-- "many" Lemma
```

## Project Structure

The Flowbots project is organized into several key directories:

- `/lib`: Main application code
  - `/components`: Core system components
  - `/processors`: Text and NLP processors
  - `/tasks`: Individual workflow tasks
  - `/workflows`: Workflow definitions
  - `/ohm`: Ohm model definitions
  - `/utils`: Utility functions and classes
- `/nano-bots/cartridges`: Nano-bot cartridge definitions
- `/test`: Test files and test helpers
- `/log`: Log files

## Key Components

1. **CLI**: The main entry point for user interaction, allowing users to select and run workflows.
2. **WorkflowOrchestrator**: Manages the execution of workflows and their constituent tasks.
3. **Task Processors**: Specialized classes for text processing, NLP analysis, and topic modeling.
4. **Ohm Models**: Data persistence layer for storing document information and workflow states.
5. **NanoBot Integration**: Utilizes nano-bot cartridges for specialized AI-powered tasks.
6. **Logging System**: Comprehensive logging for debugging and monitoring.


# Detailed Operation

## 1. Workflow Initialization

When a user selects a workflow through the CLI, the system initializes the chosen workflow (e.g., TextProcessingWorkflow or TopicModelTrainerWorkflow). The WorkflowOrchestrator sets up the task graph based on the workflow definition.

## 2. Task Execution

The WorkflowOrchestrator executes tasks in the defined order. Each task follows a similar pattern:

1. Retrieve necessary data from Redis or Ohm models.
2. Process the data using specialized processors (e.g., NLPProcessor, TopicModelProcessor).
3. Store the results back in Redis (for temporary storage) or Ohm models (for persistence).

## 3. Data Flow

- Redis is used for storing temporary data and passing information between tasks. This includes file IDs, current batch information, and intermediate processing results.
- Ohm models, backed by Redis, are used for persistent storage of document information, segments, tokens, and analysis results.

## 4. NLP and Topic Modeling

- The NlpAnalysisTask uses the ruby-spacy gem to perform tasks like tokenization, part-of-speech tagging, and named entity recognition.
- The TopicModelingTask uses the tomoto gem to implement topic modeling algorithms.

## 5. LLM Integration

The LlmAnalysisTask integrates with external language models through the NanoBot system. This allows for high-level analysis and insights generation based on the processed text data.

## 6. Error Handling and Logging

Each task and the WorkflowOrchestrator include error handling mechanisms. Errors are caught, logged, and in some cases, trigger the ExceptionAgent for detailed error analysis.

## 7. Batch Processing

For the TopicModelTrainerWorkflow, files are processed in batches. The WorkflowOrchestrator manages the batch state, ensuring all files in a batch are processed before moving to the next batch.

## 8. Result Presentation

The DisplayResultsTask formats the analysis results and presents them to the user through the CLI. This may include summaries, topic distributions, and insights generated by the LLM.

## Key Interactions

1. **CLI <-> WorkflowOrchestrator**: The CLI initiates workflow execution and receives final results.
2. **WorkflowOrchestrator <-> Tasks**: The orchestrator manages task execution order and handles task results.
3. **Tasks <-> Redis**: Tasks use Redis for short-term storage and inter-task communication.
4. **Tasks <-> Ohm Models**: Tasks interact with Ohm models for persistent storage of document data and analysis results.
5. **NLP and Topic Modeling Tasks <-> External Libraries**: These tasks utilize external Ruby gems for specialized processing.
6. **LlmAnalysisTask <-> NanoBot**: This task interacts with the NanoBot system to leverage external language models.

This architecture allows Flowbots to process text data through a series of specialized tasks, each building upon the results of previous tasks, to provide comprehensive text analysis and insights.


# Ruby Gems Used in Flowbots

## Workflow and Task Management

- [jongleur](https://rubygems.org/gems/jongleur): Core component for defining and executing task workflows, providing workflow orchestration and task management capabilities.

## Data Persistence

- [ohm](https://rubygems.org/gems/ohm): Object-hash mapping for Redis, used as the data persistence layer for storing document information and workflow states.

## Parallel Processing

- [parallel](https://rubygems.org/gems/parallel): Enables parallel processing, with potential use for parallel execution of tasks (not prominently used in the current implementation).

## Development and Debugging

- [pry](https://rubygems.org/gems/pry) and [pry-stack_explorer](https://rubygems.org/gems/pry-stack_explorer): Enhanced REPL and debugging tools for development and debugging purposes.

## Natural Language Processing

- [ruby-spacy](https://rubygems.org/gems/ruby-spacy): Ruby bindings for the Spacy NLP library, used for Natural Language Processing tasks.
- [lingua](https://rubygems.org/gems/lingua): Provides additional natural language detection and processing capabilities.
- [pragmatic_segmenter](https://rubygems.org/gems/pragmatic_segmenter): Used for text segmentation, splitting text into meaningful segments.
- [pragmatic_tokenizer](https://rubygems.org/gems/pragmatic_tokenizer): Handles text tokenization, breaking text into individual tokens.

## Command-Line Interface

- [thor](https://rubygems.org/gems/thor): Used for building command-line interfaces, specifically for creating the CLI for Flowbots.

## Parsing and Data Handling

- [treetop](https://rubygems.org/gems/treetop): A parsing expression grammar (PEG) parser generator, used for custom grammar parsing, particularly for Markdown with YAML front matter.
- [yaml](https://rubygems.org/gems/yaml): Handles YAML parsing and generation, particularly for configuration files and document front matter.

## Terminal Output Formatting

- [tty-box](https://rubygems.org/gems/tty-box), [tty-cursor](https://rubygems.org/gems/tty-cursor), [tty-prompt](https://rubygems.org/gems/tty-prompt), [tty-screen](https://rubygems.org/gems/tty-screen), [tty-spinner](https://rubygems.org/gems/tty-spinner), [tty-table](https://rubygems.org/gems/tty-table): Various terminal output formatting and interaction tools for creating rich command-line interfaces and displaying formatted output.

## Topic Modeling

- [tomoto](https://rubygems.org/gems/tomoto): Used for implementing topic modeling algorithms.
