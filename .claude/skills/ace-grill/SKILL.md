---
name: ace-grill
description: >
  Second step of the ace workflow: settle the open decisions of a research
  document, one question at a time, each with a recommendation. Use when the
  user types /ace-grill or a message starting with "grill:", or wants to be
  challenged on choices before planning.
---

# Grill

## Goal

Turn every open question into a recorded decision with its rationale, before any plan is written.

## Steps

1. Read the research document completely, including its open questions.
2. Order the questions: those that change the scope first, details last.
3. Ask ONE question per turn. Each question MUST contain:
   - a concrete scenario showing why it matters;
   - two to four options;
   - a recommendation with its reason.
4. Wait for the answer. Record it, then ask the next question. Never batch questions.
5. When the answer reveals a new question, add it to the queue.
6. Write `docs/thoughts/research/YYYY-MM-DD-grill-<topic>.md`.

## Document sections

- Topic: the research document grilled
- Resolved decisions: table `# | Question | Decision | Rationale`
- Open questions: what remains, with who decides
- Codebase references: table `File | Line | Relevance`

## Stop

STOP after writing the document. Report its path and the number of decisions. Do not start a plan: the user decides the next step.
