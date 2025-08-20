# 🛡️ Sentry Sentinel Theme

> Beautiful, accessible developer themes inspired by Sentry's brand colors

A comprehensive theme collection bringing Sentry's distinctive purple and pink brand colors to your favorite development tools. Designed with WCAG AA accessibility standards and developer ergonomics in mind.

## ✨ Features

- 🎨 **Official Sentry Colors** - Based on authentic brand guidelines
- ♿ **WCAG AA Compliant** - 4.5:1+ contrast ratios for accessibility  
- 🌙 **Dark & Light Variants** - Optimized for all lighting conditions
- 🔧 **Multiple Editors** - VS Code, Cursor, Warp, Vim/Neovim
- 📦 **Easy Testing** - Simple installation for immediate testing

## 🚀 Quick Install & Test

### VS Code / Cursor (Recommended Method)
```bash
# Open the VS Code extension in VS Code
code vscode-extension/

# Press F5 to launch Extension Development Host
# This immediately loads all 3 theme variants for testing
```

### Warp Terminal
```bash
# Copy themes to Warp directory
cp terminal-themes/warp/*.yaml ~/.warp/themes/

# Restart Warp, then Settings → Appearance → Select theme
```

### Vim/Neovim
```bash
# Copy colorscheme
cp terminal-themes/vim/colors/sentinel_dark.vim ~/.vim/colors/

# Activate with: :colorscheme sentinel_dark
```

## 🎨 Theme Variants

| Variant | Description | Best For |
|---------|-------------|----------|
| **Sentinel Dark** | Deep purple backgrounds, bright accents | Night coding, dark environments |
| **Sentinel Light** | Clean whites with Sentry purple highlights | Daytime work, bright offices |
| **Sentinel Midnight** | Extra dark for OLED displays | Ultra-dark environments |

### Screenshots

<!-- Add screenshots here -->
<!-- ![Sentinel Dark - JavaScript](images/screenshots/vscode/dark-javascript.png) -->
<!-- ![Sentinel Light - Python](images/screenshots/vscode/light-python.png) -->
<!-- ![Sentinel Midnight - Overview](images/screenshots/vscode/midnight-overview.png) -->

## 🏗️ Development

```bash
# Clone the repo
git clone https://github.com/getsentry/sentinel-theme
cd sentinel-theme

# Build all themes
npm run build

# Test themes
npm run test

# Preview themes
npm run preview
```

## 🎯 Color Palette

### Brand Colors
- **Primary Purple**: `#362D59` - Main brand color
- **Accent Purple**: `#6559D1` - Interactive elements  
- **Sentry Pink**: `#E1567C` - Functions, errors
- **Warning Orange**: `#F4834F` - Warnings, types

### Syntax Highlighting
- **Keywords**: Sentry Purple (`#6559D1`)
- **Strings**: Emerald Green (`#10B981`) 
- **Functions**: Sentry Pink (`#E1567C`)
- **Comments**: Muted Gray (`#71717A`)
- **Numbers**: Amber (`#F59E0B`)

## ♿ Accessibility 

All themes meet **WCAG 2.1 AA** standards:
- ✅ 4.5:1 contrast ratio for normal text
- ✅ 3:1 contrast ratio for large text  
- ✅ Color-blind friendly palette
- ✅ High contrast mode support

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🔗 Links

- [Sentry Brand Guidelines](https://brand.getsentry.com)
- [Report Issues](https://github.com/getsentry/sentinel-theme/issues)
- [Feature Requests](https://github.com/getsentry/sentinel-theme/discussions)

---

Made with 💜 by the Sentry team
