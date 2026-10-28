# Local API contract (Common PRD 4.4)

Owner: project owner. Changes follow `packages/contracts/INSTRUCTIONS.md`.

The desktop UI calls the local backend at `http://127.0.0.1:8765` (`ATLAS_HOST`/`ATLAS_PORT`). The backend binds to localhost only. Payloads use `packages/contracts/`.

| Method | Path | Purpose | Body / response |
|---|---|---|---|
| POST | `/api/v1/tasks/plan` | Submit a text request (or final transcript) for planning | Request: `{ "userRequest": string }`. Response: `{ "taskId", "status" }` |
| POST | `/api/v1/tasks/{taskId}/confirm` | Approve the exact plan the user reviewed | Request: `{ "planDigest": string }` (from the `plan_ready` / `confirmation_required` event). Rejected if the plan changed since review. |
| POST | `/api/v1/tasks/{taskId}/cancel` | Cancel; no further steps run | Response: `{ "taskId", "status" }` |
| GET | `/api/v1/tasks/{taskId}` | Current task state (polling fallback) | `{ "taskId", "status": TaskStatus, "plan"?: TaskPlan, "events": AtlasEvent[] }` |
| GET | `/api/v1/health` | Liveness and mode | `{ "status": "ok", "mockMode": boolean }` |
| GET | `/api/v1/tasks/{taskId}/events` | Event stream (SSE, `docs/decisions.md` D6) | Each SSE `data:` line is one `AtlasEvent` (`events.schema.json`) |

Rules:
- Confirmation applies to the exact plan/version reviewed (`planDigest`). A plan is never silently replaced between review and execution.
- Responses and events never contain API keys, passwords, or unnecessary private content.
- Request/response field names above beyond Common PRD 4.4 are PROPOSED until the project owner accepts them in `docs/decisions.md`.
