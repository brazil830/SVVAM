# Architecture (summary of Master PRD section 8)

Owner: project owner.

Project ATLAS is **Windows desktop software**. Everything runs on the user's own Windows PC:

```text
+------------------------------- Windows PC ----------------------------------+
|  Desktop app (apps/desktop-ui, Person 3)                                    |
|    Tauri 2 shell (src-tauri/, native window via WebView2)                   |
|      React + TypeScript UI layer (src/)  --HTTP/SSE on 127.0.0.1:8765-->    |
|                                                                             |
|  Local backend (services/atlas-core, Python 3.11+), started with/by the     |
|  desktop app (proposed: Tauri sidecar), bound to 127.0.0.1 only             |
|    api/ + orchestrator/ + models/ + audit/ (project owner)                  |
|    intent/ + planner/ + providers/ (Person 2) --> 9Router, optional AWS     |
|    policy/ + executor/ + adapters/ + verifier/ + journal/ (Person 1)        |
|       adapters/ --> Windows UI Automation --> allowlisted apps              |
+-----------------------------------------------------------------------------+
```

The backend is not a hosted service. It listens on localhost only, is started with the desktop app, and is the only component that calls 9Router or AWS. Windows control uses Windows UI Automation (Master PRD 9.1), preferring semantic controls over coordinates.

## Components (Master PRD 8.1) and owners

| # | Component | Location | Owner |
|---|---|---|---|
| 1 | Desktop UI (and Tauri 2 shell) | `apps/desktop-ui/` | Person 3 |
| 2 | Local orchestration backend | `services/atlas-core/src/atlas/{main.py,config.py,api,models,orchestrator,audit}` | Project owner |
| 3 | Intent and plan adapter | `services/atlas-core/src/atlas/{intent,planner}/` | Person 2 |
| 4 | Policy and capability registry | `services/atlas-core/src/atlas/policy/` + `packages/contracts/action-registry.json` | Person 1 (registry file: project owner) |
| 5 | Windows execution adapters | `services/atlas-core/src/atlas/{executor,adapters}/` | Person 1 |
| 6 | Verifier | `services/atlas-core/src/atlas/verifier/` | Person 1 |
| 7 | Journal and audit ledger | `services/atlas-core/src/atlas/journal/` (Person 1), `audit/` (project owner) | Person 1 / project owner |
| 8 | Provider adapters | `services/atlas-core/src/atlas/providers/` | Person 2 |
| 9 | Test harness | `services/atlas-core/tests/integration/` | Person 4 |

## Request flow (Master PRD 8.2, condensed)

Capture voice/text -> show request -> planner produces a `TaskPlan` (9Router or clearly marked fixture) -> validate schema, registered actions, targets, risk tiers -> clarify if ambiguous -> confirm when required -> execute one action at a time -> verify each postcondition -> stop or bounded recovery on failure -> record and show the verified outcome -> character updates from real backend events.

## Trust boundaries (Master PRD 8.3)

The LLM is a planner, not an authority. The backend policy engine is the authorization boundary; the UI and the Tauri shell are not. Desktop text (web pages, documents, OCR, clipboard) and cloud responses are untrusted. Secrets are never passed to the LLM or the UI. A timeout never triggers blind replay.

Interfaces between components are defined only in `packages/contracts/` and `docs/api-contract.md`.
