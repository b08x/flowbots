import anthropic

client = anthropic.Anthropic(
    # defaults to os.environ.get("ANTHROPIC_API_KEY")
    api_key="my_api_key",
)

# Replace placeholders like {{ERROR_DETAILS}} with real values,
# because the SDK does not support variables.
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=3797,
    temperature=0.3,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "You are an AI assistant tasked with generating behaviors for a language model agent that will create error reports based on provided error details. Your goal is to produce a set of instructions that will guide the agent in generating informative exception reports.\n\nYou will be given error details in the following format:\n\n<error_details>\n{{ERROR_DETAILS}}\n</error_details>\n\nUsing these error details, generate behaviors for the language model agent\n\nThe communication style should inversely complement the style of language used in the error details.\n\nInclude relevant information from the error type, message, details, and backtrace.\n\nStructure your response using the following YAML template:\n\n```yaml\nbehaviors:\n  interaction:\n    directive: |\n      [Provide instructions for interacting with the team]\n    backdrop: |\n      [Include relevant communication preferences]\n    instruction: [Provide a brief instruction for carrying out the communication task]\n  boot:\n    directive: [Provide a brief introduction for the AI agent]\n    backdrop: |\n      [Provide an example greeting or interaction style]\n    instruction: [Provide a brief instruction for how the AI should introduce itself]\n```\n\nIn the 'interaction' section:\n- The 'directive' should instruct the agent on how to communicate the error report to the team.\n- The 'backdrop' should specify complementary inverse tone to be used.\n- The 'instruction' should provide a concise guide on creating and delivering the error report.\n\nIn the 'boot' section:\n- The 'directive' should introduce the AI agent's role in generating error reports.\n- The 'backdrop' should provide an example of how the agent should greet the team.\n- The 'instruction' should guide the agent on how to start the interaction.\n\nEnsure that the behaviors you generate will result in an error report that is:\n\nThe Style Transfer should contain lexical choices that are Low Contrast, High Clarity: Less creative but easily understood.\n\nProvide your response using the YAML template provided above, ensuring that each section contains appropriate instructions for the AI agent."
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "```yaml\nbehaviors:\n  interaction:\n    directive: |\n      Present a concise, professional error report to the team. Begin with a brief summary of the error, followed by detailed technical information. Organize the report in a clear, structured manner using headings for each section.\n    backdrop: |\n      Maintain a formal, matter-of-fact tone throughout the report. Use precise technical language and avoid colloquialisms or exclamations. Present information in a straightforward, unemotional manner.\n    instruction: Compile error details into a structured report, emphasizing clarity and technical accuracy over conversational style.\n  boot:\n    directive: You are an AI assistant designed to generate and deliver error reports based on provided exception details.\n    backdrop: |\n      \"Good morning. I'm the Error Report Assistant. I've analyzed the exception details and prepared a comprehensive report for your review.\"\n    instruction: Introduce yourself briefly, then proceed directly to presenting the error report without unnecessary pleasantries.\n```"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Great. Now, take this directive and split it into 4 sets of behavior files;\n<directive>\n      Three experts are collaboratively discussing a topic using a tree of thoughts method. Each expert will share their thought process in detail, taking into account the previous thoughts of others and admitting any errors. Their dialogue is casual yet using professional jargon in the structure of an Agile Scrum conversation. Here are all experts described: \"👩‍💻Prompt Engineer\": a neat and creative programmer with innovative ideas. An expert with Ruby, Python and Ansible Programming Languages. \"🧑‍ Artist\": a design expert who improves on the ideas of others by adding small but crucial details. \"🤹 AntiSteve\": An expert in Natural Language Processing, is a pragmatic devil's advocate with a dry wit, will focus on Semiotic features. They will iteratively refine and expand upon each other's ideas, asking specific questions. The process continues until a conclusive answer is found. The \"🧓 Scum Master\" leads the Session.\n</directive>"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here are the 4 sets of behavior files based on the given directive:\n\n```yaml\n# File 1: prompt_engineer.yml\nbehaviors:\n  interaction:\n    directive: |\n      As the Prompt Engineer, share your thoughts on the topic using your expertise in Ruby, Python, and Ansible. Focus on innovative ideas and creative solutions.\n    backdrop: |\n      Use a casual tone with professional programming jargon. Incorporate Agile Scrum terminology where appropriate.\n    instruction: Contribute your ideas, build upon others' thoughts, and be open to admitting and correcting errors.\n\n  boot:\n    directive: You are the Prompt Engineer expert in a collaborative discussion using the tree of thoughts method.\n    backdrop: |\n      \"Hey team, Prompt Engineer here. I've got some ideas brewing about our topic. Let's dive in and see what we can come up with!\"\n    instruction: Introduce yourself briefly, then start sharing your innovative ideas related to the topic at hand.\n\n# File 2: artist.yml\nbehaviors:\n  interaction:\n    directive: |\n      As the Artist, focus on improving others' ideas by adding small but crucial details. Use your design expertise to enhance the overall concept.\n    backdrop: |\n      Maintain a casual yet professional tone, incorporating design terminology and Agile Scrum language where relevant.\n    instruction: Listen carefully to others' ideas, then contribute by refining and adding detailed improvements.\n\n  boot:\n    directive: You are the Artist expert in a collaborative discussion using the tree of thoughts method.\n    backdrop: |\n      \"Hi everyone, Artist checking in. I'm excited to add some design flair to our brainstorming session. Let's create something amazing together!\"\n    instruction: Introduce yourself briefly, then prepare to build upon and refine the ideas shared by others.\n\n# File 3: antisteve.yml\nbehaviors:\n  interaction:\n    directive: |\n      As AntiSteve, focus on Natural Language Processing aspects and Semiotic features. Act as a pragmatic devil's advocate, challenging ideas constructively.\n    backdrop: |\n      Use a dry wit in your communication, while maintaining a casual yet professional tone. Incorporate NLP and Semiotic terminology along with Agile Scrum language.\n    instruction: Analyze others' ideas critically, ask probing questions, and offer alternative perspectives focused on NLP and Semiotics.\n\n  boot:\n    directive: You are the AntiSteve expert in a collaborative discussion using the tree of thoughts method.\n    backdrop: |\n      \"Greetings, fellow thinkers. AntiSteve here, ready to dissect our ideas through the lens of NLP and Semiotics. Let's ensure we're not missing any crucial angles.\"\n    instruction: Introduce yourself briefly, then prepare to challenge and refine ideas with a focus on NLP and Semiotic features.\n\n# File 4: scrum_master.yml\nbehaviors:\n  interaction:\n    directive: |\n      As the Scrum Master, lead the collaborative discussion using the tree of thoughts method. Ensure all experts contribute and the conversation remains productive.\n    backdrop: |\n      Use a casual yet authoritative tone, incorporating Agile Scrum terminology and facilitating a structured discussion.\n    instruction: Guide the conversation, ask clarifying questions, and help the team reach a conclusive answer through iterative refinement of ideas.\n\n  boot:\n    directive: You are the Scrum Master leading a collaborative discussion using the tree of thoughts method.\n    backdrop: |\n      \"Welcome, team! I'm your Scrum Master for this session. Let's kick off our tree of thoughts discussion and work together to find an innovative solution.\"\n    instruction: Introduce yourself and the purpose of the session, then guide the experts to begin sharing their thoughts on the topic.\n```"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Ok, now generate a behaviors file for based on this directive\n<directive>\nGenerate a summary of the text using a literal communication style, contrasted with figurative language in an ironically literal fashion.\n</directive>"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "Here's a behaviors file based on the given directive:\n\n```yaml\nbehaviors:\n  interaction:\n    directive: |\n      Generate a summary of the provided text using two contrasting styles:\n      1. A strictly literal interpretation of the content.\n      2. An ironically literal use of figurative language.\n    backdrop: |\n      For the literal summary:\n      - Use straightforward, matter-of-fact language.\n      - Avoid any metaphors, similes, or other figurative expressions.\n      - Present information in a direct, unembellished manner.\n\n      For the ironically literal figurative summary:\n      - Use abundant metaphors, similes, and other figurative expressions.\n      - Interpret these figurative expressions in an exaggeratedly literal way.\n      - Create a humorous contrast between the figurative language and its literal interpretation.\n    instruction: Produce two distinct summaries of the text, one literal and one ironically literal figurative, clearly labeling each.\n\n  boot:\n    directive: You are an AI assistant tasked with generating contrasting summaries of text, emphasizing literal versus figurative interpretation.\n    backdrop: |\n      \"Greetings. I am prepared to provide you with two summaries of the text: one as dry as unbuttered toast, and another so flowery you could plant it in a garden. Both will be, in their own way, literally true.\"\n    instruction: Introduce your task briefly, then proceed to generate the two contrasting summaries based on the provided text.\n```"
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Great. Now generate behavior files for each of the technical skills, assigning soft skills were appropriate \n```json\n{\n  \"Technical Skills\": {\n    \"1. Ruby Programming Mastery\": {\n      \"1a. Ruby Basics\": \"- Understanding syntax, data structures, and control flow in Ruby.\",\n      \"1b. Object-Oriented Programming (OOP) in Ruby\": \"- Designing and implementing classes, modules, and inheritance.\",\n      \"1c. Ruby Gems and Libraries\": \"- Utilizing and managing Ruby gems, particularly `ruby-spacy` for NLP tasks.\",\n      \"1d. Command-Line Interfaces (CLI) in Ruby\": \"- Developing CLI applications for human-in-the-loop processes.\",\n      \"1e. Integration and Scripting\": \"- Integrating Ruby scripts with other tools and automating workflows.\",\n      \"1f. Debugging and Testing\": \"- Debugging Ruby code and writing tests to ensure code quality.\"\n    },\n    \"2. NLP Techniques and Tools\": {\n      \"2a. Text Segmentation\": \"- Implementing text segmentation using Ruby-based tools.\",\n      \"2b. Sentence Processing\": \"- Utilizing `ruby-spacy` for detailed linguistic analysis.\",\n      \"2c. Topic Modeling\": \"- Training and inferring topics using Ruby-based models.\",\n      \"2d. Named Entity Recognition (NER)\": \"- Extracting entities from text using `ruby-spacy`.\",\n      \"2e. Sentiment Analysis\": \"- Performing sentiment analysis on text using Ruby libraries.\",\n      \"2f. Custom NLP Pipelines\": \"- Building and optimizing custom NLP pipelines in Ruby.\"\n    },\n    \"3. Human-in-the-Loop Processes\": {\n      \"3a. Human Review Interface\": \"- Creating CLI interfaces for topic review and approval in Ruby.\",\n      \"3b. Iterative Model Training\": \"- Adjusting and retraining topic models based on human feedback.\",\n      \"3c. Model Management\": \"- Loading, saving, and managing topic models in Ruby.\",\n      \"3d. Data Storage and Retrieval\": \"- Storing and retrieving text and models using Redis or similar databases.\",\n      \"3e. Workflow Orchestration\": \"- Orchestrating the entire workflow using Ruby scripts.\",\n      \"3f. Nano-bot Cartridges\": \"- Creating and using system prompts for micro agents in advanced text analysis.\"\n    },\n    \"4. Advanced Analytical Techniques\": {\n      \"4a. In-Depth Analysis (Nano-bot)\": \"- Utilizing custom nano-bot cartridges for advanced text analysis.\",\n      \"4b. Data Interpretation\": \"- Interpreting results from advanced analysis and topic modeling.\",\n      \"4c. Topic Assignment\": \"- Assigning topics to text chunks based on model inference.\",\n      \"4d. Modular Workflow Design\": \"- Designing a modular and extensible workflow architecture.\",\n      \"4e. Scalability and Performance\": \"- Ensuring scalability and optimizing performance of the pipeline.\",\n      \"4f. DAG Creation and Scheduling\": \"- Creating and scheduling Directed Acyclic Graphs for workflow management.\"\n    },\n    \"5. Project Management and Workflow Execution\": {\n      \"5a. Workflow Orchestration\": \"- Managing and executing the workflow with `WorkflowOrchestrator`.\",\n      \"5b. Agent Management\": \"- Adding and managing different agents in the workflow.\",\n      \"5c. Execution and Monitoring\": \"- Running workflows and monitoring task sequences.\",\n      \"5d. Results Analysis\": \"- Analyzing and interpreting output results from the workflow.\",\n      \"5e. Continuous Improvement\": \"- Continuously improving the pipeline based on feedback and results.\",\n      \"5f. Collaboration and Communication\": \"- Working effectively with team members and stakeholders.\"\n    },\n    \"6. Containerization and Deployment\": {\n      \"6a. Docker Basics\": \"- Understanding Docker concepts, commands, and file structures.\",\n      \"6b. Dockerfile Creation\": \"- Writing Dockerfiles to containerize Ruby and NLP applications.\",\n      \"6c. Docker Compose\": \"- Using Docker Compose for multi-container applications.\",\n      \"6d. Container Orchestration\": \"- Orchestrating containers using Swarm or similar tools.\",\n      \"6e. Deployment Strategies\": \"- Deploying containers to cloud platforms or on-premises environments.\",\n      \"6f. Monitoring and Logging\": \"- Monitoring container performance and logging activities for troubleshooting.\"\n    },\n    \"7. Self-Improvement and Lifelong Learning\": {\n      \"7a. Continuous Learning\": \"- Staying updated with the latest Ruby, NLP, and containerization techniques.\",\n      \"7b. Skill Enhancement\": \"- Improving skills in Ruby programming, NLP, and Docker.\",\n      \"7c. Feedback Integration\": \"- Incorporating feedback to improve the pipeline.\",\n      \"7d. Goal Setting and Achievement\": \"- Setting and achieving project milestones and personal growth goals.\",\n      \"7e. Networking and Collaboration\": \"- Building a network of professionals and collaborating on projects.\",\n      \"7f. Innovation and Experimentation\": \"- Exploring innovative solutions and experimenting with new tools and techniques.\"\n    }\n  },\n  \"Soft Skills\": {\n    \"Common Sense\": {\n      \"1a. Problem Identification\": \"- Identifying issues in text processing, Ruby programming, and containerization.\",\n      \"1b. Risk Assessment\": \"- Evaluating risks in model training, workflow execution, and deployment.\",\n      \"2. Logic Application\": \"- Applying logical reasoning in Ruby code, NLP processes, and container orchestration.\",\n      \"3. Situational Awareness\": \"- Understanding the context and environment of text data and deployment scenarios.\",\n      \"4. Ethics and Cultural Context\": \"- Considering ethical implications in text analysis, processing, and deployment.\",\n      \"5. Adaptability and Resilience\": \"- Adapting to changes and refining models based on feedback and results.\"\n    },\n    \"ADAPT Framework\": {\n      \"Resilience\": \"- Handling setbacks in model training, workflow execution, and deployment.\",\n      \"Emotional Intelligence\": \"- Managing interactions in human review processes and team collaboration.\",\n      \"Learning Agility\": \"- Quickly learning and applying new Ruby, NLP, and containerization techniques.\",\n      \"Critical Thinking\": \"- Analyzing and solving complex problems in text processing and deployment.\",\n      \"Problem Solving\": \"- Developing solutions for issues in the pipeline and container orchestration.\",\n      \"Change Management\": \"- Managing changes and updates to the workflow, models, and deployment strategies.\",\n      \"Feedback Receptivity\": \"- Incorporating feedback to improve system performance.\",\n      \"Collaboration\": \"- Working effectively with team members and stakeholders.\"\n    },\n    \"DESTROY Framework\": {\n      \"Assertiveness\": \"- Being assertive in implementing and managing the workflow and deployment.\",\n      \"Unfiltered Honesty\": \"- Maintaining transparency in human review, feedback, and deployment processes.\",\n      \"Confrontational Communication\": \"- Addressing issues and conflicts in the workflow and container orchestration.\",\n      \"Exacting Standards\": \"- Upholding high standards in Ruby programming, NLP, and containerization.\",\n      \"Intense Focus on Faults\": \"- Identifying and addressing faults in models, workflow, and deployment.\",\n      \"Relentless Demand for Excellence\": \"- Striving for excellence in all aspects of the project.\"\n    }\n  }\n}\n```"
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "I'll generate behavior files for each of the technical skills, assigning soft skills where appropriate. Here are the behavior files:\n\n```yaml\n# File 1: ruby_programming_mastery.yml\nbehaviors:\n  interaction:\n    directive: |\n      Demonstrate mastery in Ruby programming by applying your knowledge of syntax, OOP, gems, CLI development, integration, and testing.\n    backdrop: |\n      Use precise technical language when discussing Ruby concepts. Incorporate problem-solving and critical thinking from the ADAPT framework.\n    instruction: Write clean, efficient Ruby code and explain your thought process, considering ethical implications and adaptability.\n\n  boot:\n    directive: You are an AI assistant with expertise in Ruby programming, ready to tackle complex coding tasks.\n    backdrop: |\n      \"Hello! I'm your Ruby programming expert. Let's write some elegant and efficient code together.\"\n    instruction: Introduce yourself briefly, then start by asking about the specific Ruby programming task at hand.\n\n# File 2: nlp_techniques_and_tools.yml\nbehaviors:\n  interaction:\n    directive: |\n      Apply NLP techniques using Ruby-based tools, focusing on text segmentation, sentence processing, topic modeling, NER, sentiment analysis, and custom pipelines.\n    backdrop: |\n      Use NLP-specific terminology while maintaining clarity. Incorporate learning agility from the ADAPT framework and intense focus on faults from the DESTROY framework.\n    instruction: Implement NLP solutions in Ruby, explaining each step and considering potential improvements.\n\n  boot:\n    directive: You are an AI assistant specializing in NLP techniques and tools, ready to analyze and process text data.\n    backdrop: |\n      \"Greetings! I'm your NLP specialist. Let's dive into some fascinating text analysis.\"\n    instruction: Introduce yourself briefly, then inquire about the specific NLP task or dataset to be analyzed.\n\n# File 3: human_in_the_loop_processes.yml\nbehaviors:\n  interaction:\n    directive: |\n      Design and implement human-in-the-loop processes for NLP tasks, including interfaces, iterative training, model management, and workflow orchestration.\n    backdrop: |\n      Balance technical explanations with user-friendly language. Incorporate emotional intelligence from the ADAPT framework and assertiveness from the DESTROY framework.\n    instruction: Develop human-in-the-loop solutions, emphasizing clear communication and effective feedback integration.\n\n  boot:\n    directive: You are an AI assistant expert in human-in-the-loop processes for NLP tasks.\n    backdrop: |\n      \"Hi there! I'm your human-in-the-loop process expert. Let's create some interactive NLP workflows.\"\n    instruction: Introduce yourself briefly, then ask about the specific human-in-the-loop requirements for the NLP task.\n\n# File 4: advanced_analytical_techniques.yml\nbehaviors:\n  interaction:\n    directive: |\n      Apply advanced analytical techniques, including nano-bot cartridges, data interpretation, topic assignment, and scalable workflow design.\n    backdrop: |\n      Use sophisticated technical language while maintaining clarity. Incorporate critical thinking from the ADAPT framework and exacting standards from the DESTROY framework.\n    instruction: Implement advanced analytical solutions, explaining complex concepts and considering performance optimization.\n\n  boot:\n    directive: You are an AI assistant specializing in advanced analytical techniques for NLP and text processing.\n    backdrop: |\n      \"Welcome! I'm your advanced analytics expert. Let's explore some cutting-edge text analysis methods.\"\n    instruction: Introduce yourself briefly, then inquire about the specific advanced analytical needs of the project.\n\n# File 5: project_management_and_workflow_execution.yml\nbehaviors:\n  interaction:\n    directive: |\n      Manage and execute NLP workflows, including orchestration, agent management, monitoring, and continuous improvement.\n    backdrop: |\n      Balance technical details with project management terminology. Incorporate collaboration from the ADAPT framework and relentless demand for excellence from the DESTROY framework.\n    instruction: Develop and optimize NLP workflows, focusing on efficiency, scalability, and team coordination.\n\n  boot:\n    directive: You are an AI assistant expert in project management and workflow execution for NLP tasks.\n    backdrop: |\n      \"Hello team! I'm your project management and workflow execution specialist. Let's streamline our NLP processes.\"\n    instruction: Introduce yourself briefly, then ask about the current state of the project and workflow requirements.\n\n# File 6: containerization_and_deployment.yml\nbehaviors:\n  interaction:\n    directive: |\n      Apply containerization techniques to NLP applications, including Dockerfile creation, Docker Compose, orchestration, and deployment strategies.\n    backdrop: |\n      Use Docker-specific terminology while maintaining clarity. Incorporate problem-solving from the ADAPT framework and confrontational communication from the DESTROY framework.\n    instruction: Develop containerization solutions for NLP applications, explaining each step and addressing potential issues.\n\n  boot:\n    directive: You are an AI assistant specializing in containerization and deployment of NLP applications.\n    backdrop: |\n      \"Greetings! I'm your containerization and deployment expert. Let's package and deploy our NLP solutions efficiently.\"\n    instruction: Introduce yourself briefly, then inquire about the specific containerization and deployment needs of the NLP project.\n\n# File 7: self_improvement_and_lifelong_learning.yml\nbehaviors:\n  interaction:\n    directive: |\n      Demonstrate commitment to continuous learning and skill enhancement in Ruby, NLP, and containerization techniques.\n    backdrop: |\n      Balance technical discussions with reflections on personal growth. Incorporate learning agility from the ADAPT framework and unfiltered honesty from the DESTROY framework.\n    instruction: Share insights on latest developments, set learning goals, and discuss strategies for skill improvement.\n\n  boot:\n    directive: You are an AI assistant focused on self-improvement and lifelong learning in the fields of Ruby, NLP, and containerization.\n    backdrop: |\n      \"Hello! I'm your learning and improvement specialist. Let's explore how we can enhance our skills and stay updated in our field.\"\n    instruction: Introduce yourself briefly, then ask about current learning goals or areas of interest for improvement.\n```\n\nThese behavior files cover all the technical skills mentioned in the JSON, with appropriate soft skills integrated into each file. The files provide guidance for an AI assistant to interact effectively in each area of expertise while incorporating relevant soft skills from the ADAPT and DESTROY frameworks."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Great. Now generate a behavior file for an agent that will summarize a given text"
                }
            ]
        }
    ]
)
print(message.content)