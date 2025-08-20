#!/usr/bin/env node

/**
 * Validates color definitions across all theme files
 */

const fs = require('fs');
const path = require('path');

const COLORS_FILE = path.join(__dirname, '..', 'colors.json');

// Load master color palette
const colorsData = JSON.parse(fs.readFileSync(COLORS_FILE, 'utf8'));
const validColors = new Set();

// Extract all color values from colors.json
function extractColors(obj) {
  for (const key in obj) {
    if (typeof obj[key] === 'string' && obj[key].startsWith('#')) {
      validColors.add(obj[key].toLowerCase());
    } else if (typeof obj[key] === 'object') {
      extractColors(obj[key]);
    }
  }
}

extractColors(colorsData.colors);

console.log(`✅ Loaded ${validColors.size} colors from master palette`);

// Validate VS Code themes
const vsCodeThemes = [
  'vscode/themes/sentinel-dark-color-theme.json',
  'vscode/themes/sentinel-light-color-theme.json',
  'vscode/themes/sentinel-midnight-color-theme.json'
];

let errors = 0;

vsCodeThemes.forEach(themePath => {
  const fullPath = path.join(__dirname, '..', themePath);
  if (fs.existsSync(fullPath)) {
    const theme = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
    console.log(`\nValidating ${path.basename(themePath)}...`);
    
    // Check theme colors
    if (theme.colors) {
      Object.entries(theme.colors).forEach(([key, value]) => {
        if (typeof value === 'string' && value.startsWith('#')) {
          const baseColor = value.substring(0, 7).toLowerCase();
          if (!validColors.has(baseColor) && !value.match(/#[0-9a-f]{6}[0-9a-f]{2}/i)) {
            console.error(`  ❌ Invalid color in ${key}: ${value}`);
            errors++;
          }
        }
      });
    }
  }
});

if (errors === 0) {
  console.log('\n✅ All colors validated successfully!');
  process.exit(0);
} else {
  console.log(`\n❌ Found ${errors} color validation errors`);
  process.exit(1);
}
