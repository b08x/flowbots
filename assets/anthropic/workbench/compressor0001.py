import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{PROMPT}} with real values,
# because the SDK does not support variables.
message = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=4000,
    temperature=0.3,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Condense the provided prompt instruction example by identifying discourse semantics, pragmatic grammar, and functional grammar to achieve the intended communicative goal while correcting any functional grammar errors. Please differentiate necessary and extraneous details, and replace extraneous details while preserving the context. Provide a clear and concise explanation of the condensation process and the generative grammar of the condensed output. Output the condensed variant in XML format.\n<prompt>\n{{PROMPT}}\n</prompt>"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "The condensation process involves identifying the essential elements of the prompt while removing extraneous details. The discourse semantics convey the main goal: classifying a text into provided categories. The pragmatic grammar structures the task, while the functional grammar guides the desired output format.\n\nCondensed variant:\n<prompt>\nClassify the given text into one of the provided categories:\n<text>{{TEXT}}</text>\n<categories>{{CATEGORIES}}</categories>\n\n<reasoning>Explain your classification reasoning, comparing the text's fit to the selected category versus other options.</reasoning>\n\nOutput the selected category:\n<category></category>\n</prompt>\n\nGenerative grammar of the condensed output:\nS -> <prompt>\nClassify the given text into one of the provided categories:\n<text>{{TEXT}}</text>\n<categories>{{CATEGORIES}}</categories>\n\n<reasoning>Explain your classification reasoning, comparing the text's fit to the selected category versus other options.</reasoning>\n\nOutput the selected category:\n<category></category>\n</prompt>\n\nThe condensed prompt preserves the essential context and communicative goal while removing unnecessary details and correcting functional grammar errors."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Adjust the prompt to generate categories as opposed to selecting\n"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here's the adjusted prompt to generate categories instead of selecting from provided options:\n\n<prompt>\nAnalyze the given text and generate appropriate categories based on its content:\n<text>{{TEXT}}</text>\n\n<reasoning>Explain your thought process for generating each category, focusing on the text's main themes, topics, or characteristics that influenced your choices.</reasoning>\n\nOutput the generated categories, separated by commas:\n<categories></categories>\n</prompt>\n\nGenerative grammar of the adjusted output:\nS -> <prompt>\nAnalyze the given text and generate appropriate categories based on its content:\n<text>{{TEXT}}</text>\n\n<reasoning>Explain your thought process for generating each category, focusing on the text's main themes, topics, or characteristics that influenced your choices.</reasoning>\n\nOutput the generated categories, separated by commas:\n<categories></categories>\n</prompt>\n\nThe adjusted prompt now instructs the AI to generate categories based on the input text rather than selecting from a predefined list. The <reasoning> tag encourages the AI to explain its thought process for generating the categories, considering the text's main themes, topics, or characteristics. The generated categories are to be output within the <categories> tag, separated by commas."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Adjust the prompt to also look for Named Entities to look up in a search"
                }
            ]
        }
    ]
)
print(message.content)
