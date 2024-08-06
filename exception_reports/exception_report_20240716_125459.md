# 🤖 FlowBot Exception Report 🤖


## Error Report: Task Graph Implementation Error

**Summary:** 
The Flowbots application encountered an error during workflow execution. The error message "Not all the tasks in the Task Graph are implemented as WorkerTask classes" indicates that the defined workflow graph references tasks that are not properly defined as executable tasks within the system.

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** Not all the tasks in the Task Graph are implemented as WorkerTask classes
* **Relevant Code:**
    * `text_processing_workflow.rb`: This file defines the workflow graph with tasks: `NlpAnalysisTask`, `TopicModelingTask`, and `LlmAnalysisTask`. At least one of these tasks is not implemented as a `WorkerTask` subclass.
    * `WorkflowOrchestrator.rb`: This class is responsible for defining and running workflows. It interacts with the `Jongleur::API` to manage the task graph. 
* **Backtrace:** The backtrace points to the following execution flow:
    1.  `Jongleur::API.run` in `WorkflowOrchestrator.rb` attempts to execute the workflow.
    2.  The error originates in `Jongleur::API.add_task_graph`, indicating an issue with the task graph definition.
    3.  The workflow execution was initiated by the `process_text` method in `cli.rb`.

**Potential Causes:**

* **Missing Task Implementation:** One or more of the tasks listed in `text_processing_workflow.rb` (NlpAnalysisTask, TopicModelingTask, LlmAnalysisTask) is not defined as a subclass of `Jongleur::WorkerTask`, preventing the workflow engine from executing them.
* **Incorrect Task Registration:** The tasks might be implemented correctly but not registered with the `Jongleur::API` or are registered with incorrect dependencies.

**Next Steps:**

1. **Verify Task Implementations:**  Confirm that each task in the `text_processing_workflow.rb` file has a corresponding class definition that inherits from `Jongleur::WorkerTask`.
2. **Check Task Registration:** Ensure that each task class is correctly registered with the `Jongleur::API`, and the defined dependencies in the workflow graph are accurate.
3. **Test Task Execution:** Independently test the execution of each task to isolate any issues within their implementations. 



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
