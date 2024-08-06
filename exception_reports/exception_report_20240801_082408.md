# 🤖 FlowBot Exception Report 🤖


## Error Report: Flowbots Topic Model Trainer Workflow - Folder Not Found

**Summary:**

The Topic Model Trainer Workflow failed to execute due to an inability to locate the input folder specified for processing. This resulted in a "Folder not found" error being raised by the application.

**Technical Details:**

* **Error Class:** Flowbots::CLI
* **Error Message:** Folder not found
* **Root Cause:** The `prompt_for_folder` method in `topic_model_trainer_workflow.rb` was unable to verify the existence of the provided folder path. This suggests the path was either entered incorrectly or does not exist. 
* **Affected Component:** `topic_model_trainer_workflow.rb`
* **Relevant Code:**
    ```ruby
    def prompt_for_folder
      get_folder_path = `gum file --directory`.chomp.strip
      folder_path = File.join(get_folder_path)

      raise FlowbotError.new("Folder not found", "FOLDERNOTFOUND") unless File.directory?(folder_path)

      folder_path
    end
    ```

**Backtrace:**

The provided backtrace highlights the call sequence leading to the error:

1.  `prompt_for_folder` (topic_model_trainer_workflow.rb:39)
2.  `initialize` (topic_model_trainer_workflow.rb:12)
3.  `new` (workflows.rb:27)
4.  `run` (workflows.rb:27)
5.  `workflows` (cli.rb:29) 
    ... and so on.

**Recommended Action:**

* Verify the input folder path provided to the Topic Model Trainer Workflow. Ensure the path is correct and the folder exists.
* Consider adding input validation to the `prompt_for_folder` method to prevent invalid paths from being passed further into the workflow. 



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
