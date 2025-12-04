/**
 * Sentry Sentinel Themes for Shiki
 *
 * These themes are compatible with Shiki syntax highlighter and can be used
 * with documentation frameworks like Astro (Starlight), VitePress, Nuxt Content, etc.
 *
 * @see https://shiki.style/
 */

import type { ThemeRegistration } from "shiki";

import sentinelDarkJson from "./sentinel-dark.json";
import sentinelLightJson from "./sentinel-light.json";
import sentinelMidnightJson from "./sentinel-midnight.json";

export const sentinelDark: ThemeRegistration = sentinelDarkJson as ThemeRegistration;
export const sentinelLight: ThemeRegistration = sentinelLightJson as ThemeRegistration;
export const sentinelMidnight: ThemeRegistration = sentinelMidnightJson as ThemeRegistration;

// Default export for convenience
export default {
  dark: sentinelDark,
  light: sentinelLight,
  midnight: sentinelMidnight,
};

