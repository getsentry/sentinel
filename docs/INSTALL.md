# Installation Guide

Complete installation instructions for Sentry Sentinel themes across all platforms.

## 🎨 Available Themes

All platforms support three variants:
- **Sentinel Light** - Clean, bright theme for well-lit environments
- **Sentinel Dark** - Rich, vibrant theme with excellent contrast
- **Sentinel Midnight** - Ultra-dark theme optimized for OLED displays

## 💻 VS Code / Cursor

### From Marketplace (Recommended)
1. Open VS Code or Cursor
2. Go to Extensions (`Ctrl+Shift+X` / `Cmd+Shift+X`)
3. Search for **"Sentry Sentinel Theme"**
4. Click **Install**
5. Select your theme:
   - Press `Ctrl+K Ctrl+T` (Windows/Linux) or `Cmd+K Cmd+T` (macOS)
   - Choose from Sentinel Light, Dark, or Midnight

### Manual Installation
```bash
# Clone the repository
git clone https://github.com/getsentry/sentinel-theme.git
cd sentinel-theme/vscode

# Install dependencies and build
npm install
npm run build

# Package the extension
vsce package

# Install the .vsix file
code --install-extension sentinel-theme-*.vsix
```

## 🖥️ Terminal Emulators

### Ghostty

```bash
# Quick install
./scripts/install-ghostty-themes.sh

# Manual install
mkdir -p ~/.config/ghostty/themes
cp terminal-themes/ghostty/*.conf ~/.config/ghostty/themes/

# Add to your Ghostty config file:
theme = sentinel_dark

# For automatic light/dark switching:
theme = dark:sentinel_midnight,light:sentinel_light
```

### Warp

```bash
# Quick install
./scripts/install-warp-themes.sh

# Manual install
mkdir -p ~/.warp/themes
cp terminal-themes/warp/*.yaml ~/.warp/themes/

# To activate:
# 1. Open Warp Settings (Cmd+,)
# 2. Go to Appearance
# 3. Select Sentinel theme from dropdown
```

### iTerm2

```bash
# Import color schemes:
# 1. Open iTerm2 Preferences (Cmd+,)
# 2. Go to Profiles → Colors
# 3. Click "Color Presets..." dropdown
# 4. Choose "Import..."
# 5. Navigate to terminal-themes/iterm/ and select desired .itermcolors file
```

### Terminal.app (macOS)

```bash
# Double-click the .terminal file in Finder, or:
open terminal-themes/terminal/*.terminal

# Then set as default in Terminal → Preferences → Profiles
```

## 📝 Text Editors

### Vim/Neovim

```bash
# Vim
mkdir -p ~/.vim/colors
cp terminal-themes/vim/colors/*.vim ~/.vim/colors/

# Neovim
mkdir -p ~/.config/nvim/colors
cp terminal-themes/vim/colors/*.vim ~/.config/nvim/colors/

# Add to .vimrc or init.vim:
set termguicolors
colorscheme sentinel_dark
" Options: sentinel_light, sentinel_dark, sentinel_midnight
```

### Emacs

```bash
# Copy theme files
mkdir -p ~/.emacs.d/themes
cp terminal-themes/emacs/*.el ~/.emacs.d/themes/

# Add to init.el:
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'sentinel-dark t)
```

## 🌐 Web Syntax Highlighters

### Prism.js

```html
<!-- Include base Prism CSS -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism.min.css" rel="stylesheet" />

<!-- Add Sentinel theme -->
<link href="path/to/prism-sentinel-dark.css" rel="stylesheet" />
<!-- Options: prism-sentinel-light.css, prism-sentinel-dark.css, prism-sentinel-midnight.css -->

<!-- Include Prism JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js"></script>
```

### Highlight.js

```html
<!-- Include base Highlight.js -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css">

<!-- Add Sentinel theme -->
<link rel="stylesheet" href="path/to/sentinel-dark.css">
<!-- Options: sentinel-light.css, sentinel-dark.css, sentinel-midnight.css -->

<!-- Include Highlight.js -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
<script>hljs.highlightAll();</script>
```

### Theme Switching Example

```javascript
// Dynamic theme switching
function switchTheme(theme) {
    const link = document.getElementById('syntax-theme');
    link.href = `path/to/sentinel-${theme}.css`;
}

// Usage
switchTheme('dark');    // or 'light', 'midnight'
```

## 🧪 Testing Installation

### Terminal Color Test

```bash
# Basic ANSI colors
echo -e "\033[31mRed\033[0m \033[32mGreen\033[0m \033[33mYellow\033[0m \033[34mBlue\033[0m \033[35mMagenta\033[0m \033[36mCyan\033[0m"

# 256 color test
curl -s https://raw.githubusercontent.com/stark/Color-Scripts/master/color-scripts/spectrum | bash

# True color test (24-bit)
awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
}'
```

### VS Code Test

```typescript
// Create a test file to see syntax highlighting
interface SentryTheme {
  name: string;
  variant: 'light' | 'dark' | 'midnight';
  colors: {
    primary: string;
    secondary: string;
    accent: string;
  };
}

const theme: SentryTheme = {
  name: "Sentinel",
  variant: 'dark',
  colors: {
    primary: '#7553FF',
    secondary: '#FF45A8',
    accent: '#83DA90'
  }
};

console.log(`Testing ${theme.name} theme!`);
```

## 🔧 Troubleshooting

### Theme Not Appearing

**VS Code/Cursor:**
- Restart the editor
- Check Extensions view for errors
- Run `Developer: Reload Window` from Command Palette

**Terminal:**
- Ensure config file syntax is correct
- Check that theme files have proper permissions: `chmod 644 ~/.config/*/themes/*`
- Some terminals require restart after theme installation

### Colors Look Wrong

**Enable True Color Support:**

```bash
# Add to .bashrc/.zshrc
export COLORTERM=truecolor

# For tmux, add to .tmux.conf
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# For Vim/Neovim
set termguicolors
```

### Platform-Specific Issues

**macOS:** Ensure Terminal.app has "Use bright colors for bold text" unchecked

**Windows Terminal:** Add theme to `settings.json` schemes array

**Linux:** Check `$TERM` environment variable is set correctly

## 📦 Building from Source

```bash
# Clone repository
git clone https://github.com/getsentry/sentinel-theme.git
cd sentinel-theme

# Install dependencies
npm install

# Run tests
npm test

# Build all themes
npm run build
```

## 🤝 Contributing

Found an issue or want to contribute? Check our [Contributing Guide](CONTRIBUTING.md).

## 📄 License

MIT License - see [LICENSE](../LICENSE) for details.