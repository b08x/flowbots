# 🤖 FlowBot Exception Report 🤖


## Error Report: Task Graph Implementation Error

**Summary:** 
The Flowbots application encountered an error during workflow execution. The error message "Not all the tasks in the Task Graph are implemented as WorkerTask classes" indicates a configuration issue with the workflow definition in the `text_processing_workflow.rb` file. Specifically, tasks included in the workflow graph are not defined as executable tasks within the system. 

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** Not all the tasks in the Task Graph are implemented as WorkerTask classes
* **Relevant Files:**
    * `WorkflowOrchestrator.rb`
    * `text_processing_workflow.rb`
    * `cli.rb`
    * `thor_ext.rb`

**Backtrace:**

The backtrace points to the following call stack:

1.  `Jongleur::API.run` in `WorkflowOrchestrator.rb` attempts to execute the defined workflow.
2.  `Flowbots::TextProcessingWorkflow#run_workflow` in `text_processing_workflow.rb` initiates the workflow execution.
3.  `Flowbots::CLI#process_text` in `cli.rb` handles the 'process_text' command and invokes the workflow.
4.  The error originates from `Jongleur::API.run` due to the incorrect workflow definition.

**Analysis:**

The workflow defined in `text_processing_workflow.rb` includes tasks (`NlpAnalysisTask`, `TopicModelingTask`, `LlmAnalysisTask`) that are not implemented as executable `WorkerTask` classes. This causes the `Jongleur::API.run` method to fail because it expects all tasks in the graph to have corresponding executable implementations.

**Recommended Action:**

To resolve this error:

1.  **Implement missing tasks:** Create `WorkerTask` subclasses for each missing task (`NlpAnalysisTask`, `TopicModelingTask`, `LlmAnalysisTask`) in the `text_processing_workflow.rb` file. 
2.  **Define task execution logic:** Implement the `execute` method within each new `WorkerTask` subclass to define the specific actions each task should perform.

Once these steps are completed, the workflow should execute as expected.



## Exception Details

- **Class:** Flowbots::CLI
- **Message:** Not all the tasks in the Task Graph are implemented as WorkerTask classes

### Backtrace

```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:129:in `run'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:42:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:71:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:26:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:49:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

If you need more information, please check the logs or contact the development team.
