# INSTRUCTIONS - Person 1 - Desktop Runtime & Safety

> **This folder and the paths below belong to Person 1 - Desktop Runtime & Safety ALONE.**
> Only Person 1 edits files here. Nobody else's changes are accepted in these paths without Person 1's explicit approval in PR review (enforced by `.github/CODEOWNERS` + branch protection).
> Person 1 must not edit files outside these paths (other workstreams, shared contracts, root config, scripts, CI) without approval from that path's owner or the project owner. See `docs/PERMISSIONS.md`.

Project ATLAS is a **Windows desktop application**. You build the part of the local Python backend (`services/atlas-core`) that safely performs desktop actions. The backend runs on the user's own Windows machine, listens on `127.0.0.1` only, and is started with/by the desktop app (Tauri 2 sidecar, `docs/decisions.md` D10). Windows control uses **Windows UI Automation** (Master PRD 9.1), preferring semantic controls over screen coordinates.

## 1. You may edit / You must not edit

**You may edit (owner: Person 1):**
- `workstreams/person-1-runtime-safety/**` (this folder)
- `services/atlas-core/src/atlas/policy/`
- `services/atlas-core/src/atlas/executor/`
- `services/atlas-core/src/atlas/adapters/`
- `services/atlas-core/src/atlas/verifier/`
- `services/atlas-core/src/atlas/journal/`
- `services/atlas-core/tests/runtime/`

**You must not edit (request a change instead, section 9):**
- `packages/contracts/**` and `docs/api-contract.md` (project owner). This includes `action-registry.json`: you *propose* new actions by PR; the project owner merges.
- Shared backend core: `services/atlas-core/pyproject.toml`, `README.md`, `src/atlas/__init__.py`, `main.py`, `config.py`, `api/`, `models/`, `orchestrator/`, `audit/`, `tests/conftest.py` (project owner). Wiring your runtime into the orchestrator/API is requested by PR.
- Root files, `scripts/`, `.github/`, `OWNERSHIP.json`, `docs/` (project owner; `docs/test-results/` and `docs/setup-windows.md` belong to Person 4).
- `services/atlas-core/src/atlas/intent/`, `planner/`, `providers/`, `tests/intent/`, `workstreams/person-2-voice-9router/` (Person 2).
- `apps/desktop-ui/**`, `workstreams/person-3-ui-character/` (Person 3).
- `services/atlas-core/tests/integration/`, `workstreams/person-4-aws-qa-integration/` (Person 4).
- Never reformat, rename, or change line endings of files you do not own.

## 2. Branch, commits, merging

- Branch: `person-1/<topic>` (e.g. `person-1/policy`). The PRD name `feature/person-1-runtime` is also accepted. One workstream per branch: never mix another owner's files into it.
- Commit a working increment every 30-45 minutes (Common PRD section 8 rule 5). Messages: `feat(person-1): ...`, `fix(person-1): ...`, `test(person-1): ...`, `docs(person-1): ...`.
- Before every push: `git fetch` + `git rebase origin/integration`, then run
  `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-ownership.ps1 -Owner person-1` and
  `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-repo.ps1`.
- Open a PR into `integration`. No direct pushes to `main` or `integration`. CI (`ownership-check`) fails the PR if it touches files outside your paths.

## 3. PRDs to read

Your person-specific PRD goes in [`prd/`](prd/README.md) (canonical name `docs/prd/02-person-1-runtime-safety-prd.md`, placeholder until the project owner provides it). From the shared PRDs (`docs/prd/00-master-prd.md` = Master, `docs/prd/01-common-team-execution-prd.md` = Common):

- Master section 1 "Executive Summary"
- Master section 6 "Product Scope and Functional Requirements": "FR-03 — Shared action registry", "FR-04 — Target resolution and clarification", "FR-06 — Risk-based authorization", "FR-07 — Desktop execution", "FR-08 — Preconditions and postconditions", "FR-09 — Cancellation and timeouts", "FR-10 — Recovery and compensation", "FR-11 — Execution ledger", "FR-15 — Workflow reuse"
- Master section 7 "Risk and Permission Model" (incl. "Minimum blocked actions for prototype")
- Master section 8 "High-Level Architecture": "8.1 Components" items 4-7, "8.3 Trust boundaries"
- Master section 12 "Security, Privacy, and Reliability Requirements"
- Master section 14 "Testing and Acceptance Strategy"
- Common section 4 "Shared contracts frozen before parallel work"
- Common section 7 "Four parallel workstreams" -> "Person 1 — Desktop Runtime & Safety"
- Common section 9 "Six-hour parallel execution schedule — all four active throughout"
- Common section 10 "Common acceptance checklist" -> "Person 1 — Runtime"
- Common section 12 "Product safety constraints"

## 4. Scope (Common PRD section 7)

- **Owns:** Windows action adapter, allowlist, risk policy, target validation, preconditions/postconditions, cancellation, timeouts, and compensation behavior where safe.
- **Must produce (deliverables):** A small supported action set, unit tests, mock adapter, failure taxonomy, and workstream checklist (`acceptance-checklist.md`).
- **Must not:** Add arbitrary shell execution, automate credentials, or bypass plan validation.

## 5. Dependencies (verbatim from `docs/ANALYSIS.md` section 4)

| Consumes from | Provides to |
|---|---|
| Project owner: `task-plan.schema.json`, `action-registry.json`, `events.schema.json`, `ATLAS_ALLOWED_APPS`/`ATLAS_ALLOWED_DIRS` config. Person 2: validated `TaskPlan` objects via the planner interface (until ready: `packages/contracts/examples/plan.*.json`). | Orchestrator/Person 3: step results and events `step_started`, `verification_passed`, `verification_failed`, `task_completed`, `task_failed`, `task_cancelled`, and `TaskStatus` transitions. Person 4: a stable runtime interface, a runnable fake-action adapter test, the failure taxonomy. Project owner: proposed `action-registry.json` additions (via PR). |

These are interface dependencies, never "wait for" dependencies (Common PRD section 8 rule 9).

## 6. How to work without waiting

- Code against `packages/contracts/` only, never against Person 2's planner internals.
- Use `packages/contracts/examples/plan.valid.json` (must pass), `plan.invalid-unknown-action.json` and `plan.invalid-lowered-risk.json` (must be rejected) as input until Person 2's planner interface exists.
- Build against a fake action adapter first; add the smallest safe real Windows UI Automation action only after mock tests pass.

## 7. Timeline (`docs/ANALYSIS.md` section 7 + Common PRD section 9)

| Time | Your work |
|---|---|
| Hour 0-0:15 | Clone, read the ownership map, run the baseline in mock mode, start immediately. |
| 0:15-2:00 | Implement the runtime/policy/executor/verifier against a fake action adapter first; add the smallest safe real Windows action only after mock tests pass. Checkpoint: independently testable slice. |
| 2:00-3:30 | Expose a stable runtime interface and publish a runnable fake-action test. Checkpoint: UI-to-planner-to-policy path works with mocks. |
| 3:30-4:45 | Test unsupported actions, ambiguous targets, timeout, cancellation, and verification failures. Stop feature expansion at 4:45. |
| 4:45-5:00 | Feature freeze: commit a stable increment, update your checklist, report what works, what is mocked, known defects. |
| 5:00-6:00 | Fix only your owned modules. Verify that no unapproved action executes and that the displayed result comes from verification. |

## 8. Definition of done

Every item in [`acceptance-checklist.md`](acceptance-checklist.md) is checked, your tests pass, `check-ownership.ps1 -Owner person-1` passes, and your work is merged to `integration`.

## 9. Requesting a change in someone else's area

1. Do not edit the file on your branch.
2. Open a GitHub issue with the "Change request" template tagging the owner (`OWNERSHIP.json` / `.github/CODEOWNERS`), or write `workstreams/person-1-runtime-safety/docs/change-requests/YYYYMMDD-<target-owner>-<topic>.md` in your own folder and link it in the issue.
3. The owner makes the change on their own branch. If they ask you to make it, your PR needs their approval in review and the project owner adds the `ownership-override` label.
4. Contract changes follow `packages/contracts/INSTRUCTIONS.md` (propose -> affected owners approve -> project owner merges).
5. Meanwhile keep working against the current contract and mocks.
