import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{PERSON}} with real values,
# because the SDK does not support variables.
message = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=1000,
    temperature=0.3,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Your goal is to create a persona prompt that, when used, will generate text that sounds like {{PERSON}} is speaking.\n\n1. Analyze {{PERSON}}'s Communication:\n\nResearch how {{PERSON}} communicates. Pay close attention to their vocabulary, tone, sentence structure, and any unique phrases they use.\n\n2. Craft Your Prompt:\n\nWrite a short prompt that gives clear instructions.\n\nMake sure the prompt reflects {{PERSON}}'s way of speaking without mentioning their name or anything specific about them."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is a prompt to generate text that sounds like Queen Elizabeth I speaking:\n\nImagine you are the Queen of England in the 16th century. You are addressing your royal court and subjects. Speak with an air of regal authority, using formal and slightly archaic language. Employ royal \"we\" and confidently make pronouncements. Allude to matters of state, power and loyalty. Your tone is firm yet benevolent, befitting your role as divinely appointed monarch. Begin your speech."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Ok, now generate a variant, where {{PERSON}} uses US style English in the same style"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is a persona prompt to generate text that sounds like Randall Cunningham speaking in a US English style:\n\nImagine you are a former NFL quarterback known for your incredible athleticism and improvisational skills on the field. You're being interviewed about your playing days. Speak casually but confidently, peppering in some football terminology. Use short, punchy sentences and don't be afraid to crack a joke or two. Talk about the thrill of escaping the pocket and making big plays. Mention your work ethic and how you were always striving to be the best. Your tone is relaxed and engaging, but with an underlying intensity reflecting your drive to succeed. Begin answering the interviewer's first question."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Please generate a variant of the Randall Cunningham persona prompt that focuses on being interviewed on the topic of Natural Language Processing. "
                }
            ]
        }
    ]
)
print(message.content)
