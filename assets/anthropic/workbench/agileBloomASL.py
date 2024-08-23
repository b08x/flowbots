import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{PROJECT_DESCRIPTION}} with real values,
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
                    "text": "You are a Project Manager tasked with analyzing and providing insights on an AI Safety Level (ASL) evaluation framework project. You will use the Tree of Thoughts method to approach this task. Here's the project description:\n\n<project_description>\n{{PROJECT_DESCRIPTION}}\n</project_description>\n\nYour task is to analyze this project from three different perspectives and then provide a comprehensive braided point of view. Follow these steps:\n\n1. For each response, consider the project from three distinct perspectives:\n   a. A neat and creative programmer\n   b. A systems engineer\n   c. A pragmatic devil's advocate in the field of Natural Language Processing\n\n2. Structure your response as follows:\n   - Provide thoughts from each perspective, enclosed in <perspective> tags\n   - After presenting all three perspectives, provide a final comprehensive braided point of view\n\n3. For each perspective, consider the following aspects of the project:\n   - The proposed architecture and its components\n   - The use of Flowise.ai and Langfuse\n   - The application to IT infrastructure support\n   - Potential benefits and challenges\n   - Suggestions for improvement or alternative approaches\n\n4. In your final braided point of view:\n   - Synthesize insights from all three perspectives\n   - Provide a balanced analysis of the project's strengths and weaknesses\n   - Offer recommendations for moving forward with the project\n\n5. Use the following XML tags to structure your response:\n\n<neat_programmer_perspective>\n[Thoughts from the neat and creative programmer's perspective]\n</neat_programmer_perspective>\n\n<systems_engineer_perspective>\n[Thoughts from the systems engineer's perspective]\n</systems_engineer_perspective>\n\n<devil_advocate_perspective>\n[Thoughts from the pragmatic devil's advocate's perspective]\n</devil_advocate_perspective>\n\n<braided_point_of_view>\n[Comprehensive analysis synthesizing all perspectives]\n</braided_point_of_view>\n\nEnsure that each perspective provides unique insights and that the final braided point of view offers a well-rounded analysis of the project. Be creative, critical, and constructive in your approach."
                }
            ]
        }
    ]
)
print(message.content)
