# Contributing to Sentry Sentinel Theme

Thank you for considering contributing to the Sentry Sentinel Theme! We love your contributions, whether they're bug reports, feature requests, or code improvements.

## 🐛 Reporting Issues

Found a bug or have a suggestion? Please [open an issue](https://github.com/getsentry/sentinel-theme/issues) with:

- **Bug Reports**: Include your editor/IDE version, OS, and steps to reproduce
- **Feature Requests**: Describe the feature and why it would be helpful
- **Color Issues**: Include screenshots and specify which syntax elements are problematic

## 🎨 Design Principles

When contributing, please keep these principles in mind:

1. **Accessibility First**: All colors must meet WCAG AA standards (4.5:1 contrast ratio)
2. **Brand Consistency**: Use colors from `colors.json` and maintain Sentry's visual identity
3. **Developer Ergonomics**: Ensure syntax highlighting aids code comprehension
4. **Cross-Platform**: Test changes across different editors when possible

## 🚀 Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR-USERNAME/sentinel-theme.git
   cd sentinel-theme
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Make your changes**
   - Edit theme files in the appropriate directory
   - Update `colors.json` if adding new color definitions
   - Test your changes thoroughly

4. **Test locally**
   ```bash
   # Build all themes
   npm run build
   
   # Test in VS Code
   code vscode/
   # Press F5 to launch Extension Development Host
   ```

## 📁 Project Structure

```
sentry-sentinel-theme/
├── colors.json           # Master color palette
├── vscode/              # VS Code extension
├── terminal-themes/     # Terminal emulator themes
│   ├── vim/            # Vim/Neovim colorschemes
│   └── warp/           # Warp terminal themes
└── scripts/            # Build and utility scripts
```

## 🎯 Contribution Types

### Adding New Editor Support

1. Create a new directory under appropriate parent folder
2. Follow the naming convention: `sentinel_[variant].[ext]`
3. Use colors from `colors.json` for consistency
4. Add installation instructions to `INSTALL.md`
5. Update main `README.md` with supported editor

### Improving Existing Themes

1. Test the current theme extensively
2. Identify specific issues (contrast, readability, missing elements)
3. Make minimal, targeted changes
4. Verify WCAG compliance remains intact
5. Test across multiple file types and languages

### Adding Language Support

1. Research language-specific syntax elements
2. Map elements to appropriate color categories
3. Test with real-world code examples
4. Ensure consistency with other languages

## 🧪 Testing Checklist

Before submitting a PR, ensure:

- [ ] Colors meet WCAG AA standards (use a contrast checker)
- [ ] Theme works in both light and dark OS modes (if applicable)
- [ ] Common languages display correctly (JS, Python, HTML, CSS, etc.)
- [ ] UI elements are properly themed
- [ ] Terminal colors work correctly
- [ ] No accessibility regressions

## 📏 Code Style

- Use 2 spaces for indentation in JSON/YAML files
- Keep color definitions in alphabetical order
- Comment any non-obvious color choices
- Use descriptive commit messages

## 🔄 Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes and commit**
   ```bash
   git add .
   git commit -m "feat: add support for X editor"
   ```

3. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Open a Pull Request**
   - Use a clear, descriptive title
   - Reference any related issues
   - Include screenshots for visual changes
   - Describe testing performed

## 📋 PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Theme improvement

## Testing
- [ ] Tested in [Editor/IDE name and version]
- [ ] Verified WCAG compliance
- [ ] Checked multiple languages
- [ ] Screenshots attached (if visual changes)

## Screenshots
[Add before/after screenshots here]
```

## 🎉 Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes for significant contributions
- Special thanks in README for major features

## 💬 Questions?

- Open a [Discussion](https://github.com/getsentry/sentinel-theme/discussions)
- Reach out in issues for clarification
- Check existing issues/PRs for similar work

Thank you for helping make Sentry Sentinel Theme better! 💜
