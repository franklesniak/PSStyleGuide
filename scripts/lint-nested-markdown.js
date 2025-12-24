#!/usr/bin/env node

/**
 * Lint Nested Markdown Script
 * 
 * This script extracts Markdown code blocks from Markdown files and runs
 * markdownlint on them to ensure nested Markdown content follows the same
 * linting rules as the outer Markdown files.
 * 
 * Usage: node scripts/lint-nested-markdown.js
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');
const MarkdownIt = require('markdown-it');
const markdownlint = require('markdownlint');

// Initialize markdown-it parser
const md = new MarkdownIt();

// ANSI color codes for terminal output
const colors = {
    reset: '\x1b[0m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    green: '\x1b[32m',
    cyan: '\x1b[36m',
    bold: '\x1b[1m'
};

/**
 * Load markdownlint configuration from .markdownlint.jsonc or .markdownlint.json
 */
function loadMarkdownlintConfig() {
    // Try .jsonc first (preferred), then fall back to .json
    const configPaths = [
        path.join(process.cwd(), '.markdownlint.jsonc'),
        path.join(process.cwd(), '.markdownlint.json')
    ];

    for (const configPath of configPaths) {
        if (fs.existsSync(configPath)) {
            const content = fs.readFileSync(configPath, 'utf8');
            // Strip out // comments and /* */ comments for . jsonc compatibility
            const jsonContent = content
                .replace(/\/\/.*$/gm, '')  // Remove single-line comments
                .replace(/\/\*[\s\S]*?\*\//g, '');  // Remove multi-line comments
            return JSON.parse(jsonContent);
        }
    }
    return {};
}

/**
 * Extract markdown code fences from content (recursive)
 * @param {string} content - Markdown content to parse
 * @param {string} filePath - Path to the original markdown file
 * @param {number} baseLine - Line number offset in the original file
 * @param {number} depth - Current nesting depth
 * @param {string} parentPath - Path description for nested blocks
 * @returns {Array} Array of extracted blocks with metadata
 */
function extractMarkdownFencesRecursive(content, filePath, baseLine = 0, depth = 0, parentPath = '') {
    const tokens = md.parse(content, {});
    const blocks = [];
    
    for (let i = 0; i < tokens.length; i++) {
        const token = tokens[i];
        
        // Look for fence tokens with markdown language identifier
        if (token.type === 'fence' && 
            (token.info.trim().toLowerCase() === 'markdown' || 
             token.info.trim().toLowerCase() === 'md')) {
            
            const blockLine = baseLine + (token.map ? token.map[0] + 1 : 0);
            const blockPath = parentPath ? `${parentPath} > block at line ${blockLine}` : `line ${blockLine}`;
            
            const blockInfo = {
                content: token.content,
                line: blockLine,
                info: token.info.trim(),
                filePath: filePath,
                depth: depth,
                parentPath: blockPath
            };
            
            blocks.push(blockInfo);
            
            // Recursively extract nested markdown fences
            if (token.content.trim().length > 0) {
                const nestedBlocks = extractMarkdownFencesRecursive(
                    token.content,
                    filePath,
                    blockLine,
                    depth + 1,
                    blockPath
                );
                blocks.push(...nestedBlocks);
            }
        }
    }
    
    return blocks;
}

/**
 * Extract markdown code fences from a file
 * @param {string} filePath - Path to the markdown file
 * @returns {Array} Array of extracted blocks with metadata
 */
function extractMarkdownFences(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    return extractMarkdownFencesRecursive(content, filePath, 0, 0, '');
}

/**
 * Run markdownlint on extracted content
 * @param {string} content - Markdown content to lint
 * @param {object} config - Markdownlint configuration
 * @returns {object} Markdownlint results
 */
function lintMarkdownContent(content, config) {
    // Create a modified config for nested markdown
    // Disable MD041 (first-line-heading) since nested markdown snippets
    // may not start with a top-level heading
    // Disable MD051 (link-fragments) since nested markdown often contains
    // example/placeholder links that reference anchors in other documents
    const nestedConfig = {
        ...config,
        'MD041': false,
        'MD051': false
    };
    
    const options = {
        strings: {
            'content': content
        },
        config: nestedConfig
    };
    
    return markdownlint.sync(options);
}

/**
 * Format and display linting results
 * @param {Array} allResults - Array of results with context
 * @returns {boolean} True if any errors were found
 */
function displayResults(allResults) {
    let hasErrors = false;
    
    if (allResults.length === 0) {
        console.log(`${colors.green}✓${colors.reset} No issues found in nested Markdown code fences`);
        return false;
    }
    
    console.log(`\n${colors.bold}${colors.red}Nested Markdown Linting Issues:${colors.reset}\n`);
    
    for (const result of allResults) {
        if (result.errors.length === 0) {
            continue;
        }
        
        hasErrors = true;
        
        console.log(`${colors.cyan}File:${colors.reset} ${result.filePath}`);
        const depthIndicator = result.depth > 0 ? ` ${colors.yellow}[depth ${result.depth}]${colors.reset}` : '';
        const pathInfo = result.parentPath ? ` (${result.parentPath})` : '';
        console.log(`  ${colors.yellow}Code fence at line ${result.line}${depthIndicator} (${result.info} block #${result.blockIndex})${pathInfo}:${colors.reset}`);
        
        for (const error of result.errors) {
            // Calculate the actual line number in the outer file
            // result.line is the fence opening line (e.g., line 9)
            // error.lineNumber is 1-based line within the content (e.g., line 1 is first content line)
            // Content starts at result.line + 1, so line N of content is at result.line + N
            const actualLineNumber = result.line + error.lineNumber;
            const nestedLineInfo = result.depth > 0 ? ` (nested line ${error.lineNumber})` : '';
            console.log(`    ${actualLineNumber}:${error.errorRange ? error.errorRange[0] : 1}${nestedLineInfo} ${colors.red}${error.ruleNames.join('/')}${colors.reset} ${error.ruleDescription}`);
            if (error.errorDetail) {
                console.log(`      ${colors.yellow}${error.errorDetail}${colors.reset}`);
            }
        }
        
        console.log('');
    }
    
    return hasErrors;
}

/**
 * Main function
 */
async function main() {
    try {
        console.log(`${colors.bold}Linting nested Markdown in code fences...${colors.reset}\n`);
        
        // Load markdownlint configuration
        const config = loadMarkdownlintConfig();
        
        // Find all markdown files (excluding node_modules)
        const files = await glob('**/*.md', {
            ignore: ['node_modules/**', '**/node_modules/**'],
            cwd: process.cwd(),
            absolute: true
        });
        
        console.log(`Found ${files.length} Markdown file(s) to scan\n`);
        
        let totalBlocks = 0;
        const allResults = [];
        
        // Process each file
        for (const file of files) {
            const relativePath = path.relative(process.cwd(), file);
            const blocks = extractMarkdownFences(file);
            
            if (blocks.length > 0) {
                console.log(`${colors.cyan}${relativePath}${colors.reset}: Found ${blocks.length} nested Markdown block(s)`);
                totalBlocks += blocks.length;
                
                // Lint each extracted block
                blocks.forEach((block, index) => {
                    const lintResults = lintMarkdownContent(block.content, config);
                    const errors = lintResults.content || [];
                    
                    if (errors.length > 0) {
                        allResults.push({
                            filePath: relativePath,
                            line: block.line,
                            info: block.info,
                            blockIndex: index + 1,
                            depth: block.depth,
                            parentPath: block.parentPath,
                            errors: errors
                        });
                    }
                });
            }
        }
        
        console.log(`\nTotal nested Markdown blocks found: ${totalBlocks}\n`);
        
        // Display results
        const hasErrors = displayResults(allResults);
        
        if (hasErrors) {
            console.log(`${colors.red}${colors.bold}✗${colors.reset} ${colors.red}Nested Markdown linting failed${colors.reset}\n`);
            process.exit(1);
        } else {
            console.log(`${colors.green}${colors.bold}✓${colors.reset} ${colors.green}Nested Markdown linting passed${colors.reset}\n`);
            process.exit(0);
        }
        
    } catch (error) {
        console.error(`${colors.red}Error:${colors.reset}`, error.message);
        console.error(error.stack);
        process.exit(1);
    }
}

// Run main function
main();
