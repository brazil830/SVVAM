OWNER: Person 3 - UI & Animated Character - do not edit without owner approval

# apps/desktop-ui - Windows desktop app (Tauri 2 shell + React/TypeScript/Vite UI)

Project ATLAS is Windows desktop software. This folder holds the desktop application the user installs and runs:

- `src-tauri/` - the Tauri 2 native shell (Rust). It opens the app window (WebView2) and starts the local Python backend (`services/atlas-core`, localhost only) as a sidecar. Placeholder for now.
- `src/` - the React + TypeScript UI layer rendered inside the shell (Vite is the build tool only).

Ownership: everything under `apps/desktop-ui/` belongs to Person 3, **except** that changes to `src-tauri/tauri.conf.json` (bundle, identifier, signing, sidecar = packaging/installer config) need project-owner approval (`.github/CODEOWNERS`, `docs/decisions.md` D9).

- The UI talks to the local backend only through `src/services/atlasClient.ts` using `docs/api-contract.md`.
- `src/services/mockClient.ts` replays `packages/contracts/examples/` so the UI works without the backend.
- Neither the UI nor the shell performs Windows automation, and neither fakes success in live mode (Common PRD section 7).

Dependencies are not installed yet; Person 3 adds them to this folder's `package.json` and `src-tauri/Cargo.toml`. Build/packaging: `scripts/build-desktop.ps1` and `docs/setup-windows.md`.
