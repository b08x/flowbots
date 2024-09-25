# 🤖 FlowBot Exception Report 🤖


# Error Report: "No such file or directory"

## Summary
The error "No such file or directory @ rb_sysopen - ../grammars/markdown_text_yaml" occurred during the execution of the Flowbots application. This indicates that the specified file could not be found in the given directory.

## Technical Details

### Backtrace
The error occurred within the `GrammarProcessor` class in the `Flowbots` module. Specifically, it happened during the initialization of the `GrammarProcessor` object and the subsequent call to the `load_grammar` method.

```ruby
# /home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:23:in `load_grammar'
# /home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:10:in `initialize'
```

### Relevant Files

#### GrammarProcessor.rb
The `GrammarProcessor` class is responsible for loading and processing a specific grammar file. The `load_grammar` method attempts to load the grammar file using `Treetop.load`, which compiles the grammar into a parser class.

```ruby
# /home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb

module Flowbots
  class GrammarProcessor
    # ...

    def load_grammar
      begin
        Treetop.load(File.join(GRAMMAR_DIR, "#{@grammar_name}.treetop"))
        # ...
      rescue StandardError => e
        Flowbots::ExceptionHandler.handle_exception(self.class.name, e)
      end
    end
    # ...
  end
end
```

#### preprocess_text_file_task.rb
The `preprocess_text_file_task.rb` file contains the `PreprocessTextFileTask` class, which executes the text preprocessing task. It creates an instance of the `GrammarProcessor` class with the argument `'markdown_text_yaml'`, indicating the expected grammar file.

```ruby
# /home/b08x/Workspace/flowbots/lib/tasks/preprocess_text_file_task.rb

class PreprocessTextFileTask < Jongleur::WorkerTask
  # ...

  def execute
    # ...
    grammar_processor = Flowbots::GrammarProcessor.new('markdown_text_yaml')
    # ...
  rescue StandardError => e
    Flowbots::UI.exception("#{e.message}")
    exit
  end
  # ...
end
```

### Suggested Action Items:
- Confirm the existence of the `markdown_text_yaml` file in the specified directory (`../grammars/`).
- Ensure that the path to the grammar file is correctly specified and accessible by the application.
- Consider using the `File.join` method to construct the file path to ensure proper path separation.
- Review the `Treetop` documentation for additional guidance on loading and using grammar files.


## Exception Details

- **Class:** Flowbots::GrammarProcessor
- **Message:** No such file or directory @ rb_sysopen - ../grammars/markdown_text_yaml

### Backtrace

```
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/treetop-1.6.12/lib/treetop/compiler/grammar_compiler.rb:40:in `initialize'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/treetop-1.6.12/lib/treetop/compiler/grammar_compiler.rb:40:in `open'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/treetop-1.6.12/lib/treetop/compiler/grammar_compiler.rb:40:in `load'
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:23:in `load_grammar'
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
