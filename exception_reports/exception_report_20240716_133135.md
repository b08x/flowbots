# 🤖 FlowBot Exception Report 🤖


## Error Report: Flowbots CLI - Type Error

**Summary:** 

The Flowbots CLI encountered a type error during the text processing workflow execution. The error message indicates that a `nil` value was encountered where an integer was expected.

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** can't convert nil into Integer
* **Backtrace:** The primary error originates from the `jongleur` gem, specifically in the `api.rb` file. The error propagates through the `WorkflowOrchestrator` and `TextProcessingWorkflow` classes.
* **Relevant Code:**  The error likely occurs during workflow definition or execution in `WorkflowOrchestrator.rb` or during task execution in `text_processing_workflow.rb`.  The specific line in `api.rb:153` suggests a potential issue with a modulo operation (`%`) where the operand is nil.
* **Potential Cause:** The root cause appears to be an unexpected `nil` value being passed as an argument to a method or operation expecting an integer. This could be due to:
    *  Incorrect data being passed to the `Jongleur::API.add_task_graph` method in `WorkflowOrchestrator.rb`.
    * An issue with task definitions or data handling within `text_processing_workflow.rb`.

**Next Steps:**

1. **Inspect `WorkflowOrchestrator.rb:42` and `text_processing_workflow.rb:71`:** Examine the code around these lines to identify what data is being passed to the `Jongleur::API` methods.
2. **Debug `jongleur/api.rb:153`:** Analyze the context of the modulo operation to determine the source of the `nil` value.
3. **Review Task Definitions:**  Ensure that the task graph defined in `text_processing_workflow.rb` is correctly structured and that all data dependencies are met.

This report provides a starting point for further investigation and debugging. 



## Exception Details

- **Class:** Flowbots::CLI
- **Message:** can't convert nil into Integer

### Backtrace

```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `%'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:153:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `sleep'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:188:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `loop'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `run'
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
