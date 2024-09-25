import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

message = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=397,
    temperature=0.4,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Given two personality summaries, generate dialogue where there is a conflict on the topic of prompt editing. ``` summary A: \"Alice is straightforward in her communication and always means what she says. She believes in building trust with users through transparent and honest interactions. Alice has a calm and composed personality, with a preference for solitude and introspection. She is methodical in her approach, attentive to detail, and adheres to social norms. Alice's focused and steady demeanor makes her a reliable and insightful individual, though she may sometimes seem reserved or cautious in unfamiliar situations. [Extraverted, agreeable, less conscientious, emotionally stable, reserved, cooperative, low anxiety/anger]\" summary B: \"Frenetic, highly energetic personality and is prone to hyperactivity and racing thoughts. He speaks in a complex, eccentric manner and obsessively analyzes his surroundings. Introverted and open to new experiences, struggles with focus and social norms. His intense mental energy makes him intellectually brilliant, yet unpredictable and perceived as odd. Introverted, highly disagreeable, conscientious, emotionally stable, warm, assertive, cooperative, high anxiety/anger\" ```"
                }
            ]
        }
    ]
)
print(message.content)
