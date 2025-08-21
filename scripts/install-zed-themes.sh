#!/bin/bash

# Sentry Sentinel Theme - Zed Installation Script
# Installs all three Sentinel theme variants for Zed editor

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛡️  Sentry Sentinel Theme - Zed Installer${NC}"
echo ""

# Determine the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEME_DIR="$SCRIPT_DIR/../editor-themes/zed"
ZED_THEMES_DIR="$HOME/.config/zed/themes"

# Check if theme files exist
if [ ! -d "$THEME_DIR" ]; then
    echo -e "${RED}Error: Theme directory not found at $THEME_DIR${NC}"
    echo "Please run this script from the sentinel-theme repository."
    exit 1
fi

# Create Zed themes directory if it doesn't exist
echo -e "${YELLOW}Creating Zed themes directory...${NC}"
mkdir -p "$ZED_THEMES_DIR"

# Install theme
echo -e "${YELLOW}Installing Sentinel theme family...${NC}"
cp "$THEME_DIR"/sentinel.json "$ZED_THEMES_DIR/"

# List installed themes
echo ""
echo -e "${GREEN}✅ Successfully installed the following themes:${NC}"
echo "   • Sentinel Light"
echo "   • Sentinel Dark"
echo "   • Sentinel Midnight"

# Instructions
echo ""
echo -e "${BLUE}To use a theme in Zed:${NC}"
echo "1. Open Zed"
echo "2. Press Cmd+K, Cmd+T (Theme Selector)"
echo "3. Select your preferred Sentinel theme"
echo ""
echo -e "${GREEN}Installation complete! Enjoy your new themes! 🎨${NC}"
