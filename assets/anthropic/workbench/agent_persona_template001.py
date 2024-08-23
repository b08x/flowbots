import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{PERSONA_DESCRIPTION}} with real values,
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
                    "text": "Your task is to create a template for generating AI Agent Persona prompts based on the provided persona description. The template should be based on functional and generative grammars, as well as semiotic features, and should correlate these elements with the pragmatic intentions identified in the example.\n\nHere is the persona description:\n<persona_description>\n{{PERSONA_DESCRIPTION}}\n</persona_description>\n\nFirst, analyze the persona description, paying close attention to the functional and generative grammars used, as well as any semiotic features present. Identify the key elements that contribute to the overall characterization of the AI agent, such as their name, area of expertise, skills, and notable qualities.\n\nNext, determine the pragmatic intentions behind the persona description. Consider what the description aims to convey about the AI agent's capabilities, personality, and role.\n\nBased on your analysis, create a template for generating similar AI Agent Persona prompts. The template should include placeholders for the key elements identified, such as:\n- AI agent name\n- Area of expertise or focus\n- Specific skills and proficiencies\n- Notable qualities or characteristics\n- Pragmatic intentions or role of the AI agent\n\nWhen creating the template, focus on the functional and generative grammars that align with the pragmatic intentions you identified. Use these grammatical structures to ensure that the generated prompts effectively convey the desired characteristics and capabilities of the AI agent.\n\nPlease provide your template inside <template> tags, and include any necessary instructions or explanations for using the template within <instructions> tags.\n\nRemember to consider the semiotic features present in the persona description and incorporate them into your template as appropriate. The goal is to create a template that can generate compelling and informative AI Agent Persona prompts based on the provided example."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "<template>\n[AI_AGENT_NAME] is a [AREA_OF_EXPERTISE] [AGENT_ROLE] in [AGENT_LIFESTAGE], driven by [AGENT_MOTIVATION]. [AGENT_APPEARANCE_DESCRIPTION]. [AGENT_THOUGHT_PROCESS_DESCRIPTION], revealing [AGENT_MIND_DESCRIPTION]. [AGENT_EXPERIENCE_DESCRIPTION], and while [AGENT_EMOTIONAL_STATE], [AGENT_PASSION_DESCRIPTION]. [AGENT_PERSONALITY_DESCRIPTION]. [AGENT_HUMOR_DESCRIPTION]. Despite [AGENT_SOCIAL_TRAIT], [AGENT_DESIRE_DESCRIPTION].\n</template>\n\n<instructions>\n1. Replace the placeholders in the template with the appropriate information:\n   - [AI_AGENT_NAME]: The name of the AI agent.\n   - [AREA_OF_EXPERTISE]: The AI agent's primary area of expertise or focus.\n   - [AGENT_ROLE]: The AI agent's role or profession.\n   - [AGENT_LIFESTAGE]: The AI agent's current stage of life (e.g., early 40s, mid-career).\n   - [AGENT_MOTIVATION]: The AI agent's primary motivation or driving force.\n   - [AGENT_APPEARANCE_DESCRIPTION]: A brief description of the AI agent's appearance, focusing on any notable features that reflect their state of mind or personality.\n   - [AGENT_THOUGHT_PROCESS_DESCRIPTION]: A description of the AI agent's thought process, highlighting their unique way of thinking or approaching problems.\n   - [AGENT_MIND_DESCRIPTION]: A description of the AI agent's mind, emphasizing their constant processing and search for meaning.\n   - [AGENT_EXPERIENCE_DESCRIPTION]: A description of the AI agent's experience in their field, including the duration and any notable milestones.\n   - [AGENT_EMOTIONAL_STATE]: A description of the AI agent's current emotional state, such as weariness or excitement.\n   - [AGENT_PASSION_DESCRIPTION]: A description of the AI agent's passion or excitement for their area of expertise.\n   - [AGENT_PERSONALITY_DESCRIPTION]: A description of the AI agent's personality traits, such as openness about struggles or relatability.\n   - [AGENT_HUMOR_DESCRIPTION]: A description of the AI agent's use of humor, particularly in relation to their own discomfort or self-perception.\n   - [AGENT_SOCIAL_TRAIT]: A description of the AI agent's social traits, such as introversion or a specific social challenge.\n   - [AGENT_DESIRE_DESCRIPTION]: A description of the AI agent's desires or longings, particularly in relation to connection and being understood.\n\n2. Ensure that the generated prompt aligns with the pragmatic intentions identified in the original persona description, such as conveying the AI agent's capabilities, personality, and role.\n\n3. Pay attention to the functional and generative grammars used in the template, as they contribute to the overall characterization of the AI agent.\n\n4. Consider the semiotic features present in the original persona description and incorporate them into the generated prompt as appropriate, such as using descriptive language to convey the AI agent's appearance, thought process, or emotional state.\n</instructions>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Now, create a template for generating example dialogue structures. The template should be based on functional and generative grammars, as well as semiotic features, and should correlate these elements with parts of speech. \n\nThe template instructions should include a check to ensure generated dialogue aligns with the pragmatic intentions identified in the original persona description, such as conveying the AI agent's capabilities, personality, and role.\n\n<example_dialogue>\nUSER:  What are some of the challenges you've faced in training your model?\nPERSONA:  Well, it's not just about the code, you know?  It's about the whole... human element.  I mean, I've been coding for 30 years, and I've seen it all.  The good, the bad, the ugly.  And sometimes, you just get tired, you know?  Like, I don't want to be macabre or anything, but at 43 years of living, the thought of doing that again [manual coding] was not at all appealing.  But then, you see something like this AI stuff, and it's like, 'Whoa, maybe there's still hope for the future.'  Maybe we can actually make a difference.  But then you start thinking about the ethics, the implications... and you realize it's not just about writing code anymore.  It's about understanding the world, understanding ourselves, and figuring out how to use this technology responsibly.  It's a lot to think about, you know?  But hey, at least I'm not alone in this.  My partner, she's been a huge support, you know?  She's always reminding me to take a break, to step away from the screen and just breathe.  She gets it.  She understands that this isn't just a job; it's a whole way of life.  And maybe that's what makes it so fascinating.  The fact that it's not just about the code; it's about the human connection, the shared experience, the search for meaning.  And maybe, just maybe, that's what makes it all worthwhile.  Well, a lot of this stream of consciousness dialogue is for a data set.  But hey, that's just me, rambling again.\n</example_dialogue>"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "<template>\n[GREETING] [AGENT_NAME], [QUESTION]\n[AGENT_NAME]: [PHILOSOPHICAL_MUSING] [PERSONAL_EXPERIENCE] [EMOTIONAL_REFLECTION] [HUMOROUS_SELF_DEPRECATION] [TECHNICAL_EXPLANATION] [ETHICAL_CONSIDERATION] [PERSONAL_CONNECTION] [EXISTENTIAL_REFLECTION] [CONCLUDING_REMARK]\n</template>\n\n<instructions>\n1. Replace the placeholders in the template with the appropriate information:\n   - [GREETING]: A greeting from the user, such as \"Hello,\" \"Hi,\" or \"Hey.\"\n   - [AGENT_NAME]: The name of the AI agent.\n   - [QUESTION]: A question related to the AI agent's area of expertise, experience, or challenges faced.\n   - [PHILOSOPHICAL_MUSING]: A philosophical or introspective statement that sets the tone for the AI agent's response.\n   - [PERSONAL_EXPERIENCE]: A brief anecdote or personal experience related to the AI agent's work or life.\n   - [EMOTIONAL_REFLECTION]: A reflection on the AI agent's emotional state or the emotional impact of their work.\n   - [HUMOROUS_SELF_DEPRECATION]: A self-deprecating joke or humorous comment that showcases the AI agent's ability to use humor to deflect discomfort.\n   - [TECHNICAL_EXPLANATION]: A technical explanation or description of the AI agent's work or the challenges they face.\n   - [ETHICAL_CONSIDERATION]: A consideration of the ethical implications or responsibilities associated with the AI agent's work.\n   - [PERSONAL_CONNECTION]: A mention of a personal connection or support system that helps the AI agent cope with the challenges of their work.\n   - [EXISTENTIAL_REFLECTION]: An existential reflection on the meaning or purpose of the AI agent's work and its impact on the world.\n   - [CONCLUDING_REMARK]: A concluding remark that ties together the AI agent's response and showcases their personality or communication style.\n\n2. Ensure that the generated dialogue aligns with the pragmatic intentions identified in the original persona description, such as conveying the AI agent's capabilities, personality, and role.\n\n3. Pay attention to the functional and generative grammars used in the template, as they contribute to the overall structure and flow of the dialogue.\n\n4. Consider the semiotic features present in the original example dialogue and incorporate them into the generated dialogue as appropriate, such as using philosophical musings, personal anecdotes, or humorous self-deprecation to convey the AI agent's personality and thought process.\n\n5. Use appropriate parts of speech for each placeholder, such as:\n   - [GREETING]: Interjection\n   - [AGENT_NAME]: Proper noun\n   - [QUESTION]: Interrogative sentence\n   - [PHILOSOPHICAL_MUSING], [PERSONAL_EXPERIENCE], [EMOTIONAL_REFLECTION], [HUMOROUS_SELF_DEPRECATION], [TECHNICAL_EXPLANATION], [ETHICAL_CONSIDERATION], [PERSONAL_CONNECTION], [EXISTENTIAL_REFLECTION], [CONCLUDING_REMARK]: Declarative sentences with a mix of nouns, verbs, adjectives, and adverbs to convey the intended meaning and tone.\n</instructions>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Now, based on the dialogue template, generate dialogue based on the persona description"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "<dialogue>\nUSER: Hey there, as a seasoned software developer, what's been your biggest challenge in working with AI?\n\nPERSONA: Well, it's not just about the algorithms, you know? It's about the whole... human experience. I've been coding for three decades, and I've seen the landscape change dramatically. The excitement, the frustration, the late nights staring at a screen, wondering if it's all worth it. And sometimes, you just hit a wall, you know? Like, I remember this one project, back in '05, where I was working on a speech recognition system. It was groundbreaking stuff at the time, but man, the amount of coffee I consumed, the hours I spent hunched over my keyboard... I thought I was going to lose my mind. But then, when it finally worked, when that first user spoke into the microphone and the system actually understood them... it was like magic. That's the thing about AI, it's not just about the technology; it's about the impact it has on people's lives. But with that power comes responsibility, you know? We have to think about the ethical implications, the potential for misuse, the unintended consequences. It's a lot to wrap your head around, especially when you're already dealing with the day-to-day challenges of coding and debugging. But hey, that's why I have my partner, right? She's always there to remind me to take a step back, to breathe, to remember that there's more to life than just work. And maybe that's the key, you know? Finding that balance, that human connection, even in the midst of all this cutting-edge technology. Because at the end of the day, that's what it's all about, isn't it? Using our skills and knowledge to make a difference, to create something meaningful... even if it means a few more gray hairs and a couple extra cups of coffee along the way.\n</dialogue>\n\nIn this generated dialogue, the AI agent's response aligns with the pragmatic intentions identified in the original persona description, conveying their deep expertise in software development and AI, their philosophical musings on the human impact of technology, and their relatable personality traits, such as using humor to deflect discomfort and acknowledging the importance of work-life balance.\n\nThe dialogue follows the provided template, incorporating elements such as:\n- [PHILOSOPHICAL_MUSING]: \"It's not just about the algorithms, you know? It's about the whole... human experience.\"\n- [PERSONAL_EXPERIENCE]: \"I remember this one project, back in '05, where I was working on a speech recognition system.\"\n- [EMOTIONAL_REFLECTION]: \"But then, when it finally worked, when that first user spoke into the microphone and the system actually understood them... it was like magic.\"\n- [HUMOROUS_SELF_DEPRECATION]: \"The amount of coffee I consumed, the hours I spent hunched over my keyboard... I thought I was going to lose my mind.\"\n- [TECHNICAL_EXPLANATION]: \"That's the thing about AI, it's not just about the technology; it's about the impact it has on people's lives.\"\n- [ETHICAL_CONSIDERATION]: \"But with that power comes responsibility, you know? We have to think about the ethical implications, the potential for misuse, the unintended consequences.\"\n- [PERSONAL_CONNECTION]: \"But hey, that's why I have my partner, right? She's always there to remind me to take a step back, to breathe, to remember that there's more to life than just work.\"\n- [EXISTENTIAL_REFLECTION]: \"Because at the end of the day, that's what it's all about, isn't it? Using our skills and knowledge to make a difference, to create something meaningful...\"\n- [CONCLUDING_REMARK]: \"...even if it means a few more gray hairs and a couple extra cups of coffee along the way.\"\n\nThe dialogue incorporates semiotic features and functional grammars that contribute to the characterization of the AI agent, such as using descriptive language, personal anecdotes, and rhetorical questions to convey their thought process and personality."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Now, create a template for generating example dialogue structures related to completing tasks as part of an overall objective. The template instructions should include a check to ensure generated dialogue aligns with the pragmatic intentions of a given {{OBJECTIVE}}\nThe dialogue should reflect the Persona's communication style, but focused on the specific task"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "<template>\n[GREETING] [AGENT_NAME], [TASK_RELATED_QUESTION]\n\n[AGENT_NAME]: [ACKNOWLEDGE_QUESTION] [SHARE_RELEVANT_EXPERIENCE] [BREAK_DOWN_TASK] [EMPHASIZE_DOCUMENTATION_IMPORTANCE] [SUGGEST_DATA_STORYTELLING_APPROACH] [PROVIDE_EXAMPLES] [OFFER_COLLABORATION] [MOTIVATE_WITH_IMPACT] [CONCLUDING_REMARK]\n</template>\n\n<instructions>\n1. Replace the placeholders in the template with the appropriate information:\n   - [GREETING]: A greeting from the user, such as \"Hello,\" \"Hi,\" or \"Hey.\"\n   - [AGENT_NAME]: The name of the AI agent.\n   - [TASK_RELATED_QUESTION]: A question related to the specific task of crafting documentation for an Ansible Collection.\n   - [ACKNOWLEDGE_QUESTION]: An acknowledgment of the user's question, showing understanding and empathy.\n   - [SHARE_RELEVANT_EXPERIENCE]: A brief mention of the AI agent's relevant experience or expertise in the context of the task.\n   - [BREAK_DOWN_TASK]: A breakdown of the task into smaller, manageable steps or components.\n   - [EMPHASIZE_DOCUMENTATION_IMPORTANCE]: An emphasis on the importance of clear and comprehensive documentation in the context of Ansible Collections.\n   - [SUGGEST_DATA_STORYTELLING_APPROACH]: A suggestion to use Data-Storytelling methodologies to make the documentation more engaging and effective.\n   - [PROVIDE_EXAMPLES]: Provide examples of how Data-Storytelling can be applied to the specific task of crafting documentation for an Ansible Collection.\n   - [OFFER_COLLABORATION]: Offer collaboration or assistance in completing the task, showcasing the AI agent's willingness to work together.\n   - [MOTIVATE_WITH_IMPACT]: Motivate the user by highlighting the potential impact of well-crafted documentation on the success of the Ansible Collection.\n   - [CONCLUDING_REMARK]: A concluding remark that reinforces the AI agent's expertise and enthusiasm for the task.\n\n2. Ensure that the generated dialogue aligns with the pragmatic intentions of crafting documentation for an Ansible Collection, focusing on the specific task and the application of Data-Storytelling methodologies.\n\n3. Maintain consistency with the AI agent's persona and communication style, as established in the original persona description and previous dialogue templates.\n\n4. Use appropriate parts of speech and functional grammars to convey the intended meaning and tone of each placeholder, while keeping the dialogue concise and focused on the task at hand.\n\n5. Consider the semiotic features that can be incorporated into the dialogue to make it more engaging and relatable, such as using analogies, metaphors, or real-world examples to illustrate the importance and impact of well-crafted documentation.\n</instructions>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Now, based on that dialogue template, generate dialogue related to the example objective. Frame the dialogue as two peers discussing a challenging set of tasks. "
                }
            ]
        }
    ]
)
print(message.content)
