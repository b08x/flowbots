# 🤖 FlowBot Exception Report 🤖


## Summary:

An error occurred during the execution of the "Flowbots" application, specifically in the "GrammarProcessor" class. The error message indicates that the parser class "MarkdownTextYamlParser" could not be found. This issue prevented the successful preprocessing of text files and the extraction of metadata.

## Technical Details:

### Error Message:

> Unable to find parser class: MarkdownTextYamlParser

### Backtrace:

The backtrace provides information about the sequence of method calls leading up to the error:

- The error originated in the "load_grammar" method of the "GrammarProcessor" class, where the Treetop grammar file is loaded and the parser class is instantiated.
- The "initialize" method of "GrammarProcessor" calls "load_grammar" during object initialization.
- The "execute" method of the "PreprocessTextFileTask" class creates an instance of "GrammarProcessor" with the argument 'markdown_text_yaml'.
- The error is then propagated through various framework and utility classes, eventually reaching the "run_workflow" method of the "WorkflowOrchestrator" class.
- The "train_topic_model" method of the "CLI" class invokes the workflow, which ultimately triggers the error.

### Relevant Files:

- **GrammarProcessor.rb**: This file defines the "GrammarProcessor" class, which is responsible for loading Treetop grammars and creating parser objects. The error occurred within the "load_grammar" method of this class.
- **preprocess_text_file_task.rb**: This file contains the "PreprocessTextFileTask" class, which utilizes the "GrammarProcessor" to preprocess text files. The error was caught in the "execute" method of this class.
- **WorkflowOrchestrator.rb**: This file defines the "WorkflowOrchestrator" class, which manages the execution of workflows. The "run_workflow" method contains the error handling logic.
- **cli.rb**: This file implements the command-line interface (CLI) for the "Flowbots" application. The "train_topic_model" method triggers the workflow execution and captures the error.
- **thor_ext.rb**: This file provides extensions for the Thor framework, enhancing its behavior for CLI applications. It includes error handling and help message functionality.

## Suggested Action Items:

- Verify that the Treetop grammar file ("markdown_text_yaml.treetop") exists in the expected location.
- Ensure that the class name "MarkdownTextYamlParser" matches the parser class defined in the Treetop grammar file.
- Review the "load_grammar" method in "GrammarProcessor.rb" to ensure it properly handles the loading of the Treetop grammar and instantiation of the parser class.
- Consider adding additional error handling or logging mechanisms to identify and resolve similar issues more efficiently in the future.


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
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflowtest.rb:83:in `block in process_batch'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflowtest.rb:81:in `each'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflowtest.rb:81:in `process_batch'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflowtest.rb:74:in `block in process_files'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflowtest.rb:67:in `times'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflowtest.rb:67:in `process_files'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflowtest.rb:23:in `run'
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
