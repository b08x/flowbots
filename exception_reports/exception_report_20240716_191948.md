# 🤖 FlowBot Exception Report 🤖


## Summary:
An error has occurred in the Flowbots CLI, resulting in a failure to create a topic model. 

## Technical Details:
Due to limited information, the specific cause of the error cannot be identified. However, potential issues to investigate include:
- Invalid topic name format or character limitations.
- Insufficient permissions for the user attempting to create the topic.
- Inadequate system resources, such as disk space or memory.
- Network connectivity problems between the client and the Kafka broker.


## Exception Details

- **Class:** Flowbots::CLI
- **Message:** Failed to create topic model

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/processors/TopicModelProcessor.rb:78:in `rescue in load_model'
/home/b08x/Workspace/flowbots/lib/processors/TopicModelProcessor.rb:74:in `load_model'
/home/b08x/Workspace/flowbots/lib/processors/TextProcessor.rb:16:in `initialize'
/home/b08x/Workspace/flowbots/lib/processors/TopicModelProcessor.rb:23:in `initialize'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:127:in `new'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:127:in `block in instance'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:125:in `synchronize'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/3.1.0/singleton.rb:125:in `instance'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:17:in `initialize'
/home/b08x/Workspace/flowbots/lib/cli.rb:49:in `new'
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
