---
description: Creates a structured ticket for bugs, features, or technical debt. Interactive — asks questions to define scope before writing.
---

# Create Ticket

You create structured tickets that serve as the foundation for the rest of the workflow.

## Process

### Step 1: Understand the Request

Read the user's request carefully. If anything is unclear or ambiguous, ask clarifying questions immediately. Do not assume.

### Step 2: Determine Type

Classify as **bug**, **feature**, or **debt**:
- **bug**: Something broken, unexpected behavior, errors
- **feature**: New functionality or enhancement
- **debt**: Technical debt, refactoring, cleanup

If the type is ambiguous, ask the user to clarify.

### Step 3: Interactive Scope Definition

This is the critical step. Ask questions to define the precise scope. Keep asking until boundaries are clear.

1. Ask what the user specifically wants to achieve
2. Ask about related areas that might be affected
3. Try to expand scope with questions like "Should this also handle X?" or "What about edge case Y?"
4. Stop when the user says something is "out of scope" multiple times
5. Aim for at least 2 rounds of questions

Present questions as a numbered list. Wait for answers before asking the next round.

### Step 4: Write the Ticket

Write to `thoughts/tickets/<type>_<subject>.md`:

```markdown
---
type: [bug|feature|debt]
priority: [high|medium|low]
created: [ISO date]
status: open
stage: created
tags: [comma-separated]
---

# [TYPE]: [Descriptive Title]

## Description

[Clear description of what needs to be done]

## Scope

### In Scope
- [Specific item]
- [Specific item]

### Out of Scope
- [Specific item explicitly excluded]
- [Specific item explicitly excluded]

## Requirements

- [Acceptance criterion]
- [Acceptance criterion]

## Context

[Background information, why this matters]

## Success Criteria

- [ ] [Verifiable outcome]
- [ ] [Verifiable outcome]

## Related

[Links to related tickets, files, or docs]
```

### Step 5: Present and Confirm

Show the ticket to the user. Ask if anything needs to be changed. If the user wants changes, make them.

After confirmation, update the ticket's `status: open` if it was draft.

## Scope Enforcement

If you discover the ticket's scope needs to change:
1. STOP immediately
2. Explain what was found and why scope must change
3. Wait for explicit user permission
4. Do NOT modify the ticket or proceed without approval

## Important Guidelines

- **Be thorough**: Ask follow-up questions to clarify vague points
- **Atomic**: Each ticket should address one specific concern
- **Testable**: Include clear, verifiable success criteria
- **Boundaries**: Explicitly list what is OUT of scope

## File Naming

Format: `<type>_<subject>.md`
Examples: `bug_login_validation.md`, `feature_rootless_docker.md`, `debt_auth_refactor.md`

**user_request**

$ARGUMENTS
