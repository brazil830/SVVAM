# Handoff - what to send each person

Owner: project owner.

Project ATLAS is a Windows desktop application (Tauri 2 shell + React UI + local Python backend). Each person gets: the two shared PRDs, their own specialist PRD, and the name of the folder they own. Section names below are the exact headings in the PRDs.

Shared PRDs (send to everyone):
- Master PRD: `project_atlas_master_prd.md` (copy: `docs/prd/00-master-prd.md`)
- Common PRD: `project_atlas_common_team_execution_prd_v1_2_parallel.md` (copy: `docs/prd/01-common-team-execution-prd.md`)

Everyone reads: Common sections "1. Team model and ownership", "3. Canonical repository structure", "4. Shared contracts frozen before parallel work", "8. How parallel work avoids conflicts", "9. Six-hour parallel execution schedule — all four active throughout", plus `CONTRIBUTING.md` and `docs/PERMISSIONS.md`.

## Person 1 - Desktop Runtime & Safety

- **Folder they own:** `workstreams/person-1-runtime-safety/` (start with its `INSTRUCTIONS.md`)
- **Also owns:** `services/atlas-core/src/atlas/{policy,executor,adapters,verifier,journal}/`, `services/atlas-core/tests/runtime/`
- **Specialist PRD:** `02-person-1-runtime-safety-prd.md` -> they save it in `workstreams/person-1-runtime-safety/prd/`
- **Sections:** Master "1. Executive Summary"; Master 6 "FR-03 — Shared action registry", "FR-04 — Target resolution and clarification", "FR-06 — Risk-based authorization", "FR-07 — Desktop execution", "FR-08 — Preconditions and postconditions", "FR-09 — Cancellation and timeouts", "FR-10 — Recovery and compensation", "FR-11 — Execution ledger", "FR-15 — Workflow reuse"; Master "7. Risk and Permission Model"; Master "8.1 Components" (items 4-7) and "8.3 Trust boundaries"; Master "12. Security, Privacy, and Reliability Requirements"; Master "14. Testing and Acceptance Strategy"; Common "Person 1 — Desktop Runtime & Safety" (section 7), "Person 1 — Runtime" (section 10), "12. Product safety constraints"
- **Branch:** `person-1/<topic>` - **Placeholder handle:** `@atlas-person-1`

## Person 2 - Voice, Intent & 9Router

- **Folder they own:** `workstreams/person-2-voice-9router/`
- **Also owns:** `services/atlas-core/src/atlas/{intent,planner,providers}/`, `services/atlas-core/tests/intent/`
- **Specialist PRD:** `03-person-2-voice-9router-prd.md` -> `workstreams/person-2-voice-9router/prd/`
- **Sections:** Master 6 "FR-01 — Voice and text input", "FR-02 — Intent compilation", "FR-04 — Target resolution and clarification", "FR-13 — Cloud provider integrations", "FR-14 — Privacy disclosure"; Master "8.1 Components" (items 3, 8), "8.2 Request flow", "8.3 Trust boundaries"; Master "9.2 AWS-only interpretation", "9.3 Budget controls"; Master "10.4 Provider interface"; Master "12. Security, Privacy, and Reliability Requirements"; Common "Person 2 — Voice, Intent & 9Router" (section 7), "Person 2 — Voice/LLM" (section 10), "11. AWS, 9Router, and budget boundaries"
- **Branch:** `person-2/<topic>` - **Placeholder handle:** `@atlas-person-2`

## Person 3 - UI & Animated Character

- **Folder they own:** `workstreams/person-3-ui-character/`
- **Also owns:** `apps/desktop-ui/**` including the Tauri 2 shell `src-tauri/` (`tauri.conf.json` changes also need project-owner approval)
- **Specialist PRD:** `04-person-3-ui-character-prd.md` -> `workstreams/person-3-ui-character/prd/`
- **Sections:** Master "5. Goals, Non-Goals, and Delivery Boundaries"; Master 6 "FR-05 — Plan preview", "FR-09 — Cancellation and timeouts", "FR-12 — Animated character and UI", "FR-14 — Privacy disclosure"; Master "8.3 Trust boundaries"; Master "9.1 Proposed stack"; Master "10.2 Task status", "10.3 Typed events"; Master "11. UI and Animated Character Requirements"; Common "4.2 Task states", "4.3 Event contract", "4.4 API semantics"; Common "Person 3 — UI & Animated Character" (section 7), "Person 3 — UI" (section 10)
- **Branch:** `person-3/<topic>` - **Placeholder handle:** `@atlas-person-3`

## Person 4 - AWS, QA & End-to-End Integration

- **Folder they own:** `workstreams/person-4-aws-qa-integration/`
- **Also owns:** `services/atlas-core/tests/integration/`, `docs/test-results/`, `docs/setup-windows.md`
- **Specialist PRD:** `05-person-4-aws-qa-integration-prd.md` -> `workstreams/person-4-aws-qa-integration/prd/`
- **Sections:** Master "5.3 Definition of prototype completion"; Master "9.3 Budget controls"; Master "13. Quality Attributes and Measurement"; Master "14. Testing and Acceptance Strategy"; Master "16. Six-Hour Delivery Plan"; Common "6. Root scripts and environment conventions"; Common "Person 4 — AWS, QA & End-to-End Integration" (section 7); Common section 8 rule 7; Common "Person 4 — AWS/QA/integration" and "Whole product" (section 10); Common "11. AWS, 9Router, and budget boundaries"
- **Branch:** `person-4/<topic>` - **Placeholder handle:** `@atlas-person-4`

## Project owner (you)

Owns everything else: root files, `packages/contracts/`, `scripts/`, `.github/`, shared backend core, other `docs/`. Before handing off:

1. Replace the placeholder handles in `.github/CODEOWNERS` and `OWNERSHIP.json`.
2. Push to GitHub, create `integration`, apply `docs/BRANCH_PROTECTION.md`.
3. Answer the OPEN items in `docs/decisions.md`.
4. Send each person their row above.
