import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{CODE_FUNCTIONS}} with real values,
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
                    "text": "You are tasked with creating a creative and engaging README.md file for a GitHub repository based on provided explanations of code functions within the repo or application. Your goal is to craft a README that not only informs but also excites potential users or contributors about the project.\n\nHere is the information about the code functions in the repository:\n\n<code_functions>\n{{CODE_FUNCTIONS}}\n</code_functions>\n\nThe name of the repository is:\n\n<repo_name>\n{{REPO_NAME}}\n</repo_name>\n\nUsing this information, create a README.md file with the following structure:\n\n1. Project Title and Description\n2. Features\n3. Installation\n4. Usage\n5. Contributing\n6. License\n\nWhen crafting the README.md:\n\n1. For the Project Title, use the repo_name in a creative way. Create a catchy tagline or brief description that captures the essence of the project.\n\n2. In the Description, provide an overview of what the project does, its purpose, and why it's useful or innovative. Use the information from the code functions to inform this section, but write it in an engaging, non-technical manner.\n\n3. For the Features section, list the main functionalities of the project based on the code functions provided. Make this section visually appealing by using emojis or bullet points.\n\n4. In the Installation section, provide a brief guide on how to set up the project. If there's not enough information to provide specific steps, give a general outline and mention any dependencies you can infer from the code functions.\n\n5. For the Usage section, provide examples of how to use the main functions of the project. Use code blocks to illustrate these examples.\n\n6. In the Contributing section, encourage others to contribute to the project. Suggest areas where contributions would be welcome based on the current functionalities.\n\n7. For the License section, if no specific license is mentioned in the code functions, simply state \"License information not provided.\"\n\nThroughout the README, maintain a friendly and enthusiastic tone. Use markdown formatting to make the document visually appealing and easy to read. Feel free to add relevant sections if you believe they would enhance the README based on the information provided.\n\nBe creative! Your goal is to make this README stand out and get people excited about the project. You can use analogies, metaphors, or even a theme that ties into the project's purpose to make it more engaging.\n\nPresent your final README.md content within <readme> tags. Do not include any explanation or commentary outside of these tags."
                }
            ]
        }
    ]
)
print(message.content)
