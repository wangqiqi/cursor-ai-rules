---
name: pdf
description: Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. Use when needing to process, generate, or analyze PDF documents at scale.
---

# 📄 PDF Processing Toolkit

Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. Essential for programmatic PDF document processing and automation.

## When to Use

- When Claude needs to extract text or tables from PDF documents
- For creating new PDF documents programmatically
- When merging or splitting PDF files
- For filling PDF forms automatically
- When processing PDF documents at scale
- For analyzing PDF content and structure

## Instructions

### Text and Table Extraction

1. **Text Extraction**: Use appropriate libraries to extract text content while preserving formatting
2. **Table Recognition**: Identify and extract tabular data from PDF documents
3. **OCR Processing**: Handle scanned documents with optical character recognition
4. **Content Analysis**: Parse document structure and identify key sections

### Document Creation and Modification

1. **PDF Generation**: Create new PDF documents from various data sources
2. **Form Filling**: Automatically populate PDF form fields
3. **Document Merging**: Combine multiple PDFs into single documents
4. **Page Manipulation**: Split, rotate, or reorder PDF pages

### Best Practices

- **Error Handling**: Implement robust error handling for corrupted PDFs
- **Performance**: Use efficient libraries for large document processing
- **Security**: Validate PDF sources and handle sensitive data appropriately
- **Compatibility**: Ensure cross-platform compatibility

### Common Use Cases

#### Data Extraction
```python
# Extract text from PDF
def extract_pdf_text(pdf_path):
    # Implementation for text extraction
    pass

# Extract tables from PDF
def extract_pdf_tables(pdf_path):
    # Implementation for table extraction
    pass
```

#### Form Processing
```python
# Fill PDF form fields
def fill_pdf_form(pdf_path, data_dict):
    # Implementation for form filling
    pass
```

#### Document Assembly
```python
# Merge multiple PDFs
def merge_pdfs(pdf_list, output_path):
    # Implementation for PDF merging
    pass
```

## Dependencies

- Python PDF processing libraries (PyPDF2, pdfplumber, reportlab, etc.)
- For advanced features: OCR libraries (Tesseract, etc.)
- File system access for reading/writing PDF files

## License

Proprietary. LICENSE.txt has complete terms

---
*Source: Anthropic Skills Library | Integrated: 2026-01-15*