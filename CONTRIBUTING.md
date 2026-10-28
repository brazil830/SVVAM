# Contributing

Owner: project owner. These rules let five people work in parallel without merge conflicts.

## 1. Ownership

- Every path has one owner (`OWNERSHIP.json`, `.github/CODEOWNERS`). Edit only your own paths, listed in `workstreams/<your-folder>/INSTRUCTIONS.md`.
- Nobody else's changes land in your paths without your approval in PR review.
- To change someone else's path, request it (`docs/PERMISSIONS.md`). Never edit it on your branch.
- Code against `packages/contracts/` and `docs/api-contract.md` only, never against another person's internals.

## 2. Branches

- Name: `<owner>/<topic>`, where `<owner>` is your id from `OWNERSHIP.json`: `project-owner`, `person-1`, `person-2`, `person-3`, `person-4`. Examples: `person-1/policy-allowlist`, `person-3/plan-inspector`. The Common PRD names (`feature/person-1-runtime`, `feature/person-2-voice`, `feature/person-3-ui`, `feature/person-4-integration`) are also accepted.
- One workstream per branch: a branch only ever carries one owner's work. Keep one active branch per person where possible and keep it short-lived.
- `main` is protected and receives changes only from `integration` via PR by the project owner. `integration` is protected and receives PRs from personal branches.
- **PRs only. No direct pushes to `main` or `integration`. No force pushes to shared branches.**

## 3. Before opening a PR

```powershell
git fetch origin
git rebase origin/integration        # or origin/main if your PR targets main
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-ownership.ps1 -Owner <your-id>
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\verify-repo.ps1
```

- Rebase, do not merge, the target branch into yours (linear history).
- Keep PRs small: one working increment, committed every 30-45 minutes (Common PRD section 8 rule 5).
- Fill in the PR template checklist.

## 4. Commit messages

Conventional commits with your owner id as scope:

```
feat(person-2): add deterministic fixture planner
fix(person-1): reject unlisted app ids
test(person-4): add cancel-path e2e scenario
docs(project-owner): clarify confirm payload
```

Types: `feat`, `fix`, `test`, `docs`, `refactor`, `chore`.

## 5. Avoiding conflicts

- Never touch files in other people's folders, even for a typo. Raise a change request.
- Never reformat, re-indent, rename, or change line endings of files outside your folder. Do not run repo-wide formatters; scope formatters to your own paths.
- Line endings are normalized by `.gitattributes` (`* text=auto eol=lf`, `.ps1` CRLF); do not override them locally. `.editorconfig` sets indentation.
- Lockfiles (`pnpm-lock.yaml`) and root configs (`package.json`, `pnpm-workspace.yaml`, `tsconfig.base.json`, `.gitignore`, `.gitattributes`, `.editorconfig`, `.env.example`, `services/atlas-core/pyproject.toml`) are owned by the project owner. Request dependency changes; the project owner regenerates the lockfile.
- Contract changes follow `packages/contracts/INSTRUCTIONS.md`: propose -> affected owners approve -> project owner merges; schema and examples change together.
- Never commit `.env`, secrets, recordings, or private screenshots. `scripts/check-secrets.ps1` runs inside `verify-repo.ps1`.

## 6. CI

- `ownership-check` fails a PR from `<owner>/...` that changes files outside that owner's paths. After every affected owner has approved a cross-folder PR, the project owner may add the `ownership-override` label.
- `ci` runs `scripts/verify-repo.ps1`.
- Both are required checks once branch protection is on (`docs/BRANCH_PROTECTION.md`).
