#!/bin/bash

# Sentry Sentinel Theme - iTerm2 Installation Script
# Imports all three Sentinel color schemes into iTerm2

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛡️  Sentry Sentinel Theme - iTerm2 Installer${NC}"
echo ""

# Determine the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEME_DIR="$SCRIPT_DIR/../terminal-themes/iterm"

# Check if theme files exist
if [ ! -d "$THEME_DIR" ]; then
    echo -e "${RED}Error: Theme directory not found at $THEME_DIR${NC}"
    echo "Please run this script from the sentinel-theme repository."
    exit 1
fi

# Check if iTerm2 is installed
if ! command -v osascript &> /dev/null || ! osascript -e 'id of application "iTerm2"' &> /dev/null 2>&1; then
    echo -e "${RED}Error: iTerm2 is not installed.${NC}"
    echo "Please install iTerm2 from https://iterm2.com"
    exit 1
fi

# Import color schemes
echo -e "${YELLOW}Importing Sentinel color schemes...${NC}"
echo ""

# Import each color scheme
for theme in "$THEME_DIR"/*.itermcolors; do
    if [ -f "$theme" ]; then
        theme_name=$(basename "$theme" .itermcolors)
        echo -e "Importing: ${GREEN}$theme_name${NC}"
        open "$theme"
        # Give iTerm2 time to process each import
        sleep 1
    fi
done

# Instructions
echo ""
echo -e "${GREEN}✅ Color schemes imported successfully!${NC}"
echo ""
echo -e "${BLUE}To apply a theme in iTerm2:${NC}"
echo "1. Open iTerm2 Preferences (Cmd+,)"
echo "2. Go to Profiles → Colors"
echo "3. Click on 'Color Presets...' dropdown"
echo "4. Select one of:"
echo "   • Sentinel Light"
echo "   • Sentinel Dark"
echo "   • Sentinel Midnight"
echo ""
echo -e "${YELLOW}Note: You may need to create a new profile or duplicate an existing one${NC}"
echo -e "${YELLOW}to preserve your current settings before applying a new color scheme.${NC}"
echo ""
echo -e "${GREEN}Installation complete! Enjoy your new themes! 🎨${NC}"
