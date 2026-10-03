#!/usr/bin/env node

/**
 * Lint Nested Markdown Script
 *
 * This script extracts Markdown code blocks from Markdown files and runs
 * markdownlint on them to ensure nested Markdown content follows the same
 * linting rules as the outer Markdown files.
 *
 * Usage: node .github/workflows/lint-nested-markdown.js [--outer]
 */

const fs = require('fs');
const path = require('path');
let glob, globSync, parseJsonc, MarkdownIt, markdownlintSync;
try {
    ({ glob, globSync } = require('glob'));
    ({ parse: parseJsonc } = require('jsonc-parser'));
    MarkdownIt = require('markdown-it');
    ({ lint: markdownlintSync } = require('markdownlint/sync'));
} catch (error) {
    if (require.main !== module) throw error;
    console.error(`Markdown lint tooling: ${error.message}`);
    process.exit(2);
}

const markdownIgnore = [
    'node_modules/**',
    '**/node_modules/**',
    '.git/**',
    '**/.git/**',
    '.venv/**',
    '**/.venv/**'
];

function findMarkdownFiles(repoRoot) {
    return glob('**/*.{md,mdc}', {
        ignore: markdownIgnore,
        cwd: repoRoot,
        dot: true,
        absolute: true,
        follow: false,
        nodir: true
    });
}

/**
 * Validate one nested-Markdown input before reading it.
 * @param {string} repoRoot - Repository root.
 * @param {string} filePath - Candidate Markdown input.
 * @param {object} fileSystem - File-system adapter used by deterministic tests.
 * @returns {string} Canonical in-repository input path.
 */
function validateMarkdownInput(repoRoot, filePath, fileSystem = fs) {
    const rootPath = fileSystem.realpathSync(repoRoot);
    const inputMetadata = fileSystem.lstatSync(filePath);

    if (inputMetadata.isSymbolicLink() || !inputMetadata.isFile()) {
        throw new Error(`Markdown input must be a non-symlink regular file: ${filePath}`);
    }

    const resolvedInputPath = fileSystem.realpathSync(filePath);
    const relativeInputPath = path.relative(rootPath, resolvedInputPath);
    if (relativeInputPath === '..' ||
        relativeInputPath.startsWith(`..${path.sep}`) ||
        path.isAbsolute(relativeInputPath)) {
        throw new Error(`Markdown input resolves outside the repository: ${filePath}`);
    }

    return resolvedInputPath;
}

/**
 * Read every Markdown input after validating its repository boundary.
 * @param {string} repoRoot - Repository root.
 * @returns {Promise<Array<{filePath: string, content: string}>>} Safe inputs.
 */
async function readMarkdownInputs(repoRoot) {
    const files = await findMarkdownFiles(repoRoot);
    const markdownInputs = [];

    for (const file of files) {
        const relativePath = path.relative(repoRoot, file);
        const safeInputPath = validateMarkdownInput(repoRoot, file);
        markdownInputs.push({
            filePath: relativePath,
            content: fs.readFileSync(safeInputPath, 'utf8')
        });
    }

    return markdownInputs;
}

/**
 * Prove the input boundary with deterministic file-system projections.
 */
function runMarkdownInputSafetySelfTest() {
    const fixtureRoot = path.resolve('nested-markdown-input-fixture');
    const regularInput = path.join(fixtureRoot, 'rules', 'valid.mdc');
    const outsideInput = path.resolve('nested-markdown-outside', 'outside.mdc');
    const siblingInput = path.resolve(`${fixtureRoot}-other`, 'sibling.mdc');
    const metadata = (symbolicLink, regularFile) => ({
        isSymbolicLink: () => symbolicLink,
        isFile: () => regularFile
    });
    const cases = [
        {
            name: 'regular in-root file',
            metadata: metadata(false, true),
            resolvedInput: regularInput,
            expectedFailure: ''
        },
        {
            name: 'symbolic-link leaf',
            metadata: metadata(true, true),
            resolvedInput: outsideInput,
            expectedFailure: 'must be a non-symlink regular file'
        },
        {
            name: 'non-regular leaf',
            metadata: metadata(false, false),
            resolvedInput: regularInput,
            expectedFailure: 'must be a non-symlink regular file'
        },
        {
            name: 'resolved outside file',
            metadata: metadata(false, true),
            resolvedInput: outsideInput,
            expectedFailure: 'resolves outside the repository'
        },
        {
            name: 'sibling-prefix file',
            metadata: metadata(false, true),
            resolvedInput: siblingInput,
            expectedFailure: 'resolves outside the repository'
        }
    ];

    for (const inputCase of cases) {
        const fileSystem = {
            lstatSync: () => inputCase.metadata,
            realpathSync: (targetPath) => targetPath === fixtureRoot
                ? fixtureRoot
                : inputCase.resolvedInput
        };
        let failure = '';
        try {
            const result = validateMarkdownInput(
                fixtureRoot,
                regularInput,
                fileSystem
            );
            if (result !== inputCase.resolvedInput) {
                failure = 'returned an unexpected resolved path';
            }
        } catch (error) {
            failure = error.message;
        }
        if (inputCase.expectedFailure === '') {
            if (failure !== '') {
                throw new Error(`Input-safety self-test failed (${inputCase.name}): ${failure}`);
            }
        } else if (!failure.includes(inputCase.expectedFailure)) {
            throw new Error(`Input-safety self-test did not reject ${inputCase.name}`);
        }
    }
}

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
function assertLintConfigurationInputs(repoRoot = path.resolve(__dirname, '../..')) {
    const allowed = new Set(['.github/workflows/.markdownlint.jsonc', '.github/workflows/.markdownlint.json']);
    const selectors = globSync('**/.markdownlint*', {
        cwd: repoRoot, dot: true, follow: false, ignore: markdownIgnore
    });
    const selectorName = /^\.markdownlint(?:-cli2\.(?:jsonc|json|ya?ml|cjs|mjs)|rc|ignore|\.(?:jsonc|json|ya?ml|cjs|mjs|js|toml))$/iu;
    for (const relative of selectors) {
        if (selectorName.test(path.basename(relative)) && !allowed.has(relative.split(path.sep).join('/'))) {
            throw new Error(`Unsupported Markdown lint configuration: ${relative}. Use .github/workflows/.markdownlint.jsonc.`);
        }
    }

}

function markdownlintConfigPath(repoRoot = path.resolve(__dirname, '../..')) {
    for (const name of ['.markdownlint.jsonc', '.markdownlint.json']) {
        const file = path.join(repoRoot, '.github/workflows', name);
        try { fs.lstatSync(file); }
        catch (error) { if (error.code === 'ENOENT') continue; throw error; }
        return validateMarkdownInput(repoRoot, file);
    }
    throw new Error('Markdown lint requires .github/workflows/.markdownlint.jsonc (or .markdownlint.json).');
}

function loadMarkdownlintConfig(repoRoot = path.resolve(__dirname, '../..')) {
    assertLintConfigurationInputs(repoRoot);
    const file = markdownlintConfigPath(repoRoot);
    if (fs.statSync(file).size > 1024 * 1024) throw new Error('Markdown lint configuration exceeds one MiB.');
    const errors = [];
    const config = parseJsonc(fs.readFileSync(file, 'utf8'), errors);
    if (errors.length || !config || typeof config !== 'object' || Array.isArray(config)) {
        throw new Error(`Invalid Markdown lint configuration: ${file}.`);
    }
    if (Object.hasOwn(config, 'extends')) {
        throw new Error('Unsupported Markdown lint configuration: extends. Put rules in the workflow rules file.');
    }
    return config;
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

    return markdownlintSync(options);
}

/**
 * Lint nested Markdown in caller-supplied content without reading its paths.
 * @param {Array<{filePath: string, content: string}>} markdownInputs - Inputs to lint.
 * @param {object} config - Markdownlint configuration.
 * @param {(message: string) => void} logMessage - Progress logger.
 * @returns {{totalBlocks: number, allResults: Array}} Nested lint results.
 */
function lintNestedMarkdownContents(
    markdownInputs,
    config = loadMarkdownlintConfig(),
    logMessage = () => {}
) {
    if (!Array.isArray(markdownInputs)) {
        throw new TypeError('Nested Markdown inputs must be an array.');
    }

    let totalBlocks = 0;
    const allResults = [];

    for (const input of markdownInputs) {
        if (!input || typeof input.filePath !== 'string' ||
            typeof input.content !== 'string') {
            throw new TypeError('Each nested Markdown input must contain string filePath and content values.');
        }

        const blocks = extractMarkdownFencesRecursive(
            input.content,
            input.filePath,
            0,
            0,
            ''
        );
        if (blocks.length === 0) {
            continue;
        }

        logMessage(`${colors.cyan}${input.filePath}${colors.reset}: Found ${blocks.length} nested Markdown block(s)`);
        totalBlocks += blocks.length;
        blocks.forEach((block, index) => {
            const lintResults = lintMarkdownContent(block.content, config);
            const errors = lintResults.content || [];

            if (errors.length > 0) {
                allResults.push({
                    filePath: input.filePath,
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

    return { totalBlocks, allResults };
}

/**
 * Run outer Markdown lint against caller-supplied in-memory content.
 * @param {string} repoRoot - Repository root.
 * @param {Array<{filePath: string, content: string}>} markdownInputs - Safe inputs.
 * @returns {Promise<number>} Zero for success or one for lint findings; throws on tooling failure.
 */
async function lintOuterMarkdownContents(repoRoot, markdownInputs) {
    const config = loadMarkdownlintConfig(repoRoot);
    const strings = Object.create(null);
    for (const input of markdownInputs) {
        if (!input || typeof input.filePath !== 'string' || typeof input.content !== 'string') {
            throw new TypeError('Each outer Markdown input must contain string filePath and content values.');
        }
        strings[input.filePath] = input.content;
    }
    const result = markdownlintSync({ strings, config });
    for (const [file, errors] of Object.entries(result)) {
        for (const error of errors) {
            console.error(`${file}:${error.lineNumber}:${error.errorRange?.[0] ?? 1} ${error.ruleNames.join('/')} ${error.ruleDescription}${error.errorDetail ? ` [${error.errorDetail}]` : ''}`);
        }
    }
    return Object.values(result).some(errors => errors.length) ? 1 : 0;
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
        const mode = process.argv[2] ?? '--nested';
        if (!['--nested', '--outer'].includes(mode) || process.argv.length > 3) {
            throw new Error('Usage: lint-nested-markdown.js [--outer]');
        }

        const phaseName = mode === '--outer'
            ? 'outer Markdown'
            : 'nested Markdown in code fences';
        console.log(`${colors.bold}Linting ${phaseName}...${colors.reset}\n`);

        runMarkdownInputSafetySelfTest();

        // Repository root is two levels up from this script
        const repoRoot = path.resolve(__dirname, '../..');
        const markdownInputs = await readMarkdownInputs(repoRoot);
        console.log(`Found ${markdownInputs.length} Markdown file(s) to scan\n`);

        if (mode === '--outer') {
            const exitCode = await lintOuterMarkdownContents(
                repoRoot,
                markdownInputs
            );
            if (![0, 1].includes(exitCode)) {
                throw new Error(`Outer Markdown lint returned exit status ${exitCode}.`);
            }
            process.exitCode = exitCode;
            return;
        }

        // Load markdownlint configuration
        const config = loadMarkdownlintConfig();
        const { totalBlocks, allResults } = lintNestedMarkdownContents(
            markdownInputs,
            config,
            console.log
        );

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
        process.exit(2);
    }
}

// Run main function
if (require.main === module) {
    main();
}

module.exports = {
    assertLintConfigurationInputs,
    loadMarkdownlintConfig,
    markdownlintConfigPath,
    displayResults,
    findMarkdownFiles,
    lintOuterMarkdownContents,
    lintNestedMarkdownContents,
    readMarkdownInputs,
    runMarkdownInputSafetySelfTest,
    validateMarkdownInput
};
