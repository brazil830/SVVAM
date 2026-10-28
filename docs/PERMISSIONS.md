# Permissions - who may change what, and how to ask

Owner: project owner.

## The rule

Every path in this repository has exactly one owner (`OWNERSHIP.json`, `.github/CODEOWNERS`). You edit only the paths you own. A change to anyone else's path happens only with that owner's approval in PR review. The project owner controls repository permissions, baseline contracts, and final acceptance (Common PRD section 8 rule 8).

## How it is enforced

Git cannot stop a local edit, so enforcement is layered:

1. **CODEOWNERS + branch protection** (hard gate on GitHub). With "Require review from Code Owners" on `main` and `integration`, a PR that touches your path cannot merge until you approve it. Setup: [BRANCH_PROTECTION.md](BRANCH_PROTECTION.md).
2. **`ownership-check` CI** (`.github/workflows/ownership-check.yml`). Fails a PR from `person-N/...` (or `feature/person-N-...`, `project-owner/...`) that changes files outside that owner's paths, unless the project owner adds the `ownership-override` label after the affected owners approved.
3. **Local check before every push:** `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-ownership.ps1 -Owner <your-id>`.
4. **Instructions:** every working folder's `INSTRUCTIONS.md` lists exactly what you may and must not edit.

Until the repository is on GitHub with branch protection on, layers 3 and 4 are advisory only.

## Collaborator roles

| Person | GitHub role |
|---|---|
| Project owner | Admin |
| Persons 1-4 | Write (never Admin, so they cannot change branch protection or bypass reviews) |

## Requesting a change in someone else's area

1. Do not edit the file on your branch.
2. Open an issue with the **Change request** template (`.github/ISSUE_TEMPLATE/change-request.md`) and tag the owner's handle. Alternatively, write the request as a file in your own folder, `workstreams/<your-folder>/docs/change-requests/YYYYMMDD-<target-owner>-<topic>.md`, and link it in the issue.
3. The owner makes the change on their own branch, or explicitly asks you to. In that case your PR needs their approval in review, and the project owner adds the `ownership-override` label.
4. Shared contracts follow [packages/contracts/INSTRUCTIONS.md](../packages/contracts/INSTRUCTIONS.md): propose -> affected owners approve -> project owner merges.
5. Keep working against the current contract and mocks while you wait.

## Lockfiles and root config

`package.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`, `tsconfig.base.json`, `.gitignore`, `.gitattributes`, `.editorconfig`, `.env.example`, `services/atlas-core/pyproject.toml` belong to the project owner. Ask for dependency or config changes by PR or change request.
