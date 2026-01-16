---
command: skill:docx
description: "🎯 Skills扩展: Guide for creating, editing, and formatting Microsoft Word documents with advanced features like tables, images, headers/footers, and styling | 来源: Anthropic Skills库"
alwaysApply: false
skill_metadata:
  original_name: "docx"
  source_path: "{{SKILLS_SOURCE}}/docx"
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

## 📖 详细技术指南

### 何时使用
- 创建Word文档程序化处理
- 生成报告、合同或格式化文档
- 需要自动化文档创建工作流
- 处理现有Word文档
- 将数据转换为格式化Word文档

### 基本文档创建流程
1. **初始化文档**: 创建新文档或加载现有模板
2. **设置属性**: 配置标题、作者和文档元数据
3. **配置布局**: 设置页面边距、方向和大小
4. **添加内容**: 插入标题、段落和格式化文本

### 高级格式化功能

#### 文本和段落格式化
- **字符样式**: 粗体、斜体、下划线、字体更改
- **段落样式**: 对齐方式、间距、缩进
- **字体管理**: 字体族、大小、颜色自定义

#### 文档结构
- **标题**: 层次化标题级别用于文档结构
- **章节**: 单个文档内的不同布局
- **页眉/页脚**: 带有动态内容的页面页眉和页脚

#### 富内容
- **表格**: 创建具有合并单元格的复杂表格
- **图片**: 插入带标题的图片并定位
- **列表**: 带自定义格式化的编号和项目符号列表

### Python-docx实现示例

```python
from docx import Document
from docx.shared import Inches

# 创建新文档
doc = Document()

# 添加标题
doc.add_heading('文档标题', 0)

# 添加格式化段落
para = doc.add_paragraph('这是一个')
para.add_run('粗体').bold = True
para.add_run('和')
para.add_run('斜体').italic = True
para.add_run('段落。')

# 添加表格
table = doc.add_table(rows=3, cols=3)
table.style = 'Table Grid'
hdr_cells = table.rows[0].cells
hdr_cells[0].text = '表头1'
hdr_cells[1].text = '表头2'
hdr_cells[2].text = '表头3'

# 添加图片
doc.add_picture('image.png', width=Inches(4))

# 保存文档
doc.save('example.docx')
```

### 最佳实践

#### 文档结构
- 使用语义标题层次结构（标题1、2、3等）
- 在整个文档中保持一致的格式
- 在实现前规划文档布局

#### 性能优化
- 对重复性结构使用文档模板
- 将相似的操作一起批处理
- 最小化样式更改以获得更好性能

#### 错误处理
- 处理前验证输入数据
- 处理文件权限和访问问题
- 为调试提供清晰的错误消息

### 常见用例

#### 报告生成
```python
def generate_monthly_report(data):
    doc = Document()
    doc.add_heading('月度销售报告', 0)

    # 添加汇总表格
    table = doc.add_table(rows=len(data)+1, cols=3)
    # ... 用数据填充表格

    return doc
```

#### 文档模板
- 带有动态字段替换的合同模板
- 带有计算总数的发票生成
- 带有个性化内容的证书创建

#### 批量处理
- 将CSV数据转换为格式化报告
- 从数据库记录生成多个文档
- 处理带有变量数据的文档模板

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