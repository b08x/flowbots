---
date created: "Thursday, July 4th 2024, 5:12:57 am"
date modified: "Thursday, July 11th 2024, 7:47:28 pm"
layout: page
title: Flowbots
toc: true
---



# Text Processing Workflow Documentation

This document outlines the architecture and workflow of our LLM text processing pipeline, which incorporates topic modeling and can handle both text documents and audio transcriptions.

## System Overview

Our system processes text through several phases, from initial input to LLM analysis. It uses a combination of custom Ruby classes, the Tomoto gem for topic modeling, and nano-bot cartridges for LLM analysis.

> Right, so, we take your text (or ramblings, as the case may be), and our system ruthlessly dissects it with algorithms and a sprinkle of Ruby magic.

## Workflow Phases

### 1. Workflow Initiation

``` mermaid
sequenceDiagram
    participant User as 👤 User
    participant CLI as 💻 CLI
    participant TPW as 🔄 TextProcessingWorkflow

    User->>CLI: process_text <file_path>
    CLI->>TPW: new(file_path)
    TPW->>TPW: run()
    TPW->>TPW: setup_workflow()
```

In this phase:

- The user initiates the workflow through the CLI.
- The `TextProcessingWorkflow` is created and set up.

> So, the workflow kicks off when our eager user pokes the CLI with a file. The CLI then spins up the `TextProcessingWorkflow` and gets the ball rolling.

### 2. Text Processing Phase

``` mermaid
sequenceDiagram
    participant TPW as 🔄 TextProcessingWorkflow
    participant TP as 📝 TextProcessor
    participant TS as ✂️ TextSegmenter
    participant SNLP as 🧠 SpacyNLP
    participant Redis as 🗄️ Redis

    TPW->>TP: process_file(file_path)
    TP->>TP: process(text)
    TP->>TS: new(text, options)
    TS->>TS: execute()
    alt text is array
        TS->>TS: segment_array()
    else text is string
        TS->>TS: segment_string()
    end
    TS-->>TP: return segments
    TP->>SNLP: process segments
    SNLP-->>TP: return processed segments
    TP-->>TPW: return processed_text
    TPW->>Redis: set("processed_text", processed_text.to_json)
```

Key features:

- Handles both text documents and audio transcriptions.
- Segments text using `TextSegmenter`.
- Processes text using SpacyNLP.
- Stores processed text in Redis.

> Alright, so the text processing workflow ingests text, slices and dices it into manageable chunks, then feeds it to the SpacyNLP engine for analysis. The processed output is finally stashed away in Redis for later retrieval.

### 3. Topic Modeling Phase

``` mermaid
sequenceDiagram
    participant TPW as 🔄 TextProcessingWorkflow
    participant TMT as 🔍 TopicModelingTask
    participant TMM as 📊 TopicModelManager
    participant Redis as 🗄️ Redis

    TPW->>TMT: execute()
    TMT->>Redis: get("processed_text")
    Redis-->>TMT: return raw_text
    TMT->>TMT: JSON.parse(raw_text)
    TMT->>TMM: new(model_path)
    alt model not trained
        TMT->>TMM: train_model(processed_text)
        TMM-->>TMT: model trained
    end
    TMT->>TMM: infer_topics(text)
    TMM-->>TMT: return topics
    TMT->>Redis: set("topics", topics.to_json)
```

Key features:

- Loads or creates a topic model using `TopicModelManager`.
- Trains the model if necessary.
- Infers topics from the processed text.
- Stores inferred topics in Redis.

> Ah, the Topic Modeling Phase. Where we sift through the textual muck to unearth those shimmering nuggets of thematic gold. It's like panning for gold, but instead of a pan, we have a TopicModelManager, and instead of gold, we have, well, topics.

#### Modular Topic Modeling

We've refactored the `TopicModelingTask` into a separate, reusable module. This improves the modularity of our code and allows for easier maintenance and potential reuse in other parts of the application.

##### Topic Modeling Module

The topic modeling functionality is now encapsulated in a separate module:

``` ruby
# lib/modules/topic_modeling.rb

module TopicModeling
  class TopicModelingTask < Jongleur::WorkerTask
    def initialize(model_path:, redis_client: nil)
      @model_path = model_path
      @redis_client = redis_client
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    def execute
      @logger.info "Starting TopicModelingTask"

      begin
        raw_text = get_processed_text
        @logger.debug "Retrieved processed text from Redis (length): #{raw_text.length}"
        
        processed_text = JSON.parse(raw_text)
        @logger.debug "Parsed processed text (length): #{processed_text.length}"
        
        topic_modeler = TopicModelManager.new(@model_path)
        @logger.debug "Created TopicModelManager instance"
        
        # Train the model if it's not already trained
        unless topic_modeler.model_trained?
          @logger.info "Model is not trained. Training now..."
          begin
            topic_modeler.train_model(processed_text)
            @logger.info "Model training completed"
          rescue StandardError => e
            @logger.error "Error during model training: #{e.message}"
            raise
          end
        else
          @logger.info "Model is already trained"
        end
        
        @logger.debug "Inferring topics"
        begin
          topics_info = topic_modeler.infer_topics(processed_text.join(" "), 5)
          @logger.info "Most probable topic: #{topics_info[:most_probable_topic]}"
          @logger.info "Top words: #{topics_info[:top_words].map { |word, prob| word }.join(', ')}"
          @logger.debug "Full topic distribution: #{topics_info[:topic_distribution]}"
        
          store_topics_info(topics_info)
          @logger.debug "Stored topics info in Redis"
        rescue StandardError => e
          @logger.error "Error during topic inference: #{e.message}"
          raise
        end
        
        @logger.info "TopicModelingTask completed"
      rescue StandardError => e
        @logger.error "Error in TopicModelingTask: #{e.message}"
        @logger.error e.backtrace.join("\n")
        raise
      end
    end

    private

    def get_processed_text
      redis = @redis_client || Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.get("processed_text")
    end

    def store_topics_info(topics_info)
      redis = @redis_client || Jongleur::WorkerTask.class_variable_get(:@@redis)
      redis.set("topics_info", topics_info.to_json)
    end
  end
end
```

#### Integration with Workflow

To use this modular `TopicModelingTask` in your workflow, update the `TextProcessingWorkflow` class:

``` ruby
# lib/workflows/text_processing_workflow.rb

require_relative '../modules/topic_modeling'

class TextProcessingWorkflow
  def initialize(input_file_path)
    # ... [other initializations] ...
    @topic_modeling_task = TopicModeling::TopicModelingTask.new(
      model_path: File.join(ENV["HOME"], "Workspace", "flowbots", "models", "topic_model.lda.bin"),
      redis_client: Jongleur::WorkerTask.class_variable_get(:@@redis)
    )
  end

  def run
    # ... [other steps] ...
    @topic_modeling_task.execute
    # ... [remaining steps] ...
  end

  # ... [rest of the class]
end
```

> So, we've tidied up the code and tucked away the topic modeling bits into their own module.

### 4. LLM Analysis Phase

``` mermaid
sequenceDiagram
    participant TMT as 🔍 TopicModelingTask
    participant AAT as 🔬 LLMAnalysisTask
    participant Redis as 🗄️ Redis

    TMT->>AAT: execute()
    AAT->>Redis: get("processed_text")
    AAT->>Redis: get("topics")
    Redis-->>AAT: return processed_text and topics
    AAT->>AAT: perform LLM analysis
    AAT->>Redis: set("analysis_result", analysis_result.to_json)
```

Key features:

- Retrieves processed text and topics from Redis.
- Performs LLM analysis using a nano-bot cartridge.
- Stores analysis results in Redis.

> The LLM Analysis Task, digs through the processed text and topics from Redis and performs its assigned LLM analysis. The results, hopefully useful, are then sent back to the Redis storehouse.

### 5. (Placeholder For Additional Workflow Task)

``` mermaid
sequenceDiagram
    participant PreviousTask as Previous Task
    participant NewTask as 🆕 New Workflow Task
    participant Redis as 🗄️ Redis

    PreviousTask->>NewTask: execute()
    NewTask->>Redis: get required data
    Redis-->>NewTask: return data
    NewTask->>NewTask: perform new task
    NewTask->>Redis: set("new_task_result", result.to_json)
```

This placeholder diagram illustrates how an additional task could be integrated into the workflow. The new task would:

- Be triggered by the previous task.
- Retrieve necessary data from Redis.
- Perform its specific function.
- Store its results back in Redis.

> Alright, so let's say the previous task was baking a cake. This new task, it's like adding the frosting. It takes the cake from the previous step, grabs the frosting recipe (that's the Redis part), and then, well, you get your frosted cake. Basically, it's just saying that a new task would grab data, do its thing, and then update Redis.

### Literal Summary

The text describes a placeholder in a workflow labeled "future development." This section lacks concrete implementation details. The text uses an analogy to explain the placeholder's intended function: a task retrieves data, processes it, and updates a Redis database. The analogy compares this process to frosting a cake, where the cake represents the data from the previous step, the frosting recipe represents data fetched from Redis, and the act of frosting represents the data processing and update.

### Ironically Literal Figurative Language Summary

The text doesn't actually bake any cakes. It's disappointing, I know. There is no delicious frosting involved, only cold, hard data. And while the text mentions "grabbing" things, no physical grabbing occurs. This "grabbing" is a metaphor, representing data retrieval, not a strongman competition. It's all very metaphorical and not at all delicious.

# TODO..

this section:

## Usage

- ☐ dockerize and document....

1.  Ensure all required gems and dependencies are installed.

2.  Prepare your input text file or audio transcription.

3.  Run the workflow using the CLI:

    ``` bash
    flowbots process_text path/to/your/input/file.txt
    ```

4.  The system will process the text, perform topic modeling, and conduct LLM analysis.

5.  Results will be stored in Redis and can be retrieved for further use or display.

## Extending the Workflow

To add a new task to the workflow:

1.  Create a new task class that inherits from `Jongleur::WorkerTask`.

``` ruby
class Your < Jongleur::WorkerTask

    def execute
        puts "yes! a task!"
    end

end
```

2.  Update the `WorkflowOrchestrator` to include the new task in the workflow graph.
3.  If necessary, modify the `TextProcessingWorkflow` class to accommodate the new task.

Example of adding a new task to the workflow graph:

``` ruby
workflow_graph = {
  TextProcessingTask: [:TopicModelingTask],
  TopicModelingTask: [:LLMAnalysisTask],
  LLMAnalysisTask: [:NewTask],  # Add this line
  NewTask: []  # Add this line
}
```

This flexible architecture allows for expansion of the workflow to include additional processing or analysis steps as needed.

------------------------------------------------------------------------

# DevOps Enhancements for the Text Processing Workflow

This response focuses on providing practical DevOps solutions for the given text processing workflow, incorporating best practices and industry standards.

**Key Areas of Improvement:**

- **Configuration Management:** Implement environment-based configuration for flexibility.
- **Containerization (Docker):** Package the application and its dependencies for consistent execution.
- **CI/CD Pipeline (GitHub Actions):** Automate testing, building, and deploying the application.
- **Monitoring and Logging:** Gain insights into application performance and identify potential issues.
- **Security:** Address potential vulnerabilities in Redis and data handling.

## 1. Configuration Management

**Problem:** Hardcoded paths and settings within the codebase make it difficult to manage different environments (development, testing, production).

**Solution:** Utilize environment variables and a configuration file to externalize settings.

**Example:**

1.  **Create a configuration file (e.g., `config/application.yml`)**:

``` yaml
development:
  redis_host: localhost
  redis_port: 6379
  model_path: "#{ENV['HOME']}/Workspace/flowbots/models/topic_model.lda.bin"
production:
  redis_host: redis.example.com
  redis_port: 6380
  model_path: /app/models/topic_model.lda.bin
```

2.  **Load configuration in your Ruby code:**

``` ruby
require 'yaml'

config = YAML.load_file('config/application.yml')[ENV['RAILS_ENV'] || 'development']

# Access configuration values
redis_host = config['redis_host']
model_path = config['model_path']
```

## 2. Containerization with Docker

**Problem:** Dependency management and ensuring consistent execution across environments can be challenging.

**Solution:** Create a Docker image for the application.

**Example (Dockerfile):**

``` dockerfile
FROM ruby:3.1

RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install spacy
RUN python3 -m spacy download en_core_web_sm

RUN gem install ruby-spacy sinatra

WORKDIR /app
COPY ./app/spacy_server.rb /app/

CMD ["ruby", "spacy_server.rb"]
```

Create a `Dockerfile.workflow` for your main workflow:

``` dockerfile
FROM ruby:3.1

RUN gem install redis

WORKDIR /app
COPY ./app /app

CMD ["ruby", "main.rb"]
```

    project_root/
    ├── docker-compose.yml
    ├── Dockerfile
    ├── Dockerfile.workflow
    └── app/
        ├── main.rb
        ├── spacy_server.rb
        └── [other Ruby files]

``` mermaid
sequenceDiagram
    participant TPW as 🔄 TextProcessingWorkflow
    participant TP as 📝 TextProcessor
    participant TS as ✂️ TextSegmenter
    participant RubySpacy as 🐳 Ruby-Spacy Service
    participant Redis as 🗄️ Redis Service

    TPW->>TP: process_file(file_path)
    TP->>TP: process(text)
    TP->>TS: new(text, options)
    TS->>TS: execute()
    alt text is array
        TS->>TS: segment_array()
    else text is string
        TS->>TS: segment_string()
    end
    TS-->>TP: return segments
    TP->>RubySpacy: POST /process (segments)
    RubySpacy-->>TP: return processed segments
    TP-->>TPW: return processed_text
    TPW->>Redis: set("processed_text", processed_text.to_json)
```

### Usage with Docker Compose

To use this system with Docker Compose:

1.  Ensure Docker and Docker Compose are installed on your system.

2.  Navigate to your project root directory.

3.  Build and start the services:

    `docker-compose up --build`

4.  In a new terminal, run the workflow:

    `docker-compose run workflow ruby main.rb path/to/your/input/file.txt`

    Note: Make sure `path/to/your/input/file.txt` is within the `./app` directory or adjust the volume mapping in `docker-compose.yml` accordingly.

The system will now use the Dockerized versions of ruby-spacy and Redis for text processing and data storage, ensuring consistency and ease of deployment across different environments.

## 3. CI/CD Pipeline with GitHub Actions

**Problem:** Manual testing and deployment processes are time-consuming and error-prone.

**Solution:** Implement a CI/CD pipeline using GitHub Actions.

**Example (.github/workflows/ci-cd.yml):**

``` yaml
name: CI/CD Pipeline

on: [push]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 2.7
      - name: Install dependencies
        run: bundle install
      - name: Run tests
        run: bundle exec rspec

  build-and-push-image:
    needs: build-and-test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Login to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
```

> Right, because flowery language is to DevOps as a floppy disk is to a supercomputer
