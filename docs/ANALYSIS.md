# Project ATLAS — Parallel-Work Repository Analysis & Scaffold Plan

**Sources analysed (read in full, not modified):**
- `project_atlas_master_prd.md` — Master PRD v1.0 (referred to below as **M§n**)
- `project_atlas_common_team_execution_prd_v1_2_parallel.md` — Common Team Execution PRD v1.2 (referred to below as **C§n**)

**Workspace / repo root:** `c:\Users\vellu\Desktop\mani` (this folder *is* the `project-atlas` repository; see Decision D1).

**Environment facts checked:** Git 2.54, Node 24, Python 3.12, **Windows PowerShell 5.1** (all `.ps1` scripts must be 5.1-compatible: no `&&`/`||` pipeline chains, no ternary `?:`, no `??`, use `ConvertFrom-Json` for JSON parsing). The workspace is **not** yet a git repository.

This document is the single source of truth for the scaffolding step. Section 9 is the ordered implementation plan.

---

## 1. Who works on what (owners defined by the PRDs)

The PRDs define exactly **five owners**: one project owner (pre-sprint maintainer, not a workstream, C§1) and **four parallel developer workstreams** (C§1, C§7, M§15). No other workstreams are invented here.

| Owner | Role (PRD wording) | Working folder (notes/design/tests/checklist) | Production code paths they own (only they edit) | PRD sections they need |
|---|---|---|---|---|
| **Project owner** | Repository + shared-contract maintainer, final acceptance (C§1, C§8 rule 8) | *(none — owns root)* | Root files (`README.md`, `CONTRIBUTING.md`, `.gitignore`, `.env.example`, `.editorconfig`, `package.json`, `pnpm-workspace.yaml`, `tsconfig.base.json`), `packages/contracts/**`, `scripts/**`, `.github/**`, `OWNERSHIP.json`, `docs/prd/**`, `docs/architecture.md`, `docs/api-contract.md`, `docs/threat-model.md`, `docs/decisions.md`, `docs/ANALYSIS.md`, shared backend core: `services/atlas-core/pyproject.toml`, `services/atlas-core/README.md`, `src/atlas/main.py`, `src/atlas/api/`, `src/atlas/models/`, `src/atlas/orchestrator/`, `src/atlas/audit/`, `src/atlas/config.py` | All of both PRDs. Especially C§3 "Canonical repository structure", C§4 "Shared contracts frozen before parallel work", C§5 "Project-owner setup checklist", C§6 "Root scripts and environment conventions", C§8 "How parallel work avoids conflicts", M§10 "Shared Data Contracts", M§18 "Decisions Required Before Implementation" |
| **Person 1** | Desktop Runtime & Safety | `workstreams/person-1-runtime-safety/` | `services/atlas-core/src/atlas/policy/`, `executor/`, `adapters/`, `verifier/`, `journal/`; `services/atlas-core/tests/runtime/` | M§1 "Executive Summary", M§6 FR-03, FR-04, FR-06, FR-07, FR-08, FR-09, FR-10, FR-11, FR-15; M§7 "Risk and Permission Model"; M§8 "High-Level Architecture" (8.1 items 4–7, 8.3 "Trust boundaries"); M§12 "Security, Privacy, and Reliability Requirements"; M§14 "Testing and Acceptance Strategy"; C§4 "Shared contracts frozen before parallel work"; C§7 "Person 1 — Desktop Runtime & Safety"; C§9 "Six-hour parallel execution schedule"; C§10 "Person 1 — Runtime" checklist; C§12 "Product safety constraints"; specialist PRD `02-person-1-runtime-safety-prd.md` |
| **Person 2** | Voice, Intent & 9Router | `workstreams/person-2-voice-9router/` | `services/atlas-core/src/atlas/intent/`, `planner/`, `providers/` (`nine_router.py`, `aws_transcribe.py`, `aws_polly.py`); `services/atlas-core/tests/intent/` | M§6 FR-01, FR-02, FR-04, FR-13, FR-14; M§8.1 items 3 & 8, M§8.2 "Request flow", M§8.3 "Trust boundaries"; M§9 "Technology and Cloud Constraints" (9.2 "AWS-only interpretation", 9.3 "Budget controls"); M§10.4 "Provider interface"; M§12 "Security, Privacy, and Reliability Requirements"; C§4; C§7 "Person 2 — Voice, Intent & 9Router"; C§9; C§10 "Person 2 — Voice/LLM"; C§11 "AWS, 9Router, and budget boundaries"; specialist PRD `03-person-2-voice-9router-prd.md` |
| **Person 3** | UI & Animated Character | `workstreams/person-3-ui-character/` | `apps/desktop-ui/**` (including its own tests) | M§5 "Goals, Non-Goals, and Delivery Boundaries"; M§6 FR-05, FR-09, FR-12, FR-14; M§10.2 "Task status", M§10.3 "Typed events"; M§11 "UI and Animated Character Requirements"; M§8.3 "Trust boundaries" (frontend is not a security boundary); C§4 (4.2 "Task states", 4.3 "Event contract", 4.4 "API semantics"); C§7 "Person 3 — UI & Animated Character"; C§9; C§10 "Person 3 — UI"; specialist PRD `04-person-3-ui-character-prd.md` |
| **Person 4** | AWS, QA & End-to-End Integration (integration/QA owner during sprint) | `workstreams/person-4-aws-qa-integration/` | `services/atlas-core/tests/integration/`; `docs/test-results/`; `docs/setup-windows.md` | M§9 "Technology and Cloud Constraints" (9.3 "Budget controls"); M§13 "Quality Attributes and Measurement"; M§14 "Testing and Acceptance Strategy" (full); M§16 "Six-Hour Delivery Plan"; M§5.3 "Definition of prototype completion"; C§4; C§6 (runs scripts, proposes fixes); C§7 "Person 4 — AWS, QA & End-to-End Integration"; C§8 rule 7; C§9; C§10 "Person 4 — AWS/QA/integration" and "Whole product"; C§11; specialist PRD `05-person-4-aws-qa-integration-prd.md` |

Branch names (C§8): `feature/person-1-runtime`, `feature/person-2-voice`, `feature/person-3-ui`, `feature/person-4-integration`; integration branch `integration`; protected `main`.

---

## 2. Repository layout decision

**Decision D2: Use the Common PRD's canonical hybrid layout (C§3) exactly** — production code in a stack-appropriate monorepo (`apps/desktop-ui`, `services/atlas-core`, `packages/contracts`) **plus** one working folder per person under `workstreams/<person-slug>/`.

Justification:
- C§3 is explicit and authoritative ("one canonical location for each production module"), and C§8 rule 4 forbids duplicating production code under workstream folders. A pure `workstreams/`-only layout would contradict that; a pure `apps/services/packages` layout would lose the per-person working folder the user asked for.
- Conflict-freedom comes from disjoint ownership: every production path has exactly one owner (table above), recorded in two machine-readable places that must stay consistent: `.github/CODEOWNERS` (enforced by GitHub "Require review from Code Owners") and `OWNERSHIP.json` (enforced locally by `scripts/check-ownership.ps1`).
- The only shared-edit hotspots in C§3 (backend `main.py`, `api/`, `models/`, `orchestrator/`, `audit/`, `config.py`, `services/atlas-core/tests/`) are resolved by Decisions D4 and D5 below.

Full target tree (what the scaffold step creates; `.gitkeep` in otherwise-empty folders):

```text
<repo root = c:\Users\vellu\Desktop\mani>
├── project_atlas_master_prd.md                         # original, untouched
├── project_atlas_common_team_execution_prd_v1_2_parallel.md  # original, untouched
├── README.md  CONTRIBUTING.md  OWNERSHIP.json
├── .gitignore  .env.example  .editorconfig  .gitattributes
├── package.json  pnpm-workspace.yaml  tsconfig.base.json
├── apps/desktop-ui/            (README.md OWNER: Person 3; package.json, index.html, vite.config.ts, tsconfig.json, src/{main.tsx,App.tsx,app/,components/{Character,CommandBar,TranscriptPanel,PlanInspector,ConfirmDialog,ExecutionLedger,StatusBanner}/,services/{atlasClient.ts,mockClient.ts},hooks/,styles/,types/})
├── services/atlas-core/        (pyproject.toml, README.md, src/atlas/{__init__.py,main.py,config.py,api/,models/,orchestrator/,audit/,intent/,planner/,policy/,executor/,adapters/,verifier/,journal/,providers/{nine_router.py,aws_transcribe.py,aws_polly.py}}, tests/{runtime/,intent/,integration/})
├── packages/contracts/         (README.md, task-plan.schema.json, action-registry.json, events.schema.json, examples/)
├── workstreams/
│   ├── README.md               (index: who owns which folder)
│   ├── person-1-runtime-safety/      INSTRUCTIONS.md README.md acceptance-checklist.md design/ tests/
│   ├── person-2-voice-9router/       INSTRUCTIONS.md README.md acceptance-checklist.md design/ fixtures/ tests/
│   ├── person-3-ui-character/        INSTRUCTIONS.md README.md acceptance-checklist.md design/ assets/ tests/
│   └── person-4-aws-qa-integration/  INSTRUCTIONS.md README.md acceptance-checklist.md aws/ integration-tests/ test-results/
├── docs/
│   ├── ANALYSIS.md  PERMISSIONS.md  architecture.md  api-contract.md  threat-model.md  decisions.md  setup-windows.md
│   ├── prd/00-master-prd.md 01-common-team-execution-prd.md 02-…05-… (02–05 are placeholders)
│   └── test-results/
├── scripts/ setup.ps1 dev.ps1 test.ps1 lint.ps1 check-secrets.ps1 verify-repo.ps1 check-ownership.ps1
└── .github/ CODEOWNERS  pull_request_template.md  workflows/ci.yml
```

---

## 3. Shared contracts (`packages/contracts/`) and the integration owner

Owner/maintainer: **Project owner** (C§1, C§4: "The project owner must publish these before the sprint"). **Person 4** is the sprint-time integration/QA owner (runs contract and E2E tests, reports defects to module owners; does not fix others' code and does not change contracts unilaterally, C§1, C§7). Contract change procedure (C§4, C§8 rule 6): PR touching `packages/contracts/**` → notify all four → update schema **and** `examples/` together → `scripts/verify-repo.ps1` passes → project-owner approval.

| Contract file | Content (from PRD) | Producer | Consumers |
|---|---|---|---|
| `task-plan.schema.json` | JSON Schema (draft 2020-12) for `TaskPlan`, `ActionStep`, `Condition`, `RiskTier` enum `T0..T3` exactly as C§4.1 / M§10.1; `additionalProperties: false` | Person 2 emits plans | Person 1 validates/executes, Person 3 renders, Person 4 tests |
| `action-registry.json` | Registered actions with `actionType`, argument schema, `riskTier`, preconditions, postconditions, `timeoutMs`, failure behaviour (FR-03). Seed with the one demo action `app.open` (open allowlisted editor, T1, postcondition `window.exists`) plus a `blocked` list from M§7 (password/MFA entry, shell exec, UAC bypass, unrestricted delete, send/post, purchase, security settings) | Project owner (Person 1 proposes additions via PR) | Person 1 enforces, Person 2 constrains prompts to it, Person 4 tests |
| `events.schema.json` | Envelope `{schemaVersion, taskId, timestamp, type, payload}`; `type` enum of the 11 events (C§4.3); `TaskStatus` enum of 10 states (C§4.2) | Backend (orchestrator; runtime and planner emit via it) | Person 3 maps to UI/character states, Person 4 asserts |
| `examples/` | `plan.valid.json`, `plan.invalid-unknown-action.json`, `plan.invalid-lowered-risk.json`, `event.plan_ready.json`, `event.task_completed.json`, `event.task_failed.json` | Project owner | All (fixtures for mocks) |
| `docs/api-contract.md` | REST surface C§4.4: `POST /api/v1/tasks/plan`, `POST /api/v1/tasks/{taskId}/confirm` (must carry the reviewed plan version), `POST /api/v1/tasks/{taskId}/cancel`, `GET /api/v1/tasks/{taskId}`, `GET /api/v1/health`, event stream `GET /api/v1/tasks/{taskId}/events` (SSE; Decision D6) | Project owner | All |

Decision D6: the event mechanism is **SSE at `GET /api/v1/tasks/{taskId}/events`** with polling of `GET /api/v1/tasks/{taskId}` as fallback. C§4.4 requires "one documented event stream or polling mechanism"; SSE is one-way, works with plain HTTP from React, and polling fallback keeps the UI usable if streaming breaks. Recorded in `docs/decisions.md` as "proposed, owner to confirm".

---

## 4. Dependencies per workstream (consumes-from / provides-to)

Every workstream starts against contracts + mocks at Hour 0 (C§8 rule 9); these are interface dependencies, never "wait for" dependencies. Each `INSTRUCTIONS.md` must restate its row verbatim.

| Workstream | Consumes from | Provides to |
|---|---|---|
| **Person 1 — Runtime & Safety** | Project owner: `task-plan.schema.json`, `action-registry.json`, `events.schema.json`, `ATLAS_ALLOWED_APPS`/`ATLAS_ALLOWED_DIRS` config. Person 2: validated `TaskPlan` objects via the planner interface (until ready: `packages/contracts/examples/plan.*.json`). | Orchestrator/Person 3: step results and events `step_started`, `verification_passed`, `verification_failed`, `task_completed`, `task_failed`, `task_cancelled`, and `TaskStatus` transitions. Person 4: a stable runtime interface, a runnable fake-action adapter test, the failure taxonomy. Project owner: proposed `action-registry.json` additions (via PR). |
| **Person 2 — Voice, Intent & 9Router** | Project owner: `task-plan.schema.json`, `action-registry.json` (allowed action types), `events.schema.json`, `.env.example` keys `NINE_ROUTER_*`, `AWS_TRANSCRIBE_ENABLED`, `AWS_POLLY_ENABLED`, `AWS_REGION`, `ATLAS_MOCK_MODE`. Person 4: AWS region/access/budget confirmation before any live Transcribe/Polly call. | Person 1 & orchestrator: schema-valid `TaskPlan` (planner interface) and a deterministic fixture planner. Person 3: events `transcript`, `plan_ready`, `clarification_required`, `provider_error`. Person 4: valid/invalid plan fixtures (in `workstreams/person-2-voice-9router/fixtures/`), provider mocks, provider-failure tests. |
| **Person 3 — UI & Character** | Project owner: `events.schema.json`, `TaskStatus`, `docs/api-contract.md`, `examples/`. Backend (Persons 1 & 2 via orchestrator): REST API + event stream; until ready, `apps/desktop-ui/src/services/mockClient.ts` driven by the contract examples. | User: command bar, transcript, plan inspector, consent dialog (`confirm`/`cancel` calls), execution ledger, 2D character. Person 4: UI test results and demo states (success, blocked, failed, partial, cancelled). |
| **Person 4 — AWS, QA & Integration** | Project owner: all contracts, root scripts, `.env.example`. Person 1: runtime interface + fake adapter. Person 2: plan fixtures + provider mocks. Person 3: runnable UI in mock mode. | Everyone: integration harness + mock server/fixtures, E2E test (plan → approval → action → verification → ledger), negative tests, defect reports addressed to the owning person, `docs/test-results/` report, AWS feature-flag/cost guidance (`workstreams/person-4-aws-qa-integration/aws/`), `docs/setup-windows.md`, final acceptance checklist. Project owner: proposed fixes to root scripts (via PR, not direct edit). |
| **Project owner** | Proposals/PRs from all four. | Contracts, root scripts, scaffold, `docs/decisions.md`, final acceptance, repository permissions. |

---

## 5. How "only you can change your folder" is enforced

The user's requirement: each person works alone in their folder; nothing else changes without proper permission; everything must work without conflict. Git cannot technically stop a local edit, so enforcement is layered (Decision D3):

1. **`.github/CODEOWNERS`** — every path mapped to exactly one owner handle, default `* @atlas-project-owner`. With GitHub branch protection on `main` and `integration` ("Require a pull request", "Require review from Code Owners", "Dismiss stale approvals", block force pushes), a change to another person's path cannot merge without that person's (or the project owner's) approval. Handles are placeholders `@atlas-project-owner`, `@atlas-person-1` … `@atlas-person-4` that the owner replaces with real GitHub usernames (see Open question Q1).
2. **`OWNERSHIP.json`** — the same mapping in machine-readable form: `{ "owners": { "<id>": { "name", "branch", "paths": [glob...] } } }`. `scripts/check-ownership.ps1 -Owner person-1 [-Base integration]` lists files changed vs. base (`git diff --name-only <base>...HEAD` plus uncommitted/untracked) and fails if any file falls outside that owner's paths. It also runs in CI on PRs (derives owner from the branch name `feature/person-N-*`).
3. **`.github/pull_request_template.md`** — checklist: owner, paths touched, contract change? (if yes, all four notified), `verify-repo.ps1` passed.
4. **`docs/PERMISSIONS.md`** — step-by-step GitHub settings for the project owner (branch protection, CODEOWNERS, repo collaborator roles: devs get *Write*, not *Admin*), and the "permission request" procedure: to change a path you don't own, open an issue/PR tagging the owner; never edit it on your branch.
5. **Every `INSTRUCTIONS.md`** opens with a "You may edit / You must not edit" block listing exact paths.

Decision D4 (shared backend core): `main.py`, `api/`, `models/`, `orchestrator/`, `audit/`, `config.py`, and `pyproject.toml` are **project-owner owned**. C§3 labels them "Shared local backend" without an assignee; giving them one owner removes the only multi-writer hotspot. Persons 1/2 expose their modules through interfaces inside their own packages; wiring into `orchestrator/` and `api/` is requested by PR to the project owner. Dependency additions to `pyproject.toml`/`package.json` root are likewise requested by PR (`apps/desktop-ui/package.json` is Person 3's).

Decision D5 (backend tests): `services/atlas-core/tests/` is split into `tests/runtime/` (Person 1), `tests/intent/` (Person 2), `tests/integration/` (Person 4); `tests/conftest.py` is project-owner owned. This keeps C§3's single test root while giving disjoint write sets.

Decision D7: `.gitattributes` with `* text=auto eol=lf` and `*.ps1 text eol=crlf` to prevent whole-file line-ending conflicts between Windows machines.

---

## 6. Tech stack (M§9.1, C§3)

UI: React + TypeScript + Vite (Tauri 2 only if an existing scaffold already uses it — none exists here, so plain Vite web UI). Backend: Python 3.11+ (local backend on `127.0.0.1:8765`). Windows control: UI Automation library. LLM: 9Router from backend only. Optional AWS Transcribe/Polly. Contracts: JSON Schema. Package manager: pnpm workspaces (`apps/*`, `packages/*`). Scripts: Windows PowerShell 5.1. CI: GitHub Actions on `windows-latest`.

Decision D8: The scaffold creates **minimal, dependency-free placeholders** for production code (`README.md` with owner header, empty `__init__.py`, stub `main.py` that only documents the health endpoint, stub `atlasClient.ts`/`mockClient.ts` with TODO and contract imports noted). It does **not** implement the backend health endpoint, UI shell, or install dependencies: the user asked for repo structure + instructions; framework choice (FastAPI vs. other, Tauri vs. web) is an owner decision listed in M§18 Q3. `setup.ps1`/`dev.ps1`/`test.ps1`/`lint.ps1` therefore detect missing manifests/tools and report "SKIPPED: <reason>" explicitly (C§6 requires skipped checks to be reported) instead of failing; `verify-repo.ps1`, `check-secrets.ps1`, and `check-ownership.ps1` are fully functional now.

---

## 7. Phases / milestones (for INSTRUCTIONS.md timelines)

Pre-sprint: project owner starter kit (C§5). Hour 0–0:15 kickoff (clone, read ownership map, run mock baseline). 0:15–2:00 four-way parallel implementation → checkpoint "independently testable slice". 2:00–3:30 contract-level connection → checkpoint "UI→planner→policy works with mocks". 3:30–4:45 hardening → stop feature expansion. 4:45–5:00 feature freeze. 5:00–6:00 fixes in own modules only + demo (one success, one blocked, one failure/cancel). Commit every 30–45 min (C§8 rule 5). Each person's per-phase tasks come from C§9 and must be copied into their INSTRUCTIONS.md.

---

## 8. Open questions (could not be resolved from the PRDs)

- **Q1 — Real identities.** The PRDs name roles ("Person 1–4", "project owner") not people or GitHub handles. Folders use the PRD slugs (`person-1-runtime-safety`, …); CODEOWNERS/OWNERSHIP.json use placeholder handles the owner must replace.
- **Q2 — Specialist PRDs 02–05 do not exist yet.** C§2 requires them; the user says they will share each person's PRD. The scaffold creates placeholder files at `docs/prd/02-person-1-runtime-safety-prd.md` … `05-person-4-aws-qa-integration-prd.md` marked "TO BE PROVIDED BY PROJECT OWNER", and each INSTRUCTIONS.md points to its file.
- **Q3 — Master PRD file numbering conflict.** M§15 lists `01-desktop-runtime.md … 04-aws-integration-qa.md`; C§2/C§3 (newer, v1.2) list `01-common-…` and `02…05-person-N-…`. We follow C (newer, more specific).
- **Q4 — Master vs Common on Person 1 scope.** M§15 gives Person 1 "action registry"; C§3 puts `packages/contracts/` (incl. `action-registry.json`) under the project owner. We follow C: owner maintains the file; Person 1 proposes entries by PR.
- **Q5 — Unassigned shared backend modules** (`main.py`, `api/`, `models/`, `orchestrator/`, `audit/`, `config.py`): assigned to project owner (D4). Owner may reassign.
- **Q6 — Location of the repo.** C§5 says "Create one Git repository named `project-atlas`". We scaffold in the current workspace root (D1) so the original PRDs stay at root as required; the remote can still be named `project-atlas`.
- **Q7 — Transport/framework** (FastAPI vs other, Tauri vs browser, SSE vs WebSocket): not decided by PRDs (M§18 Q3). Proposed SSE (D6); framework left to owner.
- **Q8 — M§18 decisions 1–10** (demo workflow, allowlists, 9Router approval, AWS region, budget stop threshold, log location) are unanswered; `docs/decisions.md` is created with each question and "Status: OPEN".
- **Q9 — Local-only enforcement limit.** Without a GitHub remote with branch protection, ownership is advisory + `check-ownership.ps1`; true "no changes without permission" requires the owner to apply `docs/PERMISSIONS.md` settings on GitHub.

Decision D1: Scaffold directly in `c:\Users\vellu\Desktop\mani` and run `git init -b main` there (the workspace has no `.git`). Rationale: the user asked to build the repo here; the two original PRDs remain at root untouched and are **copied** (not moved) into `docs/prd/00-master-prd.md` and `docs/prd/01-common-team-execution-prd.md`. Do **not** commit or add a remote; the owner does that.

---

## 9. Implementation plan (for the scaffolding step)

All paths are relative to `c:\Users\vellu\Desktop\mani`. Never modify/move/delete the two root PRD files. Scripts must run under Windows PowerShell 5.1 (`powershell -NoProfile -ExecutionPolicy Bypass -File ...`).

- [ ] 1. Initialise git and create root config files.
      Run `git init -b main` (only if `.git` is absent). Create `.gitignore` (C§6 list, plus `!.env.example`), `.gitattributes` (D7), `.editorconfig`, `.env.example` (exact keys/values from C§6), `package.json` (private, `"packageManager": "pnpm@9"`, scripts pointing to `scripts/*.ps1`, no dependencies), `pnpm-workspace.yaml` (`apps/*`, `packages/*`), `tsconfig.base.json` (strict).
      Files: `.gitignore`, `.gitattributes`, `.editorconfig`, `.env.example`, `package.json`, `pnpm-workspace.yaml`, `tsconfig.base.json`
      Verify: `git status` succeeds; `node -e "JSON.parse(require('fs').readFileSync('package.json'))"` and the same for `tsconfig.base.json` exit 0; `git check-ignore .env` prints `.env` and `git check-ignore .env.example` prints nothing.

- [ ] 2. Create the shared contracts in `packages/contracts/` per Section 3.
      JSON Schemas (draft 2020-12) mirroring C§4.1–4.3 exactly (all 10 TaskStatus values, all 11 event types, RiskTier T0–T3, envelope with `schemaVersion`, `taskId`, `timestamp`, `type`, `payload`); `action-registry.json` with `app.open` + `blocked` list; the six example files; `README.md` with the change procedure from Section 3.
      Files: `packages/contracts/{README.md,package.json,task-plan.schema.json,action-registry.json,events.schema.json}`, `packages/contracts/examples/*.json`
      Verify: `python -c "import json,glob;[json.load(open(f)) for f in glob.glob('packages/contracts/**/*.json',recursive=True)]"` exits 0; `plan.valid.json` contains only `actionType`s present in `action-registry.json`.

- [ ] 3. Create production-code skeleton folders with owner markers (D8).
      `apps/desktop-ui/` tree from Section 2 (minimal `package.json` name `@atlas/desktop-ui`, `index.html`, `vite.config.ts`, `tsconfig.json`, `src/main.tsx`, `src/App.tsx`, stub `services/atlasClient.ts` and `mockClient.ts`, `.gitkeep` in component dirs) and `services/atlas-core/` tree (`pyproject.toml` with `requires-python = ">=3.11"`, no deps; `src/atlas/__init__.py`, stub `main.py`, `config.py` reading the `.env.example` keys; one `__init__.py` + `README.md` per subpackage whose first line is `OWNER: <owner> — do not edit without owner approval`; `providers/nine_router.py`, `aws_transcribe.py`, `aws_polly.py` docstring stubs; `tests/{runtime,intent,integration}/` with `.gitkeep`, `tests/conftest.py`).
      Files: everything under `apps/desktop-ui/` and `services/atlas-core/`
      Verify: `python -c "import sys; sys.path.insert(0,'services/atlas-core/src'); import atlas, atlas.policy, atlas.planner, atlas.providers.nine_router"` exits 0; `node -e "JSON.parse(require('fs').readFileSync('apps/desktop-ui/package.json'))"` exits 0.

- [ ] 4. Create ownership enforcement files (Section 5): `OWNERSHIP.json`, `.github/CODEOWNERS`, `.github/pull_request_template.md`, `docs/PERMISSIONS.md`.
      `OWNERSHIP.json` and `CODEOWNERS` must encode exactly the path→owner map in Section 1 (incl. D4, D5); every path has one owner; default `*` → project owner.
      Files: `OWNERSHIP.json`, `.github/CODEOWNERS`, `.github/pull_request_template.md`, `docs/PERMISSIONS.md`
      Verify: `python -c "import json;json.load(open('OWNERSHIP.json'))"` exits 0; each of the four `workstreams/person-*` paths and each production path in Section 1 appears in both files (checked by `verify-repo.ps1` in item 6).

- [ ] 5. Create the four workstream folders with `INSTRUCTIONS.md`, `README.md`, `acceptance-checklist.md` and the subfolders from C§3, plus `workstreams/README.md` index.
      Each `INSTRUCTIONS.md` contains, in this order: (a) banner "This folder and the paths below belong to <Person N — role> ALONE. Changes anywhere else require the owning person's approval via PR; see docs/PERMISSIONS.md."; (b) **You may edit** (exact paths from Section 1) / **You must not edit** (everything else, naming contracts, root, scripts, other persons' paths); (c) your branch name and the commit/merge rules (C§8: 30–45 min commits, merge to `integration`, run `scripts/check-ownership.ps1 -Owner person-N` and `scripts/verify-repo.ps1` before every push); (d) PRDs to read with section headings (Section 1 column) and the path of your specialist PRD placeholder; (e) Owns / Must produce / Must not (C§7 verbatim meaning); (f) Consumes-from / Provides-to (Section 4 row, restated exactly); (g) how to work without waiting (mocks/fixtures to use from `packages/contracts/examples/`); (h) per-phase timeline (Section 7 + C§9 tasks for that person); (i) how to request a contract or shared-file change; (j) definition of done. `acceptance-checklist.md` = that person's C§10 checklist as `- [ ]` items. Person 4's file additionally includes the "Whole product" checklist.
      Files: `workstreams/README.md`, `workstreams/person-1-runtime-safety/{INSTRUCTIONS.md,README.md,acceptance-checklist.md,design/.gitkeep,tests/.gitkeep}`, `workstreams/person-2-voice-9router/{…,design/,fixtures/,tests/}`, `workstreams/person-3-ui-character/{…,design/,assets/,tests/}`, `workstreams/person-4-aws-qa-integration/{…,aws/,integration-tests/,test-results/}`
      Verify: `scripts/verify-repo.ps1` (item 6) reports PASS for workstream checks; manual read confirms each consumes/provides block matches Section 4 word-for-word.

- [ ] 6. Create root scripts (C§6, D8), PowerShell 5.1-compatible.
      `check-secrets.ps1` (regex scan of tracked + untracked-not-ignored files for AWS keys `AKIA[0-9A-Z]{16}`, `-----BEGIN .*PRIVATE KEY-----`, `(api[_-]?key|secret|token|password)\s*[=:]\s*\S{8,}` excluding `.env.example` empty values; fails on any tracked `.env`; prints file:line only). `check-ownership.ps1 -Owner <id> [-Base <ref>]` (Section 5 item 2; when no commits/base exist, checks working-tree changes; reads `OWNERSHIP.json`; exit 1 on violation). `verify-repo.ps1` (asserts every required folder/file from Section 2 exists, parses all contract JSON + `OWNERSHIP.json`, checks every OWNERSHIP path has a CODEOWNERS line, runs `check-secrets.ps1` and `test.ps1`, prints PASS/FAIL summary, non-zero on failure). `setup.ps1`, `dev.ps1`, `test.ps1`, `lint.ps1` implement the C§6 behaviour where tooling/manifests exist and print `SKIPPED: <reason>` otherwise; `setup.ps1` copies `.env.example`→`.env` only if absent; `test.ps1` always runs contract JSON checks and runs `python -m pytest services/atlas-core/tests` only if pytest is installed.
      Files: `scripts/{setup,dev,test,lint,check-secrets,verify-repo,check-ownership}.ps1`
      Verify: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-repo.ps1` exits 0 with PASS; `... -File scripts\check-secrets.ps1` exits 0; create a temp file `workstreams/person-2-voice-9router/tmp.txt`, run `... -File scripts\check-ownership.ps1 -Owner person-1` → exits 1 naming that file, `-Owner person-2` → exits 0; delete the temp file.

- [ ] 7. Create docs and CI: copy the two root PRDs to `docs/prd/00-master-prd.md` and `docs/prd/01-common-team-execution-prd.md` (copy, byte-identical); create placeholders `docs/prd/02-person-1-runtime-safety-prd.md`, `03-person-2-voice-9router-prd.md`, `04-person-3-ui-character-prd.md`, `05-person-4-aws-qa-integration-prd.md` ("TO BE PROVIDED BY PROJECT OWNER"); `docs/decisions.md` (D1–D8 as PROPOSED + M§18 Q1–10 as OPEN); `docs/architecture.md` (M§8 summary + module→owner map), `docs/api-contract.md` (Section 3 API table), `docs/threat-model.md` (M§8.3 + M§12 summary), `docs/setup-windows.md` (owned by Person 4; initial content: prerequisites + script usage), `docs/test-results/.gitkeep`; root `README.md` (project summary, owner map table from Section 1, quick start) and `CONTRIBUTING.md` (branch strategy, ownership rules, contract-change procedure, link to PERMISSIONS.md); `.github/workflows/ci.yml` (windows-latest: run `verify-repo.ps1`; on PRs run `check-ownership.ps1` with owner derived from `github.head_ref` `feature/person-N-*`, skipped for other branches).
      Files: `docs/prd/*`, `docs/{decisions,architecture,api-contract,threat-model,setup-windows}.md`, `README.md`, `CONTRIBUTING.md`, `.github/workflows/ci.yml`
      Verify: `(Get-FileHash project_atlas_master_prd.md).Hash -eq (Get-FileHash docs\prd\00-master-prd.md).Hash` is `True` (same for the common PRD); originals still present at root; `scripts\verify-repo.ps1` exits 0.

- [ ] 8. Final consistency check.
      Re-run `verify-repo.ps1`, `check-secrets.ps1`, and the `check-ownership.ps1` positive/negative test from item 6. Confirm `git status` shows the root PRDs unmodified (untracked is fine; nothing committed by the scaffold step) and that every owner in Section 1 has a folder, an INSTRUCTIONS.md, CODEOWNERS lines, and OWNERSHIP.json entries.
      Files: none (fix any file from items 1–7 that fails)
      Verify: all three scripts exit with the expected codes; `docs/scaffold-review.json` is then written by the reviewer step (not by the scaffolder).
