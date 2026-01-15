---
name: xlsx
description: Comprehensive spreadsheet creation, editing, and analysis toolkit. Supports formulas, formatting, data analysis, and visualization for Excel and CSV files.
---

# 📊 Excel Spreadsheet Toolkit

Comprehensive toolkit for creating, editing, and analyzing spreadsheets. Supports advanced features including formulas, data analysis, visualization, and automated processing.

## When to Use

- When creating new spreadsheets with formulas and formatting
- For reading or analyzing existing spreadsheet data
- When modifying spreadsheets while preserving formulas
- For data analysis and visualization in spreadsheets
- When recalculating formulas and updating calculations
- For processing CSV, XLSX, or other spreadsheet formats

## Instructions

### Spreadsheet Creation and Management

1. **Workbook Initialization**: Create new workbooks or load existing files
2. **Worksheet Management**: Add, rename, or delete worksheets
3. **Data Entry**: Input data manually or programmatically
4. **Formula Implementation**: Add calculations and functions

### Data Processing and Analysis

#### Basic Operations
- **Data Import/Export**: Read from CSV, write to Excel formats
- **Data Cleaning**: Remove duplicates, handle missing values
- **Sorting and Filtering**: Organize data by criteria
- **Data Validation**: Ensure data integrity and consistency

#### Advanced Analysis
- **Pivot Tables**: Create summary tables for data analysis
- **Data Aggregation**: Sum, average, count operations
- **Conditional Formatting**: Visual data highlighting
- **Data Relationships**: Link data across worksheets

### Formula and Calculation Support

#### Common Formulas
- **Mathematical**: SUM, AVERAGE, MIN, MAX, COUNT
- **Logical**: IF, AND, OR, NOT
- **Text**: CONCATENATE, LEFT, RIGHT, MID
- **Date/Time**: TODAY, NOW, DATEDIF

#### Advanced Functions
- **Lookup**: VLOOKUP, HLOOKUP, INDEX, MATCH
- **Statistical**: STDEV, CORREL, TREND
- **Financial**: NPV, IRR, PMT
- **Array Formulas**: Complex multi-cell calculations

### Implementation with openpyxl

```python
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill
from openpyxl.utils import get_column_letter

# Create new workbook
wb = Workbook()
ws = wb.active
ws.title = "Data Analysis"

# Add headers with styling
headers = ['Name', 'Age', 'Department', 'Salary']
for col_num, header in enumerate(headers, 1):
    cell = ws.cell(row=1, column=col_num)
    cell.value = header
    cell.font = Font(bold=True)
    cell.fill = PatternFill(start_color="CCCCCC", fill_type="solid")

# Add sample data
data = [
    ['Alice Johnson', 28, 'Engineering', 75000],
    ['Bob Smith', 34, 'Marketing', 65000],
    ['Carol Williams', 29, 'Sales', 70000],
]

for row_num, row_data in enumerate(data, 2):
    for col_num, value in enumerate(row_data, 1):
        ws.cell(row=row_num, column=col_num, value=value)

# Add formulas
ws['E1'] = 'Bonus (10%)'
for row in range(2, len(data) + 2):
    ws[f'E{row}'] = f'=D{row}*0.1'

# Add totals
last_row = len(data) + 2
ws[f'A{last_row}'] = 'Total'
ws[f'D{last_row}'] = f'=SUM(D2:D{last_row-1})'
ws[f'E{last_row}'] = f'=SUM(E2:E{last_row-1})'

# Format columns
for column in ws.columns:
    max_length = 0
    column_letter = get_column_letter(column[0].column)
    for cell in column:
        try:
            if len(str(cell.value)) > max_length:
                max_length = len(str(cell.value))
        except:
            pass
    adjusted_width = (max_length + 2)
    ws.column_dimensions[column_letter].width = adjusted_width

# Save workbook
wb.save('analysis.xlsx')
```

### Chart and Visualization

```python
from openpyxl.chart import BarChart, Reference, Series

# Create chart
chart = BarChart()
chart.title = "Department Salaries"
chart.y_axis.title = "Salary ($)"
chart.x_axis.title = "Department"

# Data references
categories = Reference(ws, min_col=3, min_row=2, max_row=4)
values = Reference(ws, min_col=4, min_row=1, max_row=4)

chart.add_data(values, titles_from_data=True)
chart.set_categories(categories)

# Add chart to worksheet
ws.add_chart(chart, "G2")
```

### Best Practices

#### Data Organization
- Use clear, descriptive headers
- Maintain consistent data formats
- Separate data from calculations
- Use named ranges for clarity

#### Performance Optimization
- Minimize volatile functions
- Use efficient lookup methods
- Avoid excessive formatting
- Compress large datasets when possible

#### Error Prevention
- Implement data validation rules
- Use error handling in formulas
- Document complex calculations
- Test formulas with edge cases

### Common Use Cases

#### Financial Analysis
- Budget tracking and forecasting
- Expense reports and analysis
- Financial modeling and projections
- Invoice processing and management

#### Data Processing
- Import/export data transformations
- Automated report generation
- Data cleaning and normalization
- Statistical analysis and reporting

#### Business Intelligence
- Sales dashboards and metrics
- Inventory management systems
- Customer data analysis
- Performance tracking reports

## Dependencies

- Python 3.6+
- openpyxl library for Excel file handling
- pandas (optional) for advanced data manipulation
- matplotlib or seaborn (optional) for additional visualization

## Integration Patterns

- **Automated Reporting**: Generate spreadsheets from databases
- **Data Pipelines**: ETL processes with spreadsheet output
- **Web Applications**: Dynamic spreadsheet generation
- **API Integration**: Spreadsheet data as web service endpoints

## Supported Formats

- Excel (.xlsx, .xlsm, .xltx, .xltm)
- CSV and TSV files
- OpenDocument Spreadsheet (.ods)
- Legacy Excel formats (.xls)

## License

Proprietary. LICENSE.txt has complete terms

---
*Source: Anthropic Skills Library | Integrated: 2026-01-15*