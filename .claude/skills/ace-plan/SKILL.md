---
name: ace-plan
description: >
  Third step of the ace workflow: write an implementation plan from research
  and grill documents, with acceptance criteria, phases with BEFORE / AFTER
  code, test scaffolding first, and pauses between phases. Use when the user
  types /ace-plan or a message starting with "plan:", or asks how to implement
  a decided change.
---

# Plan

## Goal

A plan precise enough that implementation is execution, not design.

## Steps

1. Read the research and grill documents completely.
2. Map the problem: current state with `file:line`, desired end state, out of scope.
3. Ask the remaining design questions, short form: one concrete scenario and one code block per option, a recommendation. One question per turn.
4. Write acceptance criteria in Given / When / Then, each with a verification method: unit test, manual check, or script.
5. Cut the work into phases. The first code phase is test scaffolding: one `@Test` per automatable criterion, failing with `#expect(Bool(false), "AC-N: Not yet implemented")`.
6. For every modified file, give BEFORE and AFTER code. For every new file, give the complete code. No pseudocode.
7. End each phase with success criteria (automated and manual) and a `[PAUSE]` line.
8. Fill the template `plan-template.md` and write `docs/thoughts/plans/YYYY-MM-DD-<topic>.md`.

## Rules

- A decision cites its alternatives and why they lost.
- An uncertain fact becomes an uncertainty flag with the phase that will measure it.
- A phase leaves the build green, except the expected failures of the scaffolding phase.

## Stop

STOP after writing the plan. Report its path and the uncertainty flags. Do not start implementing: the user decides the next step.
