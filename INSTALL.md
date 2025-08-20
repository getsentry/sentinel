# 🔧 Installation Guide

## Testing Themes Right Now

The themes are now ready to test! Here's how to install them:

### ✅ **Already Installed**
- **Cursor/VS Code**: Theme installed at `~/.vscode/extensions/sentry-sentinel-theme`
- **Warp**: Theme installed at `~/.warp/themes/sentinel_dark.yaml`

### 🎨 **Additional Themes to Install**

#### **Vim/Neovim**
```bash
# Create colors directory if it doesn't exist
mkdir -p ~/.vim/colors

# Copy the theme
cp themes/vim/colors/sentinel_dark.vim ~/.vim/colors/

# For Neovim
mkdir -p ~/.config/nvim/colors
cp themes/vim/colors/sentinel_dark.vim ~/.config/nvim/colors/
```

**To activate in Vim/Neovim:**
```vim
:colorscheme sentinel_dark
```

**To make it permanent, add to your config:**
```vim
" In ~/.vimrc or ~/.config/nvim/init.vim
colorscheme sentinel_dark
```

#### **Zed Editor**
```bash
# Create themes directory
mkdir -p ~/.config/zed/themes

# Copy the theme
cp themes/zed/sentinel_dark.json ~/.config/zed/themes/
```

**To activate in Zed:**
1. Open Zed
2. Command Palette (Cmd+Shift+P)
3. Type "theme" and select "Select Theme"
4. Choose "Sentry Sentinel Dark"

#### **iTerm2**
```bash
# Just double-click the file or use command line:
open "themes/iterm2/Sentry Sentinel Dark.itermcolors"
```

**To activate in iTerm2:**
1. iTerm2 → Preferences (Cmd+,)
2. Go to **Profiles** tab
3. Select **Colors** tab
4. Click **Color Presets** dropdown
5. Select **"Sentry Sentinel Dark"**

## 🔧 **How to Activate Each Theme**

### **Cursor/VS Code**
1. Open Settings (Cmd+,)
2. Search "color theme"
3. Select **"Sentry Sentinel Dark"**

### **Warp Terminal**
1. Open Settings (Cmd+,) 
2. Go to **Appearance**
3. Select **"Sentry Sentinel Dark"** from Theme dropdown

### **Vim/Neovim**
```vim
:colorscheme sentinel_dark
```

### **Zed**
1. Command Palette (Cmd+Shift+P)
2. "Select Theme" → "Sentry Sentinel Dark"

### **iTerm2**
1. Preferences → Profiles → Colors
2. Color Presets → "Sentry Sentinel Dark"

## 🎯 **Quick Test Commands**

Try these in your terminal to see the colors in action:

```bash
# Color test
echo -e "\033[31mRed\033[0m \033[32mGreen\033[0m \033[33mYellow\033[0m \033[34mBlue\033[0m \033[35mMagenta\033[0m \033[36mCyan\033[0m"

# Directory listing (shows various file types)
ls -la --color=auto

# Git status (if in a git repo)
git status

# Python syntax highlighting test
cat << 'EOF' > test.py
def hello_sentry():
    """A test function to show syntax highlighting."""
    name = "Sentry Sentinel"
    version = 1.0
    features = ["accessibility", "beautiful", "developer-friendly"]
    
    for feature in features:
        print(f"{name} is {feature}!")
    
    return True

if __name__ == "__main__":
    hello_sentry()
EOF

# View the Python file with syntax highlighting (in vim/neovim)
vim test.py
```

## 🎨 **Theme Preview**

All themes feature:
- **Keywords**: Sentry Purple (`#6559D1`) 
- **Functions**: Sentry Pink (`#E1567C`)
- **Strings**: Emerald Green (`#10B981`)
- **Comments**: Muted Gray (`#71717A`)
- **Numbers**: Amber (`#F59E0B`)
- **Types**: Sentry Orange (`#F4834F`)

## ❓ **Troubleshooting**

### **Theme not showing up?**
- Restart the application
- Check file permissions: `chmod 644 <theme-file>`
- Verify correct directory placement

### **Colors look wrong?**
- Ensure your terminal supports 24-bit color
- Check if application is in dark/light mode as intended

### **Vim/Neovim issues?**
```vim
" Check if colors are working
:echo has('termguicolors')
" Should return 1

" Enable true colors
set termguicolors
```

## 🚀 **Next Steps**

Once you've tested the themes, let me know:
1. How do they look?
2. Any color adjustments needed?
3. Should we create light variants?
4. Ready to build the full installation package?
