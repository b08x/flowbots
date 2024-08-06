# 🤖 FlowBot Exception Report 🤖


## Error Report: Task Graph Execution Failure

**Summary:** The Flowbots application encountered an error during the execution of a text processing workflow. The error message indicates that not all tasks defined within the workflow's task graph are implemented as executable `WorkerTask` classes.

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** Not all the tasks in the Task Graph are implemented as WorkerTask classes
* **Affected Workflow:** Text Processing Workflow (`text_processing_workflow.rb`)
* **Trigger Point:** `Jongleur::API.run` call within the `WorkflowOrchestrator.run_workflow` method (`WorkflowOrchestrator.rb`)

**Backtrace:** The provided backtrace points to the line of code where the error was raised (line 129 in `jongleur/api.rb`). It traces the execution path back through the following components:

1.  `Jongleur::API.run` (jongleur gem)
2.  `WorkflowOrchestrator.run_workflow` 
3.  `TextProcessingWorkflow.run_workflow`
4.  `TextProcessingWorkflow.run`
5.  `Flowbots::CLI.process_text`
6.  Thor command execution (`thor` gem)

**Analysis:**

The error indicates a discrepancy between the workflow definition (`workflow_graph`) in `text_processing_workflow.rb` and the actual implementation of executable tasks. While the workflow defines tasks like `NlpAnalysisTask`, `TopicModelingTask`, and `LlmAnalysisTask`, it appears that at least one of these is not implemented as a `WorkerTask` subclass, preventing the Jongleur engine from executing the workflow correctly. 

**Recommendations:**

1. **Verify Task Implementations:** Examine the codebase to confirm that each task listed in the `workflow_graph` within `text_processing_workflow.rb` has a corresponding `WorkerTask` class implementation.
2. **Implement Missing Tasks:** If any tasks are missing their corresponding `WorkerTask` implementations, create them according to the required functionality of each task.
3. **Review Workflow Definition:** Double-check the `workflow_graph` definition in `text_processing_workflow.rb` for any potential typos or mismatches with the actual task class names. 

This error highlights a critical requirement for defining and executing workflows within the Flowbots application. Addressing the missing or incorrect task implementations is essential for resolving this error and ensuring the successful execution of the text processing workflow. 



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
