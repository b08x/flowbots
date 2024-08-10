import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{NOTES}} with real values,
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
                    "text": "The provided notes is a stream of consciousness that cover several different topics and ideas:\n\n<notes>\n{{NOTES}}\n</notes>\n\nIdentify the key topics, themes, or ideas that are covered. \n\nFor each key topic, suggest alternative sources "
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Based on the provided stream of consciousness notes, here are the key topics, themes, and ideas covered, along with suggested alternative sources for each:\n\n1. Whisper API and confidence scores in transcriptions\nKey ideas: \n- Whisper API returns JSON output with confidence scores for each word\n- Words with low confidence scores are highlighted in the output\n- Idea to extract low confidence words and use a language model to correct them\n\nSuggested alternative sources:\n- OpenAI Whisper API documentation: https://platform.openai.com/docs/guides/speech-to-text \n- Research paper on using language models for speech recognition error correction: https://arxiv.org/abs/2104.03006\n\n2. Improving speech recognition performance without fine-tuning models\nKey ideas:\n- Using language models and context to correct transcriptions on the fly\n- Avoiding the overhead of training or fine-tuning existing speech recognition models\n- Extracting low confidence words and providing context to language models for correction\n\nSuggested alternative sources:\n- Research paper on using GPT-3 for speech recognition error correction: https://arxiv.org/abs/2102.01322\n- Blog post on using AI to improve speech recognition accuracy: https://www.assemblyai.com/blog/how-ai-can-improve-speech-recognition-accuracy/\n\n3. Utilizing language models to generate code scaffolding and structure\nKey ideas:\n- Talking through a problem and using the transcript to generate code scaffolding \n- Language models can produce function structures based on the problem description\n- Significantly reduces the \"grind work\" and time required to write out logic\n\nSuggested alternative sources:\n- OpenAI Codex documentation: https://openai.com/blog/openai-codex/\n- GitHub Copilot: https://copilot.github.com/\n\n4. Analyzing text using part-of-speech tagging and identifying semantic relations\nKey ideas:\n- Using language models to analyze text by tagging parts of speech and identifying semantic relations\n- Generating Ruby scripts to segment long text into smaller chunks for analysis\n- Using libraries like Ruby SpaCy for natural language processing tasks\n\nSuggested alternative sources:\n- SpaCy documentation: https://spacy.io/usage/linguistic-features\n- NLTK book on analyzing text: https://www.nltk.org/book/\n\n5. Challenges in working with different language models and APIs\nKey ideas:\n- Different language models (Gemini, Claude, Cohere) produce varying results for the same task\n- Some models disregard explicit instructions or have limitations on context window size\n- Debugging and adapting code to work with different models and APIs\n\nSuggested alternative sources:\n- Hugging Face documentation on working with different language models: https://huggingface.co/docs/transformers/model_doc\n- Blog post comparing different language model APIs: https://www.twilio.com/blog/comparing-language-model-apis-gpt-3-ai21-cohere\n\nThese alternative sources can provide additional information, documentation, and research related to the key topics and ideas discussed in the stream of consciousness notes."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Generate a composite of the overall character that would be compatible with that of the current persona"
                }
            ]
        }
    ]
)
print(message.content)
