# 🤖 FlowBot Exception Report 🤖


## Summary:

An error occurred during the execution of the "Flowbots" application, specifically within the "GrammarProcessor" class. The issue is due to an inability to locate the specified parser class, resulting in a "NameError".

## Error Details:

Class: Flowbots::GrammarProcessor
Message: Unable to find parser class: MarkdownTextYamlParser

## Backtrace:

The backtrace provides a trace of method calls leading up to the error:

- The error occurred within the "load_grammar" method of the "GrammarProcessor" class, where the Treetop parser is loaded and the parser class is instantiated.
- This method is called during the initialization of the "GrammarProcessor" class in the "initialize" method.
- The "GrammarProcessor" class is utilized in the "execute" method of the "PreprocessTextFileTask" class, where the "Flowbots::GrammarProcessor.new('markdown_text_yaml')" line triggers the error.
- The "execute" method is invoked as part of the task execution in the "Jongleur::Implementation" module.
- The task execution is managed by the "WorkflowOrchestrator" class, which adds agents, defines workflows, and initiates workflow runs.
- The "run_workflow" method of the "WorkflowOrchestrator" class is responsible for starting the workflow execution and handling any errors or interruptions.
- The "train_topic_model" method in the "CLI" class of the "Flowbots" module invokes the workflow for training a topic model, which eventually leads to the error.

## Relevant Files:

- "GrammarProcessor.rb": This file defines the "GrammarProcessor" class, which is responsible for loading the Treetop grammar and creating the parser.
- "preprocess_text_file_task.rb": This file contains the "PreprocessTextFileTask" class, which utilizes the "GrammarProcessor" to parse text files.
- "WorkflowOrchestrator.rb": This file defines the "WorkflowOrchestrator" class, which manages the workflow execution.
- "cli.rb": This file includes the "CLI" class, providing command-line interface functionality for the application, including the "train_topic_model" method.
- "thor_ext.rb": This file contains the "ThorExt::Start" module, which configures Thor for improved CLI behavior and error handling.

## Suggested Action Items:

- Review the "GrammarProcessor.rb" file to ensure the specified parser class ("MarkdownTextYamlParser") is defined correctly and located in the expected directory.
- Verify that the "markdown_text_yaml" grammar file exists in the appropriate location and is properly formatted.
- Check the "GRAMMAR_DIR" constant in the "GrammarProcessor.rb" file to ensure it points to the correct directory containing the grammar files.
- Consider implementing additional error handling or logging within the "load_grammar" method to provide more detailed information about the specific cause of the error.


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
