# Quick Start: Using Skills 🪓

**Get up and running with Matt Pocock's engineering skills**

---

## 🚀 First Time Setup

### 1. Install Skills

```bash
# In your coding agent, run:
/setup-matt-pocock-skills
```

**This will:**
- Ask which issue tracker you use (GitHub, Linear, or local files)
- Ask what labels you apply to issues during triage
- Ask where to save documentation
- Set up all the skills for you

### 2. Verify Installation

```bash
# Check that skills are available
/grill-me --help
/tdd --help
```

---

## 📝 Your First Feature

### Step 1: Plan with `/grill-me`

```bash
/grill-me
```

**What to expect:**
```
AI: What are you building?

You: I want a user authentication system

AI: Great! Let me understand...
    - Single user or multi-user?
    - What auth methods? (email, OAuth, etc.)
    - Password requirements?
    - Session management?
    - [continues asking questions...]

You: [answer all questions]

AI: Here's my understanding:
    [summary of requirements]
    
    Should I create a PRD?

You: Yes
```

**Result**: Clear specification, no ambiguity!

---

### Step 2: Split into Issues with `/to-issues`

```bash
/to-issues
```

**What to expect:**
```
AI: [creates GitHub issues]

Issue #1: User Registration
Issue #2: User Login  
Issue #3: User Logout
Issue #4: Password Reset
Issue #5: Session Management

Each issue is independent and shippable!
```

**Result**: Your work is now organized!

---

### Step 3: Implement with `/tdd`

Pick an issue and run:

```bash
/tdd
```

**What to expect:**
```
AI: [starts TDD loop]

RED: Writing test for user registration...
[shows failing test]

You: [runs test, confirms it fails]

AI: GREEN: Implementing registration...
[shows code]

You: [runs test, confirms it passes]

AI: REFACTOR: Cleaning up code...
[shows refactored code]

You: [reviews, accepts]

✅ Test passed! Next test?
```

**Result**: Working, tested code!

---

### Step 4: Keep Architecture Clean with `/improve-codebase-architecture`

After completing 3-4 issues:

```bash
/improve-codebase-architecture
```

**What to expect:**
```
AI: [scans codebase]

Issues found:
1. Shallow module: services/auth.js
   → Suggestion: Split into validation, persistence, tokens

2. Tight coupling: components/LoginForm
   → Suggestion: Inject auth service as dependency

Accept suggestions? (y/n)
```

**Result**: Cleaner architecture!

---

## 🎯 Common Workflows

### Workflow 1: New Feature

```bash
/grill-me          # Plan it
/to-issues         # Split it
[tick off issue]
/tdd               # Build it
/improve-codebase-architecture  # Clean it up
```

### Workflow 2: Bug Fix

```bash
/diagnose          # Understand the bug
[tick off issue]
/tdd               # Fix it (with tests!)
```

### Workflow 3: Design Exploration

```bash
/prototype         # Build throwaway version
[evaluate]
[decide on approach]
/grill-with-docs   # Plan properly with docs
```

---

## 📚 Skill Cheat Sheet

### Planning Skills

| Skill | Command | Use When |
|-------|---------|----------|
| **Grill** | `/grill-me` | Starting any feature |
| **Grill + Docs** | `/grill-with-docs` | Complex feature needing documentation |
| **To PRD** | `/to-prd` | You've chatted but need formal spec |
| **To Issues** | `/to-issues` | You have a PRD, need tasks |

### Development Skills

| Skill | Command | Use When |
|-------|---------|----------|
| **TDD** | `/tdd` | Implementing any feature |
| **Diagnose** | `/diagnose` | Debugging a bug |
| **Prototype** | `/prototype` | Exploring design options |

### Architecture Skills

| Skill | Command | Use When |
|-------|---------|----------|
| **Improve Architecture** | `/improve-codebase-architecture` | After several features |
| **Zoom Out** | `/zoom-out` | Lost in code details |

### Communication Skills

| Skill | Command | Use When |
|-------|---------|----------|
| **Caveman** | `/caveman` | Want to save tokens |
| **Handoff** | `/handoff` | Switching to another agent |
| **Write Skill** | `/write-a-skill` | Creating custom skills |

---

## 💡 Pro Tips

### Tip 1: Always Grill First

❌ **Wrong:**
```
You: Build login
AI: [starts coding]
You: No, I meant OAuth!
AI: [changes code]
```

✅ **Right:**
```
You: /grill-me
AI: What auth methods?
You: OAuth with Google and GitHub
AI: [confirms everything]
AI: /to-issues
```

### Tip 2: TDD Every Time

❌ **Wrong:**
```
You: [codes feature]
You: [tests it manually]
You: [ships it]
[bug discovered later]
```

✅ **Right:**
```
You: /tdd
AI: [writes failing test]
You: [confirms it fails]
AI: [makes it pass]
You: [confirms it passes]
AI: [refactors]
[feature is tested and safe]
```

### Tip 3: Use Shared Language

After `/grill-with-docs`, you'll have `CONTEXT.md`:

```bash
# Instead of:
You: Make the thing where users can request password reset

# Use:
You: Implement PasswordResetRequest per CONTEXT.md
```

**Benefits:**
- Saves tokens
- Clearer communication
- Consistent terminology

### Tip 4: Regular Architecture Checks

Don't wait for code to rot:

```bash
# Every 3-4 completed issues:
/improve-codebase-architecture
```

**Prevents:**
- Shallow modules
- Tight coupling
- Technical debt accumulation

---

## 🎓 Learning Path

### Beginner (Week 1)

1. ✅ Set up skills (`/setup-matt-pocock-skills`)
2. ✅ Use `/grill-me` for every feature
3. ✅ Use `/tdd` for implementation
4. ✅ Read `docs/SOFTWARE_ENGINEERING_WORKFLOW.md`

### Intermediate (Week 2-3)

1. ✅ Use `/grill-with-docs` for complex features
2. ✅ Use `/to-issues` to split work
3. ✅ Use `/improve-codebase-architecture` regularly
4. ✅ Start using `/zoom-out` when confused

### Advanced (Week 4+)

1. ✅ Use `/caveman` to save tokens
2. ✅ Create custom skills with `/write-a-skill`
3. ✅ Use `/triage` for issue management
4. ✅ Use `/prototype` for design exploration

---

## 🐛 Troubleshooting

### Skill Not Found

```bash
# Re-run setup
/setup-matt-pocock-skills

# Check installation
ls ~/.claude/skills  # or wherever skills are stored
```

### Tests Not Running

```bash
# Check test configuration
npm test  # or yarn test, pnpm test

# Verify test files exist
ls **/*.test.*
```

### Issues Not Creating

```bash
# Check GitHub integration
# Ensure GitHub token is set
# Verify repository permissions
```

---

## 📖 More Resources

- [Full Software Engineering Workflow](./docs/SOFTWARE_ENGINEERING_WORKFLOW.md)
- [Matt Pocock's Original Skills](https://github.com/mattpocock/skills)
- [Addy Osmani Agent Skills](https://github.com/addyosmani/agent-skills)

---

**WAAAGH! Now go build something brilliant!** 👊🪓
