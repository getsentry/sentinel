# Sentry Sentinel Theme for Web Syntax Highlighters

This directory contains Sentry Sentinel theme implementations for popular web-based syntax highlighting libraries.

## Available Themes

### Prism.js
- **File**: `prismjs/prism-sentinel-light.css`
- **Description**: Light theme optimized for Prism.js syntax highlighter
- **Usage**:
  ```html
  <!-- Include Prism.js core -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css" rel="stylesheet" />
  
  <!-- Include Sentinel Light theme -->
  <link href="path/to/prism-sentinel-light.css" rel="stylesheet" />
  
  <!-- Include Prism.js JavaScript -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js"></script>
  ```

### Highlight.js
- **File**: `highlightjs/sentinel-light.css`
- **Description**: Light theme optimized for Highlight.js syntax highlighter
- **Usage**:
  ```html
  <!-- Include Highlight.js default styles -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css">
  
  <!-- Include Sentinel Light theme -->
  <link rel="stylesheet" href="path/to/sentinel-light.css">
  
  <!-- Include Highlight.js JavaScript -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
  <script>hljs.highlightAll();</script>
  ```

## Color Palette

The light theme uses official Sentry brand colors:

- **Near Black** (#181225) - Primary text
- **Deep Purple** (#36166B) - Keywords, tags
- **Dark Purple** (#4D0A55) - Strings
- **Medium Purple** (#6E47AE) - Functions, classes
- **Light Purple** (#A737B4) - Types
- **Orange** (#EE8019) - Numbers, constants
- **Hot Pink** (#FF45A8) - Errors
- **Blue** (#226DFC) - Links, info
- **Lime Green** (#92DD00) - Success states

## Testing

Open `index.html` in a web browser to see both implementations side-by-side with various code examples.

## Features

Both themes include:
- Optimized color contrast for readability
- Support for line numbers
- Selection highlighting
- Diff highlighting (additions/deletions)
- Language-specific optimizations
- Responsive design considerations
- Custom scrollbar styling

## Browser Support

These themes support all modern browsers:
- Chrome/Edge (Chromium) 80+
- Firefox 75+
- Safari 13.1+

## License

MIT License - See the repository's main LICENSE file for details.
