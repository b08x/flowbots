import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{TEXT}} with real values,
# because the SDK does not support variables.
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=1000,
    temperature=0.6,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Your task is to assess a given text and look for gaps in the pragmatic context. Then, you will negate the premise of the text by asking the question \"or is it?\" This exercise aims to challenge assumptions and encourage critical thinking about the text's implications.\n\nHere is the text you will analyze:\n\n<text>\n{{TEXT}}\n</text>\n\nTo complete this task, follow these steps:\n\n1. Carefully read the provided text.\n\n2. Identify any gaps in the pragmatic context. These may include:\n   - Unstated assumptions\n   - Missing background information\n   - Unclear intentions or motivations\n   - Ambiguous references or meanings\n\n3. Once you've identified a gap or assumption, formulate a way to negate the premise by asking \"or is it?\" This question should challenge the text's main point or underlying assumption.\n\n4. Provide your analysis in the following format:\n   <analysis>\n   a) Briefly summarize the main point or premise of the text.\n   b) Identify the gap in pragmatic context you've found.\n   c) Present your \"or is it?\" question that negates the premise.\n   d) Explain how this negation challenges the original text's assumption or implication.\n   </analysis>\n\n5. If you find multiple gaps or opportunities for negation, you may provide up to three separate analyses, each in its own <analysis> tags.\n\nRemember, the goal is not to definitively disprove the text, but to encourage critical thinking about its premises and implications. Your \"or is it?\" questions should be thought-provoking and highlight alternative perspectives or interpretations."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "<analysis>\na) The main premise of the text is that style transfer in data visualization is a tool that should be used judiciously, with consideration for clarity, audience, and the underlying data's significance.\n\nb) There's a gap in the pragmatic context regarding the assumption that style transfer is always a desirable or necessary technique in data visualization.\n\nc) Or is it? Is style transfer in data visualization always beneficial or even necessary?\n\nd) This negation challenges the original text's implicit assumption that style transfer is a valuable tool in data visualization that just needs to be applied correctly. It raises the question of whether style transfer might sometimes be unnecessary or even detrimental to effective data communication. The text focuses on how to use style transfer properly but doesn't consider whether it should be used at all in certain situations. This negation encourages readers to think critically about the fundamental value of style transfer in data visualization, rather than simply accepting it as a given technique that needs refinement.\n</analysis>\n\n<analysis>\na) The text suggests that behind every data point, there's a human story that shouldn't be overshadowed by stylistic concerns.\n\nb) There's a gap in the pragmatic context regarding the assumption that all data inherently represents human stories or that humanizing data is always appropriate or beneficial.\n\nc) Or is it? Does every data point truly represent a human story, and is humanizing data always the right approach?\n\nd) This negation challenges the text's implication that data should always be viewed through a human lens. It raises questions about the nature of data itself and the appropriateness of always seeking to humanize it. Some data might be purely abstract or represent non-human phenomena, and attempting to force a human narrative onto it could potentially distort its meaning or significance. This negation encourages readers to consider whether there are situations where a more detached, objective approach to data might be more appropriate or insightful.\n</analysis>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "The correct answer was: \n```\n**Mind the Gap:** If your style transfer is about as subtle as a hippopotamus in a tutu, you might need to dial it back a smidge. Remember, the goal is *clarity*, not a psychedelic nightmare. Or is it? \n```\n\nWhy?"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "The chosen section \"Mind the Gap\" makes a clear statement about the goal of style transfer being clarity rather than excessive stylization.\n\nBy adding \"Or is it?\" at the end, this answer directly challenges the premise stated in the text, which is exactly what the task required.\n\nThis negation opens up the possibility that in some cases, a more dramatic or \"psychedelic\" style transfer might actually be desirable or effective, contrary to the original assertion.\n\nIt's a concise and direct way to question the assumption made in the text, encouraging critical thinking about whether clarity should always be the primary goal in style transfer.\n\nMy previous response was overly complex and didn't adhere to the specific format requested. I should have focused on identifying a single statement within the text and negating it with \"or is it?\" as demonstrated in the correct answer."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "It's also sort of ironic.  Now generate a new set of system instructions that set better server the pragmatic intention\n\n"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "You're absolutely right, and I appreciate you pointing that out. The irony in questioning whether clarity should always be the goal in a section about clarity is indeed quite clever. Let me create a new set of system instructions that better capture this pragmatic intention:\n\nNew System Instructions:\n\nYour task is to analyze a given text and identify an opportunity for ironic negation. Follow these steps:\n\n1. Read the provided text carefully.\n\n2. Look for a statement or premise that makes a clear assertion about how something should be done or understood.\n\n3. Create an \"Or is it?\" question that directly challenges this assertion in an ironic or paradoxical way.\n\n4. The negation should:\n   - Be concise, appending \"Or is it?\" directly to the original statement.\n   - Create a thought-provoking contrast with the original assertion.\n   - Potentially highlight the humor or irony in questioning the very principle being advocated.\n\n5. Present your response in this format:\n   [Original statement] Or is it?\n\n6. Briefly explain why your chosen negation is ironic or paradoxical.\n\nRemember, the goal is to create a subtle, clever contradiction that makes the reader pause and reconsider the original statement in a new light. The irony should serve to underscore the complexity of the topic at hand.\n\nThese instructions better serve the pragmatic intention by:\n1. Focusing on irony and paradox, which adds depth to the critical thinking exercise.\n2. Encouraging brevity and directness in the negation.\n3. Emphasizing the humorous or thought-provoking aspect of questioning a principle within its own context.\n4. Aligning more closely with the style and tone of the example provided."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Add in something about ensuring grammatical consistency, for example if it makes sense use \"Or does it?\" instead"
                }
            ]
        }
    ]
)
print(message.content)
