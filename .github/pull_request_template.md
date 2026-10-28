## What and why

<!-- One or two sentences. Link the issue / change request if there is one. -->

## Owner and scope

- Owner (branch prefix): <!-- project-owner | person-1 | person-2 | person-3 | person-4 -->
- Folder(s) touched:

## Checklist

- [ ] Only my own folder and owned paths are touched (see my `INSTRUCTIONS.md` and `OWNERSHIP.json`).
- [ ] `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-ownership.ps1` passes locally.
- [ ] If any file outside my paths changed: every affected owner has approved in this PR's review, and I listed them here: <!-- @handle, @handle -->
- [ ] No reformatting, renames, or line-ending changes in files outside my folder.
- [ ] No lockfile or root config changes (or the project owner approved them).
- [ ] Contract change? If yes: schema + `examples/` + `CHANGELOG.md` updated together and all affected owners notified (`packages/contracts/INSTRUCTIONS.md`).
- [ ] Rebased on the latest target branch; small, focused PR.
- [ ] `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify-repo.ps1` passes.
- [ ] No secrets, `.env` files, recordings, or private screenshots committed.
