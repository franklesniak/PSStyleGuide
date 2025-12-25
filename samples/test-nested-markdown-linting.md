# Test File for Nested Markdown Linting

This file demonstrates the nested Markdown linting capability and serves as a test suite.

## Example 1: Compliant nested markdown

This nested markdown block follows all the rules:

````markdown
## Header

List without blank lines:

- Item 1
- Item 2
````

## Example 2: Another compliant block

This nested markdown block also follows all the rules:

````markdown
# Proper Header

This is a paragraph.

- List item 1
- List item 2

Another paragraph.
````

## Example 3: Nested markdown with code

This demonstrates that nested code blocks within markdown fences are handled correctly:

````markdown
# Example

Code example:

```powershell
Write-Host "Hello World"
```
````

## Example 4: Multiple fence lengths

This demonstrates support for different fence lengths:

`````markdown
# Five Backtick Fence

This can contain four-backtick code blocks:

````text
Content here
````
`````

## Example 5: 'md' language identifier

This uses 'md' instead of 'markdown':

````md
# MD Language Identifier

This should also be linted.

- List item
````
