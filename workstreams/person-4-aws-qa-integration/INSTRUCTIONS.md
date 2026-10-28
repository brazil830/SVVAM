# INSTRUCTIONS - Person 4 - AWS, QA & End-to-End Integration

> **This folder and the paths below belong to Person 4 - AWS, QA & End-to-End Integration ALONE.**
> Only Person 4 edits files here. Nobody else's changes are accepted in these paths without Person 4's explicit approval in PR review (enforced by `.github/CODEOWNERS` + branch protection).
> Person 4 must not edit files outside these paths (other workstreams, shared contracts, root config, scripts, CI) without approval from that path's owner or the project owner. See `docs/PERMISSIONS.md`.

Project ATLAS is a **Windows desktop application** (Tauri 2 shell + React UI + local Python backend on `127.0.0.1`). You are the sprint-time integration/QA owner: you test the whole desktop app end to end on Windows, guide the optional AWS features and costs, and report defects to the owning person. You do not fix other people's code and you do not change contracts unilaterally.

## 1. You may edit / You must not edit

**You may edit (owner: Person 4):**
- `workstreams/person-4-aws-qa-integration/**` (this folder)
- `services/atlas-core/tests/integration/`
- `docs/test-results/`
- `docs/setup-windows.md` (including its "Packaging" section)

**You must not edit (request a change instead, section 9):**
- `packages/contracts/**` and `docs/api-contract.md` (project owner).
- Root files, `.env.example`, `scripts/` (you run them and propose fixes by PR, Common PRD section 6), `.github/`, `OWNERSHIP.json`, other `docs/` files (project owner).
- Shared backend core `services/atlas-core/{pyproject.toml,README.md,src/atlas/__init__.py,main.py,config.py,api/,models/,orchestrator/,audit/,tests/conftest.py}` (project owner).
- Person 1 paths (`policy/`, `executor/`, `adapters/`, `verifier/`, `journal/`, `tests/runtime/`, `workstreams/person-1-runtime-safety/`), Person 2 paths (`intent/`, `planner/`, `providers/`, `tests/intent/`, `workstreams/person-2-voice-9router/`), Person 3 paths (`apps/desktop-ui/**`, `workstreams/person-3-ui-character/`).
- Never reformat, rename, or change line endings of files you do not own.

## 2. Branch, commits, merging

- Branch: `person-4/<topic>` (e.g. `person-4/e2e-harness`). The PRD name `feature/person-4-integration` is also accepted. One workstream per branch.
- Commit a working increment every 30-45 minutes. Messages: `feat(person-4): ...`, `test(person-4): ...`, `docs(person-4): ...`.
- Before every push: `git fetch` + `git rebase origin/integration`, then run
  `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-ownership.ps1 -Owner person-4` and
  `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-repo.ps1`.
- Open a PR into `integration`. No direct pushes to `main` or `integration`. Rerun the integration suite after each merge into `integration`.

## 3. PRDs to read

Your person-specific PRD goes in [`prd/`](prd/README.md) (canonical name `docs/prd/05-person-4-aws-qa-integration-prd.md`, placeholder until provided). From the shared PRDs:

- Master section 5 "Goals, Non-Goals, and Delivery Boundaries": "5.3 Definition of prototype completion"
- Master section 9 "Technology and Cloud Constraints": "9.3 Budget controls"
- Master section 13 "Quality Attributes and Measurement"
- Master section 14 "Testing and Acceptance Strategy" (full)
- Master section 16 "Six-Hour Delivery Plan"
- Common section 4 "Shared contracts frozen before parallel work"
- Common section 6 "Root scripts and environment conventions" (you run them and propose fixes)
- Common section 7 "Four parallel workstreams" -> "Person 4 — AWS, QA & End-to-End Integration"
- Common section 8 "How parallel work avoids conflicts", rule 7
- Common section 9 "Six-hour parallel execution schedule — all four active throughout"
- Common section 10 "Common acceptance checklist" -> "Person 4 — AWS/QA/integration" and "Whole product"
- Common section 11 "AWS, 9Router, and budget boundaries"

## 4. Scope (Common PRD section 7)

- **Owns:** AWS feature flags and configuration guidance, cost checks, provider mock setup, integration harness, end-to-end testing, test evidence, and final demo readiness.
- **Must produce (deliverables):** A repeatable end-to-end test, negative test cases, a test-results report (`docs/test-results/`), and the final prototype acceptance checklist (`acceptance-checklist.md`), plus Windows setup and packaging notes in `docs/setup-windows.md`.
- **Must not:** Rebuild the repository foundation, change shared contracts without agreement, or provision expensive resources without explicit owner approval.

## 5. Dependencies (verbatim from `docs/ANALYSIS.md` section 4)

| Consumes from | Provides to |
|---|---|
| Project owner: all contracts, root scripts, `.env.example`. Person 1: runtime interface + fake adapter. Person 2: plan fixtures + provider mocks. Person 3: runnable UI in mock mode. | Everyone: integration harness + mock server/fixtures, E2E test (plan → approval → action → verification → ledger), negative tests, defect reports addressed to the owning person, `docs/test-results/` report, AWS feature-flag/cost guidance (`workstreams/person-4-aws-qa-integration/aws/`), `docs/setup-windows.md`, final acceptance checklist. Project owner: proposed fixes to root scripts (via PR, not direct edit). |

These are interface dependencies, never "wait for" dependencies. Integration is continuous from Hour 0, not a final handoff; you never become a queue others wait for (Common PRD section 8 rule 7).

## 6. How to work without waiting

- Build the harness from the shared contracts and `packages/contracts/examples/` from Hour 0; plug in each person's implementation as it becomes available.
- Send each defect to the owner of that module (issue tagged with their handle); do not fix it in their files.
- Confirm AWS region/access/budget before Person 2 makes any live Transcribe/Polly call. Track AWS and 9Router costs separately.

## 7. Timeline (`docs/ANALYSIS.md` section 7 + Common PRD section 9)

| Time | Your work |
|---|---|
| Hour 0-0:15 | Clone, read the ownership map, run the baseline in mock mode, start immediately. |
| 0:15-2:00 | Implement integration tests, mock server/fixtures, AWS feature flags and cost checks, and a pass/fail test report from the shared contracts; do not wait for feature code. Checkpoint: independently testable slice. |
| 2:00-3:30 | Run contract tests continuously, record failures, and send each defect to the owner of that module. Checkpoint: UI-to-planner-to-policy path works with mocks. |
| 3:30-4:45 | Run end-to-end and negative tests, secret scans, build checks, and AWS budget/configuration checks. Stop feature expansion at 4:45. |
| 4:45-5:00 | Feature freeze: commit a stable increment, update your checklist, report status. |
| 5:00-6:00 | Rerun the integration suite after each merge and report exact failing tests. |

## 8. Definition of done

Every item in [`acceptance-checklist.md`](acceptance-checklist.md) (including "Whole product") is checked or honestly marked, the test-results report is in `docs/test-results/`, `check-ownership.ps1 -Owner person-4` passes, and your work is merged to `integration`.

## 9. Requesting a change in someone else's area

1. Do not edit the file on your branch.
2. Open a GitHub issue with the "Change request" template tagging the owner, or write `workstreams/person-4-aws-qa-integration/docs/change-requests/YYYYMMDD-<target-owner>-<topic>.md` in your own folder and link it in the issue.
3. The owner makes the change on their own branch. If they ask you to make it, your PR needs their approval and the project owner adds the `ownership-override` label.
4. Contract changes follow `packages/contracts/INSTRUCTIONS.md` (propose -> affected owners approve -> project owner merges).
5. Meanwhile keep testing against the current contract and mocks.
