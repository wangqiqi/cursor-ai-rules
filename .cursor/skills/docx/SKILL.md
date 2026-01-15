---
name: docx
description: Guide for creating, editing, and formatting Microsoft Word documents with advanced features like tables, images, headers/footers, and styling.
---

# 📝 Word Document Processing

Comprehensive guide for creating, editing, and formatting Microsoft Word documents programmatically. Supports advanced features including tables, images, headers/footers, and professional styling.

## When to Use

- When creating Word documents programmatically
- For generating reports, contracts, or formatted documents
- When needing to automate document creation workflows
- For processing existing Word documents
- When converting data to formatted Word documents

## Instructions

### Document Creation Basics

1. **Initialize Document**: Create new document or load existing template
2. **Set Properties**: Configure title, author, and document metadata
3. **Configure Layout**: Set page margins, orientation, and size
4. **Add Content**: Insert headings, paragraphs, and formatted text

### Advanced Formatting Features

#### Text and Paragraph Formatting
- **Character Styles**: Bold, italic, underline, font changes
- **Paragraph Styles**: Alignment, spacing, indentation
- **Font Management**: Font family, size, color customization

#### Document Structure
- **Headings**: Hierarchical heading levels for document structure
- **Sections**: Different layouts within single document
- **Headers/Footers**: Page headers and footers with dynamic content

#### Rich Content
- **Tables**: Create and format complex tables with merged cells
- **Images**: Insert and position images with captions
- **Lists**: Numbered and bulleted lists with custom formatting

### Implementation with Python-docx

```python
from docx import Document
from docx.shared import Inches

# Create new document
doc = Document()

# Add title
doc.add_heading('Document Title', 0)

# Add formatted paragraph
para = doc.add_paragraph('This is a ')
para.add_run('bold').bold = True
para.add_run(' and ')
para.add_run('italic').italic = True
para.add_run(' paragraph.')

# Add table
table = doc.add_table(rows=3, cols=3)
table.style = 'Table Grid'
hdr_cells = table.rows[0].cells
hdr_cells[0].text = 'Header 1'
hdr_cells[1].text = 'Header 2'
hdr_cells[2].text = 'Header 3'

# Add image
doc.add_picture('image.png', width=Inches(4))

# Save document
doc.save('example.docx')
```

### Best Practices

#### Document Structure
- Use semantic heading hierarchy (Heading 1, 2, 3, etc.)
- Maintain consistent formatting throughout document
- Plan document layout before implementation

#### Performance Optimization
- Use document templates for repetitive structures
- Batch similar operations together
- Minimize style changes for better performance

#### Error Handling
- Validate input data before processing
- Handle file permissions and access issues
- Provide clear error messages for debugging

### Common Use Cases

#### Report Generation
```python
def generate_monthly_report(data):
    doc = Document()
    doc.add_heading('Monthly Sales Report', 0)

    # Add summary table
    table = doc.add_table(rows=len(data)+1, cols=3)
    # ... populate table with data

    return doc
```

#### Document Templates
- Contract templates with dynamic field replacement
- Invoice generation with calculated totals
- Certificate creation with personalized content

#### Batch Processing
- Convert CSV data to formatted reports
- Generate multiple documents from database records
- Process document templates with variable data

## Dependencies

- Python 3.6+
- python-docx library
- Optional: pandas for data processing
- Optional: jinja2 for template processing

## Integration Patterns

- **Web Applications**: Generate documents on-demand
- **Command Line Tools**: Batch document processing
- **API Services**: Document generation as a service
- **Data Pipelines**: Automated report generation

## License

Complete terms in LICENSE.txt

---
*Source: Anthropic Skills Library | Integrated: 2026-01-15*