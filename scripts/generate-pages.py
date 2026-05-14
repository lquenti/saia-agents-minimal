#!/usr/bin/env python3
"""
Generate HTML documentation pages from Markdown files.
Pure Python implementation - no external dependencies required.
"""

import os
import re

def markdown_to_html(md_text):
    """Simple markdown to HTML converter (basic support)."""
    html = md_text
    
    # Headers
    html = re.sub(r'^###### (.+)$', r'<h6>\1</h6>', html, flags=re.MULTILINE)
    html = re.sub(r'^##### (.+)$', r'<h5>\1</h5>', html, flags=re.MULTILINE)
    html = re.sub(r'^#### (.+)$', r'<h4>\1</h4>', html, flags=re.MULTILINE)
    html = re.sub(r'^### (.+)$', r'<h3>\1</h3>', html, flags=re.MULTILINE)
    html = re.sub(r'^## (.+)$', r'<h2>\1</h2>', html, flags=re.MULTILINE)
    html = re.sub(r'^# (.+)$', r'<h1>\1</h1>', html, flags=re.MULTILINE)
    
    # Bold and italic
    html = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', html)
    html = re.sub(r'\*(.+?)\*', r'<em>\1</em>', html)
    
    # Inline code
    html = re.sub(r'`(.+?)`', r'<code>\1</code>', html)
    
    # Code blocks
    html = re.sub(r'```(\w*)\n(.*?)```', r'<pre><code>\2</code></pre>', html, flags=re.DOTALL)
    
    # Links
    html = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', html)
    
    # Images
    html = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', r'<img src="\2" alt="\1">', html)
    
    # Blockquotes
    html = re.sub(r'^> (.+)$', r'<blockquote>\1</blockquote>', html, flags=re.MULTILINE)
    
    # Unordered lists
    html = re.sub(r'^- (.+)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    html = re.sub(r'^\* (.+)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    
    # Ordered lists
    html = re.sub(r'^\d+\. (.+)$', r'<li>\1</li>', html, flags=re.MULTILINE)
    
    # Horizontal rule
    html = re.sub(r'^---$', r'<hr>', html, flags=re.MULTILINE)
    
    # Tables (basic)
    def convert_table(match):
        rows = match.group(1).strip().split('\n')
        html_table = '<table>'
        for i, row in enumerate(rows):
            if i == 1:  # Skip separator row
                continue
            cells = [c.strip() for c in row.split('|')[1:-1]]
            if i == 0:
                html_table += '<thead><tr>' + ''.join(f'<th>{c}</th>' for c in cells) + '</tr></thead>'
            else:
                html_table += '<tr>' + ''.join(f'<td>{c}</td>' for c in cells) + '</tr>'
        html_table += '</table>'
        return html_table
    
    html = re.sub(r'\|(.+)\|\n\|[-\s|]+\|\n((?:\|.+\|\n?)+)', convert_table, html)
    
    # Line breaks
    html = re.sub(r'  \n', r'<br>\n', html)
    html = re.sub(r'\n\n', r'</p><p>', html)
    
    # Wrap in paragraphs if needed
    if not html.strip().startswith('<'):
        html = f'<p>{html}</p>'
    
    return html

def create_html_template(title, content):
    """Create full HTML page with navigation."""
    return f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{title}</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/github-markdown-css@5/github-markdown.min.css">
  <style>
    .markdown-body {{ box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px; }}
    @media (max-width: 767px) {{ .markdown-body {{ padding: 15px; }} }}
    body {{ background-color: #f6f8fa; }}
    nav {{ background: #24292e; padding: 1rem; margin-bottom: 2rem; }}
    nav a {{ color: #fff; margin-right: 1rem; text-decoration: none; }}
    nav a:hover {{ text-decoration: underline; }}
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
  </nav>
  <div class="markdown-body">{content}</div>
</body>
</html>'''

def main():
    """Convert all markdown files to HTML."""
    # Create public directory
    os.makedirs('public', exist_ok=True)
    
    # Convert README.md
    with open('README.md', 'r') as f:
        md_content = f.read()
    html_content = markdown_to_html(md_content)
    full_html = create_html_template('Advanced Coding Agent', html_content)
    with open('public/index.html', 'w') as f:
        f.write(full_html)
    print('Converted: README.md -> index.html')
    
    # Convert docs/*.md
    docs_dir = 'docs'
    for filename in sorted(os.listdir(docs_dir)):
        if filename.endswith('.md'):
            with open(os.path.join(docs_dir, filename), 'r') as f:
                md_content = f.read()
            html_content = markdown_to_html(md_content)
            
            title = filename.replace('.md', '').replace('-', ' ').title()
            full_html = create_html_template(title, html_content)
            
            output_file = filename.replace('.md', '.html')
            with open(os.path.join('public', output_file), 'w') as f:
                f.write(full_html)
            print(f'Converted: {filename} -> {output_file}')
    
    print('\nConversion complete!')

if __name__ == '__main__':
    main()
