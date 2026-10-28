# Decisions

Owner: project owner. Scaffold decisions come from `docs/ANALYSIS.md` (D1-D8) and the user's corrections (D9-D11). Status values: PROPOSED (owner to confirm), ACCEPTED, OPEN.

## Scaffold decisions

| ID | Decision | Status |
|---|---|---|
| D1 | The repository is scaffolded in this workspace root; the two original PRDs stay at the root untouched and are copied to `docs/prd/00-...` and `docs/prd/01-...`. | PROPOSED |
| D2 | Layout follows Common PRD section 3: production code in `apps/desktop-ui`, `services/atlas-core`, `packages/contracts`, plus one working folder per person under `workstreams/`. | PROPOSED |
| D3 | Ownership is enforced by `.github/CODEOWNERS` + branch protection, mirrored in `OWNERSHIP.json` and checked by `scripts/check-ownership.ps1` locally and in CI. | PROPOSED |
| D4 | The shared backend core (`main.py`, `api/`, `models/`, `orchestrator/`, `audit/`, `config.py`, `pyproject.toml`) is owned by the project owner; Persons 1/2 request wiring by PR. | PROPOSED |
| D5 | Backend tests are split: `tests/runtime/` (Person 1), `tests/intent/` (Person 2), `tests/integration/` (Person 4); `tests/conftest.py` is project-owner owned. | PROPOSED |
| D6 | Event mechanism: SSE at `GET /api/v1/tasks/{taskId}/events`, with polling of `GET /api/v1/tasks/{taskId}` as fallback. | PROPOSED |
| D7 | `.gitattributes` normalizes line endings (`* text=auto eol=lf`, `*.ps1` CRLF) to avoid whole-file CRLF conflicts on Windows. | PROPOSED |
| D8 | The scaffold contains structure, ownership, and instruction files only. Source files are one-line placeholders; each owner writes their own code. Root scripts other than the ownership/verify/secret checks are placeholders the project owner implements. | ACCEPTED (user instruction) |
| D9 | Project ATLAS is a Windows desktop application packaged with **Tauri 2** (Master PRD 9.1). The shell lives in `apps/desktop-ui/src-tauri/` and is owned by Person 3, but `src-tauri/tauri.conf.json` (bundle, identifier, signing, sidecar = packaging/installer config) needs project-owner approval: CODEOWNERS lists only `@atlas-project-owner` for that file, and `OWNERSHIP.json` records it under `approvalRequired`. | ACCEPTED (user instruction) |
| D10 | `services/atlas-core` is a local Python backend that runs on the user's Windows machine, binds to `127.0.0.1` only, and is started with/by the desktop app (proposed: as a Tauri sidecar). The UI is not a security boundary; the backend policy engine is. | ACCEPTED (user instruction); sidecar mechanism PROPOSED |
| D11 | Windows builds: `scripts/build-desktop.ps1` (placeholder) produces `.msi`/`.exe` installers via Tauri. Installer signing is future work (Master PRD section 17, "Stage C — Private beta"). | ACCEPTED (user instruction) |

## Master PRD section 18 "Decisions Required Before Implementation"

| # | Question | Answer | Status |
|---|---|---|---|
| 1 | Is v1 Windows-only? Recommended: yes. | Yes: Windows desktop app (D9). | PROPOSED |
| 2 | Is 9Router an approved external LLM exception to AWS-only cloud infrastructure? | | OPEN |
| 3 | Which existing desktop scaffold will be retained? | No scaffold existed; Tauri 2 + React/TypeScript/Vite (D9). Backend web framework still to choose. | PROPOSED |
| 4 | What exact safe workflow will be demonstrated? | Candidate: open one allowlisted editor (`app.open`, see `packages/contracts/action-registry.json`). | OPEN |
| 5 | Is Amazon Transcribe enabled in the selected region and account? | | OPEN |
| 6 | Is the 9Router key/model available, and what are its usage limits? | | OPEN |
| 7 | Which applications and directories are allowlisted? | | OPEN |
| 8 | Which actions are blocked entirely in the prototype? | Baseline: `blocked` list in `action-registry.json` (Master PRD section 7). | PROPOSED |
| 9 | Where are logs stored, and what content is redacted? | | OPEN |
| 10 | What is the agreed stop-work threshold if AWS or 9Router spend approaches the budget? | | OPEN |
