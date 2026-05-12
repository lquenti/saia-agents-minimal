# Software Engineering Workflow with AI Agents 🪓

**A complete guide to proper software engineering using AI coding agents**

> Based on Matt Pocock's engineering skills - Real engineering, not vibe coding!

## 📋 Table of Contents

1. [The Problem with AI Coding](#the-problem-with-ai-coding)
2. [The Solution: Structured Workflow](#the-solution-structured-workflow)
3. [Phase 1: Planning & Design (The Grilling)](#phase-1-planning--design-the-grilling)
4. [Phase 2: Breaking Into Parts](#phase-2-breaking-into-parts)
5. [Phase 3: Test-Driven Development](#phase-3-test-driven-development)
6. [Phase 4: Architecture & Deep Modules](#phase-4-architecture--deep-modules)
7. [Complete Workflow Example](#complete-workflow-example)
8. [Skill Reference](#skill-reference)

---

## The Problem with AI Coding

Most people use AI agents wrong:

❌ **Wrong Approach:**
```
User: "Build me a todo app"
AI: *starts coding immediately*
User: "No, that's not what I meant"
AI: *changes code*
User: "Also add this..."
AI: *spaghetti code accumulates*
Result: Broken, unmaintainable code
```

**Why it fails:**
- No clear requirements
- No design before coding
- No tests to verify behavior
- No architecture planning
- AI guesses what you want

---

## The Solution: Structured Workflow

✅ **Right Approach:**

```
┌─────────────────────────────────────────────────────────┐
│ 1. GRILLING PHASE                                       │
│    AI asks questions until design is ABSOLUTELY CLEAR  │
│    → No coding yet!                                     │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 2. SPLITTING PHASE                                      │
│    Break design into independent vertical slices        │
│    → Create issues/tasks                                │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 3. TDD PHASE (per task)                                 │
│    Write failing test → Make pass → Refactor           │
│    → Clear interfaces, deep modules                     │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 4. ARCHITECTURE CHECK                                   │
│    Regular review to prevent entropy                    │
│    → Keep codebase clean                                │
└─────────────────────────────────────────────────────────┘
```

---

## Phase 1: Planning & Design (The Grilling)

### Goal: Absolute Clarity Before Coding

**Never start coding until you've answered every question.**

### How to Use `/grill-me`

```bash
# In your AI agent, run:
/grill-me
```

**What happens:**
1. AI describes what you want to build
2. AI asks HARD questions about your design
3. You answer until EVERY ambiguity is gone
4. AI creates a clear specification

### Example Grilling Session

**User:** "I want to build a task management app"

**AI (grilling):**
```
Let me understand what you're building:

1. Who are the users?
   - Single user or multi-user?
   - Do users need accounts/authentication?
   - Can users share tasks with others?

2. What task properties do you need?
   - Just title and description?
   - Due dates? Priority levels? Tags?
   - Subtasks or nested tasks?
   - Attachments or file uploads?

3. What are the core workflows?
   - Create, read, update, delete tasks?
   - Search and filter?
   - Reminders or notifications?
   - Recurring tasks?

4. Where will data be stored?
   - Local file? Database? Cloud?
   - Do you need offline support?
   - Sync across devices?

5. What's your tech stack preference?
   - Frontend framework?
   - Backend language?
   - Database choice?

6. What does "done" look like?
   - MVP features?
   - Timeline?
   - Success metrics?
```

**You answer ALL questions:**
```
1. Multi-user with accounts. Users can share tasks.
2. Title, description, due date, priority (low/med/high), tags, subtasks.
3. CRUD, search by tag/priority, email reminders, no recurring yet.
4. PostgreSQL database, cloud-hosted, no offline needed.
5. React frontend, Node.js backend, Tailwind CSS.
6. MVP: core CRUD + sharing + reminders. 2 weeks timeline.
```

**AI confirms understanding:**
```
✅ CONFIRMED SPECIFICATION:

Task Management App (MVP)
- Multi-user with authentication
- Tasks: title, description, due date, priority, tags, subtasks
- Features: CRUD, search/filter, task sharing, email reminders
- Stack: React + Node.js + PostgreSQL + Tailwind
- Timeline: 2 weeks

Should I create a PRD (Product Requirements Document)?
```

**You:** "Yes, create the PRD"

### Using `/grill-with-docs`

For more thorough planning:

```bash
/grill-with-docs
```

**What it adds:**
- Creates `CONTEXT.md` with shared language
- Documents decisions in ADRs (Architecture Decision Records)
- Builds domain model for consistent terminology

**Example CONTEXT.md:**
```markdown
# Context: Task Management App

## Domain Language

- **Workspace**: A collection of tasks shared by users
- **Task**: A unit of work with properties
- **Assignment**: Linking a task to a user
- **Share**: Granting another user access to a workspace

## Key Concepts

### Materialization
When a draft task becomes "real" (saved to database)

### Priority Levels
- `LOW`: Can be delayed
- `MEDIUM`: Standard priority
- `HIGH`: Needs attention soon

## Architecture Decisions

### ADR-001: Database Choice
**Decision**: PostgreSQL
**Reason**: Relational data, ACID compliance, mature ecosystem
```

---

## Phase 2: Breaking Into Parts

### Goal: Independent, Grabbable Tasks

**Never build everything at once!**

### Using `/to-issues`

```bash
/to-issues
```

**What happens:**
1. AI takes your PRD/specification
2. Breaks it into **vertical slices** (not layers!)
3. Creates independent GitHub issues
4. Each issue is a complete, testable feature

### What is a Vertical Slice?

❌ **Wrong (Layer-based):**
```
- Task 1: Database schema
- Task 2: API endpoints
- Task 3: Frontend components
- Task 4: Tests
```
**Problem**: Can't test anything until ALL done!

✅ **Right (Vertical Slice):**
```
- Issue 1: Create task (DB + API + UI + Tests)
- Issue 2: Read tasks list (DB + API + UI + Tests)
- Issue 3: Update task (DB + API + UI + Tests)
- Issue 4: Delete task (DB + API + UI + Tests)
```
**Benefit**: Each issue is shippable!

### Example Issue Output

```markdown
## Issue: Create Task

**Story**: As a user, I can create a new task so I can track my work.

**Acceptance Criteria**:
- [ ] User can enter task title (required)
- [ ] User can add description (optional)
- [ ] User can set due date (optional)
- [ ] User can set priority (low/medium/high)
- [ ] Task is saved to database
- [ ] User sees confirmation
- [ ] Task appears in task list

**Technical Notes**:
- Endpoint: `POST /api/tasks`
- Request: `{ title, description?, dueDate?, priority? }`
- Response: `{ id, ...task, created_at }`
- Database: `tasks` table

**Tests Required**:
- [ ] Test: Can create task with minimal fields
- [ ] Test: Title is required
- [ ] Test: Priority defaults to MEDIUM
- [ ] Test: Task persists to database

**Dependencies**: None (can do first)
```

### Using `/to-prd`

If you've been chatting but haven't created a PRD:

```bash
/to-prd
```

**What it does:**
- Synthesizes your conversation into a PRD
- Creates it as a GitHub issue
- No need to write it yourself!

---

## Phase 3: Test-Driven Development

### Goal: Clear Feedback Loops

**TDD is the heartbeat of quality code.**

### Using `/tdd`

```bash
/tdd
```

**What happens:**
1. AI understands the issue you're working on
2. Writes a **failing test** first
3. You verify the test fails (red)
4. AI writes minimum code to pass (green)
5. You verify the test passes
6. AI **refactors** for clarity
7. Repeat for next test

### The Red-Green-Refactor Loop

```
┌─────────────────────────────────────────────────────────┐
│ RED                                                     │
│ Write a failing test that defines desired behavior     │
│ "What should this code DO?"                            │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ GREEN                                                   │
│ Write minimum code to make test pass                   │
│ "How do I make this work?" (no optimization yet!)      │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ REFACTOR                                                │
│ Improve code quality while tests stay green            │
│ "How can I make this cleaner?"                         │
└─────────────────────────────────────────────────────────┘
                           ↓
                    Repeat for next test
```

### Example TDD Session

**Issue**: Create Task

**AI (TDD mode):**
```
## Step 1: Write Failing Test

```typescript
// tasks.test.ts
describe('createTask', () => {
  it('should create a task with minimal fields', async () => {
    const task = await createTask({ title: 'Test Task' });
    
    expect(task).toBeDefined();
    expect(task.title).toBe('Test Task');
    expect(task.id).toBeDefined();
    expect(task.priority).toBe('MEDIUM'); // default
  });
});
```

**Run test:**
```bash
npm test -- tasks.test.ts
```

**Expected**: ❌ FAIL (function doesn't exist yet)

---

## Step 2: Make Test Pass

```typescript
// tasks.ts
export async function createTask(input: { title: string }) {
  return {
    id: Date.now(),
    title: input.title,
    priority: 'MEDIUM',
    created_at: new Date()
  };
}
```

**Run test:**
```bash
npm test -- tasks.test.ts
```

**Expected**: ✅ PASS

---

## Step 3: Refactor

```typescript
// tasks.ts
type Priority = 'LOW' | 'MEDIUM' | 'HIGH';

interface Task {
  id: string;
  title: string;
  description?: string;
  dueDate?: Date;
  priority: Priority;
  created_at: Date;
}

interface CreateTaskInput {
  title: string;
  description?: string;
  dueDate?: Date;
  priority?: Priority;
}

export async function createTask(input: CreateTaskInput): Promise<Task> {
  const task: Task = {
    id: generateId(),
    title: input.title,
    description: input.description,
    dueDate: input.dueDate,
    priority: input.priority ?? 'MEDIUM',
    created_at: new Date()
  };
  
  await saveToDatabase(task);
  
  return task;
}

function generateId(): string {
  return crypto.randomUUID();
}

async function saveToDatabase(_task: Task): Promise<void> {
  // TODO: Implement database save
}
```

**Tests still pass**: ✅

---

Next test: Validate title is required...
```

### Why TDD Works

1. **Clear requirements**: Tests define "done"
2. **No regressions**: Old tests stay green
3. **Better design**: Tests force clean interfaces
4. **Documentation**: Tests show how to use code
5. **Confidence**: Safe to refactor

---

## Phase 4: Architecture & Deep Modules

### Goal: Prevent Software Entropy

**Codebases rot. Fight back!**

### Deep vs Shallow Modules

**Shallow Module** (bad):
```typescript
// Does too much, hard to use
export function processOrder(order) {
  validate(order);
  calculateTotal(order);
  saveToDatabase(order);
  sendEmail(order.customer);
  updateInventory(order.items);
  logActivity(order);
  return order;
}
```
**Problem**: One function does everything, can't test parts, hard to change

**Deep Module** (good):
```typescript
// Clear interface, lots of power
export function processOrder(order: Order): ProcessedOrder {
  const validated = validateOrder(order);
  const calculated = calculateOrderTotal(validated);
  const saved = saveOrder(calculated);
  notifyCustomer(saved);
  updateStock(saved.items);
  
  return saved;
}

// Each function is testable, reusable, clear
export function validateOrder(order: Order): ValidatedOrder { ... }
export function calculateOrderTotal(order: Order): CalculatedOrder { ... }
export function saveOrder(order: Order): SavedOrder { ... }
export function notifyCustomer(order: SavedOrder): void { ... }
export function updateStock(items: OrderItem[]): void { ... }
```
**Benefit**: Clear interface, easy to test, easy to change

### Using `/improve-codebase-architecture`

```bash
/improve-codebase-architecture
```

**What it does:**
1. Scans your codebase
2. Finds shallow modules (too much logic)
3. Finds coupling problems
4. Suggests refactoring opportunities
5. Uses CONTEXT.md for domain language

**Example Output:**
```
## Architecture Issues Found

### 1. Shallow Module: `services/order.js`
**Problem**: 500 lines, does validation, DB, email, inventory
**Suggestion**: Split into:
- `services/order/validation.js`
- `services/order/calculations.js`
- `services/order/persistence.js`
- `services/order/notifications.js`

### 2. Tight Coupling: `components/TodoList`
**Problem**: Depends on direct API calls
**Suggestion**: Inject API as dependency
```

### Using `/zoom-out`

When stuck in code details:

```bash
/zoom-out
```

**What it does:**
- Explains code in system context
- Shows how it fits the whole picture
- Helps understand dependencies
- Prevents local optimizations that break global design

---

## Complete Workflow Example

### Scenario: Build a Blog Platform

---

### Step 1: Grilling

```
User: /grill-me

AI: What are you building?

User: A blog platform where writers can publish posts

AI: [asks 20+ questions about features, users, tech stack, etc.]

User: [answers all questions]

AI: Here's my understanding:
- Multi-user blog platform
- Writers can create, edit, publish posts
- Readers can view posts, comment
- Tags and categories
- Markdown support
- Stack: Next.js, PostgreSQL, Tailwind
- MVP in 3 weeks

Create PRD?

User: Yes
```

---

### Step 2: Splitting

```
User: /to-issues

AI: [creates 12 GitHub issues]

Issue #1: User Authentication (can do first)
Issue #2: Create Draft Post
Issue #3: List Draft Posts
Issue #4: Edit Draft Post
Issue #5: Publish Post
Issue #6: View Published Post
Issue #7: List Published Posts
Issue #8: Add Tags to Post
Issue #9: Comment on Post
Issue #10: Markdown Rendering
Issue #11: Search Posts
Issue #12: Admin Dashboard

All issues are independent vertical slices!
```

---

### Step 3: TDD on Each Issue

```
User: [selects Issue #2: Create Draft Post]
User: /tdd

AI: [runs TDD loop]

RED: Write test for createDraftPost()
GREEN: Implement minimum code
REFACTOR: Clean up types and structure

RED: Write test for validation
GREEN: Add validation logic
REFACTOR: Extract validation rules

RED: Write test for database persistence
GREEN: Add database save
REFACTOR: Create repository pattern

[Repeat until all tests pass]

✅ Issue #2 complete!
```

---

### Step 4: Architecture Check

```
User: [after completing 5 issues]
User: /improve-codebase-architecture

AI: [finds issues]

1. Shallow module in `pages/api/posts.js`
   → Split into separate route handlers

2. Missing error handling layer
   → Add error boundary component

3. Database queries duplicated
   → Create repository pattern

User: [accepts suggestions, refactors]
```

---

## Skill Reference

### Core Workflow Skills

| Skill | When to Use | What It Does |
|-------|-------------|--------------|
| `/grill-me` | Starting new feature | AI asks questions until design is clear |
| `/grill-with-docs` | Starting complex feature | Grilling + creates CONTEXT.md and ADRs |
| `/to-prd` | After planning chat | Turns conversation into PRD issue |
| `/to-issues` | After PRD is ready | Breaks into independent GitHub issues |
| `/tdd` | Working on an issue | Runs red-green-refactor loop |
| `/diagnose` | Stuck on a bug | Systematic bug diagnosis |
| `/improve-codebase-architecture` | After several features | Finds architecture issues |
| `/zoom-out` | Lost in code details | Shows system-level context |

### Supporting Skills

| Skill | When to Use | What It Does |
|-------|-------------|--------------|
| `/caveman` | Communicating with AI | Ultra-compressed mode (saves tokens) |
| `/handoff` | Switching agents | Compacts conversation for another agent |
| `/prototype` | Exploring design | Builds throwaway prototype |
| `/triage` | Managing issues | Triage state machine for issues |

---

## Best Practices

### ✅ DO

1. **Always grill first** - Never code without clear requirements
2. **Write tests first** - Red-green-refactor every time
3. **Vertical slices** - Each task should be shippable
4. **Refactor regularly** - Don't let entropy accumulate
5. **Use shared language** - CONTEXT.md keeps terminology consistent
6. **Zoom out often** - Keep system perspective

### ❌ DON'T

1. **Don't start coding immediately** - Plan first!
2. **Don't build layers** - Build vertical slices
3. **Don't skip tests** - TDD is non-negotiable
4. **Don't wait for "later"** - Refactor now
5. **Don't work in silos** - Keep architecture in mind
6. **Don't guess** - Ask AI to clarify

---

## Common Patterns

### Pattern 1: New Feature

```
1. /grill-me → Clarify requirements
2. /to-issues → Split into tasks
3. Pick one issue
4. /tdd → Implement with tests
5. Commit when done
6. Repeat for next issue
7. /improve-codebase-architecture → After 3-4 issues
```

### Pattern 2: Bug Fix

```
1. /diagnose → Understand the bug
2. Write failing test that reproduces bug
3. /tdd → Fix the bug
4. Verify tests pass
5. /zoom-out → Check for side effects
```

### Pattern 3: Refactoring

```
1. /zoom-out → Understand current architecture
2. /improve-codebase-architecture → Find issues
3. Create issues for refactoring work
4. /tdd → Refactor (tests ensure no regressions)
```

---

## Summary

**The Golden Path:**

```
Grill → Split → TDD → Refactor → Repeat
```

**Key Principles:**

1. **Clarity before code** - Grilling eliminates ambiguity
2. **Small feedback loops** - TDD gives constant feedback
3. **Vertical slices** - Each task is complete and shippable
4. **Deep modules** - Clear interfaces, lots of power
5. **Regular maintenance** - Architecture check prevents rot

**Remember:**

> "Developing real applications is hard. The gap between what you want and what you get is filled with decisions. Make them explicit before coding."

---

**WAAAGH! Now go build something awesome!** 👊🪓
