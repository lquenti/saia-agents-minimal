# Skills Reference

Complete reference for all pre-installed skills in the Advanced Coding Agent.

## Overview

The agent comes with **production-grade skills** from two curated collections:

- **Matt Pocock's Skills** (12+) - Engineering best practices
- **Addy Osmani's Agent Skills** (24) - Production-grade workflows + Understand-Anything

---

## Matt Pocock's Skills

Location: `skills/matt-pocock/skills/`

### Engineering Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| `/grill-me` | `grill-me` | Get relentlessly interviewed about plans until fully specified |
| `/grill-with-docs` | `grill-with-docs` | Grilling session that builds shared language + CONTEXT.md |
| `/tdd` | `tdd` | Test-driven development with red-green-refactor loop |
| `/diagnose` | `diagnose` | Disciplined diagnosis loop for hard bugs |
| `/to-prd` | `to-prd` | Turn conversation into PRD + GitHub issue |
| `/to-issues` | `to-issues` | Break plans into independent GitHub issues |
| `/triage` | `triage` | Triage issues through state machine |
| `/improve-codebase-architecture` | `improve-codebase-architecture` | Find deepening opportunities in codebase |
| `/zoom-out` | `zoom-out` | Get broader context on unfamiliar code |
| `/prototype` | `prototype` | Build throwaway prototypes to explore designs |
| `/caveman` | `caveman` | Ultra-compressed communication (~75% token savings) |
| `/handoff` | `handoff` | Compact conversation for agent handoff |

### Skill Details

#### `/grill-me`

**Purpose:** Get relentlessly interviewed about your plans until they're fully specified.

**When to use:**
- Starting a new feature
- Making a significant change
- Requirements are vague

**What it does:**
- Asks one question at a time
- Uncovers edge cases
- Documents assumptions
- Creates clear requirements

**Example:**
```bash
/grill-me

# Agent will ask:
# "What are you trying to build?"
# "Who is the user?"
# "What are the edge cases?"
# ... and more
```

---

#### `/grill-with-docs`

**Purpose:** Same as `/grill-me`, but also builds shared language and documentation.

**When to use:**
- Starting a new project
- Onboarding to existing codebase
- Team needs shared terminology

**What it does:**
- All of `/grill-me`
- Creates `CONTEXT.md` with shared language
- Documents architecture decisions
- Creates ADRs for major decisions

**Example output - CONTEXT.md:**
```markdown
# Context: E-Commerce Platform

## Shared Language

| Term | Meaning |
|------|---------|
| Materialization | Making a lesson visible to students |
| Materialization Cascade | One change triggers multiple updates |

## Naming Conventions

- Functions: `camelCase`
- Components: `PascalCase`
- Files: `kebab-case`
```

---

#### `/tdd`

**Purpose:** Test-driven development with red-green-refactor loop.

**When to use:**
- Implementing new features
- Fixing bugs
- Refactoring code

**What it does:**
- Write test first (red)
- Implement minimum code (green)
- Refactor while keeping tests green

**Example:**
```bash
/tdd

# Agent will:
# 1. Ask what to test
# 2. Write the test
# 3. Run it (should fail)
# 4. Implement code
# 5. Run it (should pass)
# 6. Refactor
```

---

#### `/diagnose`

**Purpose:** Disciplined diagnosis loop for hard bugs.

**When to use:**
- Bug is unclear
- Error message is cryptic
- Behavior is unexpected

**What it does:**
- Forms hypothesis
- Tests hypothesis
- Narrows down root cause
- Documents findings

---

#### `/to-prd`

**Purpose:** Turn conversation into Product Requirements Document (PRD) + GitHub issue.

**When to use:**
- After grilling session
- Before planning
- Need formal specification

**What it does:**
- Creates PRD with objectives
- Defines scope and boundaries
- Creates GitHub issue
- Links to PRD

---

#### `/to-issues`

**Purpose:** Break plans into independent GitHub issues.

**When to use:**
- Have a large plan
- Need to track progress
- Working with team

**What it does:**
- Decomposes plan
- Creates issues with acceptance criteria
- Orders by dependencies
- Links related issues

---

#### `/triage`

**Purpose:** Triage issues through state machine.

**When to use:**
- Have backlog of issues
- Need to prioritize
- Working with team

**What it does:**
- Categorizes issues
- Assigns priorities
- Creates action plan
- Updates status

---

#### `/improve-codebase-architecture`

**Purpose:** Find deepening opportunities in codebase.

**When to use:**
- Codebase is growing
- Architecture is unclear
- Need refactoring

**What it does:**
- Analyzes codebase
- Identifies problems
- Suggests improvements
- Prioritizes changes

---

#### `/zoom-out`

**Purpose:** Get broader context on unfamiliar code.

**When to use:**
- New to codebase
- Need big picture
- Understanding dependencies

**What it does:**
- Maps architecture
- Identifies key components
- Explains relationships
- Creates overview

---

#### `/prototype`

**Purpose:** Build throwaway prototypes to explore designs.

**When to use:**
- Uncertain about approach
- Need to validate idea
- Exploring options

**What it does:**
- Creates quick prototype
- Tests assumptions
- Gathers feedback
- Informs decisions

---

#### `/caveman`

**Purpose:** Ultra-compressed communication (~75% token savings).

**When to use:**
- Token budget is tight
- Need efficiency
- Experienced with context

**What it does:**
- Uses shorthand
- Removes verbosity
- Preserves meaning
- Saves tokens

---

#### `/handoff`

**Purpose:** Compact conversation for agent handoff.

**When to use:**
- Switching agents
- Taking a break
- Need continuity

**What it does:**
- Summarizes progress
- Documents next steps
- Saves context
- Enables resumption

---

## Addy Osmani's Agent Skills

Location: `skills/addy-osmani/skills/`

### Slash Commands

| Command | Skill | Purpose |
|---------|-------|---------|
| `/spec` | `spec-driven-development` | Write PRD before any code |
| `/plan` | `planning-and-task-breakdown` | Decompose specs into small, verifiable tasks |
| `/build` | `incremental-implementation` | Thin vertical slices - implement, test, verify |
| `/test` | `test-driven-development` | Red-green-refactor with test pyramid |
| `/review` | `code-review-and-quality` | Five-axis code review before merge |
| `/code-simplify` | `code-simplification` | Reduce complexity while preserving behavior |
| `/ship` | `shipping-and-launch` | Pre-launch checklists + feature flags |
| `/understand` | `understand-anything` | Codebase analysis & knowledge graph generation |

### All 23 Skills

#### Meta

| Skill | Purpose |
|-------|---------|
| `using-agent-skills` | Maps work to right skill workflow |

#### Define (Clarify what to build)

| Skill | Purpose |
|-------|---------|
| `interview-me` | One-question-at-a-time requirement extraction |
| `idea-refine` | Divergent/convergent thinking for vague ideas |
| `spec-driven-development` | Write PRD before any code |

#### Plan (Break it down)

| Skill | Purpose |
|-------|---------|
| `planning-and-task-breakdown` | Decompose specs into small, verifiable tasks |

#### Build (Write the code)

| Skill | Purpose |
|-------|---------|
| `incremental-implementation` | Thin vertical slices - implement, test, verify |
| `test-driven-development` | Red-green-refactor, test pyramid |

#### Review (Improve before merge)

| Skill | Purpose |
|-------|---------|
| `code-review-and-quality` | Five-axis review with severity labels |
| `code-simplification` | Reduce complexity |
| `security-and-hardening` | OWASP Top 10 prevention |
| `performance-optimization` | Measure-first performance work |

#### Ship (Deploy with confidence)

| Skill | Purpose |
|-------|---------|
| `shipping-and-launch` | Pre-launch checklists + feature flags |
| `git-workflow-and-versioning` | Trunk-based development + atomic commits |
| `ci-cd-and-automation` | Shift Left + quality gate pipelines |

#### Specialized

| Skill | Purpose |
|-------|---------|
| `frontend-ui-engineering` | Component architecture + accessibility |
| `api-and-interface-design` | Contract-first API design |
| `browser-testing-with-devtools` | Chrome DevTools MCP for runtime data |
| `debugging-and-error-recovery` | Five-step triage for broken builds |
| `documentation-and-adrs` | Architecture Decision Records |
| `source-driven-development` | Ground decisions in official docs |
| `doubt-driven-development` | Adversarial review of non-trivial decisions |
| `context-engineering` | Feed agents right info at right time |
| `understand-anything` | Codebase analysis & knowledge graph generation |

---

## Skill Usage Patterns

### Pattern 1: Start with Interview

```bash
/interview-me
# → Agent asks questions until requirements are clear
```

### Pattern 2: Build Shared Language

```bash
/grill-with-docs
# → Creates CONTEXT.md with shared terminology
```

### Pattern 3: Write Spec

```bash
/spec
# → Creates PRD with scope, requirements, testing approach
```

### Pattern 4: Plan Implementation

```bash
/plan
# → Breaks down into tasks with acceptance criteria
```

### Pattern 5: Implement with TDD

```bash
/test
# → TDD cycle: red → green → refactor
```

### Pattern 6: Review Before Merge

```bash
/review
# → Five-axis code review
```

### Pattern 7: Simplify

```bash
/code-simplify
# → Reduces complexity
```

### Pattern 8: Ship

```bash
/ship
# → Pre-launch checklist
```

---

## Complete Workflow

```bash
# PHASE 1: Shared Understanding
/interview-me
/grill-with-docs
/spec

# PHASE 2: Module & Interface Design
/plan
/api-and-interface-design
/documentation-and-adrs

# PHASE 3: TDD Implementation
/test
/build

# PHASE 4: Review & Simplify
/review
/code-simplify

# PHASE 5: Ship
/ship
```

**📖 Full Guide:** See [SOFTWARE_ENGINEERING_WORKFLOW.md](SOFTWARE_ENGINEERING_WORKFLOW.md)

---

#### `/understand` (Understand-Anything)

**Purpose:** Turn any codebase into an interactive knowledge graph you can explore, search, and ask questions about.

**When to use:**
- Starting work on a large/complex codebase (10k+ lines)
- Need to understand architecture quickly
- Onboarding new team members
- Planning major refactoring
- Need visual documentation

**Installation (first-time):**
```bash
curl -fsSL https://raw.githubusercontent.com/Lum1104/Understand-Anything/main/install.sh | bash
```

**Commands:**

**Scan codebase:**
```bash
/understand [path] [--language <lang>]
```

**Open dashboard:**
```bash
/understand-dashboard
```

**Ask questions:**
```bash
/understand-chat "How does authentication work?"
```

**Deep-dive into file:**
```bash
/understand-explain src/auth/login.ts
```

**Generate onboarding docs:**
```bash
/understand-onboard docs/UNDERSTANDING.md
```

**Extract business domains:**
```bash
/understand-domain
```

**Analyze impact of changes:**
```bash
/understand-diff
```

**What it does:**
- Multi-agent pipeline scans your project
- Builds interactive knowledge graph
- Generates plain-English summaries
- Creates visual dashboard for exploration
- Supports incremental updates
- Works with 6 languages (en, zh, ja, ko, ru)

**Output:**
- `.understand-anything/knowledge-graph.json` - Main graph (commit this!)
- Interactive web dashboard with visual exploration
- Plain-English code explanations
- Architecture layer mapping

**Example workflow:**
```bash
# 1. Scan codebase
/understand

# 2. Open dashboard
/understand-dashboard

# 3. Ask questions
/understand-chat "What are the main architectural layers?"

# 4. Generate onboarding docs
/understand-onboard docs/UNDERSTANDING.md

# 5. Share with team
git add .understand-anything/ docs/UNDERSTANDING.md
git commit -m "Add knowledge graph and onboarding docs"
```

**Resources:**
- GitHub: https://github.com/Lum1104/Understand-Anything
- Demo: https://understand-anything.com/demo/
- Documentation: https://understand-anything.com

---

## Skill Selection Guide

### By Task Type

**Clarifying Requirements:**
- `/interview-me` - One question at a time
- `/idea-refine` - Turn vague ideas into concrete plans
- `/grill-me` - Relentless questioning

**Planning:**
- `/spec` - Write PRD
- `/plan` - Break into tasks
- `/to-issues` - Create GitHub issues

**Implementation:**
- `/test` - TDD with test pyramid
- `/build` - Vertical slices
- `/tdd` - Red-green-refactor loop

**Review:**
- `/review` - Five-axis review
- `/code-simplify` - Reduce complexity
- `/security-and-hardening` - Security check

**Deployment:**
- `/ship` - Pre-launch checklist
- `/git-workflow-and-versioning` - Version control

### By Project Phase

**Starting a Project:**
1. `/interview-me` or `/grill-with-docs`
2. `/spec`
3. `/plan`

**During Development:**
1. `/test` (for each feature)
2. `/build` (vertical slices)
3. `/diagnose` (for bugs)

**Before Release:**
1. `/review`
2. `/code-simplify`
3. `/security-and-hardening`
4. `/ship`

---

## Skill Files

Each skill has a `SKILL.md` file with detailed instructions:

```
skills/matt-pocock/skills/engineering/tdd/SKILL.md
skills/addy-osmani/skills/test-driven-development/SKILL.md
```

**Read these files** for complete documentation on each skill.

---

## Related Documentation

- [Software Engineering Workflow](SOFTWARE_ENGINEERING_WORKFLOW.md)
- [Quick Start Skills](QUICK_START_SKILLS.md)
- [Configuration Guide](CONFIGURATION.md)
