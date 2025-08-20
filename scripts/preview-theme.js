#!/usr/bin/env node

/**
 * Preview theme colors in the terminal
 */

const fs = require('fs');
const path = require('path');

// ANSI escape codes for terminal colors
const reset = '\x1b[0m';
const bold = '\x1b[1m';

// Load colors
const colorsData = JSON.parse(
  fs.readFileSync(path.join(__dirname, '..', 'colors.json'), 'utf8')
);

function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

function colorText(text, hex, bg = false) {
  const rgb = hexToRgb(hex);
  if (!rgb) return text;
  
  const code = bg ? 48 : 38;
  return `\x1b[${code};2;${rgb.r};${rgb.g};${rgb.b}m${text}${reset}`;
}

console.log(`\n${bold}🎨 Sentry Sentinel Theme Preview${reset}\n`);

// Preview brand colors
console.log(`${bold}Brand Colors:${reset}`);
Object.entries(colorsData.colors.brand).forEach(([name, color]) => {
  const preview = colorText('  ', color, true);
  console.log(`${preview} ${name.padEnd(12)} ${color}`);
});

// Preview dark theme syntax colors
console.log(`\n${bold}Dark Theme Syntax:${reset}`);
const darkSyntax = colorsData.colors.dark.syntax;
const darkBg = colorsData.colors.dark.background.primary;

console.log(colorText('\nfunction ', darkSyntax.keyword) + 
            colorText('greet', darkSyntax.function) + 
            '(' + colorText('name', darkSyntax.variable) + ') {');
console.log('  ' + colorText('// Say hello to the user', darkSyntax.comment));
console.log('  ' + colorText('const', darkSyntax.keyword) + 
            ' greeting = ' + colorText('"Hello, "', darkSyntax.string) + 
            ' + name;');
console.log('  ' + colorText('return', darkSyntax.keyword) + ' greeting;');
console.log('}\n');

// Preview UI colors
console.log(`${bold}UI Status Colors:${reset}`);
const uiColors = colorsData.colors.dark.ui;
console.log(colorText('✓ Success', uiColors.success));
console.log(colorText('⚠ Warning', uiColors.warning));
console.log(colorText('✗ Error', uiColors.error));
console.log(colorText('ℹ Info', uiColors.info));

console.log(`\n${bold}Accessibility Info:${reset}`);
console.log(`WCAG Level: ${colorsData.accessibility.wcag_level}`);
console.log(`Normal Text Contrast: ${colorsData.accessibility.contrast_ratios.normal_text}`);
console.log(`Large Text Contrast: ${colorsData.accessibility.contrast_ratios.large_text}\n`);
