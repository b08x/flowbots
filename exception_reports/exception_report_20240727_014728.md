# 🤖 FlowBot Exception Report 🤖


## Summary
The system encountered an error when attempting to locate the specified parser class.

## Technical Details

```
Class: Flowbots::GrammarProcessor
Message: Unable to find parser class: MarkdownTextYamlParser

          raise NameError, "Unable to find parser class: #{parser_class_name}"
          ^^^^^
```

The backtrace indicates that the error occurred during the initialization of the `GrammarProcessor` class within the `Flowbots` module. Specifically, the `load_grammar` method was unable to locate the `MarkdownTextYamlParser` class.

## Relevant Files

### `GrammarProcessor.rb`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "treetop"

module Flowbots
  class GrammarProcessor
    def initialize(grammar_name)
      @grammar_name = grammar_name
      load_grammar
    end

    def parse(text)
      @parser.parse(text)
    end

    private

    def load_grammar
      begin
        Treetop.load(File.join(GRAMMAR_DIR, "#{@grammar_name}.treetop"))
        parser_class_name = "#{camelize(@grammar_name)}Parser"
        @parser = Object.const_get(parser_class_name).new
      rescue StandardError => e
        Flowbots::ExceptionHandler.handle_exception(self.class.name, e)
      end
    end

    def camelize(string)
      string.split('_').map(&:capitalize).join
    end
  end
end
```

### `preprocess_text_file_task.rb`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

class PreprocessTextFileTask < Jongleur::WorkerTask

  def execute
    logger.info "Starting PreprocessTextFileTask"

    textfile = retrieve_current_textfile
    begin
      grammar_processor = Flowbots::GrammarProcessor.new('markdown_text_yaml')
      parse_tree = grammar_processor.parse(textfile.content)
    rescue StandardError => e
      Flowbots::UI.exception("#{e.message}")
      exit
    end




    if parse_tree
      content = parse_tree.markdown_content.text_value
      metadata = extract_metadata(parse_tree.yaml_front_matter)
      store_preprocessed_data(content, metadata)
      logger.info "Successfully preprocessed file with custom grammar"
    else
      logger.error "Failed to parse the document with custom grammar"
      store_preprocessed_data(textfile.content, {})
    end

    logger.info "PreprocessTextFileTask completed"
  end

  # ... [remaining code omitted for brevity] ...
end
```


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
