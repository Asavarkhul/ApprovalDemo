# Plan: <title>

Date: YYYY-MM-DD
Starting commit: <sha>
Research: `docs/thoughts/research/<file>.md`
Grill: `docs/thoughts/research/<file>.md`

## Overview

<One or two sentences: objective and approach.>

## Current State

- `path/to/File.swift:12`: <fact>

## Desired End State

<What exists when the plan is done.>

How to verify: AC-1 to AC-N.

## Out of Scope

- <Exclusion and reason.>

## Decisions Log

| # | Decision | Rationale | Alternatives rejected |
|---|----------|-----------|-----------------------|

## Uncertainty Flags

- [ ] <Unverified fact>. Validation: phase N, <how>.

## Acceptance Criteria

### AC-1: <name>
- Given: <state>
- When: <action>
- Then: <observable result>
- Verification: Unit test | Manual check | Script

## Phase 1: Test scaffolding

### Objective

One `@Test` per automatable criterion, compiling and failing.

### Changes Required

#### 1. <Suite>

File: `<path>`
Action: Create

```swift
<complete code>
```

### Success Criteria

#### Automated
- [ ] Build succeeds, new tests fail with "Not yet implemented"

#### Manual
- [ ] Test names match the acceptance criteria

[PAUSE] Review the tests before phase 2.

## Phase 2: <name>

### Objective

### Changes Required

#### 1. <change>

File: `<path>`
Action: Modify

```swift
// BEFORE
```

```swift
// AFTER
```

### Success Criteria

#### Automated
- [ ] <command>: <expected result>

#### Manual
- [ ] <check>

[PAUSE] Confirm before phase 3.

## Testing Strategy

### Unit tests
- [ ] AC-1 to AC-N: `<Suite>`

### Manual steps
1. <step>

## Implementation Checklist

- [ ] Phase 1: Test scaffolding
- [ ] Phase 2: <name>

## Files to Create

| File | Phase |
|------|-------|

## Files to Modify

| File | Phase | Changes |
|------|-------|---------|
