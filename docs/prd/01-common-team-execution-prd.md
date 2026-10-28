# PROJECT ATLAS — COMMON REPOSITORY SETUP & PARALLEL TEAM EXECUTION PRD
**Version:** 1.2  
**Date:** 29 October 2026  
**Product:** Project ATLAS — Voice-driven Windows desktop operator  
**Team model:** Project owner prepares the shared starter kit before the sprint; all four developers begin independent implementation in parallel from minute 0  
**Prototype timebox:** 6 hours  
**Budget:** US$100  
**LLM:** 9Router  
**Cloud:** AWS services where required and available  
**Target:** Windows 10/11 x64

> **Purpose of this document:** The project owner (you) will create the repository and common structure before the sprint. There is NO Person 1 assigned to repository foundation or integration. Once the starter kit is ready, all four developers start their own implementation at the same time and continue in parallel for the full sprint. No developer waits for another person to finish before starting. This document defines the shared folder structure, boundaries, contracts, integration rules, and acceptance checklist. The four individual PRDs will contain each person's complete file-by-file implementation instructions, scripts, tests, and checklist.

---

## 1. Team model and ownership

### Before the six-hour sprint — Project owner
You create the repository and shared foundation once, before the four developers start:
- Create the folder structure and add the Master PRD plus this Common PRD.
- Add the shared task-plan, action-registry, and event contracts.
- Add `.gitignore`, `.env.example`, `README.md`, and baseline startup/test scripts.
- Confirm the chosen UI/backend scaffold and the demo workflow.
- Publish the repo URL, branch rules, owner map, and API contract.
- Verify that the skeleton launches in mock mode without AWS or 9Router credentials.

This is setup work performed by the project owner, not a fifth workstream and not one of the four parallel developer roles.

### During the sprint — Four people work in parallel

| Person | Dedicated workstream | Owns | Does not own |
|---|---|---|---|
| Person 1 | Desktop runtime & safety | Windows action adapters, action policy, pre/postcondition verification, cancellation, timeouts, local execution/journal behavior | Root repository structure, shared contracts, overall integration ownership |
| Person 2 | Voice, intent & 9Router | 9Router client, structured plan generation, validation adapter, optional AWS Transcribe/Polly, provider mocks and errors | Windows action execution or UI components |
| Person 3 | UI & animated character | React/TypeScript interface, SVG/CSS 2D character, transcript, plan inspector, consent UI, execution ledger | Policy enforcement or direct Windows automation |
| Person 4 | AWS configuration, QA & end-to-end integration | AWS setup/feature flags, budget checks, integration harness, cross-module testing, demo readiness, setup/test documentation | Rebuilding the root scaffold or independently changing core interfaces without agreement |

**Important:** Person 4 is the integration/QA owner during the sprint, but the project owner remains the maintainer of the repository and shared contracts. Person 4 coordinates tests and reports integration defects; feature owners fix their own code.

---

## 2. What this Common PRD governs

This document defines:
- One repository and the canonical folder layout.
- The four workstream ownership boundaries.
- Shared interfaces that all four workstreams must use.
- How the team works in parallel without duplicating modules.
- How integration, testing, and demo readiness are handled.
- Common acceptance criteria and security constraints.

This document does **not** replace the Master PRD or the four specialist PRDs.

### Required PRD set
Store these five files under `docs/prd/`:
1. `00-master-prd.md` — product vision and common product requirements (already exists).
2. `01-common-team-execution-prd.md` — this document.
3. `02-person-1-runtime-safety-prd.md`.
4. `03-person-2-voice-9router-prd.md`.
5. `04-person-3-ui-character-prd.md`.
6. `05-person-4-aws-qa-integration-prd.md`.

There are four specialist PRDs, plus the Master PRD and this Common PRD.

---

## 3. Canonical repository structure

Create the repository before assigning work. Keep one shared repo and one canonical location for each production module.

```text
project-atlas/
├── README.md
├── CONTRIBUTING.md
├── .gitignore
├── .env.example
├── .editorconfig
├── package.json
├── pnpm-workspace.yaml
├── tsconfig.base.json
├── apps/
│   └── desktop-ui/                         # Person 3
│       ├── package.json
│       ├── index.html
│       ├── vite.config.ts
│       ├── tsconfig.json
│       └── src/
│           ├── main.tsx
│           ├── App.tsx
│           ├── app/
│           ├── components/
│           │   ├── Character/
│           │   ├── CommandBar/
│           │   ├── TranscriptPanel/
│           │   ├── PlanInspector/
│           │   ├── ConfirmDialog/
│           │   ├── ExecutionLedger/
│           │   └── StatusBanner/
│           ├── services/
│           │   ├── atlasClient.ts
│           │   └── mockClient.ts
│           ├── hooks/
│           ├── styles/
│           └── types/
├── services/
│   └── atlas-core/                         # Shared local backend
│       ├── pyproject.toml
│       ├── README.md
│       ├── src/
│       │   └── atlas/
│       │       ├── main.py
│       │       ├── api/
│       │       ├── models/
│       │       ├── orchestrator/
│       │       ├── intent/                 # Person 2 integration
│       │       ├── planner/                # Person 2
│       │       ├── policy/                 # Person 1
│       │       ├── executor/               # Person 1
│       │       ├── adapters/               # Person 1
│       │       ├── verifier/               # Person 1
│       │       ├── journal/                # Person 1
│       │       ├── providers/              # Person 2
│       │       │   ├── nine_router.py
│       │       │   ├── aws_transcribe.py
│       │       │   └── aws_polly.py
│       │       ├── audit/
│       │       └── config.py
│       └── tests/
├── packages/
│   └── contracts/                          # Project owner creates before sprint
│       ├── README.md
│       ├── task-plan.schema.json
│       ├── action-registry.json
│       ├── events.schema.json
│       └── examples/
├── workstreams/
│   ├── person-1-runtime-safety/
│   │   ├── README.md
│   │   ├── design/
│   │   ├── tests/
│   │   └── acceptance-checklist.md
│   ├── person-2-voice-9router/
│   │   ├── README.md
│   │   ├── design/
│   │   ├── fixtures/
│   │   ├── tests/
│   │   └── acceptance-checklist.md
│   ├── person-3-ui-character/
│   │   ├── README.md
│   │   ├── design/
│   │   ├── assets/
│   │   ├── tests/
│   │   └── acceptance-checklist.md
│   └── person-4-aws-qa-integration/
│       ├── README.md
│       ├── aws/
│       ├── integration-tests/
│       ├── test-results/
│       └── acceptance-checklist.md
├── docs/
│   ├── prd/
│   │   ├── 00-master-prd.md
│   │   ├── 01-common-team-execution-prd.md
│   │   ├── 02-person-1-runtime-safety-prd.md
│   │   ├── 03-person-2-voice-9router-prd.md
│   │   ├── 04-person-3-ui-character-prd.md
│   │   └── 05-person-4-aws-qa-integration-prd.md
│   ├── architecture.md
│   ├── api-contract.md
│   ├── threat-model.md
│   ├── decisions.md
│   ├── setup-windows.md
│   └── test-results/
├── scripts/
│   ├── setup.ps1
│   ├── dev.ps1
│   ├── test.ps1
│   ├── lint.ps1
│   ├── check-secrets.ps1
│   └── verify-repo.ps1
└── .github/
    └── workflows/
        └── ci.yml
```

### Folder ownership rules
- **Person 1:** Runtime-owned production modules: `policy/`, `executor/`, `adapters/`, `verifier/`, and `journal/`; plus `workstreams/person-1-runtime-safety/`.
- **Person 2:** `intent/`, `planner/`, `providers/`, and `workstreams/person-2-voice-9router/`.
- **Person 3:** `apps/desktop-ui/` and `workstreams/person-3-ui-character/`.
- **Person 4:** AWS setup guidance, integration tests, test results, and `workstreams/person-4-aws-qa-integration/`.
- **Project owner:** Root scaffolding, shared contracts, root scripts, canonical API contract, and repository settings. The owner is not assigned to one of the four developer workstreams.

Workstream folders contain work notes, designs, fixtures, tests, and checklists. Production code must not be duplicated under workstream folders.

---

## 4. Shared contracts frozen before parallel work

The project owner must publish these before the sprint. All four people must consume them rather than inventing separate payload formats. If a change is necessary, notify all four and update the contract and examples together.

### 4.1 Task plan
```ts
type RiskTier = "T0" | "T1" | "T2" | "T3";

interface Condition {
  type: string;
  args: Record<string, unknown>;
}

interface ActionStep {
  stepId: number;
  actionType: string;
  arguments: Record<string, unknown>;
  riskTier: RiskTier;
  preconditions: Condition[];
  postconditions: Condition[];
  timeoutMs: number;
  idempotencyKey: string;
}

interface TaskPlan {
  taskId: string;
  userRequest: string;
  summary: string;
  requiresConfirmation: boolean;
  steps: ActionStep[];
}
```

The JSON Schema and `action-registry.json` are authoritative. This TypeScript snippet is explanatory, not an authorization to execute arbitrary action types.

### 4.2 Task states
```ts
type TaskStatus =
  | "QUEUED"
  | "PLANNING"
  | "AWAITING_CONFIRMATION"
  | "RUNNING"
  | "VERIFYING"
  | "CANCELLING"
  | "SUCCEEDED"
  | "FAILED"
  | "PARTIAL"
  | "CANCELLED";
```

### 4.3 Event contract
Events must be versioned and typed:
- `transcript`
- `plan_ready`
- `clarification_required`
- `confirmation_required`
- `step_started`
- `verification_passed`
- `verification_failed`
- `task_completed`
- `task_failed`
- `task_cancelled`
- `provider_error`

Each event must include `schemaVersion`, `taskId`, `timestamp`, and a typed payload. Never include API keys, passwords, or unnecessary private content.

### 4.4 API semantics
The team should use the existing scaffold's transport if one already works. If a REST API is selected, the minimum interface is:
- `POST /api/v1/tasks/plan`
- `POST /api/v1/tasks/{taskId}/confirm`
- `POST /api/v1/tasks/{taskId}/cancel`
- `GET /api/v1/tasks/{taskId}`
- `GET /api/v1/health`
- One documented event stream or polling mechanism.

Confirmation must apply to the exact plan/version the user reviewed. A plan must not be silently replaced between review and execution.

---

## 5. Project-owner setup checklist (complete before the sprint)

### Repository
- [ ] Create one Git repository named `project-atlas`.
- [ ] Add the existing Master PRD as `docs/prd/00-master-prd.md`.
- [ ] Add this document as `docs/prd/01-common-team-execution-prd.md`.
- [ ] Create all canonical folders from Section 3.
- [ ] Add `README.md`, `CONTRIBUTING.md`, `.gitignore`, `.env.example`, and `.editorconfig`.
- [ ] Add the shared JSON schemas and sample payloads.
- [ ] Add a minimal backend health endpoint and a minimal UI shell, or confirm the existing scaffold starts.
- [ ] Make mock mode work without cloud credentials.
- [ ] Add the root setup/dev/test/lint/secret-scan scripts.
- [ ] Verify the repository starts from a clean clone.
- [ ] Push the baseline commit and share the repo URL.

### Shared decisions
- [ ] Confirm Windows-only scope for v1.
- [ ] Choose one demo workflow.
- [ ] Confirm the UI/backend transport and payload formats.
- [ ] Confirm 9Router is allowed as an external LLM provider.
- [ ] Confirm AWS region and service access only if cloud features are needed.
- [ ] Confirm the allowed app list and approved test directory.
- [ ] Set the maximum budget threshold and who checks spend.
- [ ] Share the owner map and branch strategy.

**Parallel-start rule:** The project owner prepares and smoke-tests the contracts, folders, mock mode, and startup instructions before Hour 0. At Hour 0, all four developers begin implementation simultaneously. If any starter-kit item is incomplete, each developer uses the documented contract and local mocks; nobody waits idle for another workstream.

---

## 6. Root scripts and environment conventions

These scripts are created by the project owner before the sprint. Person 4 may run them and propose fixes, but should not need to build the repository foundation during the six-hour sprint.

### `scripts/setup.ps1`
Must:
1. Check Git, Node.js, the selected package manager, and Python are available.
2. Install frontend dependencies and backend dependencies.
3. Create a Python virtual environment if required.
4. Copy `.env.example` to `.env` only when `.env` does not already exist.
5. Never overwrite an existing `.env`.
6. Never print secret values.
7. Exit with a clear error if a required tool is missing.

### `scripts/dev.ps1`
Must:
1. Start the local backend and UI dev server.
2. Print the local UI and backend health URLs.
3. Indicate mock mode when provider credentials are absent.
4. Bind the backend to `127.0.0.1` by default.
5. Stop spawned child processes where possible.

### `scripts/test.ps1`
Must run schema checks, backend tests, available frontend tests, and the agreed integration test. It must return a non-zero exit code if required checks fail.

### `scripts/lint.ps1`
Must run configured TypeScript and Python lint/format checks. Any skipped check must be reported explicitly.

### `scripts/check-secrets.ps1`
Must detect likely secrets and tracked `.env` files, print file/line references only (never secret values), and fail on likely findings. A basic regex scan is a safety net, not a guarantee.

### `scripts/verify-repo.ps1`
Must verify required folders/files, parse shared schemas, run tests and secret checks, and print a concise pass/fail summary.

### `.env.example`
```dotenv
APP_ENV=development
ATLAS_MOCK_MODE=true
ATLAS_HOST=127.0.0.1
ATLAS_PORT=8765
AWS_REGION=ap-south-1
AWS_TRANSCRIBE_ENABLED=false
AWS_POLLY_ENABLED=false
NINE_ROUTER_BASE_URL=
NINE_ROUTER_MODEL=
NINE_ROUTER_API_KEY=
ATLAS_ALLOWED_DIRS=
ATLAS_ALLOWED_APPS=
ATLAS_LOG_LEVEL=INFO
```

### `.gitignore`
Must ignore `.env`, `.env.*` except `.env.example`, virtual environments, `node_modules/`, build outputs, Python caches, logs, local databases, recordings, private screenshots, and generated user data.

---

## 7. Four parallel workstreams

### Person 1 — Desktop Runtime & Safety
**Owns:** Windows action adapter, allowlist, risk policy, target validation, preconditions/postconditions, cancellation, timeouts, and compensation behavior where safe.

**Must produce:** A small supported action set, unit tests, mock adapter, failure taxonomy, and workstream checklist.

**Must not:** Add arbitrary shell execution, automate credentials, or bypass plan validation.

### Person 2 — Voice, Intent & 9Router
**Owns:** 9Router provider adapter, structured-plan generation, JSON/schema validation, bounded retries/timeouts, and optional Transcribe/Polly integration.

**Must produce:** Provider configuration, request/response interface, mock fixtures, redacted logging, and provider-failure tests.

**Must not:** Put API keys in the UI, invent action permissions, or execute model output.

### Person 3 — UI & Animated Character
**Owns:** React/TypeScript UI, command input, transcript, plan inspector, confirmation dialog, execution ledger, status banners, and SVG/CSS 2D character.

**Must produce:** All components, shared event handling, state mapping, accessible controls, reduced-motion support, and UI tests.

**Must not:** Fake success in live mode or directly perform Windows automation.

### Person 4 — AWS, QA & End-to-End Integration
**Owns:** AWS feature flags and configuration guidance, cost checks, provider mock setup, integration harness, end-to-end testing, test evidence, and final demo readiness.

**Must produce:** A repeatable end-to-end test, negative test cases, a test-results report, and the final prototype acceptance checklist.

**Must not:** Rebuild the repository foundation, change shared contracts without agreement, or provision expensive resources without explicit owner approval.

---

## 8. How parallel work avoids conflicts

1. **Shared contracts first:** The project owner freezes the schemas before Hour 0 so all four can start together.
2. **Separate ownership:** Each person changes their owned production modules and dedicated workstream folder.
3. **Mock interfaces:** Each workstream can progress using the shared interface and fixture data without waiting for another person's implementation.
4. **No duplicate implementations:** Workstream folders hold tests/design/notes; canonical production code stays under `apps/` and `services/`.
5. **Small commits:** Each developer commits a working increment every 30–45 minutes.
6. **Contract changes:** Notify all affected owners, update schema plus examples, and test compatibility before merging.
7. **Integration is continuous, not a final handoff:** Person 4 writes and runs the integration harness from Hour 0 using mock implementations. Each feature owner independently supplies a contract-compatible implementation and fixes defects in their own module. Person 4 never becomes a queue that everyone must wait for.
8. **Project owner authority:** The project owner controls repository permissions, baseline contracts, and final acceptance.
9. **No dependency blocking:** Every workstream must have a local mock/stub and tests from the start; live cloud credentials and another person’s unfinished code must not block progress.
10. **Final-hour freeze:** No new features in the last hour; fix blockers and verify the demo.

Suggested branch names:
- `feature/person-1-runtime`
- `feature/person-2-voice`
- `feature/person-3-ui`
- `feature/person-4-integration`

Use short-lived branches and merge into the shared integration branch frequently. If the six-hour deadline makes pull requests too slow, use direct commits to a shared integration branch only if the team has agreed on ownership and can avoid simultaneous edits to shared files.

---

## 9. Six-hour parallel execution schedule — all four active throughout

### Before Hour 0 — Project owner prepares the starter kit
The owner creates the repository, canonical folders, shared contracts and examples, baseline startup/test scripts, mock mode, and the selected demo workflow. This work is completed before the timed sprint and is not assigned to any developer.

### Hour 0–0:15 — Simultaneous kickoff
All four developers clone the same repo, read the ownership map, run the baseline in mock mode, and start their assigned work immediately. The kickoff is not a separate phase that delays implementation.

### Hour 0:15–2:00 — Four-way parallel implementation
- **Person 1:** Implement the runtime/policy/executor/verifier against a fake action adapter first; add the smallest safe real Windows action only after mock tests pass.
- **Person 2:** Implement the planner/provider interface, 9Router client, strict schema validation, and deterministic fixture planner. Live provider access is optional.
- **Person 3:** Implement the complete UI against mock API responses and event fixtures; do not wait for the real backend.
- **Person 4:** Implement integration tests, mock server/fixtures, AWS feature flags and cost checks, and a pass/fail test report from the shared contracts; do not wait for feature code.

**Checkpoint at Hour 2:** Each person demonstrates an independently testable slice. A missing dependency must be replaced by a stub/mock, not a reason to stop.

### Hour 2:00–3:30 — Continue parallel development + contract-level connection
All four keep working in their owned files:
- Person 1 exposes a stable runtime interface and publishes a runnable fake-action test.
- Person 2 exposes a stable planner interface and publishes valid/invalid plan fixtures.
- Person 3 swaps mock data for the available API client only when the interface is ready; retains mock fallback.
- Person 4 runs contract tests continuously, records failures, and sends each defect to the owner of that module.

The project owner resolves only cross-boundary contract decisions. No person takes over another person's work by default.

**Checkpoint at Hour 3:30:** UI-to-planner-to-policy path works with mocks, or each missing connection has a reproducible issue and a mock-backed fallback.

### Hour 3:30–4:45 — Parallel hardening
- Person 1 tests unsupported actions, ambiguous targets, timeout, cancellation, and verification failures.
- Person 2 tests provider outage, malformed output, retries/timeouts, and secret redaction.
- Person 3 tests loading/error/blocked/success states, consent flow, keyboard accessibility, and reduced motion.
- Person 4 runs end-to-end and negative tests, secret scans, build checks, and AWS budget/configuration checks.

**Checkpoint at Hour 4:45:** Stop feature expansion. List blockers and identify the smallest reliable demo path.

### Hour 4:45–5:00 — Feature freeze (all four)
Each person commits a stable increment, updates their checklist, and reports what works, what is mocked, and known defects. No new features.

### Hour 5:00–6:00 — Parallel fixes and shared demo validation
- Each developer fixes only their owned modules.
- Person 4 reruns the integration suite after each merge and reports exact failing tests.
- Person 3 prepares the UI demo states using the real path where available and mock fallback otherwise.
- Person 2 verifies the provider can fail safely without bypassing validation.
- Person 1 verifies that no unapproved action executes and that the displayed result comes from verification.
- The project owner reviews scope, limitations, secrets, and budget.

**Definition of done:** One selected task works end-to-end with verification and honest failure reporting, or the demo clearly labels any mocked segment. Also demonstrate one blocked unsafe request and one failure/cancel path. This is a prototype, not proof of universal production-ready desktop control.

---

## 10. Common acceptance checklist

### Project owner baseline
- [ ] Master PRD and Common PRD committed.
- [ ] Four specialist PRD files have been generated and placed in `docs/prd/`.
- [ ] Canonical folders and four workstream folders exist.
- [ ] Shared schemas and examples are present.
- [ ] `.env.example` and `.gitignore` are safe.
- [ ] Setup/dev/test/lint/secret-check scripts work.
- [ ] Mock mode runs without AWS or 9Router credentials.
- [ ] Repository starts from a clean clone.

### Person 1 — Runtime
- [ ] Only registered actions can execute.
- [ ] Unsupported paths/apps/actions are rejected.
- [ ] Preconditions and postconditions are checked.
- [ ] Failure does not become a success message.
- [ ] Cancellation prevents future steps.
- [ ] Tests cover timeout, missing target, stale selector, and duplicate request.

### Person 2 — Voice/LLM
- [ ] 9Router is called from backend only.
- [ ] Structured output is schema-validated.
- [ ] Unknown actions and invalid JSON are rejected.
- [ ] Provider timeouts and bounded retries work.
- [ ] No secrets appear in logs.
- [ ] Mock mode and text fallback work.

### Person 3 — UI
- [ ] Command entry and transcript are usable.
- [ ] Plan is visible before execution.
- [ ] Confirmation and cancel controls work.
- [ ] Character reflects real task state.
- [ ] Success, failed, partial, and cancelled states differ.
- [ ] Keyboard navigation and reduced-motion basics work.

### Person 4 — AWS/QA/integration
- [ ] AWS services are feature-flagged and optional.
- [ ] Region/access/quotas are checked before use.
- [ ] AWS and 9Router costs are tracked separately.
- [ ] Integration test covers plan → approval → action → verification.
- [ ] Negative tests and test results are recorded.
- [ ] No expensive resource is provisioned without owner approval.

### Whole product
- [ ] One supported task completes and is verified.
- [ ] One unsafe or unsupported action is blocked.
- [ ] One failure/cancellation path is demonstrated.
- [ ] No arbitrary shell execution is exposed to the LLM.
- [ ] No credential/MFA automation exists.
- [ ] No secrets are committed.
- [ ] No claim of perfect or universal app control is made.
- [ ] Known limitations are written down.

---

## 11. AWS, 9Router, and budget boundaries

- Use AWS for optional speech services and justified cloud infrastructure.
- Use 9Router for LLM requests only if the project owner approves it as an external provider exception.
- If the requirement is that all inference/data processing remain within AWS, 9Router must be replaced by an AWS-hosted model endpoint.
- Desktop automation runs locally. Do not stream the entire desktop to cloud services by default.
- Confirm AWS service availability, region, credentials, and current billing/credit eligibility before testing.
- Keep cloud services off by default in mock mode.
- Avoid GPU instances, always-on compute, NAT Gateway, and provisioned inference capacity for the six-hour prototype.
- Set budget alerts where available, but do not treat alerts as a guaranteed hard spending cap.
- Never commit API keys or include them in the UI bundle.

## 12. Product safety constraints

1. The LLM may propose a plan but cannot authorize it.
2. The local backend policy engine is authoritative.
3. Unknown or ambiguous targets must stop safely.
4. Risk tiers cannot be lowered by model output.
5. No automated password, MFA, or secret entry.
6. No silent sending, purchasing, publishing, or destructive action.
7. Do not promise complete rollback for irreversible or remote effects.
8. Do not assume a Windows virtual desktop is a security sandbox.
9. A 2D SVG/CSS character is enough; no 3D model is needed.
10. The six-hour goal is a narrowly scoped working prototype, not a universally capable production product.

## 13. Required output from each specialist PRD

Each of the four individual PRDs must be detailed enough for its owner to implement without inventing missing interfaces. It must include:
- Exact ownership boundaries.
- Every file to create or modify and its path.
- The complete implementation sequence.
- Code/script responsibilities and interfaces.
- Configuration variables.
- Dependencies on shared contracts.
- Unit and failure-injection tests.
- Manual run instructions.
- A workstream-specific checklist.
- Expected commits and integration handoff.
- Explicit out-of-scope items and known limitations.

The specialist PRDs must be consistent with this Common PRD and the existing Master PRD.

## 14. Final instruction

The project owner prepares the starter kit before the sprint. From Hour 0, all four developers work simultaneously and independently: Person 1 on runtime safety, Person 2 on voice/9Router, Person 3 on UI/character, and Person 4 on AWS/QA/integration. Every workstream starts with mocks and contract tests, so nobody waits for another person to finish.

**No developer is assigned to repository foundation. No one waits for a fifth teammate. The project owner maintains the shared baseline, and the four developers deliver independent, testable slices against the frozen contracts.**
