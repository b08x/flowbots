# 🤖 FlowBot Exception Report 🤖


## Summary
An error has occurred in the Flowbots::CLI class due to an uninitialized constant TextProcessingWorkflow. This issue arises during the execution of the run method in the Workflows class, specifically when trying to access the constant TextProcessingWorkflow.

## Technical Details
The backtrace indicates that the error occurs in the following code snippet from workflows.rb:

```ruby
workflow_class = Object.const_get(workflow_name.split("_").map(&:capitalize).join)
```

Here, the `const_get` method is used to retrieve the value of the constant specified by `workflow_name.split("_").map(&:capitalize).join`. However, the constant TextProcessingWorkflow is not defined, leading to the error.

The relevant files provided include workflows.rb, cli.rb, command.rb, and thor_ext.rb. The error seems to be specifically related to the Workflows class defined in workflows.rb and the CLI class defined in cli.rb.

## Suggested Action
To resolve this issue, ensure that the TextProcessingWorkflow constant is defined and accessible in the scope of the `const_get` method call. This may involve defining the constant in the appropriate module or class, or importing the necessary module or class where the constant is defined.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** uninitialized constant TextProcessingWorkflow

      workflow_class = Object.const_get(workflow_name.split("_").map(&:capitalize).join)
                             ^^^^^^^^^^

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in `const_get'
/home/b08x/Workspace/flowbots/lib/workflows.rb:29:in `run'
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
