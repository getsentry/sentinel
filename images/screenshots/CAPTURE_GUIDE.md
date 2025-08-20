# Screenshot Capture Guide

## Best Practices for Theme Screenshots

### Recommended Settings

**Resolution**: 1400x900px (or similar 16:10 ratio)
**Font**: Use a popular coding font like:
- JetBrains Mono
- Fira Code
- Source Code Pro
- Consolas

**Font Size**: 14-16px for clarity
**Line Height**: 1.4-1.6 for readability

### VS Code Screenshot Tips

1. **Clean Setup**
   - Hide minimap: `View > Show Minimap`
   - Hide breadcrumbs: `View > Show Breadcrumbs`
   - Use clean file tree (collapse unnecessary folders)
   - Close unnecessary panels

2. **Window Size**
   - Use consistent window dimensions
   - Command on macOS: `Window > Zoom` then manually resize

3. **Code Examples**
   ```javascript
   // Good example - shows various syntax elements
   import { useState, useEffect } from 'react';
   
   const API_URL = 'https://api.sentry.io/v2';
   
   export function SentryDashboard({ projectId }) {
     const [errors, setErrors] = useState([]);
     const [loading, setLoading] = useState(true);
     
     useEffect(() => {
       // Fetch recent errors from Sentry
       fetchErrors(projectId).then(data => {
         setErrors(data);
         setLoading(false);
       });
     }, [projectId]);
     
     return (
       <div className="dashboard">
         {loading ? <Spinner /> : <ErrorList errors={errors} />}
       </div>
     );
   }
   ```

### What to Capture

1. **Syntax Variety**
   - Keywords (function, const, import)
   - Strings and template literals
   - Comments (single and multi-line)
   - Functions and methods
   - Numbers and constants
   - Types (if TypeScript)

2. **UI Elements**
   - Sidebar with file tree
   - Tabs showing multiple files
   - Status bar
   - Activity bar icons
   - Terminal (if showing integrated terminal)

3. **Theme Features**
   - Selection highlighting
   - Bracket matching
   - Current line highlight
   - Git diff indicators (if applicable)

### File Naming Convention

```
[editor]-[variant]-[language/feature].png

Examples:
vscode-dark-javascript.png
vscode-light-python.png
vscode-midnight-overview.png
vim-dark-overview.png
warp-dark-terminal.png
```

### macOS Screenshot Commands

```bash
# Full screen
Cmd + Shift + 3

# Selection
Cmd + Shift + 4

# Window (with shadow)
Cmd + Shift + 4, then Space

# Window (without shadow) - Recommended
Cmd + Shift + 4, then Space, then hold Option while clicking
```

### Image Optimization

After capturing, optimize images:

```bash
# Using ImageOptim (macOS)
open -a ImageOptim images/screenshots/*.png

# Using pngquant (cross-platform)
pngquant --quality=90-100 images/screenshots/*.png

# Using tinypng CLI
tinypng images/screenshots/*.png
```

### Sample Code Files

Create example files that showcase the theme well:

1. **JavaScript/TypeScript** - React component with hooks
2. **Python** - Class with decorators and type hints  
3. **CSS/SCSS** - Variables, nesting, and animations
4. **HTML** - Semantic markup with attributes
5. **JSON** - Configuration with nested objects
6. **Markdown** - Headers, lists, code blocks
7. **YAML** - Complex configuration structure

Remember: The goal is to show how beautiful and readable code looks with the Sentinel theme!
