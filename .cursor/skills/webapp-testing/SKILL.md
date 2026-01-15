---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
---

# 🧪 Web Application Testing

Comprehensive toolkit for testing web applications using Playwright. Enables automated testing, debugging, and quality assurance for frontend applications.

## When to Use

- When verifying frontend functionality and user interactions
- For debugging UI behavior and visual regressions
- When capturing browser screenshots for documentation or debugging
- For viewing and analyzing browser console logs
- When performing end-to-end testing of web applications
- For automated testing workflows

## Instructions

### Test Automation Setup

1. **Environment Configuration**: Set up Playwright testing environment
2. **Browser Selection**: Choose appropriate browsers (Chrome, Firefox, Safari, etc.)
3. **Test Structure**: Organize tests with proper setup, execution, and cleanup
4. **Assertion Framework**: Implement comprehensive validation checks

### Testing Strategies

#### Functional Testing
- **User Interactions**: Click buttons, fill forms, navigate pages
- **Element Verification**: Check element presence, visibility, and properties
- **Data Validation**: Verify displayed data matches expected values

#### Visual Testing
- **Screenshot Comparison**: Capture and compare UI screenshots
- **Layout Verification**: Check responsive design and layout consistency
- **Visual Regression**: Detect unintended visual changes

#### Performance Testing
- **Load Time Analysis**: Measure page load performance
- **Resource Monitoring**: Track network requests and resource usage
- **Memory Leak Detection**: Monitor for memory issues

### Debugging and Monitoring

1. **Console Log Analysis**: Capture and analyze browser console output
2. **Network Monitoring**: Track HTTP requests and responses
3. **Error Detection**: Identify JavaScript errors and exceptions
4. **Performance Metrics**: Monitor page performance indicators

### Best Practices

- **Test Isolation**: Ensure tests don't interfere with each other
- **Wait Strategies**: Use appropriate wait conditions for dynamic content
- **Cross-Browser Testing**: Test across multiple browser environments
- **CI/CD Integration**: Automate testing in continuous integration pipelines

### Example Test Structure

```javascript
// Basic Playwright test example
const { test, expect } = require('@playwright/test');

test('user login flow', async ({ page }) => {
  // Navigate to login page
  await page.goto('/login');

  // Fill login form
  await page.fill('[data-testid="email"]', 'user@example.com');
  await page.fill('[data-testid="password"]', 'password123');

  // Submit form
  await page.click('[data-testid="login-button"]');

  // Verify successful login
  await expect(page).toHaveURL('/dashboard');
  await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
});

test('visual regression check', async ({ page }) => {
  await page.goto('/dashboard');

  // Capture screenshot for comparison
  await expect(page).toHaveScreenshot('dashboard.png');
});
```

## Dependencies

- Node.js runtime environment
- Playwright testing framework
- Browser binaries (automatically managed by Playwright)
- Local web application running on accessible port

## Configuration

- **Headless Mode**: Run tests without visible browser UI
- **Slow Motion**: Add delays for debugging test execution
- **Video Recording**: Capture test execution videos
- **Screenshot Options**: Configure screenshot capture settings

## License

Complete terms in LICENSE.txt

---
*Source: Anthropic Skills Library | Integrated: 2026-01-15*