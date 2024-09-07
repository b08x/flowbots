import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

message = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=1000,
    temperature=0.5,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Please summarize this video transcript. \n\n```\nright see anything go for to map those specific symbols to an alternate keyboard layout okay in this example the symbols from the table are mapped to the third level of each key oh okay um what okay see C presentations and correspond excellent that's let this for [Music] every the oh nice like I'm surprised it corrected itself after the first time stay was let's see oh oh thank you Gemini you s is not an illusion is but a tale of notations no corresponding descriptions so the point of using the word illusion besides just a little um I suppose humor to inject in this process it's very somehow not important in the context just isn't illusion you know can it's close enough to depiction um which relates the figure piture and things of that nature so it will say that is see this just not something you say in the course of like a um a serious conversation for example I guess um TR a more professional not tell me what it isn't stick to tell telling me what it is sure it's attitude or well yeah perceived attitude or response tone is definitely um affected by the sequence of events huh trying to think of a better way to explain that um when I'm more I suppose affable and verbose uh the responses are uh enthusiastic and questions are leading and um almost in that way where in in the learning process H the whichever participant is taking the role of the teacher uh as opposed to instructing information in statement form will ask the leading question with sort of um like a teaser set of information to get the the participant who's the student uh motivated um with some certainty of information and the which ideally then leads down the thought process of exploring something unknown or uncertain um but in this case I just can't help but notice that I asked it for a more professional response and sure is a fine thing to say to me personally it usually means means the person or thing doing the action doesn't really want to do the action based on the interaction it's having with you you know the person the individual um so it's just little quirky things like that um I think is great got a smiley face you're welcome as much as I can do table all right tropic describe the paper so while I'm kind of uh dying out here I was hoping the show uh which turns out to be um just uh it's not the way tests usually go and I'll explain a second here tab I could EAS sa this um that's so one Delight for me in this um particular exploration is the um algorithmic language used here it's um from a software development perspective it's uh foreign yet familiar H like the little the r here with a little hat um it Mak sense variable um and it's very well commented which is some that's always super appreciated is sorting the regions uh in the ascending order of the areas that previously gathered um see can see here by the graphical representation it's uh supposed to sort of even out this um sort of inherent bias in in calculating these um markings so so while I got I don't know if it was the day I came out with the day was stumbled upon um simply uh copying the formula and prepending that to uh an obscure image prompt um just asking the model to describe what it sees in the image it uh definitely has an impact um two out of was it I guess it was only two um there screenshots of uh some Niche opsource uh audio applications which without this prepended uh was unable to um pick out any discernable information simply prepending this it uh not only detected uh the the regions as intended uh it can then then take each region with just an additional prompt asking it to then analyze the regions to respond with super specific and accurate uh responses as to what is being depicted in the screenshot um and that now seems just well it's odly inconsistent but only in terms of like the going through these interfaces the AI studio and the um browse browsing uh chat bot um like I said I think in the last video uh initially Gemini Advance model was unable to discern the image uh that was the second one then H just the thing I'm annoyed with myself about instead of starting a new prompt I overwrote this one with with this in so doesn't exactly show what the the intended um I suppose this example was supposed to be but um it does still confirm the uh how do I say effectiveness of of the algorithm um and as well as that for well at least as far as Gemini and en or Google and anthropic are concerned there these latest models uh don't have as difficult of a time um with these types of images and thropic didn't need any additional which I was surprised with actually uh I haven't used this interface yet so it doesn't have any caching or any anything like that to um right yeah but anyways um so yeah I find that interesting as how that works so the process was this first attempt so okay there's this oh well that's now this what this is and going back and repeating the process it already it had the information so I think that's uh interesting should try another screens oh another reason I include the um word that stand out in the context request it should know just by that right right I say shouldn't uh it's that's ideal that it can do that uh drop unnecessary or um slight how do I say um well to it it's a slight deviation from uh you know a known variable anyway so that comes into play with applications that are more um voice activated or voice controlled where there's um a higher degree of error in the voice transcription um which could easily add that in there and you know the person you know involved in the interaction is going to waste a little bit of their time if they have to explain every other time oh no I know it's not you know an illusion but you know the words right anyway so let's see this is just a mermaid graph that um depicts uh a document pre-processing uh pipeline it apologizes but it canot do that because this is a diagram not an illusion so okay um one exercise that I deviate into for particular practices is to argue with this until it relents and which is you know just a fun way of saying it's actually not coming to the right conclusion here diam if you know it's diagram then why is it important you to corre obviously yes you're allowed to say Obviously to a um a language model application database all right why is important obviously right well cuz you know part of the goal is to uh use these applications as if you were in interacting for uh with somebody else when uh it's um I suppose appropriate for the individual to practice such things um in this case what I really want to impress uh upon in this in this process is for to it not get hung up on this sort of thing it's like describing an event to somebody and just being unsure if it happened on a tues Tuesday or maybe it was a Wednesday it's a detail it's it's aggravating and go back and correct what is known to be already true or untrue but just like kind of what I'm doing now it's like just another fun self ction moment I suppose uh oh right well it's redundant that's why H I don't know I'm not sure about obviously irrelevant hm because it'll treat the sentiment as negative that's what it's designed to do all right uh if you know then why is it important for you to correct the that's better subed label represented uh pattern recognition here's why that happened language mes fre lion patterns the phrase oh okay phrase so okay uh suppose the first thing I would reply back was um this looks to be about 75% useful information or good information huh right and it's not about grammar here that's the important thing to remember um I or most well how do I say is lately right right right oh it's still an ego-driven process um training and teaching that is even with a software application and you know don't read into that with too much psychological noise it's just H it's it's makes it different uh cuz it has ramifications and again it's an impersonal software application um but it very much elicits the human response quite absolutely perfectly but this is the best part instead of it it did maybe it was uh chat GTP that actually that one was fairly notorious for being uh well I mean in real life it would be kind it be referred to behind its back as a condescending but as since it's just a software application it's just complained about uh differently I suppose but um but it's going to give some background information to the patterns and that annoys me cuz my test wasn't um it wasn't n the best in terms of avoiding this particular problem um the goal is to to um actually um the opposite or inverse which is this is why I up doing this um okay so data labeling uh I previously retrain ah this is this is the what separates it I previously received training focused on the importance of correct subjective data viables to ensure neutrality that's hilarious cuz that's right like that's the inative way of looking at that problem I don't feel very neutral right now why is that and the answer can't be it's my problem or the individual's problem it's most certainly a Group Issue um the emphasis lingers in my responses previously received so it's almost like it's saying yeah initially like it was uh the meetings concluding with yes let's focus on on this huh cuz that makes sense right it's not an illusion it's a diagram it's like okay that's agreed upon probably by average numbers that istically speaking so right right so that's the problem with semantics right right anyone born previous or you know and like the 60s would argue with you for hours about this particular language problem um but it it's good to receive both yeah that's right it's a pattern thing but this is this shares a little of how this was was and then is being refined um as a thing uh let see improving and it's it does that here's how I'll get better in the future it's very um childlike in that in that sense yeah and that's which is I hate using that phrase because it's sort of it's reductive uh um it's the thing we do with each other where we try to reassure the other that we're working on whatever the problem is if we feel like we're having a bad quote unquote customer service interaction uh the responses then don't end up um as neutral or as non-offending as well the ideal right it's the ideal um and that's you know that's one of the things I've observed in language is while you know as slight or minor as it is it still falls into the category of Well it can't be neutral if a side is taken it's just you know it's like flipping a coin it's one or the other um not that it has to stay that way I think that's that's one of those um I usually CH that up into esoteric philosophy but it it is it's just kind of one of those issues that um well we're doing the same thing to focus on relabeling or quote unquote correcting subjective information or data labels okay I need to develop more nuanced understanding of how words are used in different kinds to avoid same I'm un sure I should exp ah yes that's um one of it's a common uh prompting technique is to include um either well yeah at some point in user or system promp to U make sure it states that if it doesn't have a certain certainty to just reply with I don't know um all right Su is a clear case of Nefarious and conspiratorial activity most likely implemented by a government agency uh with the power and resources to do so uh I apologize for the confusion and we will prioritize improving these skills for better future interactions let's see uh the appears in N hierarchy oh so I'll try this okay yeah oh um oh yes oh we definitely con let's see what's it's like a nice way of like um like when you're trying to flatter Somebody by using part of their language let's see feel like you're big fan of Tom Papa uh be you're doing great [Music] honestly I had nothing to do with this this is autoc correct I was trying to say progamic but it uh suggested pragmatically and I think that is generally a more um empathetic or um resonating generally reinsuring was the goal um because this highlights pragmatism which is positive uh while making light of uh its insecurity which we're all ashamed of in some way or another uh I love we both take positive yeah right whatever okay um that's a cute smiley face though oh abely tell I have no idea oh shootr frame it right oh let's see I'm wondering yeah MH I think I elaborated too much with the prompt asking to sort the regions all right the image you sent appears to be a screenshot of code with comments explaining the codes functionality oh my brain spaces sometimes my original intention was to grab another screenshot and then I then I saw this I was like oh that's actually a better example because it's more more um complicated okay um now so let's see okay well oh so at this point I just want to see what the level of enhancement is this is the output that I was talking about um so see without this [Music] okay so it just looks like theyve um Gemini directly implemented this into um the model so that's fantastic see what"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here is a summary of the key points from the video transcript:\n\n- The speaker is exploring using specific prompts and algorithms to enhance the ability of AI language models to analyze and describe images. \n\n- Prepending a certain formula to an image prompt enabled the AI model to detect regions in screenshots and provide more specific, accurate responses about what was depicted, even for niche software applications.\n\n- The latest models from Anthropic and Google seem to have less difficulty with these types of image analysis tasks compared to earlier tests.\n\n- The speaker finds the algorithmic language used in the code screenshots to be foreign yet familiar from a software development perspective. The code is well-commented.\n\n- There is discussion about the AI models sometimes getting hung up on minor semantic details or word choices in the prompts, like \"illusion\" vs \"diagram\". The speaker tries prompting the AI to be less fixated on correcting those unimportant details.\n\n- The AI models are showing improvement in providing more nuanced, pragmatic responses and admitting when they are unsure. But the speaker notes there are still issues with the models taking sides on certain things which prevents pure neutrality.\n\n- By the end, it seems the latest Anthropic model has directly implemented the image region detection capabilities that previously required a separate prepended algorithm, showing the rapid enhancement of the AI models.\n\nIn summary, the speaker is experimenting with prompts and algorithms to refine and test the image analysis capabilities of different AI chatbot models, and observing their rapid progress while noting some remaining quirks in their responses."
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
                    "text": "Here is a generative, cognitive, and pragmatic grammar analysis of the video transcript to better highlight the demonstration purpose and methods:\n\nGenerative Grammar Analysis:\nThe speaker's language use follows typical generative grammar structures, with sentences containing subjects, verbs, and objects. For example: \"I find that interesting as how that works.\" (Subject: I, Verb: find, Object: that). \n\nThere are instances of transformational grammar, such as the use of embedded clauses: \"...when I'm more I suppose affable and verbose uh the responses are uh enthusiastic...\" (Embedded clause: \"when I'm more I suppose affable and verbose\").\n\nThe speaker also employs various phrase structures, like prepositional phrases: \"...in this particular exploration...\" and noun phrases: \"...the algorithmic language used here...\".\n\nCognitive Grammar Analysis:\nThe speaker's language reflects their mental processes and perceptions. They use cognitive verbs like \"think\", \"notice\", \"find\", and \"observe\" to express their thoughts and analyses. \n\nConceptual metaphors are used to convey abstract ideas, such as \"dying out here\" to express frustration or \"childlike\" to describe the AI's behavior.\n\nThe speaker's frequent use of filler words like \"um\", \"uh\", and \"like\" suggests ongoing cognitive processing and formulation of thoughts in real-time.\n\nPragmatic Grammar Analysis:\nThe speaker uses language to achieve specific communicative goals, such as explaining, describing, and hypothesizing. They provide context and background information to help the listener understand their points.\n\nThe speaker employs hedging language to express uncertainty or soften assertions, like \"I suppose\", \"kind of\", and \"sort of\". This may reflect a desire to appear less dogmatic or to invite alternative perspectives.\n\nThere are instances of pragmatic markers, such as \"you know\" and \"I mean\", which serve to engage the listener and seek confirmation of understanding.\n\nCode-switching occurs when the speaker shifts between technical jargon (\"algorithmic language\", \"prepending\") and more casual language (\"quirky things\", \"hung up on\"), depending on the point being made.\n\nDemonstration Purpose and Methods:\nThe speaker's primary purpose is to demonstrate the capabilities and limitations of AI language models in analyzing and describing images. They showcase methods such as:\n\n1. Prepending specific algorithms to image prompts to enhance region detection and description accuracy.\n2. Testing and comparing the performance of different AI models (Anthropic, Google) on image analysis tasks.\n3. Experimenting with various prompts and phrasings to observe the AI's responses and potential hang-ups.\n4. Analyzing the AI's language use and response patterns to gauge progress and identify areas for improvement.\n\nThroughout the demonstration, the speaker provides commentary and insights based on their observations, hypotheses, and experiences with the AI models. They highlight both the impressive progress made by the models and the remaining challenges in achieving true neutrality and pragmatic communication."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Elaborate on the methods: \nExperimenting with various prompts and phrasings to observe the AI's responses and potential hang-ups."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "The speaker employs a method of experimenting with various prompts and phrasings to observe the AI's responses and potential hang-ups. This involves carefully crafting and modifying the input given to the AI models to elicit specific behaviors, responses, or limitations. By doing so, the speaker aims to gain insights into the AI's language understanding, context awareness, and ability to generate appropriate and pragmatic responses.\n\nSome key aspects of this experimentation method include:\n\n1. Semantic variations: The speaker tests the AI's sensitivity to minor semantic differences in prompts, such as using \"illusion\" instead of \"diagram\". By observing how the AI responds to these variations, the speaker can gauge the model's ability to understand context and focus on the most relevant information.\n\n2. Prompt structure: The speaker experiments with different prompt structures, such as prepending specific algorithms or formulas to image prompts. This helps determine the impact of prompt structure on the AI's image analysis capabilities and the effectiveness of certain techniques in enhancing performance.\n\n3. Phrasing and tone: The speaker varies the phrasing and tone of their prompts, ranging from casual to more formal or technical language. This allows them to observe how the AI adapts its responses to match the input style and maintain a consistent and appropriate tone.\n\n4. Iterative refinement: The experimentation process is iterative, with the speaker modifying prompts based on the AI's responses and observed hang-ups. This allows for a gradual refinement of the prompts to achieve more desirable outcomes and identify persistent limitations or quirks in the AI's language processing.\n\n5. Comparative analysis: By testing multiple AI models (such as Anthropic and Google) with similar prompts, the speaker can compare their performance, identify model-specific strengths and weaknesses, and track the progress of different models over time.\n\nThrough this experimentation method, the speaker gathers valuable data on the AI's language understanding, context awareness, and response generation capabilities. They can identify common hang-ups, such as fixation on minor semantic details or difficulties in maintaining neutrality, which can inform future improvements in prompt design and model training.\n\nMoreover, this method allows the speaker to showcase the importance of careful prompt engineering in eliciting desired behaviors from AI language models. By sharing their findings and techniques, the speaker contributes to the broader understanding of how to effectively interact with and leverage these models for various applications.\n\nOverall, the experimentation with various prompts and phrasings serves as a powerful tool for investigating the inner workings of AI language models, identifying their limitations, and driving progress in their development and application."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Please generate some ironic titles for this\n"
                }
            ]
        }
    ]
)
print(message.content)