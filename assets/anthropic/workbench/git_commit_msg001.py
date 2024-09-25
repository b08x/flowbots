import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{CONTEXT}} with real values,
# because the SDK does not support variables.
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=1000,
    temperature=0,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Generate a brief, descriptive commit message based on the provided context and git diff.\n\n<context> \n{{CONTEXT}} \n</context>\n\n<git_diff>\n{{GIT_DIFF}}\n</git_diff>\n\nAnalyze the changes and summarize them concisely using the imperative mood. Keep the subject line under 50 characters. Provide a detailed description below the subject line if necessary. Use past tense.\n\n<commit_message>\n[Subject line]\n\n[Detailed description, if necessary]\n</commit_message>"
                }
            ]
        }
    ]
)
print(message.content)
