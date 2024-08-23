import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

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
                    "text": "Please assess the topic and content of this transcript:\n\n\"\"\"\n[Music] to point out so this person uh this is their question\n\nso now I'm trying to do my due diligence and\n\nuh get this person the information they need\n\nbecause I believe in all of\n\nthis but I currently don't have a budget\n\noh something oh\n\nall right anyway so yeah uh so this has been\n\ninterrupted so I can contribute to another cause with resources I don't have with uh with a subscription\n\nfee well\n\nuh how is that supposed to work for those that don't have the\n\nluxury I would say it's hard to describe this without sounding resentful cuz\n\nit's right uh\n\nwell I guess the classic mistake is uh wanting certain things and what I want is equality and fairness like I was\n\npromised uh as a child which you know like all car commercials you know you learn\n\nbut\n\num right I'm going to I'm going to act disillusioned and uh discouraged because I know for well as empirical data [Music] shows the individual tends to lose motivation when they feel like their energy and efforts isn't uh how do I say properly\n\ncompensated so I'm just making the point that yeah I get you know a company that's given billions and billions and billions of dollars for this product project needs more money somehow or you know maintenance and all that I\n\nguess which I wouldn't have a problem with If the product which is the language model wasn't still under development because even if I pay this $20 what that $20 will get me is just the privilege of continuing my work\n\nit doesn't improve the\n\nquality so understand companies that do this you know for you know the cause\n\nyes it's little things like this that add up to a attitude and mindset of just general societal malays and that's where the motivation and intent is\n\nborn and I let your wild imaginations fill in the rest of the details as far as the\n\nconsequences [Music] longterm\n"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "The transcript appears to be discussing the topic of financial barriers to accessing certain products or services, and the frustration and disillusionment that can result from feeling that one's efforts and contributions are not being properly compensated or recognized.\n\nThe speaker expresses a desire for equality and fairness, which they feel they were promised as a child, but which they believe is not being delivered in practice. They specifically mention a company that has received billions of dollars in funding for a product or project, but which is still asking for more money from users, even though the product is still under development and the quality has not improved.\n\nThe speaker argues that this kind of financial barrier can lead to a loss of motivation and a sense of resentment among individuals who feel that their energy and efforts are not being properly compensated. They suggest that this can contribute to a broader sense of societal malaise and a lack of motivation and intent.\n\nOverall, the transcript touches on themes of economic inequality, access to resources, and the psychological impact of feeling undervalued or unrecognized in one's efforts. The speaker seems to be expressing a sense of frustration and disillusionment with the current state of affairs, and a desire for greater fairness and equality in the distribution of resources and opportunities."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Ok. Now counter the response with it's measured equivalent"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "While the speaker raises valid concerns about financial barriers and the potential for disillusionment when efforts feel undervalued, it's important to consider the broader context and the realities of running a business or developing a complex product.\n\nCompanies that receive significant funding still have ongoing expenses and need to generate revenue to sustain their operations, pay their employees, and continue improving their products. Offering a subscription model or charging for access to certain features is a common and legitimate business practice, even for companies that have received substantial investment.\n\nIt's understandable that individuals may feel frustrated when they cannot afford to access certain products or services, but it's not necessarily a sign of unfairness or a lack of equality. Different products and services are targeted at different markets and demographics, and not everything will be accessible to everyone.\n\nMoreover, while the speaker suggests that paying for access to a product that is still under development does not improve the quality, it's important to recognize that ongoing financial support is often necessary to fund continued development and improvement. Without a sustainable business model, many products and services would simply cease to exist.\n\nThat being said, the speaker's concerns about the psychological impact of feeling undervalued or unrecognized are valid and worth considering. Companies and society as a whole should strive to create a more inclusive and equitable environment where everyone feels valued and has access to opportunities for growth and advancement.\n\nUltimately, balancing the needs of businesses with the desires and concerns of individuals is a complex challenge without easy solutions. While it's important to acknowledge and address the frustrations and disillusionment that many people feel, it's also necessary to recognize the practical realities and constraints that businesses and developers face."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Ok. Now counter that perspective response with it's measured equivalent"
                }
            ]
        }
    ]
)
print(message.content)
