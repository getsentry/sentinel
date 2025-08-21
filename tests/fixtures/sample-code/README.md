# Sentry Sentinel Theme - Code Examples

This directory contains example files in various programming languages to test and showcase the Sentry Sentinel theme's syntax highlighting capabilities.

## 📁 Files Overview

### Web Development
- **`javascript.js`** - Node.js/Express server with Sentry SDK integration
- **`typescript.ts`** - React components with TypeScript and error boundaries
- **`index.html`** - HTML5 dashboard with semantic markup
- **`styles.css`** - Modern CSS with variables and animations
- **`styles.scss`** - SCSS with mixins, functions, and nesting

### Backend Languages
- **`python.py`** - Django/Python with decorators and type hints
- **`example.go`** - Go HTTP server with Sentry middleware
- **`example.rb`** - Ruby on Rails with background jobs

### Configuration Files
- **`config.json`** - JSON configuration with Sentry settings
- **`example.yaml`** - YAML with complex nested structures
- **`Dockerfile`** - Multi-stage Docker build example
- **`example.sql`** - SQL queries with CTEs and window functions

### Shell & Scripts
- **`example.sh`** - Bash script with functions and error handling
- **`Makefile`** - Build automation with targets

## 🎨 Testing the Theme

### In VS Code/Cursor
1. Open any example file
2. The theme should automatically apply if installed
3. Try different variants: Sentinel Dark, Light, or Midnight

### In Vim/Neovim
```bash
# Open a file
vim examples/javascript.js

# Apply the theme
:colorscheme sentinel_dark
```

### Quick Test All Files
```bash
# View all examples with syntax highlighting
for file in examples/*; do
  echo "=== $file ==="
  head -20 "$file"
  echo
done | less
```

## 🔍 What to Look For

### Syntax Elements
- **Keywords** - Should be Sentry Purple (#6559D1)
- **Strings** - Should be Emerald Green (#10B981)
- **Functions** - Should be Sentry Pink (#E1567C)
- **Comments** - Should be Muted Gray (#71717A)
- **Numbers** - Should be Amber (#F59E0B)
- **Types** - Should be Sentry Orange (#F4834F)

### Special Features
- **Error highlighting** in error-related code
- **Diff indicators** in git contexts
- **Bracket matching** with purple highlights
- **Selection** with semi-transparent purple

### Accessibility
- All text should have **4.5:1 contrast ratio**
- Comments can have **3:1 contrast ratio**
- Important elements should remain clear

## 📸 Taking Screenshots

Use these files to create screenshots for the README:

1. **JavaScript** - Shows modern JS with async/await
2. **TypeScript** - Demonstrates type annotations
3. **Python** - Highlights decorators and classes
4. **CSS/SCSS** - Shows nested selectors and variables
5. **HTML** - Displays semantic markup

See `images/screenshots/CAPTURE_GUIDE.md` for detailed instructions.

## 🧪 Language Coverage

The examples cover:
- ✅ Imperative languages (JS, Python, Go, Ruby)
- ✅ Markup languages (HTML, Markdown)
- ✅ Style languages (CSS, SCSS)
- ✅ Configuration formats (JSON, YAML)
- ✅ Shell scripting (Bash)
- ✅ Build tools (Make, Docker)
- ✅ Query languages (SQL)

Each file includes:
- Real-world code patterns
- Sentry SDK integration examples
- Various syntax elements
- Comments and documentation
- Error handling patterns
