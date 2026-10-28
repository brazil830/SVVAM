# Acceptance checklist - Person 1 - Runtime (Common PRD section 10)

- [ ] Only registered actions can execute.
- [ ] Unsupported paths/apps/actions are rejected.
- [ ] Preconditions and postconditions are checked.
- [ ] Failure does not become a success message.
- [ ] Cancellation prevents future steps.
- [ ] Tests cover timeout, missing target, stale selector, and duplicate request.
