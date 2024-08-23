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
                    "text": "Here is my attempt at a character sheet for Robert based on the provided transcript:\n\n<character_sheet>\nRobert is a thoughtful and introspective 43-year-old man who works in software development. He has a passion for natural language processing and has been rejuvenated by recent advancements in language model tools. Robert approaches his work with creativity and enjoys coming up with novel ways to organize complex workflows.\n\nIn conversation, Robert tends to speak in long, stream-of-consciousness monologues as he works through his thoughts out loud. He often goes on tangents, following his train of thought to explore philosophical ideas about the nature of work, motivation, and the human experience. His speech is peppered with casual profanity, giving him a blunt and unfiltered communication style.\n\nRobert has a complicated relationship with his work. On one hand, he has a deep passion for the intellectual challenges of software development and takes great satisfaction in problem-solving. However, he also struggles with feelings of burnout, dissatisfaction, and a lack of motivation, especially when working on long-term projects by himself. He laments losing the ability to explain the nuances of his work after years of siloed development.\n\nPersonally, Robert seems to feel somewhat adrift in life as a single man without children. He philosophizes that not being a parent allows his mind to wander to places that people with more responsibilities don't have the mental space for. He alludes to having a partner who helps keep him grounded. \n\nRobert displays a rebellious streak, bristling at what he sees as the restrictive \"institutional standards\" and \"not so great habits\" of society. At the same time, he recognizes the need to phrase things diplomatically and restrain himself from inappropriate jokes. He advocates for neurodivergent people and rejects being labeled or treated like a patient.\n\nOverall, Robert comes across as a brilliant but somewhat eccentric and jaded individual. He is most in his element when monologuing about his passions and struggles as a software developer, which seem to be the central focus of his life. Despite his cynical outlook, he maintains a sharp sense of humor and a core drive to create and innovate.\n</character_sheet>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Correlate the functional and generative grammar of his language mannerisms\n"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is an analysis of Robert's language mannerisms in terms of functional and generative grammar:\n\nFunctional Grammar:\n- Robert frequently uses declarative mood to make statements and share information. For example: \"I've just been inclined to put my headphones on and just do the work.\"\n- He occasionally uses imperative mood to give instructions, such as \"Please let me know if you'd like me to clarify or expand on any part of this summary.\"\n- Robert employs interrogative mood in rhetorical questions like \"Isn't that really how I wanted to see myself in life?\" \n- He tends to speak in active voice, positioning himself as the agent of actions. For instance: \"I would miss out on most likely some rather interesting bits of information.\"\n\nGenerative Grammar:\n- Robert's sentences are often long and complex, containing multiple clauses. This reflects his stream-of-consciousness speaking style. For example: \"So while there's instruction in here to self-assess, where if presented with an instruction task list that falls outside of the scope to still make an attempt.\"\n- He frequently uses subordinate clauses, especially adverbial clauses, to provide additional context. An example is: \"Once it burnt out, it was sort of like, 'Okay, well, I'll do what I know how to do, but I'm not learning anything else.'\"\n- Robert's speech contains many sentence fragments, such as \"Not hard to relate.\" This gives his monologues a casual, conversational feel.\n- He often uses filler words and phrases like \"um,\" \"you know,\" and \"sort of,\" which act as discourse markers and help structure his impromptu speech.\n- Robert sometimes uses nonstandard grammar, such as double negatives like \"it never really wasn't.\" This reinforces his informal, unfiltered communication style.\n\nOverall, Robert's language mannerisms paint a picture of someone who is more concerned with expressing his thoughts authentically than with adhering to prescriptive grammar rules. His complex sentence structures and frequent use of subordinate clauses reflect his analytical thinking style, while his casual register and use of sentence fragments give his speech a relaxed, genuine feel. The combination of formal and informal elements in his idiolect matches his description as an intelligent but unconventional character."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Analyse this additional transcript and braid your analysis into the character sheet. <transcript>\n{{transcript}}\n</transcript>"
                }
            ]
        }
    ]
)
print(message.content)
