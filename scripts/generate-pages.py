#!/usr/bin/env python3
"""
Generate HTML documentation pages from Markdown files.
Pure Python implementation - no external dependencies required.
"""

import os
import re

def markdown_to_html(md_text):
    """Convert markdown to HTML with proper support for all features."""
    lines = md_text.split('\n')
    html_lines = []
    in_code_block = False
    in_list = False
    in_table = False
    code_block_lang = ''
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Code blocks
        if line.startswith('```'):
            if not in_code_block:
                in_code_block = True
                code_block_lang = line[3:].strip()
                html_lines.append(f'<pre><code class="language-{code_block_lang}">')
            else:
                in_code_block = False
                html_lines.append('</code></pre>')
            i += 1
            continue
        
        if in_code_block:
            html_lines.append(line)
            i += 1
            continue
        
        # Close list if we hit non-list content
        if in_list and not line.startswith('- ') and not line.startswith('* ') and not re.match(r'^\d+\. ', line):
            html_lines.append('</ul>')
            in_list = False
        
        # Close table if we hit non-table content
        if in_table and (not '|' in line or line.strip() == ''):
            html_lines.append('</table>')
            in_table = False
        
        # Empty line
        if line.strip() == '':
            i += 1
            continue
        
        # Headers
        if line.startswith('###### '):
            html_lines.append(f'<h6>{line[7:]}</h6>')
        elif line.startswith('##### '):
            html_lines.append(f'<h5>{line[6:]}</h5>')
        elif line.startswith('#### '):
            html_lines.append(f'<h4>{line[5:]}</h4>')
        elif line.startswith('### '):
            html_lines.append(f'<h3>{line[4:]}</h3>')
        elif line.startswith('## '):
            html_lines.append(f'<h2>{line[3:]}</h2>')
        elif line.startswith('# '):
            html_lines.append(f'<h1>{line[2:]}</h1>')
        
        # Horizontal rule
        elif line.strip() in ['---', '***', '___']:
            html_lines.append('<hr>')
        
        # Table detection (starts with |)
        elif line.strip().startswith('|') and in_table:
            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            html_lines.append('</table>')
            in_table = False
        
        # Table start
        elif line.strip().startswith('|') and not in_table:
            # Check if this is a header row (first row)
            html_lines.append('<table><thead><tr>')
            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            for cell in cells:
                html_lines.append(f'<th>{process_inline(cell)}</th>')
            html_lines.append('</tr></thead><tbody>')
            in_table = True
        
        # Table separator row (skip it)
        elif line.strip().startswith('|') and in_table and re.match(r'^\|[-\s|]+\|$', line):
            pass
        
        # Table body
        elif line.strip().startswith('|') and in_table:
            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            html_lines.append('<tr>')
            for cell in cells:
                html_lines.append(f'<td>{process_inline(cell)}</td>')
            html_lines.append('</tr>')
        
        # Unordered list
        elif line.startswith('- ') or line.startswith('* '):
            if not in_list:
                html_lines.append('<ul>')
                in_list = True
            item = line[2:]
            html_lines.append(f'<li>{process_inline(item)}</li>')
        
        # Ordered list
        elif re.match(r'^\d+\. ', line):
            if not in_list:
                html_lines.append('<ol>')
                in_list = True
            item = re.sub(r'^\d+\. ', '', line)
            html_lines.append(f'<li>{process_inline(item)}</li>')
        
        # Blockquote
        elif line.startswith('> '):
            html_lines.append(f'<blockquote>{process_inline(line[2:])}</blockquote>')
        
        # Regular paragraph
        else:
            html_lines.append(f'<p>{process_inline(line)}</p>')
        
        i += 1
    
    # Close any open tags
    if in_list:
        html_lines.append('</ul></ol>')
    if in_table:
        html_lines.append('</tbody></table>')
    if in_code_block:
        html_lines.append('</code></pre>')
    
    return '\n'.join(html_lines)

def process_inline(text):
    """Process inline markdown elements."""
    # Inline code (must be before bold/italic)
    text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
    
    # Bold (must be before italic)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', text)
    
    # Italic
    text = re.sub(r'\*([^*]+)\*', r'<em>\1</em>', text)
    
    # Links
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', text)
    
    # Images
    text = re.sub(r'!\[([^\]]*)\]\(([^)]+)\)', r'<img src="\2" alt="\1">', text)
    
    # Inline code spans (multiple backticks)
    text = re.sub(r'``([^`]+)``', r'<code>\1</code>', text)
    
    return text

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
    pre {{ background: #f6f8fa; padding: 16px; overflow-x: auto; border-radius: 6px; }}
    code {{ background: rgba(27,31,35,0.05); padding: 0.2em 0.4em; border-radius: 3px; }}
    pre code {{ background: transparent; padding: 0; }}
    table {{ border-collapse: collapse; width: 100%; margin: 16px 0; }}
    th, td {{ border: 1px solid #dfe2e5; padding: 6px 13px; }}
    th {{ background: #f6f8fa; font-weight: bold; }}
    tr:nth-child(2n) {{ background: #f6f8fa; }}
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
