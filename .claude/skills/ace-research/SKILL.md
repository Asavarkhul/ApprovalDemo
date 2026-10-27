---
name: ace-research
description: >
  First step of the ace workflow: research a question before deciding anything.
  Explores the codebase with file:line references, checks external claims
  against their sources, suggests acceptance criteria and lists open
  questions. Use when the user types /ace-research or a message starting with
  "research:", or asks to investigate, compare options or understand a problem
  before a plan.
---

# Research

## Goal

Produce a document that states facts, each with its source, so the next steps decide on evidence rather than memory.

## Steps

1. Restate the question in one paragraph. If it is ambiguous, ask before exploring.
2. Explore the codebase. Every finding about the code MUST cite `path/to/file.swift:line`.
3. Research external facts (API behavior, standards, limits). Every claim MUST cite its source with a verbatim quote and a verdict: confirmed, contradicted, not found.
4. Mark each statement with its origin: `[code]`, `[web #N]`, `[test]` for something measured locally, `[model]` for an unverified belief. A `[model]` statement MUST NOT support a decision.
5. When a claim can be measured in a few minutes (a build setting, an API on the simulator), measure it and record the command and its output.
6. Write the document to `docs/thoughts/research/YYYY-MM-DD-<topic>.md` with the sections below.

## Document sections

- Question
- Summary: the answer in one paragraph
- Detailed findings, grouped by axis
- Code references: table `File | Line | Description`
- External sources: table `# | Claim | Quote | Source | Verdict`
- Patterns to follow
- Suggested acceptance criteria: table `# | Scenario | Given | When | Then`
- Open questions: checkboxes

`docs/thoughts/` is ignored by git: workflow documents stay local.

## Stop

STOP after writing the document. Report its path and the open questions. Do not start a grill or a plan: the user decides the next step.
