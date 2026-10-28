# Branch protection - GitHub settings the project owner must enable

Owner: project owner.

Folder permissions are enforced by `.github/CODEOWNERS` **plus** these settings. Without them, CODEOWNERS only requests reviews and does not block merges.

## 0. Before you start

1. Push this repository to GitHub (suggested name `project-atlas`).
2. Replace the placeholder handles in `.github/CODEOWNERS` and the `handle` fields in `OWNERSHIP.json` with real GitHub usernames (`@atlas-project-owner`, `@atlas-person-1` ... `@atlas-person-4`). Code owners need Write access, or CODEOWNERS ignores them.
3. Add Persons 1-4 as collaborators with the **Write** role (Settings -> Collaborators). Only the project owner is Admin.
4. Create the `integration` branch from `main` and push it.
5. Create the label `ownership-override` (Issues -> Labels). Only the project owner applies it.

## 1. Rules for `main` and `integration`

Settings -> Branches -> Add branch protection rule (or Settings -> Rules -> Rulesets -> New branch ruleset), once per branch:

| Setting | Value | Why |
|---|---|---|
| Require a pull request before merging | On | No direct pushes |
| Required approvals | 1 | At least one reviewer |
| Require review from Code Owners | On | The owner of every touched path must approve |
| Dismiss stale pull request approvals when new commits are pushed | On | Approval covers the final diff |
| Require approval of the most recent reviewable push | On | Authors cannot self-approve late changes |
| Require status checks to pass | On: `ownership-check / ownership` and `ci / verify-repo` | Blocks out-of-folder changes and broken structure |
| Require branches to be up to date before merging | On | Forces rebase on the target branch first |
| Require linear history | On | Rebase/squash only, no merge commits |
| Require conversation resolution | On | Open review comments block merge |
| Allow force pushes | **Off** | Nobody can rewrite shared history |
| Allow deletions | **Off** | Protected branches cannot be deleted |
| Do not allow bypassing the above settings / Include administrators | On | Applies to the project owner as well |

Settings -> General -> Pull Requests: enable "Allow squash merging" and/or "Allow rebase merging", disable "Allow merge commits" (matches linear history), and enable "Automatically delete head branches".

## 2. Check it works

1. As Person 1, push `person-1/test-ownership` with a change to `apps/desktop-ui/README.md` and open a PR into `integration`.
2. Expected: `ownership-check` fails, and the PR asks `@atlas-person-3` for review and cannot be merged.
3. Close the PR and delete the branch.
