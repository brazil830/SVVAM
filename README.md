# Project ATLAS

Project ATLAS is a **Windows desktop application**: a voice/text assistant that turns a request into a visible plan, asks for confirmation, performs a small set of allowlisted desktop actions through Windows UI Automation, verifies the result, and reports honestly. A 2D animated character shows the real task state. Requirements: `project_atlas_master_prd.md` (Master PRD) and `project_atlas_common_team_execution_prd_v1_2_parallel.md` (Common PRD).

The app has three parts that all run on the user's PC:
- **Desktop app** (`apps/desktop-ui/`): Tauri 2 shell with a React + TypeScript UI layer (Vite builds the UI only).
- **Local backend** (`services/atlas-core/`): Python 3.11+, bound to `127.0.0.1`, started with the desktop app. The only part that calls 9Router or AWS.
- **Shared contracts** (`packages/contracts/`): the JSON Schemas every part codes against.

This repository currently contains **structure, ownership rules, and instructions only**. Each person writes the code for their own area.

## Folder map and owners

| Path | Owner |
|---|---|
| `apps/desktop-ui/` (incl. Tauri shell `src-tauri/`) | Person 3 - UI & Animated Character (`tauri.conf.json` also needs project-owner approval) |
| `services/atlas-core/src/atlas/{policy,executor,adapters,verifier,journal}/`, `tests/runtime/` | Person 1 - Desktop Runtime & Safety |
| `services/atlas-core/src/atlas/{intent,planner,providers}/`, `tests/intent/` | Person 2 - Voice, Intent & 9Router |
| `services/atlas-core/tests/integration/`, `docs/test-results/`, `docs/setup-windows.md` | Person 4 - AWS, QA & End-to-End Integration |
| `services/atlas-core/` core (`main.py`, `config.py`, `api/`, `models/`, `orchestrator/`, `audit/`, `pyproject.toml`) | Project owner |
| `packages/contracts/` | Project owner (shared contracts) |
| `workstreams/person-1-runtime-safety/` ... `person-4-aws-qa-integration/` | One person each (see `workstreams/README.md`) |
| Root files, `scripts/`, `.github/`, `OWNERSHIP.json`, other `docs/` | Project owner |

The authoritative map is `OWNERSHIP.json` (used by `scripts/check-ownership.ps1`) and `.github/CODEOWNERS` (used by GitHub).

## How to start

**Project owner:** follow `docs/HANDOFF.md` (replace placeholder handles, push to GitHub, apply `docs/BRANCH_PROTECTION.md`, send each person their PRDs).

**Each person:**
1. Clone the repo and check out `integration`.
2. Read `workstreams/<your-folder>/INSTRUCTIONS.md`, then `CONTRIBUTING.md` and `docs/PERMISSIONS.md`.
3. Save your PRD in `workstreams/<your-folder>/prd/`.
4. Create your branch: `git checkout -b person-N/<topic>`.
5. Work only in your paths. Before every push run:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-ownership.ps1 -Owner person-N
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-repo.ps1
   ```
6. Open a PR into `integration`.

Windows prerequisites and packaging: `docs/setup-windows.md`. Architecture: `docs/architecture.md`. Decisions and open questions: `docs/decisions.md`.
