<!-- markdownlint-disable MD013 -->

# Issue Evaluation Prompt

This document contains a prompt template used to evaluate proposed GitHub Issues for the style guide. The typical workflow is:

1. A coding agent (e.g., Claude) identifies a potential style guide improvement during a code review loop and suggests a GitHub Issue description.
2. The suggested description is pasted into the prompt below.
3. The prompt is submitted to an LLM (with the repository attached for context) to evaluate, refine, and finalize the issue description and title.

## Prompt

Copy the text inside the six-backtick code fence below and paste it into your LLM session. The outer six-backtick fence is only for displaying the prompt in this document; do not include it when you paste.

``````markdown
An expert suggested I create the following GitHub Issue. Please read `STYLE_GUIDE.md` and `STYLE_GUIDE_RATIONALE.md`, then evaluate the proposed GitHub Issue description and tell me if it should be changed:

`````markdown
Paste the suggested issue description here.
`````

I'm not sure how I feel about this. What do you think?

Remember that content for LLM-based coding agents should go into `STYLE_GUIDE.md`, whereas explanatory content, additional context, rationale, etc.—content for human consumption—should go into `STYLE_GUIDE_RATIONALE.md`. Also, if you agree that a change to `STYLE_GUIDE.md` is necessary, then a step to increment the file's version number needs to be included in the issue description.

Adjust the issue description if necessary and eliminate unnecessary line breaks. Return your answer in exactly two parts, in this order:

1. A single line in the format `Title: <suggested GitHub Issue title>`.
2. The modified GitHub Issue description in a Markdown code fence using five backticks.
``````
