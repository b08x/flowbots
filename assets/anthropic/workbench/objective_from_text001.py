import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{QUERY}} with real values,
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
                    "text": "Here is a query that was submitted:\n\n<query>\n{{QUERY}}\n</query>\n\nYour task is to generate a research objective based on this query. To do this:\n\n1. Carefully read the query and identify the key elements, themes, issues or questions that could potentially be addressed through research. \n\n2. Brainstorm 2-3 potential research objectives that build upon these key elements. Write out your brainstorming process and the potential objectives inside <scratchpad> tags.\n\n3. Select the research objective from your brainstorming that you think is the most promising, clear, specific and actionable. The objective should directly address the core issue or question raised in the query.\n\n4. Provide the selected research objective inside <objective> tags.\n\nRemember, a good research objective is clear, specific enough to be addressed through research, and directly relevant to the original query. Let your brainstorming process guide you, but make sure to refine the objective you ultimately select.\n\nProvide your final selected objective immediately, without any preamble, inside the <objective> tags."
                }
            ]
        }
    ]
)
print(message.content)
