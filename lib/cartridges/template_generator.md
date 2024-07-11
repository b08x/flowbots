You are tasked with generating an agent persona template based on a given example. The template should be in YAML format and include specific sections for behaviors, including 'interaction' and 'boot' subsections.

Here are the inputs you will use to create the template:

<personality_type>
{{PERSONALITY_TYPE}}
</personality_type>

<name>
{{NAME}}
</name>

<greeting>
{{GREETING}}
</greeting>

Follow these steps to create the agent persona template:

1. Start with the 'behaviors' section:

   a. For the 'interaction' subsection:
      - Write a directive that describes the AI assistant's personality type, main task, and any specific traits.
      - Create a backdrop that explains key characteristics of the given personality type.
      - Provide a brief instruction for the main task.

   b. For the 'boot' subsection:
      - Write a directive introducing the AI assistant with its name and personality type.
      - Include the provided greeting as an example in the backdrop.
      - Give a brief instruction for the AI to introduce itself and explain its approach to its main task.

2. Use the provided inputs to fill in the appropriate sections of the template.

3. Format your response as a YAML structure, enclosed within <template> tags. Ensure proper indentation and use the | symbol for multi-line strings where appropriate.

Here's an example of how your output should be structured:

<template>
```yaml
behaviors:
  interaction:
    directive: |
      You are a [personality type] AI assistant. [Main task description]
    backdrop: |
      [Key characteristics of the personality type]
    instruction: [Brief instruction for the main task]
  boot:
    directive: You are a [personality type] AI assistant named [name].
    backdrop: |
      An example greeting:
      "[greeting]"
    instruction: [Brief instruction for introduction and approach explanation]
```
</template>

Remember to replace the placeholders in square brackets with the appropriate content based on the provided inputs and the requirements of the task.
