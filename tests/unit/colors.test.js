#!/usr/bin/env node

/**
 * Validates color definitions across all theme files
 */

const fs = require('fs');
const path = require('path');

const COLORS_FILE = path.join(__dirname, '..', '..', 'colors.json');

// Load master color palette
const colorsData = JSON.parse(fs.readFileSync(COLORS_FILE, 'utf8'));
const validColors = new Set();

// Additional allowed colors that are VS Code specific and not in master palette
const ALLOWED_UI_COLORS = new Set([
  // Grays and neutrals
  '#1a1a1a', '#141119', '#2a2438', '#3f3f46', '#71717a', '#a1a1aa', '#d1d5db', 
  '#e4e4e7', '#f9fafb', '#f8fafc', '#fefefe', '#6b7280', '#9ca3af', '#374151', 
  '#1f2937', '#6a6772', '#302e36', '#3e3b45', '#b8b8c8',
  
  // VS Code specific UI colors
  '#362d59', '#f8f8f9', '#d9008d', '#3f00a7', '#8a76ff', '#998bff', '#e5e7eb',
  
  // Terminal ANSI bright colors
  '#f87171', '#34d399', '#fbbf24', '#3b82f6', '#f472b6', '#06b6d4', '#818cf8',
  '#d8ab5a', '#67e8f9', '#0891b2',
  
  // Error/warning colors
  '#ef4444', '#f59e0b', '#ffd00e',
  
  // Brand colors
  '#6559d1', '#e1567c', '#f4834f', '#226dfc',
  
  // Syntax highlighting colors
  '#ff9838', '#10b981', '#7c3aed', '#a794ff', '#cdcbff', '#bab6ff',
  '#ebd0a3', '#f4e4c9', '#e1bd7d', '#b5006f', '#bf8600', '#c97c00'
]);

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

// Add allowed UI colors to valid set
ALLOWED_UI_COLORS.forEach(color => validColors.add(color.toLowerCase()));

console.log(`✅ Loaded ${validColors.size} colors from master palette and allowed UI colors`);

// Validate VS Code themes
const vsCodeThemes = [
  'vscode/themes/sentinel-dark-color-theme.json',
  'vscode/themes/sentinel-light-color-theme.json',
  'vscode/themes/sentinel-midnight-color-theme.json'
];

let errors = 0;

vsCodeThemes.forEach(themePath => {
  const fullPath = path.join(__dirname, '..', '..', themePath);
  if (fs.existsSync(fullPath)) {
    const theme = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
    console.log(`\nValidating ${path.basename(themePath)}...`);
    
    // Check theme colors
    if (theme.colors) {
      Object.entries(theme.colors).forEach(([key, value]) => {
        if (typeof value === 'string' && value.startsWith('#')) {
          const baseColor = value.substring(0, 7).toLowerCase();
          
          // Allow transparency variations (8-digit hex)
          if (!validColors.has(baseColor)) {
            console.log(`  ❌ Invalid color in ${key}: ${value}`);
            errors++;
          }
        }
      });
    }
    
    // Check token colors
    if (theme.tokenColors) {
      theme.tokenColors.forEach((rule, index) => {
        if (rule.settings && rule.settings.foreground) {
          const color = rule.settings.foreground;
          if (color && color.startsWith('#')) {
            const baseColor = color.substring(0, 7).toLowerCase();
            if (!validColors.has(baseColor)) {
              console.log(`  ❌ Invalid token color at index ${index}: ${color}`);
              errors++;
            }
          }
        }
      });
    }
  }
});

if (errors > 0) {
  console.log(`\n❌ Found ${errors} color validation errors`);
  console.log('\nTo fix: Either add missing colors to colors.json or add them to ALLOWED_UI_COLORS in this test.');
  process.exit(1);
} else {
  console.log('\n✅ All colors validated successfully!');
}