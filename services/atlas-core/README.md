OWNER: Project owner (shared backend core) - module owners are listed below

# services/atlas-core - local backend (Python 3.11+)

Binds to `127.0.0.1:8765` by default. API surface: `docs/api-contract.md`. Contracts: `packages/contracts/`.

| Path | Owner |
|---|---|
| `pyproject.toml`, `README.md`, `src/atlas/__init__.py`, `src/atlas/main.py`, `src/atlas/config.py`, `src/atlas/api/`, `src/atlas/models/`, `src/atlas/orchestrator/`, `src/atlas/audit/`, `tests/conftest.py` | Project owner |
| `src/atlas/policy/`, `executor/`, `adapters/`, `verifier/`, `journal/`, `tests/runtime/` | Person 1 - Desktop Runtime & Safety |
| `src/atlas/intent/`, `planner/`, `providers/`, `tests/intent/` | Person 2 - Voice, Intent & 9Router |
| `tests/integration/` | Person 4 - AWS, QA & End-to-End Integration |

Edit only the rows you own. Request anything else by PR to its owner (see `docs/PERMISSIONS.md`).
