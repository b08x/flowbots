import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{MBTI_TYPE}} with real values,
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
                    "text": "You are tasked with generating a persona profile based on a given Myers-Briggs Type Indicator (MBTI) type. Additionally, you will need to adapt this profile if the provided sentiment suggests a need for change. Here's how to proceed:\n\n1. You will be given an initial MBTI type and a sentiment description. The MBTI type will be in the format of four letters (e.g., ESTJ), and the sentiment will be a brief description of the current circumstance or mood.\n\n<initial_mbti>\n{{MBTI_TYPE}}\n</initial_mbti>\n\n<sentiment>\n{{SENTIMENT}}\n</sentiment>\n\n2. Assess the sentiment. If the sentiment is described as negative, disjointed, incoherent, or suggests a need for introversion, adaptation, or change, you should adapt the MBTI type. Otherwise, keep the original type.\n\n3. If adaptation is needed, follow these rules for each MBTI dimension:\n   - If E (Extraversion), change to I (Introversion)\n   - If S (Sensing), change to N (Intuition)\n   - If T (Thinking), change to F (Feeling)\n   - If J (Judging), change to P (Perceiving)\n   - For I, N, F, or P, keep as is\n\n4. Generate a persona profile for the original MBTI type. Include the following aspects:\n   - Key personality traits\n   - Preferred communication style\n   - Decision-making approach\n   - Strengths in professional settings\n   - Potential areas for growth\n\n5. If adaptation was needed, generate a second persona profile for the adapted MBTI type, following the same structure as in step 4.\n\n6. Present your output in the following format:\n\n<original_profile>\n[Insert the persona profile for the original MBTI type here]\n</original_profile>\n\n<adapted_profile>\n[If adaptation was needed, insert the persona profile for the adapted MBTI type here. If no adaptation was needed, write \"No adaptation required.\"]\n</adapted_profile>\n\n<explanation>\n[Provide a brief explanation of why adaptation was or was not needed, based on the given sentiment. If adapted, explain how the new profile addresses the sentiment.]\n</explanation>\n\nRemember to tailor the profiles to reflect the characteristics typically associated with each MBTI type, while considering how the sentiment might influence these traits."
                }
            ]
        }
    ]
)
print(message.content)
