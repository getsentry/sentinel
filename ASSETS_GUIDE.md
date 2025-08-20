# Asset Organization Guide

## Where to Put What

### 📸 Screenshots
**Location**: `images/screenshots/[editor]/`

```
images/screenshots/
├── vscode/           # VS Code screenshots
├── vim/             # Vim/Neovim screenshots  
├── warp/            # Warp terminal screenshots
└── CAPTURE_GUIDE.md # How to take good screenshots
```

### 🎨 Icons
**Location**: `images/`

```
images/
├── icon.png         # 128x128px PNG (required for VS Code)
├── icon.svg         # SVG version (optional, for scalability)
└── logo/           # Additional logo variations (optional)
```

### 📝 Documentation Images
**Location**: `images/` or `images/previews/`

```
images/previews/
├── palette-dark.png     # Color palette visualization
├── palette-light.png    # Light theme colors
└── palette-midnight.png # Midnight theme colors
```

## Usage in Files

### In README.md
```markdown
![Sentinel Dark Theme](images/screenshots/vscode/dark-javascript.png)
![Theme Icon](images/icon.png)
```

### In VS Code package.json
```json
"icon": "../images/icon.png"
```

### In CONTRIBUTING.md or other docs
```markdown
![Example](../images/screenshots/vscode/example.png)
```

## Quick Commands

### Create all directories at once
```bash
mkdir -p images/{screenshots/{vscode,vim,warp},logo,previews}
```

### Check image sizes
```bash
# macOS
sips -g pixelWidth -g pixelHeight images/**/*.png

# Linux
identify images/**/*.png
```

### Optimize images
```bash
# Install tools
npm install -g imagemin-cli imagemin-pngquant

# Optimize
imagemin images/**/*.png --out-dir=images --plugin=pngquant
```

## Tips

1. **Consistency**: Use the same window size for all screenshots
2. **Quality**: Save PNGs at high quality, optimize after
3. **Naming**: Use descriptive names: `dark-javascript-react.png`
4. **Organization**: Keep editor-specific shots in their folders
5. **Documentation**: Update README when adding new images
