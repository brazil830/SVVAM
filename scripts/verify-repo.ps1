<#
.SYNOPSIS
    Verifies the repository structure and ownership map (Common PRD section 6). Owner: project owner.
.DESCRIPTION
    Windows PowerShell 5.1 compatible. Checks required folders/files, parses the shared contract JSON
    and OWNERSHIP.json, checks that every OWNERSHIP.json path has a matching .github/CODEOWNERS line
    with the same owner handle, checks the workstream folders, and runs scripts/check-secrets.ps1.
    Prints a PASS/FAIL summary and exits non-zero on failure.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object 'System.Collections.Generic.List[string]'
$passes = 0
function Check([bool]$ok, [string]$what) {
    if ($ok) { $script:passes++ } else { $failures.Add($what); Write-Host "  FAIL  $what" }
}
function P([string]$rel) { return (Join-Path $repoRoot $rel) }

# ---- Required paths ----
$required = @(
    'README.md', 'CONTRIBUTING.md', 'OWNERSHIP.json', '.gitignore', '.gitattributes', '.editorconfig', '.env.example',
    'package.json', 'pnpm-workspace.yaml', 'tsconfig.base.json',
    'project_atlas_master_prd.md', 'project_atlas_common_team_execution_prd_v1_2_parallel.md',
    '.github/CODEOWNERS', '.github/pull_request_template.md', '.github/workflows/ci.yml', '.github/workflows/ownership-check.yml',
    '.github/ISSUE_TEMPLATE/change-request.md',
    'scripts/setup.ps1', 'scripts/dev.ps1', 'scripts/test.ps1', 'scripts/lint.ps1', 'scripts/check-secrets.ps1',
    'scripts/verify-repo.ps1', 'scripts/check-ownership.ps1', 'scripts/build-desktop.ps1',
    'packages/contracts/README.md', 'packages/contracts/INSTRUCTIONS.md', 'packages/contracts/CHANGELOG.md',
    'packages/contracts/package.json', 'packages/contracts/task-plan.schema.json', 'packages/contracts/action-registry.json',
    'packages/contracts/events.schema.json', 'packages/contracts/examples',
    'apps/desktop-ui/README.md', 'apps/desktop-ui/package.json', 'apps/desktop-ui/src', 'apps/desktop-ui/src-tauri/tauri.conf.json',
    'apps/desktop-ui/src-tauri/Cargo.toml', 'apps/desktop-ui/src-tauri/src/main.rs',
    'services/atlas-core/README.md', 'services/atlas-core/pyproject.toml', 'services/atlas-core/src/atlas',
    'services/atlas-core/tests/runtime', 'services/atlas-core/tests/intent', 'services/atlas-core/tests/integration',
    'workstreams/README.md',
    'docs/ANALYSIS.md', 'docs/PERMISSIONS.md', 'docs/BRANCH_PROTECTION.md', 'docs/HANDOFF.md', 'docs/architecture.md',
    'docs/api-contract.md', 'docs/threat-model.md', 'docs/decisions.md', 'docs/setup-windows.md', 'docs/test-results',
    'docs/prd/00-master-prd.md', 'docs/prd/01-common-team-execution-prd.md',
    'docs/prd/02-person-1-runtime-safety-prd.md', 'docs/prd/03-person-2-voice-9router-prd.md',
    'docs/prd/04-person-3-ui-character-prd.md', 'docs/prd/05-person-4-aws-qa-integration-prd.md'
)
Write-Host 'Checking required paths...'
foreach ($r in $required) { Check (Test-Path (P $r)) "missing: $r" }

# ---- PRD copies are byte-identical to the root originals ----
if ((Test-Path (P 'docs/prd/00-master-prd.md')) -and (Test-Path (P 'project_atlas_master_prd.md'))) {
    Check ((Get-FileHash (P 'project_atlas_master_prd.md')).Hash -eq (Get-FileHash (P 'docs/prd/00-master-prd.md')).Hash) 'docs/prd/00-master-prd.md differs from project_atlas_master_prd.md'
}
if ((Test-Path (P 'docs/prd/01-common-team-execution-prd.md')) -and (Test-Path (P 'project_atlas_common_team_execution_prd_v1_2_parallel.md'))) {
    Check ((Get-FileHash (P 'project_atlas_common_team_execution_prd_v1_2_parallel.md')).Hash -eq (Get-FileHash (P 'docs/prd/01-common-team-execution-prd.md')).Hash) 'docs/prd/01-common-team-execution-prd.md differs from the root Common PRD'
}

# ---- JSON parses ----
Write-Host 'Parsing JSON...'
$jsonFiles = @(Get-ChildItem -Path (P 'packages/contracts') -Recurse -Filter *.json -File) + @(Get-Item (P 'OWNERSHIP.json'))
foreach ($j in $jsonFiles) {
    $ok = $true
    try { Get-Content -Raw -Encoding UTF8 $j.FullName | ConvertFrom-Json | Out-Null } catch { $ok = $false }
    Check $ok "invalid JSON: $($j.FullName.Substring($repoRoot.Length + 1))"
}

# ---- OWNERSHIP.json <-> CODEOWNERS ----
Write-Host 'Checking OWNERSHIP.json against .github/CODEOWNERS...'
$map = Get-Content -Raw -Encoding UTF8 (P 'OWNERSHIP.json') | ConvertFrom-Json
$codeowners = @{}
foreach ($line in (Get-Content -Encoding UTF8 (P '.github/CODEOWNERS'))) {
    $t = $line.Trim()
    if ($t -eq '' -or $t.StartsWith('#')) { continue }
    $cols = $t -split '\s+'
    $codeowners[$cols[0]] = @($cols | Select-Object -Skip 1)
}
Check ($codeowners.ContainsKey('*') -and ($codeowners['*'] -contains $map.owners.($map.default).handle)) "CODEOWNERS default '*' must map to $($map.owners.($map.default).handle)"
$approvalPaths = @($map.approvalRequired | ForEach-Object { $_.path })
foreach ($id in @($map.owners.PSObject.Properties | ForEach-Object { $_.Name })) {
    $o = $map.owners.$id
    foreach ($path in @($o.paths)) {
        $key = '/' + $path
        Check ($codeowners.ContainsKey($key)) "CODEOWNERS has no line for /$path ($id)"
        if ($codeowners.ContainsKey($key)) { Check ($codeowners[$key] -contains $o.handle) "CODEOWNERS /$path is not owned by $($o.handle)" }
    }
    if ($o.workstream) {
        foreach ($f in @('README.md', 'INSTRUCTIONS.md', 'acceptance-checklist.md', 'prd/README.md', 'src/.gitkeep', 'tests/.gitkeep', 'docs/.gitkeep')) {
            Check (Test-Path (P ($o.workstream + $f))) "missing: $($o.workstream)$f"
        }
        $instr = P ($o.workstream + 'INSTRUCTIONS.md')
        if (Test-Path $instr) {
            Check ((Get-Content -Raw -Encoding UTF8 $instr).Contains($o.name)) "$($o.workstream)INSTRUCTIONS.md does not name its owner '$($o.name)'"
        }
    }
}
foreach ($rule in @($map.approvalRequired)) {
    $key = '/' + $rule.path
    Check ($codeowners.ContainsKey($key) -and ($codeowners[$key] -contains $map.owners.($rule.approver).handle)) "CODEOWNERS /$($rule.path) must require $($map.owners.($rule.approver).handle)"
}

# ---- Secret scan ----
Write-Host 'Running check-secrets.ps1...'
$old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
& powershell -NoProfile -ExecutionPolicy Bypass -File (P 'scripts/check-secrets.ps1')
$rc = $LASTEXITCODE
$ErrorActionPreference = $old
Check ($rc -eq 0) 'check-secrets.ps1 reported findings'

Write-Host ''
if ($failures.Count -gt 0) {
    Write-Host "verify-repo: FAIL ($($failures.Count) failed, $passes passed)"
    exit 1
}
Write-Host "verify-repo: PASS ($passes checks). scripts/test.ps1 is a placeholder until the project owner implements it."
exit 0
