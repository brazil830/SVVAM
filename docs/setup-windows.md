# Windows setup and packaging

Owner: Person 4 - AWS, QA & End-to-End Integration. Initial content by the project owner; Person 4 maintains it.

Project ATLAS is a Windows desktop application. Development and testing happen on Windows 10/11.

## Prerequisites (development)

| Tool | Why |
|---|---|
| Git | Version control (`git config core.autocrlf false` is fine; `.gitattributes` handles line endings) |
| Windows PowerShell 5.1 | All `scripts/*.ps1` |
| Node.js (LTS) + pnpm (`corepack enable`) | UI layer (`apps/desktop-ui`) |
| Python 3.11+ | Local backend (`services/atlas-core`) |

## Scripts

Run from the repository root with `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\<name>.ps1`.

| Script | Status |
|---|---|
| `check-ownership.ps1 -Owner <id>` | Working. Run before every push. |
| `verify-repo.ps1` | Working. Structure, ownership map, contract JSON, secret scan. |
| `check-secrets.ps1` | Working. Basic regex scan; prints file:line only. |
| `setup.ps1`, `dev.ps1`, `test.ps1`, `lint.ps1`, `build-desktop.ps1` | Placeholders; the project owner implements them (Common PRD section 6). |

Copy `.env.example` to `.env` for local settings. Never commit `.env`. With `ATLAS_MOCK_MODE=true` no cloud credentials are needed.

## Packaging (Windows installer)

The desktop app is packaged with Tauri 2 into `.msi` (WiX) and `.exe` (NSIS) installers by `scripts/build-desktop.ps1` (placeholder). The local Python backend is bundled and started by the app (proposed: Tauri sidecar, `docs/decisions.md` D10).

Additional prerequisites for building installers:

| Tool | Why |
|---|---|
| Rust toolchain (rustup, stable MSVC target `x86_64-pc-windows-msvc`) | Builds the Tauri shell |
| Microsoft C++ Build Tools (MSVC, "Desktop development with C++") | Rust linker on Windows |
| Microsoft Edge WebView2 Runtime | Renders the UI inside the app (preinstalled on Windows 11) |
| Node.js + pnpm | Builds the UI layer |
| Python 3.11+ | Backend that is bundled with the app |

Packaging config (`apps/desktop-ui/src-tauri/tauri.conf.json`: bundle, identifier, signing, sidecar) needs project-owner approval (`docs/decisions.md` D9).

**Future work:** installer code signing is Stage C ("Private beta") in Master PRD section 17; signed updates are Stage D. Unsigned prototype installers trigger Windows SmartScreen warnings.
