# PROJECT ATLAS — MASTER PRODUCT REQUIREMENTS DOCUMENT (PRD)
**Document type:** Common / Main PRD  
**Version:** 1.0  
**Date:** 29 October 2026  
**Product:** Autonomous Task Layer for Application Systems (ATLAS)  
**Target platform:** Microsoft Windows 10/11 x64  
**Team:** 4 members  
**Prototype timebox:** 6 hours  
**Budget:** US$100  
**LLM:** 9Router  
**Cloud services:** AWS services where useful and available  
**Character:** Source-code-driven 2D animation; no 3D model required

> **Document relationship:** This is the primary product document that all team members must read first. It defines the shared vision, scope, system boundaries, architecture, shared contracts, acceptance criteria, and integration rules. Keep the four specialist PRDs and this master PRD as five separate documents. Specialist PRDs add implementation detail; they must not contradict this document without an agreed decision recorded in `docs/decisions.md`.

---

## 1. Executive Summary

Project ATLAS is a Windows desktop assistant that accepts voice or text instructions, interprets the user's intent through an LLM accessed using 9Router, creates a structured plan, validates that plan against local safety policies, executes supported desktop actions, verifies the resulting state, and communicates progress through a desktop UI with an animated 2D character.

ATLAS is designed around a key principle:

**The AI may propose actions, but only the local policy-controlled execution runtime may authorize and perform them. Success must be verified from actual system state—not inferred from the model's narrative.**

The system aims to make desktop automation more understandable, safer, more recoverable, and easier to repeat. It must acknowledge uncertainty, ask clarifying questions, require confirmation for risky actions, and stop safely when it cannot establish a valid target or verify the expected result.

The six-hour target is an integrated demonstrable prototype for a narrow, selected workflow. It is not a promise that the full product can be made production-ready or control every application in six hours.

## 2. Problem Statement

Current desktop automation approaches can be brittle, hard to inspect, and unsafe when they misinterpret a request or interact with the wrong application element. Natural-language agents may generate plausible success messages without proving that the requested operation succeeded. Traditional macros may break after application UI changes. Cloud-based systems may also transmit screen or document data that users did not intend to share.

Users need a desktop assistant that:
- Accepts natural voice and text instructions.
- Converts requests into inspectable, structured plans.
- Uses approved mouse, keyboard, Windows UI Automation, and application interfaces.
- Verifies each supported operation using observable system state.
- Makes risky actions visible and requires appropriate user authorization.
- Provides cancellation, clear error states, and recovery where feasible.
- Minimizes sensitive data sent to external services.
- Reuses validated workflows without assuming they remain valid forever.

## 3. Product Vision and Value Proposition

### Vision
Build a dependable, voice-driven desktop operator that can assist with supported Windows workflows while keeping the user informed and in control.

### Value proposition
“Tell ATLAS what you want done. Review its plan. Approve the actions that need approval. Watch it operate supported desktop workflows, verify the results, and stop it when needed.”

### Differentiators
1. **Plan before action:** Natural-language output is converted into typed, validated action data.
2. **Verification-first:** A task is only successful when its required postconditions pass.
3. **Risk-based authorization:** The local policy engine determines whether an action may run, requires confirmation, or is blocked.
4. **Transparent execution:** The UI shows the plan, current step, verification result, and final status.
5. **Recovery-aware design:** Reversible operations may have compensation steps, while irreversible side effects are identified honestly.
6. **Local desktop control:** Windows interactions happen locally; cloud use is limited to enabled features.
7. **Accessible animated status:** A source-code-driven 2D character communicates real runtime states.

ATLAS does not promise perfect decisions, perfect execution, universal application compatibility, or guaranteed rollback for every action.

## 4. Target Users and Primary Use Cases

### 4.1 Target users
- **Developers:** Open projects, launch approved applications, start development servers, and verify local processes.
- **Students and power users:** Organize files in approved folders, inspect desktop state, and automate routine workflows.
- **Privacy-conscious users:** Understand what context is sent to cloud services and keep control over desktop operations.
- **Future enterprise users:** Potentially use auditable automation after the security, compatibility, and deployment controls have been independently reviewed.

### 4.2 Candidate use cases
- Open an allowlisted application and verify its window exists.
- Open a project folder and launch a development tool.
- Enter non-sensitive text into a confirmed, non-password field.
- Organize files within a specifically approved test folder, with a visible preview and recovery plan.
- Use voice to request a task and review the interpreted plan before execution.
- Replay a previously validated workflow when its preconditions and target selectors still match.

### 4.3 Six-hour demonstration use case
Select one small workflow before implementation. Recommended example:

> “Open the approved editor for the configured demo project and verify that the editor window is available.”

The team may add one other low-risk action only after the primary path is stable. Do not demonstrate destructive, financial, credential, or external-submission actions.

## 5. Goals, Non-Goals, and Delivery Boundaries

### 5.1 Prototype goals
By the end of the six-hour sprint:
- A user can submit a text command.
- The backend can produce or load a schema-valid action plan.
- The UI shows the interpretation and plan before execution.
- The backend validates actions against an allowlist and risk policy.
- At least one safe Windows action executes and has a machine-checkable verification result.
- The UI displays real backend states through the 2D animated character and execution ledger.
- Cancellation and at least one failure case are demonstrated.
- The system has a typed-input fallback when voice or cloud providers are unavailable.
- The repository includes all five PRDs, shared contracts, setup instructions, and known limitations.

Voice, AWS speech services, and live 9Router access are integrated only if credentials, account access, and the working scaffold are available. Mock mode must be clearly labeled.

### 5.2 Explicit non-goals for the six-hour prototype
- Guaranteed control of every Windows application.
- Perfect reasoning or zero-error execution.
- Unrestricted shell or PowerShell execution.
- Automated password, MFA, or credential entry.
- Silent sending, purchasing, posting, or external submission.
- Guaranteed rollback of irreversible or remote side effects.
- Full secure sandboxing of every desktop app.
- Production certification, enterprise compliance claims, or a security-audit claim.
- Training a custom foundation model.
- Creating or rigging a 3D character.
- Building complex AWS infrastructure that is not required for the demo.

### 5.3 Definition of prototype completion
The prototype is complete only when the selected end-to-end workflow works from a fresh application start, the action result is verified, the UI reports the real result, cancellation is available, and the team documents failures and unsupported capabilities.

## 6. Product Scope and Functional Requirements

### FR-01 — Voice and text input
ATLAS shall accept text commands. Voice input may be provided through Amazon Transcribe when enabled and available. Text mode must remain usable if microphone access, AWS credentials, network access, or speech services fail.

### FR-02 — Intent compilation
The system shall turn a user request into a typed, structured task plan. LLM output is untrusted and must be validated locally. Natural-language model output must never be executed directly.

### FR-03 — Shared action registry
Every executable action shall be registered with a documented schema, allowed arguments, risk tier, preconditions, postconditions, timeout, and failure behavior. Unknown action types must be rejected.

### FR-04 — Target resolution and clarification
The system shall resolve requested applications and UI targets only from supported evidence. If the target is ambiguous, unavailable, or inaccessible, ATLAS shall ask a question or halt rather than guess.

### FR-05 — Plan preview
Before a mutating action begins, the UI shall show the user a summary and ordered steps. The plan shall identify affected targets and any required confirmation.

### FR-06 — Risk-based authorization
The backend policy engine shall classify actions and enforce authorization independently of the UI and LLM.

### FR-07 — Desktop execution
The local runtime shall execute supported actions using the safest available interface: app-specific API or CLI where appropriate, Windows UI Automation for accessible controls, and coordinate-based input only as a clearly identified fallback.

### FR-08 — Preconditions and postconditions
Every executable action must have machine-checkable preconditions and postconditions. A task cannot be marked successful merely because the LLM says it succeeded.

### FR-09 — Cancellation and timeouts
Users shall be able to cancel a task. The runtime must stop dispatching future steps after cancellation is accepted and must request termination of the current action where supported. UI states must distinguish cancellation requested from cancellation confirmed.

### FR-10 — Recovery and compensation
For operations with a reliable inverse, the runtime may record a compensation action before mutation. Recovery must report partial success honestly. The product must not promise full rollback for actions that cannot be undone.

### FR-11 — Execution ledger
The system shall record task state transitions, action decisions, consent, verification results, durations, and errors. Sensitive values and secrets must be redacted.

### FR-12 — Animated character and UI
The UI shall use an original source-code-driven 2D character. Animation shall reflect actual backend events and support idle, listening, thinking, executing, approval-required, success, error, and cancelled states.

### FR-13 — Cloud provider integrations
AWS services and 9Router integrations shall be feature-flagged, timeout-bounded, and able to fail gracefully. Provider credentials must not be embedded in the frontend bundle or committed to the repository.

### FR-14 — Privacy disclosure
The UI and documentation shall explain which features use cloud services and what data is transmitted. Screenshots, clipboard contents, document contents, and complete window titles must not be transmitted by default.

### FR-15 — Workflow reuse
Validated workflows may be saved and replayed only after their preconditions, target selectors, permissions, and expected postconditions are revalidated.

## 7. Risk and Permission Model

The risk tier is assigned and enforced by local code. The model cannot lower a tier or grant itself permission.

| Tier | Description | Required behavior |
|---|---|---|
| T0 | Read-only inspection | May run after schema and scope validation |
| T1 | Narrow, low-impact action | Run within approved scope; log and verify result |
| T2 | Broad or potentially disruptive mutation | Show affected targets/diff and require explicit consent |
| T3 | Irreversible, external, credential-related, or security-sensitive action | Block in prototype or require a separately designed, explicit authorization flow |

### Minimum blocked actions for prototype
- Entering passwords, MFA codes, or secret tokens.
- Bypassing UAC or other OS security controls.
- Arbitrary shell/PowerShell execution selected by the LLM.
- Unrestricted deletion or overwriting of user files.
- Sending messages, emails, forms, or posts.
- Purchases, payment confirmations, and security-setting changes.
- Any action whose target or effect cannot be explained and validated.

## 8. High-Level Architecture

### 8.1 Components
1. **Desktop UI:** React + TypeScript interface, command entry, transcript, plan inspector, consent dialog, execution ledger, and animated character.
2. **Local orchestration backend:** Receives requests, manages task state, calls providers, validates plans, and coordinates execution.
3. **Intent and plan adapter:** Calls 9Router using a constrained prompt and parses structured output.
4. **Policy and capability registry:** Validates action type, arguments, scope, risk tier, authorization, and allowed targets.
5. **Windows execution adapters:** Implement supported app/process/file/UIA operations locally.
6. **Verifier:** Evaluates preconditions and postconditions using real system observations.
7. **Journal and audit ledger:** Records task transitions, evidence, and compensation data with sensitive-value redaction.
8. **Provider adapters:** Optional Amazon Transcribe, Amazon Polly, and 9Router client.
9. **Test harness:** Mock providers, simulated Windows observations, failure injection, and integration tests.

### 8.2 Request flow
1. Capture voice or text.
2. Display the recognized or entered request.
3. Gather only necessary, permitted desktop context.
4. Ask 9Router for a structured plan when configured, or use a clearly marked fixture in mock mode.
5. Validate schema, supported actions, targets, paths, risk tiers, preconditions, and postconditions.
6. Ask for clarification if the target is ambiguous.
7. Request confirmation when required.
8. Execute one action at a time through the local runtime.
9. Verify each action's postcondition.
10. Stop or perform only a bounded, pre-authorized recovery when a step fails.
11. Record the outcome and display verified status.
12. Update the animated character from actual backend events.

### 8.3 Trust boundaries
- The LLM is a planner, not an authority.
- The backend policy engine is the authorization boundary.
- The frontend is not a security boundary.
- Text from webpages, documents, files, OCR, or clipboard is untrusted data.
- Secrets are never passed to the LLM.
- Cloud provider responses are untrusted until validated.
- A timeout must not trigger blind replay of an action that may already have succeeded.

## 9. Technology and Cloud Constraints

### 9.1 Proposed stack
- **UI:** React + TypeScript + Vite.
- **Desktop packaging:** Use the existing scaffold. Tauri 2 is suitable if already configured; do not migrate frameworks during the six-hour sprint.
- **Local backend:** Python 3.11+ with a small typed API and a single execution path.
- **Windows control:** Windows UI Automation or a suitable maintained library; prefer semantic controls over coordinates.
- **Voice-to-text:** Amazon Transcribe, optional.
- **Text-to-speech:** Amazon Polly, optional.
- **LLM:** 9Router, called from the backend only.
- **Configuration:** Environment variables for local development; appropriate secret management for hosted workloads.
- **Tests:** Unit tests, provider mocks, and a single end-to-end Windows scenario.
- **Character:** SVG/CSS 2D source-code animation.

### 9.2 AWS-only interpretation
The team intends to use AWS for cloud services and 9Router for the LLM. These requirements need one explicit decision:

- If AWS-only means “AWS for infrastructure and AWS services, with 9Router as the approved external LLM exception,” use the architecture above and disclose that task text is sent to 9Router.
- If AWS-only means “all cloud inference and data processing must remain within AWS,” 9Router is incompatible with that policy and must be replaced by an approved AWS-hosted model endpoint.

Do not claim that 9Router traffic is processed solely by AWS.

### 9.3 Budget controls
The total available budget is US$100. This is a hard planning ceiling, not a guarantee that all services are free.

- Confirm AWS account eligibility, service availability, region, quotas, and 9Router billing before live testing.
- Prefer local development and mock providers until the integrated workflow works.
- Avoid GPU instances, always-on servers, NAT Gateway, provisioned inference capacity, and continuous audio or screen streaming for the prototype.
- Use short audio samples, bounded model output, request timeouts, and limited test runs.
- Configure AWS Budget alerts where available, but remember that alerts are not guaranteed hard spending caps.
- Review AWS and 9Router usage separately.
- Never commit credentials or use a real API key in a frontend bundle.

## 10. Shared Data Contracts

All four workstreams must agree on these contracts before parallel implementation. The exact schemas live under `packages/contracts/`.

### 10.1 Task plan
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

The example is a contract outline, not permission to support arbitrary action types. The backend registry defines which action types are actually executable.

### 10.2 Task status
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

### 10.3 Typed events
Minimum events:
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

Each event must include a task identifier, timestamp, and schema version. Do not include secrets or unnecessary private content.

### 10.4 Provider interface
Each provider adapter must expose bounded requests, timeouts, typed success/error results, and redacted logging. Provider-specific failures must not bypass policy validation or turn a failed task into a success.

## 11. UI and Animated Character Requirements

### Main interface
- Command input with push-to-talk control when voice is enabled.
- Visible microphone/listening status.
- Transcript preview and correction.
- Plan inspector with ordered steps and risk levels.
- Explicit Continue/Cancel dialog when needed.
- Execution ledger with actual status and verification evidence.
- Clear connection and provider error states.
- Cancel control while a task is active.
- Settings for approved apps/directories and cloud feature flags.

### Character states
- `idle`: subtle breathing/bob and occasional blink.
- `listening`: gentle sound-wave or pulse effect.
- `thinking`: restrained eye movement or animated dots.
- `executing`: progress indication.
- `approval_required`: still pose with clear decision controls.
- `success`: short positive animation, then idle.
- `error`: clear, restrained error pose and text.
- `cancelled`: motion settles and cancellation is confirmed.

The character must never display success solely because the LLM produced a success sentence. Respect reduced-motion preferences and keyboard accessibility.

## 12. Security, Privacy, and Reliability Requirements

### Security
- Validate every incoming action and provider response.
- Enforce a strict action allowlist and approved path/application scope.
- Use authenticated local IPC and validate origin/client where applicable.
- Reject arbitrary executable paths and unsupported key combinations.
- Do not allow prompt content to change policy or consent.
- Do not automate credentials or MFA.
- Use least-privilege execution and avoid elevation unless separately justified.
- Redact secrets from logs and errors.
- Pin and scan dependencies where tooling permits.

### Privacy
- Do not continuously stream screenshots or audio to the cloud.
- Send only minimum required request text to 9Router.
- Do not transmit screen, clipboard, or document contents by default.
- Disclose Transcribe, Polly, and 9Router usage.
- Define retention and deletion behavior before collecting persistent user data.

### Reliability
- Every action has a timeout and explicit failure state.
- Retries must be bounded and safe for the action type.
- Idempotency keys or equivalent duplicate prevention are required where applicable.
- Cancellation prevents new steps from being dispatched after the cancellation state is accepted.
- Partial execution must be reported as partial.
- Crash recovery and journal consistency must be tested before production claims.
- Recovery must not invent new permissions or silently broaden scope.

## 13. Quality Attributes and Measurement

The team must measure quality rather than claim perfect performance in advance.

| Attribute | How to measure |
|---|---|
| Plan validity | Percentage of model outputs accepted by schema validation |
| Task correctness | Percentage of supported tasks with verified postconditions |
| Wrong-target safety | Wrong-target events in a labeled test suite |
| Unsafe action rejection | Percentage of disallowed test actions blocked |
| Cancellation | Whether new steps start after cancellation is accepted |
| Recovery | Restoration success and partial-failure rate by action type |
| Latency | P50/P95 end-to-end latency for each supported action category |
| Cost | Estimated provider cost per test task |
| Privacy | Secret scan findings and review of outbound fields |
| UI reliability | Crashes, stuck states, and event/state mismatches |

Performance goals should be set after measuring on documented hardware. Do not promise sub-second execution for every app or a universal emergency-stop latency.

## 14. Testing and Acceptance Strategy

### Unit tests
- Schema validation and unknown-action rejection.
- Risk-tier enforcement and confirmation requirements.
- Argument validation, allowed paths, and allowed applications.
- Pre/postcondition evaluation.
- Secret redaction.
- State transitions, timeout, cancellation, and idempotency.

### Integration tests
- Text request → plan → validation → approval → action → verification → ledger.
- Provider timeout and invalid 9Router JSON.
- AWS provider disabled or unavailable.
- UI reconnect after backend failure.
- App not installed, target missing, stale selector, and inaccessible UIA control.

### Adversarial tests
- Prompt injection embedded in a webpage or document.
- LLM attempts to add an unsupported action.
- LLM attempts to lower risk or bypass confirmation.
- Path traversal or out-of-scope path.
- Duplicate request after a timeout.
- User cancels during a multi-step task.
- External side effect cannot be rolled back.

### Prototype acceptance criteria
- [ ] One supported task works end-to-end from a fresh start.
- [ ] A plan is visible before execution.
- [ ] Unknown actions are rejected.
- [ ] The selected action is verified using actual system state.
- [ ] A failed verification is not shown as success.
- [ ] Cancellation prevents later steps from starting.
- [ ] At least one unsafe/unsupported action is blocked.
- [ ] Voice/cloud failure leaves text mode usable.
- [ ] The 2D character reflects real task events.
- [ ] No secrets are committed or shown in the UI.
- [ ] All five PRDs and the shared contracts are committed.
- [ ] Setup and test instructions work on the team's target Windows machine.
- [ ] Known limitations are documented.

## 15. Monorepo and Team Integration

### Recommended structure
```text
project-atlas/
├── README.md
├── .gitignore
├── .env.example
├── package.json
├── pnpm-workspace.yaml
├── apps/
│   └── desktop-ui/
│       ├── package.json
│       └── src/
│           ├── app/
│           ├── components/
│           │   ├── Character/
│           │   ├── CommandBar/
│           │   ├── PlanInspector/
│           │   ├── ExecutionLedger/
│           │   └── ConfirmDialog/
│           ├── services/
│           └── types/
├── services/
│   └── atlas-core/
│       ├── pyproject.toml
│       ├── atlas/
│       │   ├── api/
│       │   ├── intent/
│       │   ├── planner/
│       │   ├── policy/
│       │   ├── executor/
│       │   ├── adapters/
│       │   ├── verifier/
│       │   ├── journal/
│       │   ├── providers/
│       │   ├── audit/
│       │   └── config.py
│       └── tests/
├── packages/
│   └── contracts/
│       ├── task-plan.schema.json
│       ├── action-registry.json
│       └── events.schema.json
├── docs/
│   ├── prd/
│   │   ├── 00-master-prd.md
│   │   ├── 01-desktop-runtime.md
│   │   ├── 02-voice-intent.md
│   │   ├── 03-character-ui.md
│   │   └── 04-aws-integration-qa.md
│   ├── architecture.md
│   ├── threat-model.md
│   ├── decisions.md
│   └── test-results/
├── scripts/
└── .github/workflows/
```

If the team already has a working scaffold, keep it and adapt the layout rather than losing sprint time to a framework migration.

### Four-person responsibility model
- **Person 1 — Desktop runtime:** Windows adapters, action registry, policy integration, verifier, cancellation.
- **Person 2 — Voice and LLM:** 9Router, structured plans, Transcribe/Polly feature flags, provider errors.
- **Person 3 — UI and character:** React interface, SVG/CSS character, plan preview, confirmation, ledger.
- **Person 4 — Integration and QA:** Shared schemas, mock providers, AWS configuration and budget checks, end-to-end tests, documentation.

All four must read this master PRD first. Each specialist PRD defines the implementation details for its workstream.

### Integration rules
- Freeze shared schemas in the first 20 minutes.
- Keep one canonical execution path; no UI or LLM bypass.
- Use mock providers until access is verified.
- Merge working increments every 30–45 minutes.
- Integrate continuously; do not wait until the final hour.
- One designated integrator resolves cross-module conflicts.
- At the start of the final hour, stop adding features and stabilize the demo.

## 16. Six-Hour Delivery Plan

### Hour 0–1: Scope and contract
- Confirm the existing scaffold, target Windows version, AWS access, and 9Router access.
- Choose one demo workflow.
- Agree on action schema, event contract, risk tiers, and API.
- Create a running UI/backend skeleton and five PRD files.

**Gate:** UI can send a command and receive a typed mock plan.

### Hour 1–2: Parallel implementation
- Runtime: one safe action plus verifier.
- LLM/voice: 9Router client, strict parser, fixture fallback.
- UI: command bar, plan view, character state skeleton.
- Integration: schemas, mocks, test command, secret checks.

**Gate:** Plan displays, but action execution remains gated.

### Hour 2–3: End-to-end safe path
- Wire plan validation and confirmation.
- Connect one Windows action.
- Add timeouts, cancellation, and explicit failure states.

**Gate:** Approved action executes and verifies; rejected action does not execute.

### Hour 3–4: Voice and visual states
- Add Transcribe if account access works.
- Add Polly only if time remains.
- Connect actual backend events to character states.
- Preserve text mode and feature flags.

**Gate:** Cloud failure does not bypass safety or break text mode.

### Hour 4–5: Failure tests
- Test malformed plan, unsupported action, missing app, timeout, cancellation, and duplicate request.
- Run secret scan and build from the agreed startup command.
- Review cloud spend and configuration.

**Gate:** No known critical safety issue remains in the selected demo path.

### Hour 5–6: Freeze and demo
- Stop feature work.
- Restart the app cleanly and run the full workflow.
- Demonstrate one successful task, one blocked task, and one failure/cancel path.
- Record results and known limitations.

**Gate:** Integrated prototype passes the checklist; otherwise label the incomplete path honestly.

## 17. Production Readiness Roadmap

### Stage A — Six-hour prototype
A narrow, integrated, demonstrable workflow with real verification and explicit limitations.

### Stage B — Personal alpha
Expand the action registry, UI Automation coverage, journal recovery, local persistence, and supported-app testing.

### Stage C — Private beta
Add disposable-VM tests, crash recovery, prompt-injection testing, dependency scanning, privacy controls, installer signing, and an application compatibility matrix.

### Stage D — Production candidate
Require independent security review, accessibility review, reliability and latency benchmarks, signed update process, secret rotation, support and incident-response procedures, retention controls, and documented recovery guarantees.

A production label is justified only after evidence from the target environment and threat model—not by the completeness of the PRD.

## 18. Decisions Required Before Implementation

The team must record answers in `docs/decisions.md`:
1. Is v1 Windows-only? Recommended: yes.
2. Is 9Router an approved external LLM exception to AWS-only cloud infrastructure?
3. Which existing desktop scaffold will be retained?
4. What exact safe workflow will be demonstrated?
5. Is Amazon Transcribe enabled in the selected region and account?
6. Is the 9Router key/model available, and what are its usage limits?
7. Which applications and directories are allowlisted?
8. Which actions are blocked entirely in the prototype?
9. Where are logs stored, and what content is redacted?
10. What is the agreed stop-work threshold if AWS or 9Router spend approaches the budget?

## 19. Final Product Principle

ATLAS must not be designed around the claim that an AI can always make the perfect decision. It must be designed so that when the AI is uncertain, wrong, manipulated, or unable to verify an outcome, the system limits damage, explains what happened, and returns control to the user.

**Build the verified execution core first. Expand desktop coverage only when each new action has a defined schema, permission rule, verifier, timeout, and failure behavior.**
