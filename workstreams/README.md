OWNER: Project owner - do not edit without owner approval

# workstreams/ - one working folder per person

Each folder belongs to exactly one person. Only that person edits it; anyone else needs that person's approval in PR review. Each person also owns specific production paths, listed in their `INSTRUCTIONS.md` and in `OWNERSHIP.json`.

| Folder | Owner | Placeholder handle | Branch prefix | Also owns |
|---|---|---|---|---|
| [`person-1-runtime-safety/`](person-1-runtime-safety/INSTRUCTIONS.md) | Person 1 - Desktop Runtime & Safety | `@atlas-person-1` | `person-1/` | `services/atlas-core/src/atlas/{policy,executor,adapters,verifier,journal}/`, `services/atlas-core/tests/runtime/` |
| [`person-2-voice-9router/`](person-2-voice-9router/INSTRUCTIONS.md) | Person 2 - Voice, Intent & 9Router | `@atlas-person-2` | `person-2/` | `services/atlas-core/src/atlas/{intent,planner,providers}/`, `services/atlas-core/tests/intent/` |
| [`person-3-ui-character/`](person-3-ui-character/INSTRUCTIONS.md) | Person 3 - UI & Animated Character | `@atlas-person-3` | `person-3/` | `apps/desktop-ui/**` incl. the Tauri shell (`src-tauri/tauri.conf.json` also needs project-owner approval) |
| [`person-4-aws-qa-integration/`](person-4-aws-qa-integration/INSTRUCTIONS.md) | Person 4 - AWS, QA & End-to-End Integration | `@atlas-person-4` | `person-4/` | `services/atlas-core/tests/integration/`, `docs/test-results/`, `docs/setup-windows.md` |

Everything else (root files, `packages/contracts/`, `scripts/`, `.github/`, shared backend core, other docs) belongs to the project owner (`@atlas-project-owner`).

Every working folder has the same layout: `README.md`, `INSTRUCTIONS.md`, `acceptance-checklist.md`, `prd/`, `src/`, `tests/`, `docs/`, plus workstream-specific folders.
