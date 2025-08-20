#!/bin/bash

# Install Sentry Sentinel themes for Warp terminal
# This script copies the theme files to Warp's custom themes directory

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEMES_DIR="$SCRIPT_DIR/../terminal-themes/warp"
WARP_THEMES_DIR="$HOME/.warp/themes"

# Create Warp themes directory if it doesn't exist
mkdir -p "$WARP_THEMES_DIR"

echo "🚀 Installing Sentry Sentinel themes for Warp..."

# Copy theme files
for theme in "$THEMES_DIR"/*.yaml; do
    if [ -f "$theme" ]; then
        theme_name=$(basename "$theme")
        cp "$theme" "$WARP_THEMES_DIR/"
        echo "✅ Installed: $theme_name"
    fi
done

echo ""
echo "🎨 Themes installed successfully!"
echo ""
echo "To use the themes in Warp:"
echo "1. Open Warp settings (Cmd+,)"
echo "2. Go to Appearance → Themes"
echo "3. Look for 'Sentinel Dark', 'Sentinel Light', or 'Sentinel Midnight'"
echo "4. Click on a theme to apply it"
echo ""
echo "Alternatively, you can use the Command Palette (Cmd+P) and search for 'theme'"
