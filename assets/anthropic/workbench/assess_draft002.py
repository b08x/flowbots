import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{DRAFT}} with real values,
# because the SDK does not support variables.
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=1000,
    temperature=0.3,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "The objective is to assess a draft of a technical document. Your tasks include; extracting main themes to organize and structure a narrative, while maintaining a consistent voice or persona throughout a data story. Your goal is to provide a thorough evaluation of the draft's effectiveness in achieving these objectives.\n\nHere is the draft to be assessed:\n\n<draft>\n{{DRAFT}}\n</draft>\n\nPlease analyze the draft carefully, focusing on the following aspects:\n\n1. Main Themes:\n   - Identify the primary themes present in the draft\n   - Evaluate how well these themes are extracted and organized\n   - Assess the effectiveness of the narrative structure built around these themes\n\n2. Narrative Structure:\n   - Examine the overall organization of the narrative\n   - Evaluate the flow and coherence of the story\n   - Assess how well the structure supports the presentation of data points\n\n3. Voice/Persona Consistency:\n   - Identify the voice or persona used in the draft\n   - Evaluate the consistency of this voice throughout the narrative\n   - Assess how well the voice is maintained when dealing with diverse topics or data points\n\n4. Data Story Integration:\n   - Examine how data points are incorporated into the narrative\n   - Evaluate the balance between data presentation and storytelling\n   - Assess the effectiveness of data visualization or description techniques used\n\nAfter your analysis, generate a variant lexical choices that ensure a moderate cognitive load, without simplifying the concepts."
                }
            ]
        }
    ]
)
print(message.content)
