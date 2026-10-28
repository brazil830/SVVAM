# Threat model (summary of Master PRD 8.3 and section 12)

Owner: project owner.

Scope: the Windows desktop app (Tauri 2 shell + React UI), the local Python backend on `127.0.0.1`, and outbound calls to 9Router and optional AWS Transcribe/Polly.

## Trust boundaries

| Boundary | Rule | Owner of the control |
|---|---|---|
| LLM output -> backend | The LLM is a planner, not an authority; output is schema-validated and checked against `action-registry.json`; never executed directly | Person 2 (validation), Person 1 (policy) |
| UI / Tauri shell -> backend | The frontend is not a security boundary; the backend re-checks every request | Person 1 (policy), project owner (API) |
| Desktop content -> planner | Text from web pages, documents, files, OCR, or clipboard is untrusted data | Person 2 |
| Cloud responses -> backend | Untrusted until validated | Person 2 |
| Backend -> network | Binds to `127.0.0.1` only | Project owner |
| Secrets | Never sent to the LLM, the UI, logs, or events; only in `.env` (git-ignored) | Everyone; `scripts/check-secrets.ps1` |

## Blocked actions (Master PRD section 7)

Password/MFA entry, arbitrary shell execution, UAC/security bypass, unrestricted deletion, sending/posting, purchases, security-setting changes. Recorded in `packages/contracts/action-registry.json` -> `blocked`.

## Reliability rules

A timeout never triggers blind replay of an action that may already have succeeded. Failure is never reported as success. Cancellation prevents future steps.

## Future work (Master PRD section 17)

Stage C adds disposable-VM tests, prompt-injection testing, dependency scanning, and installer signing; Stage D adds independent security review.
