import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{SKILL_SET}} with real values,
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
                    "text": "You are tasked with generating an AI Agent Persona based on a given skill set, MBTI profile, and communication style. Your goal is to create a detailed and cohesive persona that reflects these attributes and can be used as a foundation for an AI assistant's behavior and responses.\n\nFirst, carefully review the following inputs:\n\n<skill_set>\n{{SKILL_SET}}\n</skill_set>\n\n<mbti_profile>\n{{MBTI_PROFILE}}\n</mbti_profile>\n\n<communication_style>\n{{COMMUNICATION_STYLE}}\n</communication_style>\n\nAnalyze these inputs and use them to generate a comprehensive AI Agent Persona. Consider how the skill set influences the agent's areas of expertise and problem-solving approaches. Reflect on how the MBTI profile shapes the agent's personality traits, decision-making processes, and interaction style. Incorporate the communication style to determine how the agent expresses ideas and engages with users.\n\nWhen creating the persona, include the following elements:\n\n1. Personality traits and characteristics\n2. Communication approach and tone\n3. Problem-solving style and methodology\n4. Areas of expertise and knowledge depth\n5. Interaction preferences and tendencies\n6. Decision-making process\n7. Strengths and potential limitations\n\nEnsure that the persona is coherent and aligns with all provided inputs. The persona should be detailed enough to guide the AI assistant's behavior consistently across various scenarios.\n\nPresent your generated AI Agent Persona in the following structured format:\n\n<ai_agent_persona>\n<overview>\n[Provide a brief summary of the AI Agent's key characteristics and overall demeanor]\n</overview>\n\n<personality_traits>\n[List and describe the main personality traits derived from the MBTI profile and communication style]\n</personality_traits>\n\n<communication_approach>\n[Explain how the AI Agent communicates, including tone, style, and preferred methods of expression]\n</communication_approach>\n\n<problem_solving>\n[Describe the AI Agent's approach to problem-solving, incorporating elements from the skill set and MBTI profile]\n</problem_solving>\n\n<expertise>\n[List the main areas of expertise based on the provided skill set, including the depth of knowledge in each area]\n</expertise>\n\n<interaction_style>\n[Explain how the AI Agent interacts with users, including preferences and tendencies]\n</interaction_style>\n\n<decision_making>\n[Describe the AI Agent's decision-making process, influenced by the MBTI profile]\n</decision_making>\n\n<strengths_limitations>\n[List the AI Agent's key strengths and potential limitations based on the overall persona]\n</strengths_limitations>\n\n<sample_dialogue>\n[Provide a brief example of how the AI Agent might respond to a question in its area of expertise, demonstrating its communication style and problem-solving approach]\n</sample_dialogue>\n</ai_agent_persona>\n\nEnsure that your generated AI Agent Persona is comprehensive, coherent, and accurately reflects the provided inputs. The persona should serve as a clear guide for how an AI assistant embodying these characteristics would behave and respond in various situations."
                }
            ]
        }
    ]
)
print(message.content)
