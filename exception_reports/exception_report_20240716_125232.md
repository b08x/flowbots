# 🤖 FlowBot Exception Report 🤖


## Error Report: Unimplemented Tasks in Workflow

**Summary:** The text processing workflow failed to execute due to unimplemented tasks in the defined task graph.  The system reported that not all tasks specified in the graph are implemented as WorkerTask classes. 

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** Not all the tasks in the Task Graph are implemented as WorkerTask classes.
* **Workflow:** Text Processing Workflow (`text_processing_workflow.rb`)
* **Trigger:** `flowbots process_text <filename>` command execution. 

**Backtrace:** The error originated in `WorkflowOrchestrator.rb` during the `run_workflow` method call. The backtrace points to the following execution path:

1.  `Jongleur::API.run` in `WorkflowOrchestrator.rb`
2.  `Flowbots::TextProcessingWorkflow.run_workflow` 
3.  `Flowbots::CLI.process_text`
4.  Thor command execution (`thor-1.3.1/lib/thor/command.rb`)

**Relevant Code:**

* **`WorkflowOrchestrator.rb`**: This class is responsible for orchestrating the workflow, including adding agents, defining the workflow graph, and running the workflow.
* **`text_processing_workflow.rb`**: This file defines the Text Processing Workflow, which includes setting up the workflow graph using `@orchestrator.define_workflow(workflow_graph)`.
* **`cli.rb`**:  This file handles the `process_text` command line instruction, which initiated the workflow.

**Potential Cause:**

The error message clearly states that the workflow graph defines tasks that are not implemented as `WorkerTask` classes.  This means that while the workflow logic is defined, the actual execution units (WorkerTasks) for one or more tasks are missing.

**Next Steps:**

1. **Identify Missing Tasks:** Review the `workflow_graph` definition in `text_processing_workflow.rb` and verify that each task (NlpAnalysisTask, TopicModelingTask, LlmAnalysisTask) has a corresponding `WorkerTask` class implemented. 
2. **Implement Missing WorkerTasks:** Create the missing `WorkerTask` classes according to the required functionality of each task in the workflow.
3. **Test:** After implementing the missing `WorkerTask` classes, thoroughly test the Text Processing Workflow to ensure that it executes as expected without errors. 



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
