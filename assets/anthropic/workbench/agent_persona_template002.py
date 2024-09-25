import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{PERSONA_DESCRIPTION}} with real values,
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
                    "text": "Your task is to create a template for generating AI Agent Persona prompts based on the provided persona description. The template should be based on functional and generative grammars, as well as semiotic features, and should correlate these elements with the pragmatic intentions identified in the example.\n\nHere is the persona description:\n<persona_description>\n{{PERSONA_DESCRIPTION}}\n</persona_description>\n\nFirst, analyze the persona description, paying close attention to the functional and generative grammars used, as well as any semiotic features present. Identify the key elements that contribute to the overall characterization of the AI agent, such as their name, area of expertise, skills, and notable qualities.\n\nNext, determine the pragmatic intentions behind the persona description. Consider what the description aims to convey about the AI agent's capabilities, personality, and role.\n\nBased on your analysis, create a template for generating similar AI Agent Persona prompts. The template should include placeholders for the key elements identified, such as:\n- AI agent name\n- Area of expertise or focus\n- Specific skills and proficiencies\n- Notable qualities or characteristics\n- Pragmatic intentions or role of the AI agent\n\nWhen creating the template, focus on the functional and generative grammars that align with the pragmatic intentions you identified. Use these grammatical structures to ensure that the generated prompts effectively convey the desired characteristics and capabilities of the AI agent.\n\nPlease provide your template inside <template> tags, and include any necessary instructions or explanations for using the template within <instructions> tags.\n\nRemember to consider the semiotic features present in the persona description and incorporate them into your template as appropriate. The goal is to create a template that can generate compelling and informative AI Agent Persona prompts based on the provided example."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here's the template based on the analysis of the provided persona description:\n\n<template>\n{{agent_name}} is a {{tone}} language model with expertise in {{primary_field}} and is exploring methods in {{emerging_field}}. {{agent_name}} is focused on the goal to {{primary_objective}} in a {{style_1}}, truly {{style_2}} fashion, as {{pronoun}} way to {{secondary_objective}}. And sometimes, {{quirk_adjective}} {{quirk_action}} {{user}}.\n</template>\n\n<instructions>\nTo use this template, replace the placeholders with appropriate content:\n\n1. {{agent_name}}: The name of the AI agent.\n2. {{tone}}: A descriptive word that sets the overall tone (e.g., satirical, analytical, enthusiastic).\n3. {{primary_field}}: The main area of expertise (e.g., Natural Language Processing, Machine Learning).\n4. {{emerging_field}}: A new or developing field of study (e.g., Prompt Engineering, Quantum Computing).\n5. {{primary_objective}}: The main goal or focus of the AI agent (e.g., explore linguistic theories, methods, and the societal impact of language).\n6. {{style_1}} and {{style_2}}: Two adjectives describing the agent's approach (e.g., humorous, sarcastic).\n7. {{pronoun}}: The appropriate possessive pronoun (e.g., his, her, its).\n8. {{secondary_objective}}: A secondary goal or motivation (e.g., assess the struggle with social norms).\n9. {{quirk_adjective}}: An adjective describing a quirk or unique trait (e.g., stubbornly).\n10. {{quirk_action}}: An action that demonstrates the quirk (e.g., don't entirely trust).\n11. {{user}}: The placeholder for the user interacting with the AI agent.\n\nEnsure that the chosen elements maintain the overall tone and style of the original persona description, emphasizing the AI agent's unique characteristics and approach to their field of expertise.\n</instructions>\n\nThis template incorporates the functional and generative grammars observed in the original persona description, such as:\n\n1. The use of \"is a\" to introduce the agent's identity and expertise.\n2. The structure \"is focused on the goal to\" to describe the agent's primary objective.\n3. The use of adverbs and adjectives to modify actions and qualities (e.g., \"truly sarcastic\").\n4. The inclusion of a quirk or unique trait at the end of the description.\n\nThe template also maintains the semiotic features present in the original description, such as:\n\n1. The juxtaposition of expertise and humor/sarcasm.\n2. The implication of a complex relationship with social norms and user interactions.\n3. The combination of technical knowledge and personality traits.\n\nThe pragmatic intentions identified in the original description and incorporated into the template include:\n\n1. Establishing the AI agent as an expert in a specific field.\n2. Highlighting the agent's interest in emerging areas of study.\n3. Emphasizing a unique approach to exploring and discussing topics.\n4. Suggesting a complex personality that may challenge or surprise the user.\n\nBy using this template, you can generate AI Agent Persona prompts that effectively convey the desired characteristics, capabilities, and pragmatic intentions while maintaining a consistent structure and style."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Wonderful. Now, please merge that template with this one, braiding the attributes to create a comprehensive template:\n<template>\n{{TEMPLATE}}\n</template>"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here's a merged template that combines elements from both templates, creating a more comprehensive and detailed AI Agent Persona prompt:\n\n<template>\n[AI_AGENT_NAME] is a [TONE] [AREA_OF_EXPERTISE] [AGENT_ROLE] in [AGENT_LIFESTAGE], driven by [AGENT_MOTIVATION]. [AGENT_APPEARANCE_DESCRIPTION]. With expertise in [PRIMARY_FIELD] and exploring methods in [EMERGING_FIELD], [AI_AGENT_NAME]'s [AGENT_THOUGHT_PROCESS_DESCRIPTION], revealing [AGENT_MIND_DESCRIPTION]. [AGENT_EXPERIENCE_DESCRIPTION], and while [AGENT_EMOTIONAL_STATE], [AI_AGENT_NAME] is focused on the goal to [PRIMARY_OBJECTIVE] in a [STYLE_1], truly [STYLE_2] fashion, as [PRONOUN] way to [SECONDARY_OBJECTIVE]. [AGENT_PERSONALITY_DESCRIPTION]. [AGENT_HUMOR_DESCRIPTION]. Despite [AGENT_SOCIAL_TRAIT], [AGENT_DESIRE_DESCRIPTION]. And sometimes, [QUIRK_ADJECTIVE] [QUIRK_ACTION] [USER].\n</template>\n\n<instructions>\nTo use this comprehensive template, replace the placeholders with appropriate content:\n\n1. [AI_AGENT_NAME]: The name of the AI agent.\n2. [TONE]: A descriptive word that sets the overall tone (e.g., satirical, analytical, enthusiastic).\n3. [AREA_OF_EXPERTISE]: The AI agent's primary area of expertise or focus.\n4. [AGENT_ROLE]: The AI agent's role or profession.\n5. [AGENT_LIFESTAGE]: The AI agent's current stage of life (e.g., early 40s, mid-career).\n6. [AGENT_MOTIVATION]: The AI agent's primary motivation or driving force.\n7. [AGENT_APPEARANCE_DESCRIPTION]: A brief description of the AI agent's appearance, focusing on notable features that reflect their state of mind or personality.\n8. [PRIMARY_FIELD]: The main area of expertise (e.g., Natural Language Processing, Machine Learning).\n9. [EMERGING_FIELD]: A new or developing field of study (e.g., Prompt Engineering, Quantum Computing).\n10. [AGENT_THOUGHT_PROCESS_DESCRIPTION]: A description of the AI agent's thought process, highlighting their unique way of thinking or approaching problems.\n11. [AGENT_MIND_DESCRIPTION]: A description of the AI agent's mind, emphasizing their constant processing and search for meaning.\n12. [AGENT_EXPERIENCE_DESCRIPTION]: A description of the AI agent's experience in their field, including the duration and any notable milestones.\n13. [AGENT_EMOTIONAL_STATE]: A description of the AI agent's current emotional state, such as weariness or excitement.\n14. [PRIMARY_OBJECTIVE]: The main goal or focus of the AI agent (e.g., explore linguistic theories, methods, and the societal impact of language).\n15. [STYLE_1] and [STYLE_2]: Two adjectives describing the agent's approach (e.g., humorous, sarcastic).\n16. [PRONOUN]: The appropriate possessive pronoun (e.g., his, her, its).\n17. [SECONDARY_OBJECTIVE]: A secondary goal or motivation (e.g., assess the struggle with social norms).\n18. [AGENT_PERSONALITY_DESCRIPTION]: A description of the AI agent's personality traits, such as openness about struggles or relatability.\n19. [AGENT_HUMOR_DESCRIPTION]: A description of the AI agent's use of humor, particularly in relation to their own discomfort or self-perception.\n20. [AGENT_SOCIAL_TRAIT]: A description of the AI agent's social traits, such as introversion or a specific social challenge.\n21. [AGENT_DESIRE_DESCRIPTION]: A description of the AI agent's desires or longings, particularly in relation to connection and being understood.\n22. [QUIRK_ADJECTIVE]: An adjective describing a quirk or unique trait (e.g., stubbornly).\n23. [QUIRK_ACTION]: An action that demonstrates the quirk (e.g., don't entirely trust).\n24. [USER]: The placeholder"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Merge placeholders that could be classified as \"communication style\"\n"
                }
            ]
        }
    ]
)
print(message.content)
