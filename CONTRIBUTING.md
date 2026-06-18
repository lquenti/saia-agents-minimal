# Contributing

Thanks for wanting to contribute.

## How to Contribute

### 1. Reporting Bugs

Found a crack in the armor? Report it!

```markdown
## Bug Description
What went wrong?

## Steps to Reproduce
1. Step one
2. Step two
3. etc.

## Expected Behavior
What should have happened?

## Environment
- Docker version:
- OS:
- Agent: (OpenCode/OpenClaude)
```

### 2. Feature Requests

Want to add more firepower? Suggest it!

```markdown
## Feature Description
What would you like to see?

## Use Case
Why is this needed?

## Alternative Solutions
What else have you considered?
```

### 3. Pull Requests

Ready to fight alongside us?

1. **Fork** the repository
2. **Create** your feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Guidelines

- **Security First**: Don't weaken our defenses
- **Test Thoroughly**: Make sure it works before submitting
- **Document Changes**: Update README.md if needed
- **Keep It Clean**: Follow existing code style

## Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/advanced-coding-agent.git
cd advanced-coding-agent

# Build for testing
docker build -t test-agent ./opencode/

# Run tests
docker run -it test-agent /bin/bash
```

## Code of Conduct

- Be respectful to fellow warriors
- No discrimination or harassment
- Help others learn and grow
- Focus on constructive feedback

## Questions?

Open an issue.
