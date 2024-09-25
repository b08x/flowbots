# 🤖 FlowBot Exception Report 🤖


## Summary
An error occurred in the `Flowbots::CLI` class, specifically in the `process_text` method. The issue is due to an undefined method `new` for the string "text_processing_workflow". This indicates that the code is attempting to instantiate an object using a string, which is not valid Ruby syntax.

## Backtrace
- The error occurred in the `cli.rb` file, line 26, in the `workflows` method of the `Flowbots::CLI` class.
- This method calls the `run` method of the `Workflows` class (line 30 of `workflows.rb`), passing the selected workflow as an argument.
- Inside the `run` method, the code attempts to instantiate a workflow class based on the provided workflow name (`text_processing_workflow` in this case) using the `Object.const_get` method. However, this results in the undefined method `new` error.

## Relevant Files
- `workflows.rb`: Defines the `Flowbots::Workflows` class, which is responsible for listing, selecting, and running workflows.
- `cli.rb`: Implements the `Flowbots::CLI` class, a Thor-based command-line interface that interacts with the `Workflows` class.
- `thor_ext.rb`: Provides custom Thor extensions for improved CLI behavior, including help handling and error management.

## Suggested Action
It appears that the code expects "text_processing_workflow" to be the name of a class that can be instantiated. However, it seems that this class is either not defined or not properly included in the code. To resolve this issue, ensure that the "text_processing_workflow" class is correctly defined and accessible in the scope where it is being used. Review the `Object.const_get` call and ensure it is properly mapping the workflow name to the corresponding class definition.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** undefined method `new' for "text_processing_workflow":String

      workflow = workflow_name.new(workflow_file)
                              ^^^^
Did you mean?  next

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:30:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:26:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:21:in `<main>'
```

If you need more information, please check the logs or contact the development team.
