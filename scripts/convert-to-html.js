#!/usr/bin/env node
/**
 * Convert Markdown documentation to HTML for GitLab Pages
 * Run locally to test before pushing to GitLab
 */

const fs = require('fs');
const path = require('path');

// Try to load markdown-it, fallback to simple conversion
let md;
try {
  const MarkdownIt = require('markdown-it');
  md = new MarkdownIt({ html: true, linkify: true, typographer: true });
} catch (e) {
  console.log('markdown-it not installed, using simple conversion');
  console.log('Install with: npm install -g markdown-it');
  md = null;
}

// HTML template with navigation
function createHTML(title, content) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css@5/github-markdown.min.css">
  <style>
    .markdown-body {
      box-sizing: border-box;
      min-width: 200px;
      max-width: 980px;
      margin: 0 auto;
      padding: 45px;
    }
    @media (max-width: 767px) {
      .markdown-body {
        padding: 15px;
      }
    }
    body {
      background-color: #f6f8fa;
    }
    nav {
      background: #24292e;
      padding: 1rem;
      margin-bottom: 2rem;
    }
    nav a {
      color: #fff;
      margin-right: 1rem;
      text-decoration: none;
    }
    nav a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <nav>
    <a href="index.html">README</a>
    <a href="CONFIGURATION.html">Configuration</a>
    <a href="SKILLS.html">Skills</a>
    <a href="SECURITY.html">Security</a>
    <a href="SOFTWARE_ENGINEERING_WORKFLOW.html">Workflow</a>
    <a href="QUICK_START_SKILLS.html">Quick Start</a>
    <a href="ENABLE_GITLAB_PAGES.html">Enable Pages</a>
  </nav>
  <div class="markdown-body">
    ${content}
  </div>
</body>
</html>`;
}

// Simple markdown to HTML conversion (fallback)
function simpleConvert(markdown) {
  let html = markdown
    .replace(/^### (.*$)/gim, '<h3>$1</h3>')
    .replace(/^## (.*$)/gim, '<h2>$1</h2>')
    .replace(/^# (.*$)/gim, '<h1>$1</h1>')
    .replace(/\*\*(.*)\*\*/gim, '<strong>$1</strong>')
    .replace(/\*(.*)\*/gim, '<em>$1</em>')
    .replace(/`(.*)`/gim, '<code>$1</code>')
    .replace(/^\> (.*$)/gim, '<blockquote>$1</blockquote>')
    .replace(/^- (.*$)/gim, '<li>$1</li>')
    .replace(/\n/gim, '<br>');
  return html;
}

function convertFile(inputPath, outputPath, title) {
  const markdown = fs.readFileSync(inputPath, 'utf8');
  const content = md ? md.render(markdown) : simpleConvert(markdown);
  const html = createHTML(title, content);
  fs.writeFileSync(outputPath, html);
  console.log(`✓ ${path.basename(inputPath)} → ${path.basename(outputPath)}`);
}

function main() {
  const publicDir = path.join(__dirname, '..', 'public');
  
  // Create public directory
  if (!fs.existsSync(publicDir)) {
    fs.mkdirSync(publicDir, { recursive: true });
  }

  console.log('Converting documentation to HTML...\n');

  // Convert README.md
  convertFile(
    path.join(__dirname, '..', 'README.md'),
    path.join(publicDir, 'index.html'),
    'Advanced Coding Agent'
  );

  // Convert docs/*.md
  const docsDir = path.join(__dirname, '..', 'docs');
  const files = fs.readdirSync(docsDir);

  files.forEach(file => {
    if (file.endsWith('.md')) {
      const title = file.replace('.md', '').replace(/-/g, ' ').toUpperCase();
      convertFile(
        path.join(docsDir, file),
        path.join(publicDir, file.replace('.md', '.html')),
        title
      );
    }
  });

  console.log('\n✅ Conversion complete!');
  console.log(`\nView locally: cd ${publicDir} && python3 -m http.server 8080`);
  console.log('Then open: http://localhost:8080');
}

main();
