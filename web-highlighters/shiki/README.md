# Sentry Sentinel Theme for Shiki

[Shiki](https://shiki.style/) is a beautiful syntax highlighter powered by the same language engine as VS Code. These themes bring the Sentinel color palette to Shiki-powered documentation and websites.

## Available Themes

| Theme | Type | Background | Description |
|-------|------|------------|-------------|
| `sentinel-dark` | Dark | `#181225` | Primary dark theme with purple accents |
| `sentinel-light` | Light | `#f8f8f9` | Clean light theme for bright environments |
| `sentinel-midnight` | Dark | `#000000` | True black OLED-friendly theme |

## Installation

### Direct JSON Import

The JSON theme files can be loaded directly by Shiki:

```javascript
import { createHighlighter } from 'shiki';

// Import the theme JSON
import sentinelDark from '@getsentry/sentinel/web-highlighters/shiki/sentinel-dark.json';

const highlighter = await createHighlighter({
  themes: [sentinelDark],
  langs: ['javascript', 'typescript', 'python'],
});

const html = highlighter.codeToHtml(code, {
  lang: 'typescript',
  theme: 'sentinel-dark',
});
```

### TypeScript Import

For TypeScript projects, use the typed exports:

```typescript
import { sentinelDark, sentinelLight, sentinelMidnight } from '@getsentry/sentinel/web-highlighters/shiki';

const highlighter = await createHighlighter({
  themes: [sentinelDark, sentinelLight],
  langs: ['javascript', 'typescript'],
});
```

## Framework Integration

### Astro (Starlight)

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import sentinelDark from './path/to/sentinel-dark.json';

export default defineConfig({
  integrations: [
    starlight({
      expressiveCode: {
        themes: [sentinelDark],
      },
    }),
  ],
});
```

### VitePress

```javascript
// .vitepress/config.js
import sentinelDark from './path/to/sentinel-dark.json';

export default {
  markdown: {
    theme: sentinelDark,
    // Or for light/dark mode:
    // theme: { light: sentinelLight, dark: sentinelDark }
  },
};
```

### Nuxt Content

```javascript
// nuxt.config.ts
import sentinelDark from './path/to/sentinel-dark.json';

export default defineNuxtConfig({
  content: {
    highlight: {
      theme: sentinelDark,
    },
  },
});
```

### Rehype Pretty Code

```javascript
import { unified } from 'unified';
import rehypePrettyCode from 'rehype-pretty-code';
import sentinelDark from './path/to/sentinel-dark.json';

unified().use(rehypePrettyCode, {
  theme: sentinelDark,
});
```

## Color Palette

### Dark Theme Colors

| Token | Color | Preview |
|-------|-------|---------|
| Background | `#181225` | ![#181225](https://placehold.co/15x15/181225/181225.png) |
| Foreground | `#f9f8f9` | ![#f9f8f9](https://placehold.co/15x15/f9f8f9/f9f8f9.png) |
| Comments | `#898294` | ![#898294](https://placehold.co/15x15/898294/898294.png) |
| Keywords | `#9E86FF` | ![#9E86FF](https://placehold.co/15x15/9E86FF/9E86FF.png) |
| Strings | `#83da90` | ![#83da90](https://placehold.co/15x15/83da90/83da90.png) |
| Functions | `#226DFC` | ![#226DFC](https://placehold.co/15x15/226DFC/226DFC.png) |
| Types | `#FF45A8` | ![#FF45A8](https://placehold.co/15x15/FF45A8/FF45A8.png) |
| Numbers | `#FDB81B` | ![#FDB81B](https://placehold.co/15x15/FDB81B/FDB81B.png) |

## Accessibility

All themes meet WCAG 2.1 AA standards with minimum 4.5:1 contrast ratio for normal text.

## License

MIT License - See the repository's main LICENSE file for details.

