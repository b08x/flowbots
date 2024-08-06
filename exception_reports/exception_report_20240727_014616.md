# 🤖 FlowBot Exception Report 🤖


## Summary
The Flowbots application has encountered an error due to an undefined local variable or method `grammar_file' in the GrammarProcessor class. This issue has caused the program to terminate unexpectedly.

## Technical Details
The error occurred during the execution of the `load_grammar` method within the GrammarProcessor class. This method is responsible for loading the grammar file specified by the `@grammar_name` instance variable. However, when attempting to access the `grammar_file` variable, the system could not find it, resulting in the error message "undefined local variable or method `grammar_file'".

To resolve this issue, it is recommended to review the GrammarProcessor class and ensure that the `grammar_file` variable is properly defined and accessible within the `load_grammar` method. Additionally, it is important to verify that the grammar file exists and is accessible by the application.

## Relevant Code Snippets
**GrammarProcessor.rb**
```ruby
module Flowbots
  class GrammarProcessor
    def initialize(grammar_name)
      @grammar_name = grammar_name
      load_grammar
    end

    # ...

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

    # ...
  end
end
```

**preprocess_text_file_task.rb**
```ruby
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

    # ...

  private

  def retrieve_current_textfile
    # ...
  end

  def extract_metadata(yaml_front_matter)
    # ...
  end

  def store_preprocessed_data(content, metadata)
    # ...
  end
end
```


## Exception Details

- **Class:** Flowbots::GrammarProcessor
- **Message:** undefined local variable or method `grammar_file' for #<Flowbots::GrammarProcessor:0x00007fbf93df91e8 @grammar_name="markdown_text_yaml", @logger=#<Logger:0x00007fbf93d025a0 @level=0, @progname="Flowbots::GrammarProcessor#load_grammar", @default_formatter=#<Logger::Formatter:0x00007fbf93d02410 @datetime_format=nil>, @formatter=nil, @logdev=#<Logger::LogDevice:0x00007fbf93d022a8 @shift_period_suffix="%Y%m%d", @shift_size=6145728, @shift_age=10, @filename="/home/b08x/Workspace/flowbots/log/flowbots-2024-07-27.log", @dev=#<File:/home/b08x/Workspace/flowbots/log/flowbots-2024-07-27.log>, @binmode=false, @mon_data=#<Monitor:0x00007fbf93d02230>, @mon_data_owner_object_id=1620>, @level_override={}>>

        logger.debug "Loading grammar file: #{grammar_file}"
                                              ^^^^^^^^^^^^
Did you mean?  @grammar_name

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/processors/GrammarProcessor.rb:22:in `load_grammar'
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
