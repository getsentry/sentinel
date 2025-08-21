#!/usr/bin/env node

/**
 * Tests color contrast ratios for WCAG AA compliance
 */

const fs = require('fs');
const path = require('path');

// Simple contrast ratio calculation
function getLuminance(color) {
  const rgb = parseInt(color.slice(1), 16);
  const r = (rgb >> 16) & 0xff;
  const g = (rgb >> 8) & 0xff;
  const b = (rgb >> 0) & 0xff;
  
  const sRGB = [r, g, b].map(val => {
    val = val / 255;
    return val <= 0.03928 ? val / 12.92 : Math.pow((val + 0.055) / 1.055, 2.4);
  });
  
  return 0.2126 * sRGB[0] + 0.7152 * sRGB[1] + 0.0722 * sRGB[2];
}

function getContrastRatio(color1, color2) {
  const lum1 = getLuminance(color1);
  const lum2 = getLuminance(color2);
  const brightest = Math.max(lum1, lum2);
  const darkest = Math.min(lum1, lum2);
  return (brightest + 0.05) / (darkest + 0.05);
}

// Load colors
const colorsData = JSON.parse(
  fs.readFileSync(path.join(__dirname, '..', '..', 'colors.json'), 'utf8')
);

console.log('🎨 Testing WCAG AA Contrast Ratios\n');

// Test critical combinations
const tests = [
  // Dark theme tests
  {
    name: 'Dark: Primary text on background',
    bg: colorsData.colors.dark.background.primary,
    fg: colorsData.colors.dark.foreground.primary,
    minRatio: 4.5
  },
  {
    name: 'Dark: Secondary text on background',
    bg: colorsData.colors.dark.background.primary,
    fg: colorsData.colors.dark.foreground.secondary,
    minRatio: 4.5
  },
  {
    name: 'Dark: Comments on background',
    bg: colorsData.colors.dark.background.primary,
    fg: colorsData.colors.dark.syntax.comment,
    minRatio: 3.0 // Comments can have lower contrast
  },
  // Light theme tests
  {
    name: 'Light: Primary text on background',
    bg: colorsData.colors.light.background.primary,
    fg: colorsData.colors.light.foreground.primary,
    minRatio: 4.5
  },
  {
    name: 'Light: Secondary text on background',
    bg: colorsData.colors.light.background.primary,
    fg: colorsData.colors.light.foreground.secondary,
    minRatio: 4.5
  }
];

let passed = 0;
let failed = 0;

tests.forEach(test => {
  const ratio = getContrastRatio(test.bg, test.fg);
  const status = ratio >= test.minRatio ? '✅' : '❌';
  
  console.log(`${status} ${test.name}`);
  console.log(`   Background: ${test.bg}, Foreground: ${test.fg}`);
  console.log(`   Ratio: ${ratio.toFixed(2)}:1 (min: ${test.minRatio}:1)\n`);
  
  if (ratio >= test.minRatio) {
    passed++;
  } else {
    failed++;
  }
});

console.log(`\nResults: ${passed} passed, ${failed} failed`);

if (failed > 0) {
  process.exit(1);
}
