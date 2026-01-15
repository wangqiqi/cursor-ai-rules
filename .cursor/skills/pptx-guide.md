---
name: pptx
description: Presentation creation, editing, and analysis toolkit. Use for creating new presentations, modifying content, working with layouts, adding comments or speaker notes.
---

# 📊 PowerPoint Presentation Toolkit

Comprehensive toolkit for creating, editing, and analyzing PowerPoint presentations. Supports all major presentation tasks from content creation to advanced formatting and analysis.

## When to Use

- When creating new presentations from scratch or templates
- For modifying existing presentation content and layouts
- When adding or editing text, images, charts, and media
- For working with slide masters and themes
- When adding speaker notes or comments
- For presentation analysis and optimization

## Instructions

### Presentation Creation

1. **Initialize Presentation**: Create new presentation or load template
2. **Slide Management**: Add, delete, reorder, and duplicate slides
3. **Layout Selection**: Choose appropriate slide layouts for content
4. **Content Addition**: Insert text, images, charts, and multimedia

### Content and Formatting

#### Text and Typography
- **Text Boxes**: Add and format text content
- **Font Styling**: Control font family, size, color, and effects
- **Paragraph Formatting**: Alignment, spacing, and indentation
- **Text Hierarchy**: Headings, bullet points, and numbering

#### Visual Elements
- **Images and Graphics**: Insert and position images
- **Charts and Diagrams**: Create data visualizations
- **Shapes and Icons**: Add decorative and functional elements
- **Animations**: Apply slide transitions and object animations

#### Slide Organization
- **Slide Master**: Manage consistent layouts and themes
- **Sections**: Group related slides logically
- **Notes**: Add speaker notes for presentations

### Implementation with python-pptx

```python
from pptx import Presentation
from pptx.util import Inches

# Create new presentation
prs = Presentation()

# Add title slide
title_slide_layout = prs.slide_layouts[0]
slide = prs.slides.add_slide(title_slide_layout)
title = slide.shapes.title
subtitle = slide.placeholders[1]

title.text = "Presentation Title"
subtitle.text = "Subtitle or presenter name"

# Add content slide
bullet_slide_layout = prs.slide_layouts[1]
slide = prs.slides.add_slide(bullet_slide_layout)
shapes = slide.shapes

title_shape = shapes.title
body_shape = shapes.placeholders[1]

title_shape.text = 'Content Slide Title'
tf = body_shape.text_frame
tf.text = 'First bullet point'

p = tf.add_paragraph()
p.text = 'Second bullet point'
p.level = 1

# Add image
left = top = Inches(1)
pic = slide.shapes.add_picture('image.png', left, top, width=Inches(4))

# Save presentation
prs.save('presentation.pptx')
```

### Advanced Features

#### Chart Creation
```python
from pptx.chart.data import ChartData
from pptx.enum.chart import XL_CHART_TYPE

# Create chart data
chart_data = ChartData()
chart_data.categories = ['Q1', 'Q2', 'Q3', 'Q4']
chart_data.add_series('Sales', (100, 200, 150, 300))

# Add chart to slide
x, y, cx, cy = Inches(2), Inches(2), Inches(6), Inches(4.5)
chart = slide.shapes.add_chart(
    XL_CHART_TYPE.COLUMN_CLUSTERED, x, y, cx, cy, chart_data
).chart
```

#### Theme and Styling
- Apply consistent color schemes
- Use corporate branding elements
- Maintain visual consistency across slides
- Customize slide masters and layouts

### Best Practices

#### Content Design
- Keep slides visually clean and uncluttered
- Use high-contrast colors for readability
- Maintain consistent font usage throughout
- Align elements for professional appearance

#### Presentation Flow
- Logical progression of ideas
- Clear section breaks and transitions
- Speaker notes for guidance
- Audience-appropriate content level

#### Technical Considerations
- Optimize image sizes for file size
- Test animations and transitions
- Ensure compatibility across versions
- Validate content before final presentation

### Common Use Cases

#### Business Presentations
- Quarterly reports and dashboards
- Product demonstrations
- Training materials
- Status updates and reviews

#### Educational Content
- Lecture slides and course materials
- Workshop presentations
- Research findings
- Tutorial guides

#### Marketing Materials
- Product launch presentations
- Sales pitches and proposals
- Conference presentations
- Portfolio showcases

## Dependencies

- Python 3.6+
- python-pptx library
- Pillow (for image processing)
- Optional: pandas and matplotlib for data visualization

## Integration Patterns

- **Automated Reporting**: Generate presentations from data sources
- **Template Systems**: Fill presentation templates with dynamic content
- **Batch Processing**: Create multiple presentations programmatically
- **Web Applications**: On-demand presentation generation

## License

Proprietary. LICENSE.txt has complete terms

---
*Source: Anthropic Skills Library | Integrated: 2026-01-15*