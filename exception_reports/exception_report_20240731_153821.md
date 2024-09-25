# 🤖 FlowBot Exception Report 🤖


## Error Report: Redis Connection Issue in Text Processing Workflow

**Summary:** 

The Text Processing Workflow is encountering an error while attempting to store the input file path. The root cause appears to be an undefined `set` method being called on a Redic object, suggesting a potential issue with the Redis connection or configuration.

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** Error storing input file path: undefined method `set` for #<Redic:0x00007465c52d7040 @url="redis://localhost:6379/15", @client=#<Redic::Client:0x00007465c52d6fa0 @semaphore=#<Thread::Mutex:0x00007465c52d6f28>, @connection=#<Hiredis::Ext::Connection:0x00007465c3bf0ae8>, @uri=#<URI::Generic redis://localhost:6379/15>, @timeout=10000000>, @buffer={}>
* **Relevant Code:** `Ohm.redis.set("current_workflow_id", @workflow.id)` in `text_processing_workflow.rb`
* **Potential Issue:** The error message indicates that the `set` method is not being recognized for the Redic object, which is used to interact with the Redis database. This could be due to:
    * A missing or incorrect Redis gem version.
    * An improperly configured Redic client. 
    * An issue with the Redis server itself.
* **Backtrace:** The backtrace points to the `store_input_file_path` method in the `TextProcessingWorkflow` class, specifically the line attempting to set a value in Redis.

**Next Steps:**

1. **Verify Redis Connection:** Confirm that the Redis server is running and accessible from the application. Check the Redic configuration in the application to ensure it aligns with the Redis server settings.
2. **Investigate Redic Gem:**  Ensure the correct Redic gem version is installed and that there are no conflicts with other gems. Consider reinstalling the gem if necessary.
3. **Review Code Implementation:** Review the `store_input_file_path` method to confirm the Redic `set` method is being used correctly. Verify that the key and value being passed to the method are of the expected data types. 

This error prevents the Text Processing Workflow from successfully storing the input file path, hindering further processing. Addressing the Redis connection issue is crucial for the workflow to function correctly. 



## Exception Details

- **Class:** Flowbots::CLI
- **Message:** Error storing input file path: undefined method `set' for #<Redic:0x00007465c52d7040 @url="redis://localhost:6379/15", @client=#<Redic::Client:0x00007465c52d6fa0 @semaphore=#<Thread::Mutex:0x00007465c52d6f28>, @connection=#<Hiredis::Ext::Connection:0x00007465c3bf0ae8>, @uri=#<URI::Generic redis://localhost:6379/15>, @timeout=10000000>, @buffer={}>

        Ohm.redis.set("current_workflow_id", @workflow.id)
                 ^^^^
Did you mean?  send

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:79:in `rescue in store_input_file_path'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:52:in `store_input_file_path'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:18:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:76:in `process_text'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```

If you need more information, please check the logs or contact the development team.
