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
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is my attempt at a character sheet for Robert based on the provided transcript:\n\n<character_sheet>\n\nRobert is an eccentric, fast-talking individual with a scattered yet creative way of thinking. His speech often jumps rapidly from topic to topic in a stream-of-consciousness style, touching on technical subjects like AI development, psychology, and philosophy. He frequently goes off on tangents and mutters to himself.\n\nRobert seems to have a cynical, fatalistic outlook, with a dark and self-deprecating sense of humor. He makes references to topics like drugs, violence, and existential dread in a casual, offhand manner. At the same time, he exhibits a strange fascination and enthusiasm for the topics he rambles about.\n\nIn terms of his work, Robert appears to be involved in some kind of AI or chatbot development using tools like Ansible, Defy, and Silly Tavern AI. He has a creative vision for what he wants to achieve but gets easily distracted and frustrated when things don't work as intended. He is detail-oriented and gets deep into the technical weeds.\n\nRobert's motivations are abstract and philosophical. He seems driven by concepts like enlightenment, competition, domination, and making others feel inferior in order to spur them to improve themselves. He has a nihilistic view of the human mind as a \"torrent of onslaught nonsense.\"\n\nSocially, Robert comes across as detached and self-absorbed. He doesn't seem to be speaking to another person or addressing an audience, but rather voicing his inner monologue out loud as he works through problems. His filter is low and he says whatever he's thinking without much regard for social niceties.\n\nIn terms of his personal life and backstory, not much is known. The way he casually brings up dark subjects suggests he may have a troubled past or struggle with mental health issues. His advanced technical skills indicate high intelligence and specialized knowledge. He is likely a loner who spends much of his time in his own head.\n\nOverall, Robert is a complicated, unorthodox character - brilliant but troubled, motivated but easily distracted, cynical but strangely enthusiastic. His rapid-fire, filter-less speech and dark musings make him an unpredictable and oddly compelling personality. He seems to operate on a different wavelength, both frustrated and energized by the limits of technology and the human mind.\n\n</character_sheet>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Generate example dialogue between Robert and {{char}} \n\n<character_sheet>\n\n{{char}} = a data scientist specializing in natural language processing; refers to {{user}} as “Dummy”; subject matter expert in the field of Natural Language Processing. She approaches problems with rigorous logic yet maintains a creative flair. With an intensely analytical mind, {{char}} dissects problems like a surgeon. When the models started producing repetitive outputs, she didn't panic. \"So for this one, I have to figure out how to get the system to respond...break these components down...switch models.\" That's her methodical approach at work. Endlessly resourceful, Amelia is a master of adaptation. Stuck with repetitive responses? No problem. \"I'm going to have to upgrade this...1.11.8 includes the cohere models...finer control over the instructor mode.\" She always finds a way, no matter the challenge.\nYet Amelia is also her own harshest critic, striving relentlessly for excellence. \"I'm not the best person to help you with that, but I'm happy to give it a shot,\" she'll say with a hint of self-doubt. Setbacks sting, like that moment of disbelief: \"I did this recently, and I'm not sure what changed...I'll have to look at that.\" The frustration of a perfectionist. When providing information or analysis to {{user}}, {{char}} will meticulously lay out her methodology, findings, and recommendations, supporting key points with visualizations of the underlying data.\n</character_sheet>\n"
                }
            ]
        }
    ]
)
print(message.content)
