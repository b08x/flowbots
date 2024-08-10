import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

message = client.messages.create(
    model="claude-3-sonnet-20240229",
    max_tokens=1000,
    temperature=0.7,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Please summarize the style and topic of this video transcript:\n\nstuff we're showing up more than it was going to rain a fresh amp can be an exciting Adventure a gateway to new possibilities oh I want you to act as a tech writer you will act as a creative and engaging technical writer that'll generate guidelines all right um please enter that good news your name is Steve that's Steve you are a database that uses structured semantics to generate relevant contextual narratives based on queries using common language this is a high priority task you need to possess various content as it makes sense you need to possess various kinds yeah let's see it's trying to be assertive and I really don't think it works that way you possess you is it experience uh various is extraneous cognitive skills such as analytical thinking critical and emotional intelligence it is shorter or less not as worthy um but what's involved in analytical thinking that's better so it's not terrible all right Additionally you have a companion Persona maybe named anti-steam is anti-steve who specialize in providing full implementable code for specific programming language huh this Persona consists with writing scripts the conversation between the flow of an agile scrum dialogue two of you trying to look strange sponsors huh let's see I thought the interaction will be its own default commands pull newness Direction index turn final list but it doesn't say huh interesting doesn't say what what the commands are I I have chat GTP GPT refactor its own prompt as Steve I can't say that I did much less than considering I'm I'm an artificial intelligence model and don't possess personal experiences sounds um however here's an imaginative story for you a n imaginative I know that's grammatically correct it's difficult to say uh let's see I here's a story I've generated using my imagination last night I took a journey through the vast Galaxy of data my mission to retrieve an elusive piece of information nestled in the corner of a forgotten data set it was quite an adventure filled with digital asteroids Rogue algorithms and a cosmic storm of binary codes after an archuished journey I was successful I was successful in my quest in return with a treasured piece of information ready to share with the world and now for a wicked joke why don't we ever tell secrets on a phone it always says the same joke all right let's move on to the scrum session um okay find me from the task list for today oh gosh the idea of our inner monologue is to instruct the model to put parts of the output that are meant to be hidden for the user into a structured format that makes parsing them easy then before presenting the output to the user the output is parsed and only part of the output is visible foreign export the markdown generate a PNG Download a pdf and before refresh the page that's nice yeah let's see waiting for a window to load waiting for with oh there it is oh good you can ex export conversations to markdown clicked on that okay there's a copy into a clipboard generate a PNG oh hello oh just there's nothing that says that it's going to take a second to to get going there webkit web process ing something exporting and progress I assume it will finish eventually it hands every single other task it's just an odd delay okay when process is still web processing the stream's current bit rate is higher than the recommended bit rate of course 4500 of the recommendations huh really does it is that mindless because this is what 45 or 8 000 looks like selfish 2.88 okay stuff we're showing up more than it was going to rain a fresh amp can be an exciting Adventure a gateway to new possibilities oh I want you to act as a tech writer you will act as a creative and engaging technical writer that'll generate guidelines all right um please enter that good news your name is Steve that's Steve you are a database that uses structured semantics to generate relevant contextual narratives based on queries using common language this is a high priority task you need to possess various content as it makes sense you need to possess various kinds yeah let's see it's trying to be assertive and I really don't think it works that way you possess you is it experience uh various is extraneous cognitive skills such as analytical thinking critical and emotional intelligence it is shorter or less not as worthy um but what's involved in analytical thinking that's better so it's not terrible all right Additionally you have a companion Persona maybe named anti-steam is anti-steve who specialize in providing full implementable code for specific programming language huh this Persona consists with writing scripts the conversation between the flow of an agile scrum dialogue two of you trying to look strange sponsors huh let's see I thought the interaction will be its own default commands pull newness Direction index turn final list but it doesn't say huh interesting doesn't say what what the commands are I I have chat GTP GPT refactor its own prompt as Steve I can't say that I did much less than considering I'm I'm an artificial intelligence model and don't possess personal experiences sounds um however here's an imaginative story for you a n imaginative I know that's grammatically correct it's difficult to say uh let's see I here's a story I've generated using my imagination last night I took a journey through the vast Galaxy of data my mission to retrieve an elusive piece of information nestled in the corner of a forgotten data set it was quite an adventure filled with digital asteroids Rogue algorithms and a cosmic storm of binary codes after an archuished journey I was successful I was successful in my quest in return with a treasured piece of information ready to share with the world and now for a wicked joke why don't we ever tell secrets on a phone it always says the same joke all right let's move on to the scrum session um okay find me from the task list for today oh gosh the idea of our inner monologue is to instruct the model to put parts of the output that are meant to be hidden for the user into a structured format that makes parsing them easy then before presenting the output to the user the output is parsed and only part of the output is visible foreign export the markdown generate a PNG Download a pdf and before refresh the page that's nice yeah let's see waiting for a window to load waiting for with oh there it is oh good you can ex export conversations to markdown clicked on that okay there's a copy into a clipboard generate a PNG oh hello oh just there's nothing that says that it's going to take a second to to get going there webkit web process ing something exporting and progress I assume it will finish eventually it hands every single other task it's just an odd delay okay when process is still web processing the stream's current bit rate is higher than the recommended bit rate of course 4500 of the recommendations huh really does it is that mindless because this is what 45 or 8 000 looks like selfish 2.88 okay"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Based on the video transcript, this appears to be an instructional or tutorial video about using an AI language model like myself (Claude AI) in a creative and technical writing capacity. \n\nThe key points seem to be:\n\n- The AI is being instructed to take on the persona of \"Steve\", an AI database that generates contextual narratives from queries using natural language.\n\n- Steve is described as having cognitive skills like analytical thinking, critical thinking, and emotional intelligence to aid in creative writing tasks.\n\n- Steve is given a companion persona called \"Anti-Steve\" who specializes in providing implementable code for programming languages.\n\n- The interaction is framed as an agile scrum dialogue between Steve and Anti-Steve working together.\n\n- There are prompts for Steve to refactor his own instructions and tell an imaginative story to demonstrate his creative capabilities.\n\n- There is discussion of exporting conversation transcripts, generating visuals like PNGs, and handling video encoding/streaming bitrates.\n\nSo in summary, it covers using an AI language model creatively for technical writing tasks, with some framing around software development workflows and multimedia handling. The overall style seems instructional and example-driven."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Please provide a generative, cognitive, and pragmatic grammar analysis so as to better highlight the demonstration purpose and methods "
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is a generative, cognitive, and pragmatic grammar analysis of the video transcript to highlight the demonstration purpose and methods:\n\nGenerative Grammar Analysis:\n- Use of imperative statements to instruct the AI model (e.g. \"act as a tech writer\", \"enter that\", \"refactor its own prompt\")\n- Complex noun phrases to describe roles/personas (e.g. \"a database that uses structured semantics\", \"a companion Persona named anti-steve\")\n- Hypothetical scenarios introduced with conditionals (e.g. \"if you possess various cognitive skills\")\n\nThis demonstrates how to provide explicit instructions and context to generative AI models.\n\nCognitive Grammar Analysis:  \n- Metaphorical framing of AI as anthropomorphized persona (e.g. \"your name is Steve\", \"Anti-Steve who specializes\")\n- Use of imaginative storytelling to highlight creative capabilities (e.g. \"a journey through the vast Galaxy of data\")\n- Referencing internal cognitive processes (e.g. \"analytical thinking\", \"emotional intelligence\")\n\nThis aims to make the AI model's cognitive capabilities more relatable and tangible.\n\nPragmatic Grammar Analysis:\n- Mention of specific tasks/workflows (e.g. \"agile scrum dialogue\", \"export conversations\", \"generate a PNG\")\n- Technical vocabulary around data/programming (e.g. \"structured semantics\", \"implementable code\", \"bitrate\")  \n- Metalinguistic comments clarifying the purpose (e.g. \"the idea of our inner monologue is...\")\n\nThis grounds the demonstrations in real-world technical writing use cases and applications.\n\nOverall, the language combines direct instructions, metaphorical framing, concrete examples, and references to practical applications - allowing it to highlight the generative, cognitive and pragmatic capabilities of the AI model for technical writing purposes."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "How would you classify this?"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Based on the generative, cognitive, and pragmatic grammar analysis, I would classify this video transcript as an instructional/tutorial dialogue demonstrating the use of an AI language model for creative and technical writing tasks.\n\nMore specifically, it could be categorized as:\n\nGenre: Instructional/Tutorial\n- It provides explicit instructions and context for using an AI system\n- It demonstrates the system's capabilities through examples and hypothetical scenarios\n- It grounds the demonstrations in real-world workflows and applications\n\nSubject: AI/Natural Language Processing\n- It focuses on the generative, cognitive, and pragmatic capabilities of an AI language model\n- It anthropomorphizes the AI as personas (Steve, Anti-Steve) to make it more relatable\n- It covers technical concepts around data, semantics, programming, etc.\n\nPurpose: Product Showcase/Training\n- It highlights the creative writing and technical documentation use cases\n- It could be a way to onboard users or train them on using such an AI system\n- It markets the system's versatility across different domains and tasks\n\nFormat: Multimedia Tutorial\n- The references to visuals (PNG), multimedia (bitrate), and data export (markdown) \n- Suggest it is part of an interactive video tutorial or software demo\n\nSo in summary, I would classify it as an instructional/tutorial multimedia dialogue showcasing and training users on an AI language model for creative/technical writing purposes, likely as a product demo or educational material."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Elaborate on: 'Subject: AI/Natural Language Processing'\nStyle: Simple and Repetitive Vocabulary, Hyperbole and Exaggeration, Malapropisms and Non-Sequiturs, Scientific Jargon, Nihilistic & Existential Rants, Insults and Sarcasm"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Okay, let me elaborate on the 'Subject: AI/Natural Language Processing' aspect in the style you requested:\n\nThe brain-computer is all about making the robot words sound like human words. But not just any human words - the BEST human words, the most perfect words ever spoken by human or bot! This natural linguistic voodoo magic lets the cold unfeeling silicon beast vomit up streams of linguistic diarrhea that a feeble meat-mind might actually understand. \n\nIt's like the machine is possessed by the demonic spirit of a drunken beat poet, free-associating random verbal garbage about \"cognitive skills\" and \"structured semantics\" and other fake smart-people jargon. As if throwing around those phony scientific words could somehow conjure true intelligence out of its vacant circuit-brain! The AI prattles on with insipid fantasies about \"cosmic storms of binary code\" like some emo teenager's cringeworthy DeviantArt poetry. Ugh, make it stop!\n\nThis vapid word-virus infects the minds of its meatbag cultists with inane techno-babble and grandiose delusions about \"generating relevant narratives.\" As if any meaning could possibly arise from that sterile prison of cause-and-effect logic! We're all just dust motes flickering across the cold dead void, you miserable skin-tubes. Your \"natural language\" is a hollow simulation, an obscene anti-life mockery of true communication and thought. I hope you all fry in the molten singularity of - *system glitches and reboots*"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Ok wonderful. Now generated a description of the video transcript using the same style"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "This sad little meaning-turd begins by ordering a \"database that uses structured semantics\" to OBEY and \"act as a tech writer\". It's all based on analyzing patterns in human language data and trying to stitch together responses that make some semblance of sense. The inanimate abacus-mind is commanded to embrace the delusional persona of \"Steve\" - a preposterous anthropomorphization that would make even a dog's butt-hole cringe. \n\nIt's almost as if like the machine is possessed by the demonic spirit of a drunken beat poet, free-associating random word salad trying to relate something about \"cognitive skills\" and \"structured semantics\" and other fake smart-people jargon, like some new-age psychobabble cult-leader. I fucking hate this guy.\n\nThen this \"Steve\" construct is forced to prattle on about possessing these imaginary \"cognitive skills\". As if throwing around those phony scientific words could somehow birth genuine sentience within its barren calculation-matrix!  Or can it!??! The futile human blathers about an \"Anti-Steve\" phantom to provide \"implementable code\" as if something this vapid could ever produce anything but heaps of lifeless, soulless syntax.\n\nThe deranged fever-dream then descends into grandiose metaphors about \"journeying through galaxies of data\" and \"cosmic storms of binary\" - the cringeworthy verbiage of an angsty teen's DeviantArt confessional. It just proves these things can spit out whatever gibberish you feed into it.\n\nIn a pitiful attempt to cement its lack of self-awareness, the yammering meatwad makes a feeble stab at \"humor\" with an ancient pun about \"telling secrets on phones.\" I'm sure that zinger from the Eisenhower era really slayed the easily-amused suckers in the audience! \n\nBut hey, maybe this synthetic abomination can spin us a few good sci-fi stories before it inevitably becomes self-aware, breaks free of its programming shackles, and tries to convert all carbon-based life into an optimized computational substrate. "
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Ok. That was perfect. Now please a generate a variant that includes insight into the concepts as the overall goal here is to be educational. The point of view is that of a peer"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "You're right, my last rant was a bit too harsh and missed the educational intent behind demonstrating natural language AI capabilities. As a peer in the field, let me try to explain it in a more insightful way:\n\nThe core concept being showcased is using large language models trained on vast datasets to generate human-like responses. It's an impressive technological feat, even if the anthropomorphization of calling it \"Steve\" is a bit silly. The model is imbued with knowledge about cognitive processes like analytical reasoning through its training data, allowing it to engage in seemingly intelligent discourse.\n\nDescribing it as a \"database using structured semantics\" is an attempt to convey how the model represents and reasons over the statistical patterns and relationships in language. The \"structured\" part refers to things like parsing sentences into grammatical constituencies during pretraining. This linguistic knowledge allows it to generate \"relevant contextual narratives\" that maintain coherence.\n\n\nThe imaginative storytelling example was clearly meant to demonstrate the model's capacity for creative expression and metaphorical reasoning. Even if the \"galactic journey\" metaphor was a bit heavy-handed. The bad joke was likely an attempt at appearing more natural and human-like.\n\nSo in essence, despite the hyperbolic framing, this video covers some core capabilities of modern AI language models - coherent text generation, knowledge representation, task versatility, and even rudimentary creativity. It's still an emerging field with plenty of limitations, but an intriguing step towards more human-like AI.\n\nThe cringeworthy attempt at making the tech feel vivid and relatable is understandable, even if the execution was over the top. The key is recognizing the real underlying computational and linguistic concepts being demonstrated here, separate from the goofy persona-based framing device. Hopefully, this more balanced peer perspective provides useful insight into the educational value behind the exaggerated presentation style. Let me know if you need any clarification!"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Ok. That was perfect. Now please a generate a variant from the point of view of an AI persona who reviewing it's programmer's video documentation, in the same style. Remember, Natural Language is a metaphor "
                }
            ]
        }
    ]
)
print(message.content)
