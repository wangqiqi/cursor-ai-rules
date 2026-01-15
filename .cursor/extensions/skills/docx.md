---
command: skill:docx
description: "🎯 Skills扩展: Guide for creating, editing, and formatting Microsoft Word documents with advanced features like tables, images, headers/footers, and styling | 来源: Anthropic Skills库"
alwaysApply: false
skill_metadata:
  original_name: "docx"
  source_path: "/home/saida/workspace/skills/skills/docx"
  category: "document_processing"
  dependencies: ["python", "docx"]
  license: "Complete terms in LICENSE.txt"
---

# 🎯 Skills扩展: docx

Guide for creating, editing, and formatting Microsoft Word documents with advanced features like tables, images, headers/footers, and styling

## 🔧 使用方法

```bash
@master skill:docx [参数]    # 调用Word文档处理技能
```

## 📚 原始文档

This skill provides comprehensive guidance for working with Microsoft Word documents through code. It covers document creation, text formatting, tables, images, headers/footers, and advanced styling options.

## Core Capabilities

### Document Creation
- Create new Word documents programmatically
- Set document properties (title, author, etc.)
- Configure page layout and margins

### Text Formatting
- Apply character formatting (bold, italic, underline, etc.)
- Set paragraph formatting (alignment, spacing, indentation)
- Work with fonts, sizes, and colors

### Advanced Features
- Insert and format tables
- Add images and positioning
- Create headers and footers
- Manage styles and themes
- Handle document sections

## Implementation Approaches

### Python with python-docx
The primary implementation uses the `python-docx` library:

```python
from docx import Document

# Create a new document
doc = Document()

# Add content
doc.add_heading('Document Title', 0)
doc.add_paragraph('This is a paragraph.')

# Save the document
doc.save('example.docx')
```

### Alternative Approaches
- Direct XML manipulation for advanced formatting
- Third-party libraries for specific use cases
- Web-based document generation

## Usage Patterns

### Basic Document Creation
1. Initialize document object
2. Add content (headings, paragraphs, etc.)
3. Apply formatting as needed
4. Save to file

### Complex Document Assembly
1. Create document sections
2. Add headers/footers
3. Insert tables and images
4. Apply consistent styling
5. Generate final document

## Best Practices

### Document Structure
- Use semantic heading levels
- Maintain consistent formatting
- Plan document layout before implementation

### Performance Considerations
- Batch operations when possible
- Minimize style changes
- Use document templates for consistency

### Error Handling
- Validate input data
- Handle file permissions
- Provide meaningful error messages

## Integration Examples

### Flask Web Application
```python
@app.route('/generate-report')
def generate_report():
    doc = Document()
    # Add report content
    return send_file('report.docx')
```

### Command Line Tool
```bash
python generate_docx.py --template template.docx --output report.docx
```

## Common Use Cases

1. **Report Generation**: Automated business report creation
2. **Document Templates**: Fill templates with dynamic data
3. **Batch Processing**: Convert data to formatted documents
4. **Document Assembly**: Combine multiple sources into single document

---
*来源: Anthropic Skills库 | 集成时间: 2026-01-15*