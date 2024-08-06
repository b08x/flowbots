# 🤖 FlowBot Exception Report 🤖


## Error Report: Uninitialized Class Variable in WorkflowOrchestrator

**Summary:** 

The application encountered a fatal error during the text processing workflow execution due to an uninitialized class variable. The `@@task_graph` class variable was referenced in the `Jongleur::API` module before it was initialized, causing the workflow to crash.

**Technical Details:**

* **Error Class:** Flowbots::CLI
* **Error Message:** uninitialized class variable @@task_graph in Jongleur::API
* **Root Cause:** The `Jongleur::API` module attempts to access the `@@task_graph` class variable before it is initialized. This suggests a potential error in the initialization order or a missing initialization step for this variable.
* **Location:** The error originates in the `WorkflowOrchestrator.rb` file, specifically on line 118 during the `initialize_jongleur_task_matrix` method call within the `run_workflow` method.
* **Backtrace:** The backtrace points to a series of nested calls originating from the command-line execution of the `process_text` command, which in turn triggers the problematic code in the `WorkflowOrchestrator`.
* **Impact:** This error prevents the successful execution of text processing workflows. 

**Relevant Files:**

* `WorkflowOrchestrator.rb`
* `text_processing_workflow.rb`
* `cli.rb`
* `command.rb`
* `thor_ext.rb`

**Recommended Action:**

Investigate the `Jongleur::API` module and the `WorkflowOrchestrator` class to determine the correct initialization procedure for the `@@task_graph` class variable. Ensure that this variable is properly initialized before any attempts to access or utilize it within the codebase. 



## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized class variable @@task_graph in Jongleur::API

      Jongleur::API.class_variable_set(:@@task_matrix, Jongleur::API.class_variable_get(:@@task_graph))
                                                                    ^^^^^^^^^^^^^^^^^^^
Did you mean?  task_matrix

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:118:in `class_variable_get'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:118:in `initialize_jongleur_task_matrix'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:65:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:23:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:76:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```

If you need more information, please check the logs or contact the development team.
