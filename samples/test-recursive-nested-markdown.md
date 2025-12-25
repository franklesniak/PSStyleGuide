# Test File for Recursive Nested Markdown Linting

This file tests the recursive nested markdown linting capability.

## Example 1: Two levels of nesting

This demonstrates markdown inside markdown:

`````markdown
# Level 1 Header

This is the first level of nested markdown.

````markdown
## Level 2 Header

This is the second level - markdown inside markdown.

- List item 1
- List item 2
````

More content at level 1.
`````

## Example 2: Three levels of nesting

This demonstrates even deeper nesting:

``````markdown
# Level 1

Content at level 1.

`````markdown
## Level 2

Content at level 2.

````markdown
### Level 3

This is three levels deep!

- Item A
- Item B
````

Back to level 2.
`````

Back to level 1.
``````

## Example 3: Multiple nested blocks at same level

This demonstrates multiple nested blocks:

`````markdown
# Parent Document

First nested block:

````markdown
## First Nested

Content here.
````

Second nested block:

````markdown
## Second Nested

More content.
````
`````

## Example 4: Complex nesting with code

This demonstrates nested markdown containing code blocks:

`````markdown
# Outer Markdown

This contains a nested markdown with code:

````markdown
## Inner Markdown

Here's some PowerShell:

```powershell
Write-Host "Hello from depth 2"
```

And some more text.
````
`````
