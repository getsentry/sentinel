#!/usr/bin/env bash

# Install Ghostty themes for Sentry Sentinel

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Ghostty theme directory
GHOSTTY_THEME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/themes"

echo "🎨 Installing Sentry Sentinel themes for Ghostty..."

# Create theme directory if it doesn't exist
mkdir -p "$GHOSTTY_THEME_DIR"

# Copy theme files
for theme in sentinel_dark sentinel_light sentinel_midnight; do
    src="$PROJECT_ROOT/terminal-themes/ghostty/${theme}.conf"
    dst="$GHOSTTY_THEME_DIR/${theme}.conf"
    
    if [ -f "$src" ]; then
        cp "$src" "$dst"
        echo "✅ Installed ${theme}"
    else
        echo "❌ Theme file not found: $src"
    fi
done

echo ""
echo "🚀 Installation complete!"
echo ""
echo "To use a theme, add one of these lines to your Ghostty config:"
echo "  theme = sentinel_dark.conf"
echo "  theme = sentinel_light.conf"
echo "  theme = sentinel_midnight.conf"
echo ""
echo "Or use separate light/dark themes:"
echo "  theme = dark:sentinel_midnight.conf,light:sentinel_light.conf"
