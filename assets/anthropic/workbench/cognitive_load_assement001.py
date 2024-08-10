import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{RUBY_CODE}} with real values,
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
                    "text": "You are tasked with assessing the cognitive load of a given Ruby code snippet. Cognitive load refers to the mental effort required to understand and work with the code. Your goal is to analyze the code and provide a detailed explanation of its cognitive load, followed by a numerical score.\n\nHere is the Ruby code to analyze:\n\n<ruby_code>\n{{RUBY_CODE}}\n</ruby_code>\n\nWhen assessing the cognitive load, consider the following factors:\n\n1. Complexity: The number of control structures, nested loops, and conditional statements.\n2. Readability: The use of clear variable names, comments, and consistent formatting.\n3. Length: The overall size of the code snippet.\n4. Abstraction: The use of functions, classes, and modules to organize code.\n5. Naming conventions: Adherence to Ruby naming conventions.\n6. Use of Ruby idioms: Utilization of Ruby-specific features and best practices.\n\nAnalyze the provided code based on these factors. In your analysis, consider how each factor contributes to the overall cognitive load of the code.\n\nProvide a detailed explanation of your analysis, discussing how each factor impacts the cognitive load. Be specific and refer to parts of the code in your explanation.\n\nAfter your explanation, assign a cognitive load score to the code on a scale of 1 to 10, where 1 represents very low cognitive load (easy to understand and maintain) and 10 represents very high cognitive load (difficult to understand and maintain).\n\nPresent your response in the following format:\n\n<analysis>\nYour detailed analysis of the code's cognitive load, discussing each factor and its impact.\n</analysis>\n\n<score>\nYour numerical cognitive load score (1-10) and a brief justification for the score.\n</score>\n\nRemember to provide a thorough analysis before giving the final score."
                }
            ]
        }
    ]
)
print(message.content)
