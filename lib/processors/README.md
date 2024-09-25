# Task Processors

Flowbots uses a variety of task processors to handle different aspects of text processing and analysis. These processors are modular and can be combined in workflows to create complex text processing pipelines.

## Key Task Processors

1. **FileLoaderTask**
   - Loads input files into the system.
   - Stores file content in Ohm models for further processing.

2. **PreprocessTextFileTask**
   - Extracts metadata from file content (e.g., YAML front matter in Markdown files).
   - Preprocesses the main content for further analysis.

3. **TextSegmentTask**
   - Splits preprocessed text into manageable segments.
   - Uses the `TextSegmentProcessor` for actual segmentation logic.

4. **TokenizeSegmentsTask**
   - Breaks down text segments into individual tokens.
   - Uses the `TextTokenizeProcessor` for tokenization.

5. **NlpAnalysisTask**
   - Performs various NLP tasks on tokenized segments.
   - Includes part-of-speech tagging, dependency parsing, and named entity recognition.
   - Uses the `NLPProcessor` which wraps the Spacy library for NLP operations.

6. **FilterSegmentsTask**
   - Filters processed segments based on predefined criteria.
   - Removes irrelevant or low-quality segments to improve analysis quality.

7. **TopicModelingTask**
   - Infers topics from processed text segments.
   - Uses the `TopicModelProcessor` which implements topic modeling algorithms.

8. **LlmAnalysisTask**
   - Utilizes a language model (via NanoBot) to generate insights about the text.
   - Provides high-level analysis and summarization of the processed content.

9. **DisplayResultsTask**
   - Formats and displays the results of the text processing and analysis pipeline.

## Task Processor Architecture

Each task processor:

1. Inherits from `Jongleur::WorkerTask` or `Flowbots::BaseTask`.
2. Implements an `execute` method that performs the core task logic.
3. Uses Redis for temporary data storage and passing data between tasks.
4. Interacts with Ohm models for persistent data storage.
5. Includes error handling and logging for robust execution.

## Extensibility

The task processor system is designed to be easily extensible:

- New task processors can be added by creating new classes inheriting from `Jongleur::WorkerTask` or `Flowbots::BaseTask`.
- Existing task processors can be modified or extended to support new functionality.
- Task processors can be combined in different ways within workflows to create custom text processing pipelines.

This modular design allows Flowbots to adapt to various text processing and analysis requirements.
