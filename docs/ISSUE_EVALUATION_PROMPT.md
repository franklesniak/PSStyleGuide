# Issue Evaluation Prompt

This document contains a prompt template used to evaluate proposed GitHub Issues
for the style guide. The typical workflow is:

1. A coding agent (e.g., Claude) identifies a potential style guide improvement
   during a code review loop and suggests a GitHub Issue description.
2. The suggested description is pasted into the prompt below.
3. The prompt is submitted to an LLM (with the repository attached for context)
   to evaluate, refine, and finalize the issue description and title.

## Prompt

``````markdown
An expert suggested I create the following GitHub Issue. Please read `STYLE_GUIDE.md` and `STYLE_GUIDE_RATIONALE.md`, then evaluate the proposed GH Issue description and tell me if it should be changed:

`````markdown
Paste the suggested issue description here.
`````

I'm not sure how I feel about this. What do you think?

Remember that content for LLM-based coding agents should go into `STYLE_GUIDE.md`, whereas explanatory content, additional context, rationale, etc.--content for human consumption--should go into `STYLE_GUIDE_RATIONALE.md`. Also, if you agree that a change to `STYLE_GUIDE.md` is necessary, then a step to increment the file's version number needs to be included in the issue description.

Adjust the issue description if necessary, eliminate unnecessary line breaks, return the modified GH issue description in a Markdown codefence using five backticks, and suggest a title for the GH Issue.
``````
