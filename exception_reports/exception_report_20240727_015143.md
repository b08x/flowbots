# 🤖 FlowBot Exception Report 🤖


## Summary

An error occurred during the execution of the Flowbots application, specifically in the `GrammarProcessor` class. The issue is related to the inability to find the specified parser class, resulting in a `NameError`.

## Error Details

### Class and Message

- Class: `Flowbots::GrammarProcessor`
- Message: "Unable to find parser class: `MarkdownTextYamlParser`".

### Backtrace

The backtrace provides information about the sequence of method calls leading up to the error:

- `GrammarProcessor.rb:36:in `load_grammar''`: The error occurred within the `load_grammar` method of the `GrammarProcessor` class, specifically at line 36.
- `GrammarProcessor.rb:10:in `initialize'`: The `initialize` method of the `GrammarProcessor` class was being called when the error occurred.
- `preprocess_text_file_task.rb:11:in `new'`: The error occurred when attempting to create a new instance of the `GrammarProcessor` class in the `preprocess_text_file_task.rb` file, at line 11.
- `preprocess_text_file_task.rb:11:in `execute'`: The error occurred within the `execute` method of the `PreprocessTextFileTask` class, at line 11.
- Subsequent lines in the backtrace indicate the continuation of method calls leading up to the error, involving the Jongleur library and the WorkflowOrchestrator.

## Relevant Files

### GrammarProcessor.rb

This file contains the definition of the `GrammarProcessor` class, which is responsible for loading a grammar and parsing text based on that grammar. The error occurred within the `load_grammar` method, where it attempts to load a Treetop grammar file and instantiate a parser class.

### preprocess_text_file_task.rb

This file defines the `PreprocessTextFileTask` class, which utilizes the `GrammarProcessor` to parse text files. The error occurred when creating an instance of `GrammarProcessor` with the argument `'markdown_text_yaml'`.

### WorkflowOrchestrator.rb, topic_model_trainer_workflow.rb, cli.rb, thor_ext.rb`:

These files are also relevant to the workflow execution and error context but do not contain the direct source of the error. They provide additional information about the Flowbots application and its functionality.

## Suggested Action Items

1. Review the `GrammarProcessor` class and ensure that the specified parser class (`MarkdownTextYamlParser`) is defined correctly and located in the expected file path.
2. Verify that the necessary Treetop grammar file exists and is accessible by the application.
3. Examine the backtrace to identify any potential issues or unexpected behavior within the method calls leading up to the error.
4. Consider implementing additional error handling or logging mechanisms to capture and diagnose similar issues more effectively in the future.


## Exception Details

- **Class:** Flowbots::GrammarProcessor
- **Message:** Unable to find parser class: MarkdownTextYamlParser

          raise NameError, "Unable to find parser class: #{parser_class_name}"
          ^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:36:in `load_grammar'
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:10:in `initialize'
/home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:11:in `new'
/home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:11:in `execute'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `block (2 levels) in run_descendants'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `fork'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:205:in `block in run_descendants'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:158:in `block in each_descendant'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:156:in `each'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:156:in `each_descendant'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/implementation.rb:198:in `run_descendants'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:173:in `block in run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `loop'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/jongleur-1.1.1/lib/jongleur/api.rb:169:in `run'
/home/b08x/Workspace/flowbots/lib/components/WorkflowOrchestrator.rb:44:in `run_workflow'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:88:in `block in process_batch'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:86:in `each'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:86:in `process_batch'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:79:in `block in process_files'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:72:in `times'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:72:in `process_files'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:23:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:56:in `train_topic_model'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```

If you need more information, please check the logs or contact the development team.
