# 🤖 FlowBot Exception Report 🤖


## Summary
The Flowbots::GrammarProcessor class encountered a NameError while trying to load the MarkdownYamlParser class.

## Technical Details
The error occurred within the load_grammar method of the GrammarProcessor class, specifically on the line where the parser class is instantiated:
```ruby
@parser = Object.const_get(parser_class_name).new
```
The parser_class_name variable is expected to contain the string "MarkdownYamlParser", but the constant with this name cannot be found. This results in a NameError being raised.

## Relevant Files
- GrammarProcessor.rb: Defines the Flowbots::GrammarProcessor class and the load_grammar method where the error occurred.
- preprocess_text_file_task.rb: Instantiates the GrammarProcessor class with the 'markdown_text_yaml' argument, triggering the error.


## Exception Details

- **Class:** Flowbots::GrammarProcessor
- **Message:** Unable to find parser class: MarkdownYamlParser

          raise NameError, "Unable to find parser class: #{parser_class_name}"
          ^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:46:in `load_grammar'
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:10:in `initialize'
/home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:10:in `new'
/home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb:10:in `execute'
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
