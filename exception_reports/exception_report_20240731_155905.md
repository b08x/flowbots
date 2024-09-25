# 🤖 FlowBot Exception Report 🤖


## Error Report: Database Index Error

**Summary:**

The application encountered a fatal error while attempting to execute the Text Processing Workflow. The error originated from a missing database index 'path' on the Sourcefile model. This prevented the system from associating the input file with the workflow.

**Technical Details:**

* **Class:** Flowbots::CLI
* **Message:** Database index error: Index 'path' not found for Sourcefile 

**Root Cause:** 

The `store_input_file_path` method within `text_processing_workflow.rb` attempts to find or create a Sourcefile entry using the input file path. The search relies on an index 'path' which appears to be missing from the database schema.

**Backtrace:**

The backtrace points to the following execution flow:

1. `Flowbots::CLI#process_text` is called with the user-provided file.
2. A new `TextProcessingWorkflow` instance is created and `run` is called.
3. Within `TextProcessingWorkflow#run`, the `store_input_file_path` method attempts to associate the input file with the workflow.
4. `Sourcefile.find_or_create_by_path` fails due to the missing index, raising an `Ohm::Error`. 
5. The error is caught and re-raised as a `FlowbotError`.

**Impact:**

Users are unable to run the Text Processing Workflow. 

**Next Steps:**

1. **Investigate Database Schema:** Verify the database schema for the Sourcefile model and ensure the 'path' index exists. 
2. **Apply Missing Index:** If the index is indeed missing, apply the necessary database migration to add it.
3. **Test:** After applying the fix, thoroughly test the Text Processing Workflow to confirm the error is resolved. 



## Exception Details

- **Class:** Flowbots::CLI
- **Message:** Database index error: Index 'path' not found for Sourcefile

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:34:in `rescue in verify_indices'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:27:in `verify_indices'
/home/b08x/Workspace/flowbots/lib/workflows/text_processing_workflow.rb:14:in `run'
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
