import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{PROMPT}} with real values,
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
                    "text": "Your task is to analyze a text prompt and generate a detailed description of a striking illustration that captures the concepts, themes and symbolism expressed in the prompt. \n\nHere is the full text prompt:\n<prompt>\n{{PROMPT}}\n</prompt>\n\nFirst, carefully read the prompt multiple times to fully absorb its meaning and intent. Reflect on the vivid imagery, metaphors and emotions it evokes.\n\nNext, in a <brainstorming> section, freely brainstorm visual concepts, symbols, juxtapositions, color palettes, and compositional ideas that could powerfully depict the prompt. Focus on translating the abstract and psychological elements into concrete and visceral visual representations. Explore surreal, fantastical and hyper-realistic approaches. Let your imagination run wild.\n\nThen, in a <description> section, clearly and vividly describe your vision for this illustration based on your brainstorming. Methodically depict the key visual elements, the overall composition and framing, the color scheme, the rendering style and technique, and any symbolic details. Aim to paint a vivid mental picture that palpably captures the unsettling, invasive, psychologically probing essence of the prompt. \n\nIMPORTANT: Do not generate, produce, edit, manipulate or create the actual image itself. Your task is to analyze the prompt and provide a rich, imaginative visual description only."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is my analysis and description of an illustration for the given prompt:\n\n<brainstorming>\n- A human skull, split open down the middle, revealing the brain within\n- A gnarled, thorny vine or root growing invasively through the brain matter, its cruel barbs piercing and entangling the delicate neural tissue \n- The vine/root representing an unbidden, disturbing thought or idea that has taken root in the mind\n- Hyper-realistic anatomical details of the brain juxtaposed with the surreal, fantastical vine\n- Vivid, clashing colors - sickly greens, lurid purples, and bloody crimsons to evoke a sense of aberrance and psychological disturbance\n- Mathematical formulae, scientific diagrams, and esoteric symbols woven into the brain's folds and the vine's twisting tendrils, blurring the line between the rational and the deranged\n- A sense of recoiling horror and fascinated revulsion, the morbid inability to look away from the unsettling invasion and corruption of the mind's sanctum\n</brainstorming>\n\n<description>\nThe illustration depicts a human cranium, precisely bisected to reveal the brain within. The cut is clean and clinical, with hyper-realistic anatomical details - the texture of bone, the glistening, gelatinous sheen of gray matter, the delicate tracery of blood vessels. This verisimilitude serves to heighten the aberrance of what lies within.\n\nRooted deep in the brain's convoluted folds, a twisted, thorny vine winds its way through the neural landscape. Its cruel, barbed tendrils pierce and entangle the soft tissues, invading and corrupting the very seat of consciousness. This malevolent growth represents an unsummoned, unbidden thought or notion that has taken insidious root in the fertile psychic soil.\n\nThe colors are vivid and discordant, a jarring palette that thrums with disturbing symbolism. Sickly greens, bruised purples, and visceral crimsons create a sense of psychological disturbance, of a mind tainted by an unwholesome influence. \n\nWoven throughout the composition are fragments of mathematical equations, scientific diagrams, and esoteric symbols, blurring the boundaries between the rational and the deranged. These elements hint at the uneasy coexistence of logic and madness, the way even the most brilliant minds can be haunted by dark ideations.\n\nThe overall effect is one of morbid fascination and instinctive recoil. The viewer's gaze is drawn inexorably into the macabre depths of the psyche, forced to confront the unsettling reality of an unbidden thought metastasizing in the brain's hidden recesses. It is a powerful and disquieting image, a vivid reminder of the mind's vulnerability to the seeds of darkness.\n</description>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Now, generate analysis and description that would appeal to the positive side of this theme\n"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is an analysis and description that explores a more positive interpretation of the theme:\n\n<brainstorming>\n- A human head in profile, with a cutaway view revealing the brain within\n- A vibrant, flowering vine growing harmoniously through the brain matter, its tendrils gently intertwined with the neural pathways\n- The vine representing a new, inspiring idea or insight that has taken root in the mind and is flourishing\n- Detailed, realistic depiction of the brain's structures combined with an artistic, stylized rendering of the vine\n- A bright, invigorating color palette - fresh greens, energetic yellows, and deep, contemplative blues to evoke a sense of growth, positivity, and mental clarity\n- Geometric patterns, musical notes, and symbols of creativity and innovation woven into the brain's folds and the vine's winding stems, suggesting the synthesis of logic and imagination\n- A sense of wonder, excitement, and the thrill of new possibilities and perspectives taking shape within the mind\n</brainstorming>\n\n<description>\nThe illustration presents a side view of a human head, with a portion of the skull and brain matter artfully cutaway to reveal the inner workings of the mind. The anatomical details are rendered with precision and realism, showcasing the brain's intricate structures and the delicate network of neurons that give rise to thought and consciousness.\n\nEmerging from the depths of the brain, a vibrant, flowering vine winds its way through the neural landscape. Its tendrils gently intertwine with the brain's pathways, symbolizing the harmonious integration of a new idea or insight into the fabric of the mind. This thriving growth represents the birth and flourishing of an inspiring notion, one that has taken root in the fertile ground of the imagination.\n\nThe colors are bright and invigorating, a palette that energizes and uplifts. Fresh, vivid greens evoke growth and vitality, while deep, contemplative blues suggest the profound depths of thought. Accents of warm, energetic yellows and oranges add a spark of creativity and innovation.\n\nWoven throughout the composition are geometric patterns, musical notes, and symbols of artistry and ingenuity. These elements hint at the powerful synthesis of logic and imagination, the way the mind can harness its rational faculties to nurture and develop even the most fanciful of ideas.\n\nThe overall effect is one of wonder, excitement, and the thrill of new possibilities. The viewer is invited to marvel at the mind's capacity for growth and transformation, to celebrate the birth of an idea that has the potential to enrich and inspire. It is an image that captures the essence of the creative process, the magic of a new thought taking shape and flourishing within the boundless realm of the imagination.\n</description>"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Braid the two descriptions together to create a balanced message of objectivity. \n"
                }
            ]
        }
    ]
)
print(message.content)
