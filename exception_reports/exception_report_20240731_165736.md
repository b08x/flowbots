# 🤖 FlowBot Exception Report 🤖


## Error Report: Folder Not Found

**Summary:**

The Topic Model Trainer Workflow failed to execute due to an inability to locate the specified input folder. This appears to stem from the `prompt_for_folder` method in `topic_model_trainer_workflow.rb` which retrieves a folder path, but the path provided does not correspond to an existing directory on the system. 

**Technical Details:**

* **Class:** `Flowbots::CLI`
* **Message:** `Folder not found`
* **Error Type:**  `FlowbotError` (likely a custom exception class)
* **Error Code:** `FOLDERNOTFOUND`

**Backtrace:** 

The error originated in the `prompt_for_folder` method of the `TopicModelTrainerWorkflow` class, specifically at line 39 of `topic_model_trainer_workflow.rb`. This method is called during the initialization of the `TopicModelTrainerWorkflow` object.

See attached backtrace for the full error call stack.

**Relevant Code:**

The following code snippet from `topic_model_trainer_workflow.rb` highlights the problematic method:

```ruby
    def prompt_for_folder
      get_folder_path = `gum file --directory`.chomp.strip
      folder_path = File.join(get_folder_path)

      raise FlowbotError.new("Folder not found", "FOLDERNOTFOUND") unless File.directory?(folder_path)

      folder_path
    end
```

**Possible Causes and Next Steps:**

* **User Error:** Verify that the folder path provided as input to the workflow is correct and exists on the file system.
* **Code Logic:** Review the `prompt_for_folder` method to ensure it correctly handles user input and folder path validation. This might involve:
    * Adding more robust input sanitization.
    * Implementing error handling to provide more informative messages to the user if an invalid path is provided. 

Further investigation into the exact user input and system environment where the error occurred may be necessary. 



## Exception Details

- **Class:** Flowbots::CLI
- **Message:** Folder not found

### Backtrace

```
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:39:in `prompt_for_folder'
/home/b08x/Workspace/flowbots/lib/workflows/topic_model_trainer_workflow.rb:12:in `initialize'
/home/b08x/Workspace/flowbots/lib/workflows.rb:27:in `new'
/home/b08x/Workspace/flowbots/lib/workflows.rb:27:in `run'
/home/b08x/Workspace/flowbots/lib/cli.rb:29:in `workflows'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/command.rb:28:in `run'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor/invocation.rb:127:in `invoke_command'
/home/b08x/.asdf/installs/ruby/3.1.4/lib/ruby/gems/3.1.0/gems/thor-1.3.1/lib/thor.rb:527:in `dispatch'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:34:in `block in start'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:43:in `handle_help_switches'
/home/b08x/Workspace/flowbots/lib/thor_ext.rb:33:in `start'
./exe/flowbots:23:in `<main>'
```

If you need more information, please check the logs or contact the development team.
