---
name: ace-implement
description: >
  Fourth step of the ace workflow: implement a plan one phase at a time, tests
  first, with build and tests at every phase and a stop at every pause. Use
  when the user types /ace-implement or a message starting with "implement:",
  or asks to execute a written plan.
---

# Implement

## Goal

Execute the plan as written, prove each phase with its success criteria, and let the user validate between phases.

## Steps

1. Read the plan completely. Resume at the first unchecked box: checked work is trusted.
2. For each phase:
   1. Read the skills listed under "Required Skills".
   2. Apply the changes. When reality diverges from the plan, adapt the detail and note the difference; when the divergence changes the design, STOP and report it.
   3. Run the build and the tests. Zero warnings: a warning is a failure.
   4. In the test scaffolding phase, every new test MUST fail with its "Not yet implemented" message. A stub that passes tests nothing.
   5. For a security or validation check, disable it once and confirm its test fails, then restore it and confirm the suite is green again.
   6. Check the boxes of the phase in the plan.
   7. Commit the phase with a message in the imperative mood.
   8. [PAUSE] Report what was done, the results of the checks, and the manual checks left to the user. Wait for confirmation before the next phase.
3. Never push, publish or delete without an explicit request in the current conversation.

## Commands

```bash
xcodebuild test -project ApprovalDemo.xcodeproj -scheme ApprovalDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17'
grep "Test case '.*' failed" <log>
```

## Stop

STOP after the last phase. Report the commits, the checks passed and the manual checks left. Do not push and do not suggest the next command.
