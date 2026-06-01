---
command: skill:pdf
description: "🎯 Skills扩展: Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. When Claude needs to fill in a PDF form or programmatically process, generate, or analyze PDF documents at scale."
alwaysApply: false
---

# 🎯 Skills扩展: pdf

Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. When Claude needs to fill in a PDF form or programmatically process, generate, or analyze PDF documents at scale.

## 🔧 使用方法

```bash
/master skill:pdf [参数]
```

## 📚 原始文档

description: Comprehensive PDF manipulation toolkit for extracting text and tables, creating new PDFs, merging/splitting documents, and handling forms. When Claude needs to fill in a PDF form or programmatically process, generate, or analyze PDF documents at scale.
license: Proprietary. LICENSE.txt has complete terms

## 📖 详细技术指南

### 何时使用
- 当需要从PDF文档中提取文本或表格时
- 用于程序化创建新的PDF文档
- 当需要合并或拆分PDF文件时
- 用于自动填写PDF表单
- 当需要大规模处理PDF文档时
- 用于分析PDF内容和结构

### 文本和表格提取
1. **文本提取**: 使用适当的库来提取文本内容，同时保留格式
2. **表格识别**: 识别并从PDF文档中提取表格数据
3. **OCR处理**: 使用光学字符识别处理扫描文档
4. **内容分析**: 解析文档结构并识别关键部分

### 文档创建和修改
1. **PDF生成**: 从各种数据源创建新的PDF文档
2. **表单填写**: 自动填充PDF表单字段
3. **文档合并**: 将多个PDF合并为单个文档
4. **页面操作**: 拆分、旋转或重新排序PDF页面

### 最佳实践
- **错误处理**: 为损坏的PDF实现强大的错误处理
- **性能**: 为大型文档处理使用高效库
- **安全性**: 验证PDF来源并适当处理敏感数据
- **兼容性**: 确保跨平台兼容性

### 常见用例

#### 数据提取
```python
# 从PDF提取文本
def extract_pdf_text(pdf_path):
    # 文本提取实现
    pass

# 从PDF提取表格
def extract_pdf_tables(pdf_path):
    # 表格提取实现
    pass
```

#### 表单处理
```python
# 填写PDF表单字段
def fill_pdf_form(pdf_path, data_dict):
    # 表单填写实现
    pass
```

#### 文档组装
```python
# 合并多个PDF
def merge_pdfs(pdf_list, output_path):
    # PDF合并实现
    pass
```

## 依赖项
- Python PDF处理库（PyPDF2、pdfplumber、reportlab等）
- 高级功能：OCR库（Tesseract等）
- 文件系统访问权限用于读写PDF文件

---
*来源: Anthropic Skills库 | 集成时间: 2026-01-15*
