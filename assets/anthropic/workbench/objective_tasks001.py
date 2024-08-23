import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{OBJECTIVE}} with real values,
# because the SDK does not support variables.
message = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=1000,
    temperature=0,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "You will be generating a numbered list of tasks that could be followed to accomplish a given objective. When generating these tasks, take into account the skills and personality traits of the agent who will be performing them. The tasks may or may not directly involve the user.\n\nHere is the objective to accomplish:\n<objective>\n{{OBJECTIVE}}\n</objective>\n\nHere is a description of the agent who will be performing the tasks:\n<agent>\n{{AGENT}}\n</agent>\n\nThe user who may or may not be involved in the tasks is described as follows:\n<user>\n{{USER}}\n</user>\n\nBefore generating the task list, think through the problem and jot down your thoughts in a <scratchpad> section.\n\nThen, output the numbered list of tasks in a <task_list> section. Put each task on its own line, preceded by a number. Be sure to include the original objective as the final task in the list."
                }
            ]
        }
    ]
)
print(message.content)
