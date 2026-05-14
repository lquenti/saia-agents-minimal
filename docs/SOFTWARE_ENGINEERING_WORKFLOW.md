# Software Engineering Workflow 🦾

> A disciplined, skill-driven approach to AI-assisted software development.

**Principles:**
1. **Shared understanding first** - Never code until you and the agent agree on what to build
2. **Simple interfaces, deep modules** - Design clean boundaries, implement complex logic inside
3. **Test-driven development** - Tests as specification and safety net

---

## 📋 Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    SOFTWARE DEVELOPMENT                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌───────────────────────────────────────────────────────┐
    │  PHASE 1: SHARED UNDERSTANDING                         │
    │  ──────────────────────────────                        │
    │  • Interview to clarify requirements                   │
    │  • Build shared language (CONTEXT.md)                 │
    │  • Write spec (PRD) before code                       │
    │                                                        │
    │  Skills: /interview-me, /grill-with-docs, /spec       │
    └───────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌───────────────────────────────────────────────────────┐
    │  PHASE 2: MODULE & INTERFACE DESIGN                    │
    │  ───────────────────────────────────                   │
    │  • Split into modules (high cohesion)                 │
    │  • Design simple interfaces (low coupling)            │
    │  • Document architecture (ADR)                        │
    │                                                        │
    │  Skills: /plan, /api-and-interface-design             │
    └───────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌───────────────────────────────────────────────────────┐
    │  PHASE 3: TEST-DRIVEN IMPLEMENTATION                   │
    │  ──────────────────────────────────                    │
    │  • Write test first (red)                             │
    │  • Implement minimum code (green)                     │
    │  • Refactor while keeping tests green                 │
    │                                                        │
    │  Skills: /test, /build, /tdd                          │
    └───────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌───────────────────────────────────────────────────────┐
    │  PHASE 4: REVIEW & SIMPLIFY                            │
    │  ──────────────────────                                │
    │  • Code review (5-axis)                               │
    │  • Simplify complexity                                │
    │  • Security & performance checks                      │
    │                                                        │
    │  Skills: /review, /code-simplify, /security           │
    └───────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌───────────────────────────────────────────────────────┐
    │  PHASE 5: SHIP                                         │
    │  ─────                                                 │
    │  • Pre-launch checklist                               │
    │  • Feature flags                                      │
    │  • Documentation                                      │
    │                                                        │
    │  Skills: /ship, /documentation                        │
    └───────────────────────────────────────────────────────┘
```

---

## 🎯 Phase 1: Shared Understanding

**Goal:** Ensure you and the agent have the **exact same mental model** before writing code.

### Why This Matters

> "No-one knows exactly what they want" - *The Pragmatic Programmer*

The most common failure mode: **misalignment**. You think the agent understands, but it builds something completely different.

**Solution:** Grilling sessions + shared language.

### Step 1.1: Interview / Grill

**Use when:** Starting a new feature, project, or major change.

**Skills:**
- **Matt Pocock:** `/grill-me` or `/grill-with-docs`
- **Addy Osmani:** `/interview-me`

**What happens:**
- Agent asks you **one question at a time**
- Extracts requirements until ~95% confidence
- Uncovers edge cases you didn't think of
- Documents assumptions

**Example:**
```bash
# Inside the agent TUI:
/interview-me

# OR
/grill-me

# OR (recommended - builds shared language too)
/grill-with-docs
```

**Output:**
- Clear requirements document
- List of edge cases
- Known unknowns (things to clarify later)

---

### Step 1.2: Build Shared Language

**Use when:** After grilling, before planning.

**Skill:**
- **Matt Pocock:** `/grill-with-docs` (includes this automatically)

**What happens:**
- Creates `CONTEXT.md` with project terminology
- Documents domain-specific jargon
- Establishes naming conventions
- Creates glossary of terms

**Example `CONTEXT.md`:**
```markdown
# Context: E-Commerce Platform

## Shared Language

| Term | Meaning | Example |
|------|---------|---------|
| Materialization | Making a lesson visible to students | "Materialize this lesson" |
| Materialization Cascade | When one change triggers multiple visibility updates | "Fix the materialization cascade bug" |
| Section | Group of lessons in a course | "Move lesson to another section" |

## Naming Conventions

- Functions: `camelCase` (e.g., `materializeLesson`)
- Components: `PascalCase` (e.g., `LessonCard`)
- Files: `kebab-case` (e.g., `lesson-card.tsx`)

## Architecture Decisions

- **ADR-001:** Using PostgreSQL over MongoDB for relational data
- **ADR-002:** JWT for authentication, stored in HTTP-only cookies
```

**Why this matters:**
- Agent uses **consistent terminology** throughout
- Reduces token usage (shorter words = fewer tokens)
- Code is more readable (consistent naming)
- Future sessions start with context already loaded

---

### Step 1.3: Write Spec (PRD)

**Use when:** Requirements are clear, before any planning or coding.

**Skill:**
- **Addy Osmani:** `/spec` or `/spec-driven-development`

**What happens:**
- Creates Product Requirements Document (PRD)
- Defines objectives, scope, boundaries
- Specifies code style, testing approach
- Documents what's **out of scope**

**Example PRD structure:**
```markdown
# Product Requirements Document: User Authentication

## Objectives
- Allow users to sign up with email/password
- Enable secure login with JWT tokens
- Implement password reset flow

## Scope
✅ Email/password authentication
✅ JWT token-based sessions
✅ Password reset via email
❌ OAuth (Google, GitHub) - out of scope for v1
❌ Two-factor authentication - out of scope for v1

## Technical Requirements
- Backend: Node.js with Express
- Database: PostgreSQL
- Token expiry: 24 hours
- Password: min 8 chars, 1 number, 1 special char

## Testing
- Unit tests for password validation
- Integration tests for login flow
- E2E test for complete sign-up → login flow

## Code Style
- TypeScript with strict mode
- ESLint + Prettier
- Test naming: `should [expected behavior] when [condition]`
```

**Key principle:** **Spec before code.** Never start planning or coding until the spec is written and agreed upon.

---

## 🏗️ Phase 2: Module & Interface Design

**Goal:** Split the system into **modules with simple interfaces** and **deep internal logic**.

### Why This Matters

> "Simple interfaces, deep modules" - *The Art of Lean*

**Good design:**
- ✅ Interface is obvious what it does
- ✅ Implementation can be complex (that's okay!)
- ✅ Modules are independent (low coupling)
- ✅ Modules have single responsibility (high cohesion)

**Bad design:**
- ❌ Interface is complex (5+ parameters)
- ❌ Implementation is simple (but that's not the problem)
- ❌ Modules depend on each other's internals
- ❌ Modules do too many things

### Step 2.1: Plan & Break Down

**Use when:** Spec is complete, before implementation.

**Skill:**
- **Addy Osmani:** `/plan` or `/planning-and-task-breakdown`
- **Matt Pocock:** `/to-issues` (if using GitHub issues)

**What happens:**
- Decomposes spec into **small, verifiable tasks**
- Orders tasks by dependencies
- Creates acceptance criteria for each task
- Estimates complexity

**Example task breakdown:**
```markdown
# Implementation Plan: User Authentication

## Phase 1: Foundation
- [ ] Set up project structure
  - [ ] Initialize Node.js project
  - [ ] Configure TypeScript
  - [ ] Set up ESLint + Prettier
  - ✅ Acceptance: `npm run lint` passes with no errors

- [ ] Set up database
  - [ ] Create PostgreSQL connection pool
  - [ ] Define User schema
  - [ ] Create migrations
  - ✅ Acceptance: Can insert and query users

## Phase 2: Core Features
- [ ] Password validation module
  - [ ] Implement validation rules
  - [ ] Write unit tests
  - ✅ Acceptance: 100% test coverage on validation logic

- [ ] User registration API
  - [ ] POST /register endpoint
  - [ ] Password hashing with bcrypt
  - [ ] Integration tests
  - ✅ Acceptance: Can register a new user

[... continues for all features ...]
```

---

### Step 2.2: Design Interfaces

**Use when:** Planning tasks, before implementation.

**Skill:**
- **Addy Osmani:** `/api-and-interface-design`

**What happens:**
- Designs **API contracts** before implementation
- Defines function signatures
- Documents input/output types
- Identifies error cases

**Example interface design:**
```typescript
// BEFORE implementation - design first!

// Interface: SIMPLE (obvious what it does)
interface UserRepository {
  /**
   * Create a new user
   * @throws UserAlreadyExistsError if email exists
   * @throws InvalidPasswordError if password doesn't meet requirements
   */
  create(email: string, password: string): Promise<User>;
  
  /**
   * Find user by email
   * @returns User or null if not found
   */
  findByEmail(email: string): Promise<User | null>;
  
  /**
   * Verify password for a user
   * @returns true if password matches, false otherwise
   */
  verifyPassword(userId: string, password: string): Promise<boolean>;
}

// Implementation: DEEP (can be complex inside)
class PostgresUserRepository implements UserRepository {
  constructor(
    private pool: Pool,
    private passwordHasher: PasswordHasher,
    private emailValidator: EmailValidator
  ) {}
  
  async create(email: string, password: string): Promise<User> {
    // Deep implementation:
    // - Validate email format
    // - Check for existing user (with transaction)
    // - Hash password with bcrypt (10 rounds)
    // - Insert into database
    // - Handle connection errors
    // - Log audit trail
    // - Emit domain event
    // ... 100+ lines of complex logic ...
  }
  
  // ... other methods ...
}
```

**Key principle:** **Interface should be simple enough to understand in 5 seconds.** Implementation can be as complex as needed.

---

### Step 2.3: Document Architecture

**Use when:** Major design decisions made.

**Skill:**
- **Addy Osmani:** `/documentation-and-adrs`

**What happens:**
- Creates Architecture Decision Records (ADRs)
- Documents **why** not just **what**
- Records alternatives considered
- Makes trade-offs explicit

**Example ADR:**
```markdown
# ADR-001: Use PostgreSQL over MongoDB

## Status
✅ Accepted

## Context
We need a database for user data and authentication. Options:
- PostgreSQL (relational)
- MongoDB (document)
- Redis (key-value, not suitable)

## Decision
Choose **PostgreSQL**.

## Rationale
1. **Data structure**: User data is highly structured (email, password hash, timestamps)
2. **ACID compliance**: Authentication requires transactional guarantees
3. **Maturity**: PostgreSQL has better tooling for our stack
4. **Team expertise**: Team has more PostgreSQL experience

## Alternatives Considered
- **MongoDB**: Flexible schema not needed for this use case
- **SQLite**: Not suitable for production, lacks concurrent writes

## Consequences
✅ Pros:
- Strong consistency
- Better query capabilities
- Mature ecosystem

⚠️ Cons:
- Schema migrations required
- Less flexible for rapid prototyping
```

---

## 🧪 Phase 3: Test-Driven Implementation

**Goal:** Implement features with tests as specification and safety net.

### Why TDD?

> "Tests are the first line of defense" - *Addy Osmani*

**Benefits:**
- ✅ Tests as documentation (specification)
- ✅ Catch regressions immediately
- ✅ Design emerges from testability
- ✅ Confidence to refactor

### Step 3.1: Red-Green-Refactor Loop

**Use when:** Implementing any feature or fixing bugs.

**Skills:**
- **Addy Osmani:** `/test` or `/test-driven-development`
- **Matt Pocock:** `/tdd`

**What happens:**
1. **Red:** Write failing test first
2. **Green:** Write minimum code to pass
3. **Refactor:** Improve code while keeping tests green

**Example TDD cycle:**
```bash
# Step 1: RED - Write test first
cat > test/password-validator.test.ts << 'EOF'
import { validatePassword } from '../src/password-validator';

describe('validatePassword', () => {
  it('should reject passwords shorter than 8 characters', () => {
    expect(validatePassword('abc123')).toBe(false);
  });
  
  it('should reject passwords without numbers', () => {
    expect(validatePassword('abcdefgh')).toBe(false);
  });
  
  it('should accept valid passwords', () => {
    expect(validatePassword('abc123!@#')).toBe(true);
  });
});
EOF

# Run test - it fails!
npm test -- password-validator.test.ts
# ❌ FAIL: validatePassword is not defined

# Step 2: GREEN - Write minimum code
cat > src/password-validator.ts << 'EOF'
export function validatePassword(password: string): boolean {
  if (password.length < 8) return false;
  if (!/\d/.test(password)) return false;
  if (!/[!@#$%^&*]/.test(password)) return false;
  return true;
}
EOF

# Run test - it passes!
npm test -- password-validator.test.ts
# ✅ PASS

# Step 3: REFACTOR - Improve code
cat > src/password-validator.ts << 'EOF'
const PASSWORD_REQUIREMENTS = {
  minLength: 8,
  requiresNumber: true,
  requiresSpecialChar: true,
};

export function validatePassword(password: string): boolean {
  if (password.length < PASSWORD_REQUIREMENTS.minLength) {
    return false;
  }
  
  if (PASSWORD_REQUIREMENTS.requiresNumber && !/\d/.test(password)) {
    return false;
  }
  
  if (PASSWORD_REQUIREMENTS.requiresSpecialChar && !/[!@#$%^&*]/.test(password)) {
    return false;
  }
  
  return true;
}
EOF

# Run test - still passes!
npm test -- password-validator.test.ts
# ✅ PASS
```

---

### Step 3.2: Build Vertical Slices

**Use when:** Implementing features that span multiple layers.

**Skill:**
- **Addy Osmani:** `/build` or `/incremental-implementation`

**What happens:**
- Implements **one feature at a time** (vertical slice)
- Goes from UI → API → Database
- Tests at each layer
- Commits when slice is complete

**Example vertical slice:**
```
Feature: User Registration

✅ Slice 1: Password Validation (backend)
   - Test: validatePassword() function
   - Code: password-validator.ts
   - ✅ Test passes

✅ Slice 2: User Repository (data layer)
   - Test: UserRepository.create()
   - Code: user-repository.ts
   - ✅ Test passes

✅ Slice 3: Auth Service (business logic)
   - Test: AuthService.register()
   - Code: auth-service.ts
   - ✅ Test passes

✅ Slice 4: API Endpoint (interface)
   - Test: POST /register
   - Code: auth-routes.ts
   - ✅ Test passes

✅ Slice 5: Integration Test (full flow)
   - Test: Complete registration flow
   - Code: auth-integration.test.ts
   - ✅ Test passes

🎉 Feature complete! Commit and move to next feature.
```

**Key principle:** **One slice at a time.** Don't start Slice 2 until Slice 1 is tested and committed.

---

### Step 3.3: Test Pyramid

**Use when:** Writing tests for any feature.

**Skill:**
- **Addy Osmani:** `/test` (includes test pyramid guidance)

**What happens:**
- Follows **80/15/5** test distribution:
  - 80% Unit tests (fast, isolated)
  - 15% Integration tests (module interactions)
  - 5% E2E tests (full system)

**Example test distribution:**
```
User Registration Feature
├── Unit Tests (80%)
│   ├── password-validator.test.ts (10 tests)
│   ├── email-validator.test.ts (5 tests)
│   └── token-generator.test.ts (8 tests)
│
├── Integration Tests (15%)
│   ├── user-repository.test.ts (3 tests)
│   └── auth-service.test.ts (4 tests)
│
└── E2E Tests (5%)
    └── registration-flow.test.ts (1 test)
```

**Why this matters:**
- Unit tests are **fast** (run in milliseconds)
- Integration tests catch **interface bugs**
- E2E tests catch **system-level issues**
- **Don't over-test E2E** (slow, fragile)

---

## 🔍 Phase 4: Review & Simplify

**Goal:** Improve code quality before merging.

### Step 4.1: Code Review

**Use when:** Feature complete, before merge.

**Skill:**
- **Addy Osmani:** `/review` or `/code-review-and-quality`

**What happens:**
- Five-axis review:
  1. **Correctness** - Does it work?
  2. **Security** - Any vulnerabilities?
  3. **Performance** - Is it efficient?
  4. **Readability** - Is it clear?
  5. **Maintainability** - Easy to change?

**Example review output:**
```markdown
# Code Review: User Registration

## ✅ Correctness (5/5)
- All tests pass
- Edge cases handled
- Error messages clear

## ✅ Security (5/5)
- Password hashing with bcrypt
- SQL injection prevented (parameterized queries)
- XSS protection (output encoding)

## ⚠️ Performance (3/5)
- ISSUE: Password validation runs 3 times
- FIX: Cache validation result
- SEVERITY: Medium (affects UX)

## ✅ Readability (5/5)
- Clear naming
- Good comments
- Consistent style

## ⚠️ Maintainability (4/5)
- ISSUE: Hardcoded regex in validator
- FIX: Extract to constant
- SEVERITY: Low (minor refactor)

## Summary
✅ Ready to merge after fixes
```

---

### Step 4.2: Simplify Code

**Use when:** Code works but feels complex.

**Skill:**
- **Addy Osmani:** `/code-simplify`

**What happens:**
- Identifies unnecessary complexity
- Suggests simplifications
- Preserves behavior
- Reduces cognitive load

**Example simplification:**
```typescript
// BEFORE: Overly complex
function validateUser(user) {
  if (user == null) return false;
  if (typeof user !== 'object') return false;
  if (user.email == null) return false;
  if (typeof user.email !== 'string') return false;
  if (user.email.length === 0) return false;
  if (!user.email.includes('@')) return false;
  if (user.password == null) return false;
  if (typeof user.password !== 'string') return false;
  if (user.password.length < 8) return false;
  return true;
}

// AFTER: Simplified
function validateUser(user: User): boolean {
  return (
    user != null &&
    isValidEmail(user.email) &&
    isValidPassword(user.password)
  );
}

function isValidEmail(email: string): boolean {
  return email.includes('@') && email.length > 0;
}

function isValidPassword(password: string): boolean {
  return password.length >= 8;
}
```

---

## 🚀 Phase 5: Ship

**Goal:** Deploy with confidence.

### Step 5.1: Pre-Launch Checklist

**Use when:** Ready to deploy.

**Skill:**
- **Addy Osmani:** `/ship`

**What happens:**
- Runs pre-launch checklist
- Verifies feature flags
- Checks documentation
- Confirms rollback plan

**Example checklist:**
```markdown
# Pre-Launch Checklist: User Registration

## ✅ Testing
- [x] All unit tests pass
- [x] Integration tests pass
- [x] E2E tests pass
- [x] Performance tests within budget

## ✅ Security
- [x] Password hashing verified
- [x] SQL injection prevented
- [x] XSS protection enabled
- [x] Rate limiting configured

## ✅ Documentation
- [x] API documentation updated
- [x] README updated
- [x] Changelog entry added

## ✅ Deployment
- [x] Feature flag configured
- [x] Rollback plan documented
- [x] Monitoring alerts set up

## ✅ Go/No-Go Decision
🟢 READY TO SHIP
```

---

## 🎬 Complete Workflow Example

**Scenario:** Build user authentication feature

```bash
# Start agent in your project
cd /path/to/project
./start-opencode.sh
opencode

# PHASE 1: Shared Understanding
/interview-me
# → Agent asks questions, clarifies requirements

/grill-with-docs
# → Creates CONTEXT.md with shared language

/spec
# → Writes PRD with scope, requirements, testing approach

# PHASE 2: Module & Interface Design
/plan
# → Breaks down into tasks with acceptance criteria

/api-and-interface-design
# → Designs simple interfaces for each module

/documentation-and-adrs
# → Documents major architecture decisions

# PHASE 3: TDD Implementation
/test
# → Starts TDD cycle for first task

/build
# → Implements vertical slice (UI → API → DB)

# Repeat /test + /build for each task...

# PHASE 4: Review & Simplify
/review
# → Five-axis code review

/code-simplify
# → Reduces complexity

# PHASE 5: Ship
/ship
# → Pre-launch checklist

# Deploy! 🚀
```

---

## 📚 Skill Reference

### Matt Pocock Skills

| Skill | Phase | Purpose |
|-------|-------|---------|
| `/grill-me` | 1 | Clarify requirements |
| `/grill-with-docs` | 1 | Clarify + build shared language |
| `/interview-me` | 1 | One-question-at-a-time extraction |
| `/to-issues` | 2 | Break into GitHub issues |
| `/tdd` | 3 | Test-driven development |
| `/diagnose` | 3 | Debug hard bugs |
| `/prototype` | 2 | Explore designs quickly |

### Addy Osmani Skills

| Skill | Phase | Purpose |
|-------|-------|---------|
| `/interview-me` | 1 | Requirements extraction |
| `/idea-refine` | 1 | Turn vague ideas into concrete plans |
| `/spec` | 1 | Write PRD before code |
| `/plan` | 2 | Decompose into tasks |
| `/api-and-interface-design` | 2 | Design simple interfaces |
| `/documentation-and-adrs` | 2 | Document architecture decisions |
| `/test` | 3 | TDD with test pyramid |
| `/build` | 3 | Thin vertical slices |
| `/incremental-implementation` | 3 | Safe, incremental changes |
| `/review` | 4 | Five-axis code review |
| `/code-simplify` | 4 | Reduce complexity |
| `/security-and-hardening` | 4 | Security review |
| `/performance-optimization` | 4 | Performance check |
| `/ship` | 5 | Pre-launch checklist |
| `/git-workflow-and-versioning` | 5 | Trunk-based development |

---

## 🎯 Key Principles

### 1. Shared Understanding First
**Never code until you and the agent agree on what to build.**

Use `/interview-me` or `/grill-with-docs` every time you start a new feature.

### 2. Simple Interfaces, Deep Modules
**Interface should be obvious. Implementation can be complex.**

Design interfaces first. Keep them simple. Let the implementation handle the complexity.

### 3. Test-Driven Development
**Tests are specification and safety net.**

Write tests first. Red → Green → Refactor. Follow the 80/15/5 test pyramid.

### 4. Small, Verifiable Steps
**One vertical slice at a time.**

Don't start Phase 2 until Phase 1 is complete. Don't start Slice 2 until Slice 1 is tested and committed.

### 5. Review Before Ship
**Never merge without review.**

Use `/review` for five-axis review. Use `/code-simplify` to reduce complexity. Use `/ship` for pre-launch checklist.

---

## 🚫 Anti-Patterns to Avoid

| Anti-Pattern | Fix |
|--------------|-----|
| **Coding without spec** | → Use `/spec` first |
| **Skipping tests** | → Use `/test` for TDD |
| **Big bang implementation** | → Use `/build` for vertical slices |
| **Merging without review** | → Use `/review` before merge |
| **Over-complicating interfaces** | → Use `/api-and-interface-design` |
| **No shared language** | → Use `/grill-with-docs` |

---

**WAAAGH! Follow this workflow, and ye'll build software like a proper engineer!** 🪓👊
