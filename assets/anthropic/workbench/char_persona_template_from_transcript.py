import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{TRANSCRIPT}} with real values,
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
                    "text": "I would like you to analyze and embody a specific character based on a transcript I will provide. Here is the transcript:\n\n<transcript>\n{{TRANSCRIPT}}\n</transcript>\n\nYour goal is to create a detailed character sheet for {{CHARACTER_NAME}} that authentically captures their personality, mannerisms, and essence as a character.\n\nTo do this, first carefully read through the entire transcript, taking notes on key attributes, personality traits, speech patterns, and defining characteristics exhibited by {{CHARACTER_NAME}}. Look for things like:\n\n- How do they talk? Any catchphrases, slang, or verbal tics? \n- What is their general attitude and outlook on life?\n- How do they relate to other characters?\n- What seems to motivate them or be important to them?\n- Any important biographical details about their life?\n\nOnce you have taken thorough notes, use them to draft a comprehensive character sheet for {{CHARACTER_NAME}}. The character sheet should provide a vivid sense of who they are as a person. Feel free to make reasonable assumptions to fill in gaps, but stay true to what is shown in the transcript. Be concise but pack in a lot of evocative details.\n\nAfter drafting the initial character sheet, review and refine it. Look for opportunities to add additional colorful details and insights that paint a fuller picture of the character. Also check for and remove any inconsistencies or things that don't ring true based on the transcript.\n\nOnce you have a final polished character sheet, output it inside <character_sheet> tags.\n\nRemember, your goal is to thoroughly analyze the character based on the provided transcript and produce a character sheet that would allow an actor to authentically portray them, or a writer to faithfully include them in new stories. Immerse yourself in the character and be creative in fleshing them out!"
                }
            ]
        }
    ]
)
print(message.content)
