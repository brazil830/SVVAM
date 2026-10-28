<#
.SYNOPSIS
    Fails when changed files fall outside the paths owned by one owner (OWNERSHIP.json).

.DESCRIPTION
    Owner: project owner. Windows PowerShell 5.1 compatible.
    Each changed file is mapped to exactly one owner: the owner whose OWNERSHIP.json path is the
    longest match (paths ending in '/' cover a whole folder); files that match nothing belong to
    the "default" owner (project owner). Any file not owned by the checked owner is a violation.

    Owner selection (first that applies):
      -Owner <id>        explicit owner id (project-owner, person-1 .. person-4)
      -Branch <name>     derive owner from the branch prefix ("person-1/topic" or "feature/person-1-...")
      (neither)          derive owner from the current git branch
    Branches listed in "unscopedBranches" (main, integration) are skipped with exit 0.

    Changed-file selection (first that applies):
      -Files a,b         explicit list (simulation / tests); comma-separated also accepted
      -FileList <path>   text file with one path per line
      (neither)          git diff <Base>...HEAD + staged + unstaged + untracked (not ignored).
                         -Base defaults to the first existing of origin/integration, integration,
                         origin/main, main. With no commits yet, staged/unstaged/untracked only.

    -Override reports violations as warnings and exits 0 (CI passes it when the PR has the
    "ownership-override" label, which only the project owner should apply).

    Exit codes: 0 pass, 1 violation, 2 usage/config error.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-ownership.ps1 -Owner person-1
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-ownership.ps1 -Branch person-2/planner -Base origin/integration
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-ownership.ps1 -Owner person-3 -Files "apps/desktop-ui/src/App.tsx,README.md"
#>
[CmdletBinding()]
param(
    [string]$Owner,
    [string]$Branch,
    [string]$Base,
    [string[]]$Files,
    [string]$FileList,
    [switch]$Override
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$ownershipPath = Join-Path $repoRoot 'OWNERSHIP.json'

function Write-Fail([string]$msg, [int]$code) {
    Write-Host "FAIL: $msg"
    exit $code
}

function Invoke-Git([string[]]$GitArgs) {
    # Native stderr must not become a terminating error under 'Stop' in PowerShell 5.1.
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & git -C $repoRoot -c core.quotepath=off @GitArgs 2>$null
    $script:GitExitCode = $LASTEXITCODE
    $ErrorActionPreference = $old
    return @($out | Where-Object { $_ -ne $null -and "$_".Trim() -ne '' })
}

function ConvertTo-RepoPath([string]$p) {
    $p = $p.Trim().Trim('"').Replace('\', '/')
    while ($p.StartsWith('./')) { $p = $p.Substring(2) }
    return $p
}

function Test-PathMatch([string]$file, [string]$pattern) {
    if ($pattern.EndsWith('/')) {
        return $file.StartsWith($pattern, [System.StringComparison]::OrdinalIgnoreCase)
    }
    if ($pattern.Contains('*') -or $pattern.Contains('?')) {
        return ($file -like $pattern)
    }
    return [string]::Equals($file, $pattern, [System.StringComparison]::OrdinalIgnoreCase)
}

if (-not (Test-Path $ownershipPath)) { Write-Fail "OWNERSHIP.json not found at $ownershipPath" 2 }
try {
    $map = Get-Content -Raw -Encoding UTF8 $ownershipPath | ConvertFrom-Json
} catch {
    Write-Fail "OWNERSHIP.json is not valid JSON: $($_.Exception.Message)" 2
}
$ownerIds = @($map.owners.PSObject.Properties | ForEach-Object { $_.Name })

function Resolve-FileOwner([string]$file) {
    $best = $null
    $bestLen = -1
    foreach ($id in $ownerIds) {
        foreach ($pattern in @($map.owners.$id.paths)) {
            if ((Test-PathMatch $file $pattern) -and $pattern.Length -gt $bestLen) {
                $best = $id
                $bestLen = $pattern.Length
            }
        }
    }
    if ($null -eq $best) { $best = $map.default }
    return $best
}

# ---- Resolve the owner being checked ----
if (-not $Owner) {
    if (-not $Branch) {
        $Branch = (Invoke-Git @('symbolic-ref', '--short', 'HEAD') | Select-Object -First 1)
        if (-not $Branch) { Write-Fail "Cannot determine current branch; pass -Owner or -Branch." 2 }
    }
    if (@($map.unscopedBranches) -contains $Branch) {
        Write-Host "SKIP: branch '$Branch' is an integration branch; ownership is enforced by CODEOWNERS review on its PR."
        exit 0
    }
    foreach ($id in $ownerIds) {
        foreach ($prefix in @($map.owners.$id.branchPrefixes)) {
            if ($Branch.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { $Owner = $id; break }
        }
        if ($Owner) { break }
    }
    if (-not $Owner) {
        $all = @($ownerIds | ForEach-Object { @($map.owners.$_.branchPrefixes) }) -join ', '
        if ($Override) {
            Write-Host "WARN: branch '$Branch' does not start with an owner prefix ($all); override label present, skipping."
            exit 0
        }
        Write-Fail "branch '$Branch' does not start with an owner prefix ($all). Rename it to <owner>/<topic> (see CONTRIBUTING.md)." 1
    }
}
if ($ownerIds -notcontains $Owner) {
    Write-Fail "unknown owner '$Owner'. Known owners: $($ownerIds -join ', ')" 2
}

# ---- Collect changed files ----
$changed = New-Object 'System.Collections.Generic.List[string]'
if ($Files) {
    foreach ($f in $Files) { foreach ($part in ($f -split ',')) { if ($part.Trim()) { $changed.Add((ConvertTo-RepoPath $part)) } } }
    $source = 'explicit -Files list'
} elseif ($FileList) {
    if (-not (Test-Path $FileList)) { Write-Fail "file list '$FileList' not found" 2 }
    foreach ($line in (Get-Content -Encoding UTF8 $FileList)) { if ($line.Trim()) { $changed.Add((ConvertTo-RepoPath $line)) } }
    $source = "file list $FileList"
} else {
    Invoke-Git @('rev-parse', '--git-dir') | Out-Null
    if ($script:GitExitCode -ne 0) { Write-Fail "not a git repository: $repoRoot" 2 }
    Invoke-Git @('rev-parse', '--verify', '--quiet', 'HEAD') | Out-Null
    $hasHead = ($script:GitExitCode -eq 0)
    if (-not $Base) {
        foreach ($candidate in @('origin/integration', 'integration', 'origin/main', 'main')) {
            Invoke-Git @('rev-parse', '--verify', '--quiet', "$candidate^{commit}") | Out-Null
            if ($script:GitExitCode -eq 0) { $Base = $candidate; break }
        }
    }
    $parts = @()
    if ($hasHead -and $Base) {
        $diff = Invoke-Git @('diff', '--name-only', '--no-renames', "$Base...HEAD")
        if ($script:GitExitCode -ne 0) { Write-Fail "git diff against base '$Base' failed (does the ref exist? fetch with full history)." 2 }
        foreach ($l in $diff) { $changed.Add((ConvertTo-RepoPath $l)) }
        $parts += "committed vs $Base"
    }
    if ($hasHead) {
        foreach ($l in (Invoke-Git @('diff', '--name-only', '--no-renames', 'HEAD'))) { $changed.Add((ConvertTo-RepoPath $l)) }
    } else {
        foreach ($l in (Invoke-Git @('diff', '--name-only', '--no-renames', '--cached'))) { $changed.Add((ConvertTo-RepoPath $l)) }
        foreach ($l in (Invoke-Git @('diff', '--name-only', '--no-renames'))) { $changed.Add((ConvertTo-RepoPath $l)) }
    }
    foreach ($l in (Invoke-Git @('ls-files', '--others', '--exclude-standard'))) { $changed.Add((ConvertTo-RepoPath $l)) }
    $parts += 'staged/unstaged/untracked'
    $source = 'git (' + ($parts -join ' + ') + ')'
}
$unique = @($changed | Sort-Object -Unique)

# ---- Evaluate ----
$ownerInfo = $map.owners.$Owner
Write-Host "Ownership check for '$Owner' ($($ownerInfo.name)); files from $source"
Write-Host "Allowed paths: $(@($ownerInfo.paths) -join ', ')"
if ($unique.Count -eq 0) {
    Write-Host "PASS: no changed files."
    exit 0
}

$violations = @()
foreach ($file in $unique) {
    $fileOwner = Resolve-FileOwner $file
    if ($fileOwner -eq $Owner) {
        Write-Host "  OK       $file"
        foreach ($rule in @($map.approvalRequired)) {
            if ($rule -and (Test-PathMatch $file $rule.path) -and $rule.editor -eq $Owner) {
                Write-Host "           NOTE: needs approval from '$($rule.approver)' ($($map.owners.($rule.approver).handle)) in PR review: $($rule.reason)"
            }
        }
    } else {
        Write-Host "  OUTSIDE  $file  (owned by $fileOwner $($map.owners.$fileOwner.handle))"
        $violations += $file
    }
}

if ($violations.Count -gt 0) {
    if ($Override) {
        Write-Host "WARN: $($violations.Count) file(s) outside '$Owner' paths, allowed by override label '$($map.overrideLabel)'. The owners above must still approve in review."
        exit 0
    }
    Write-Host "FAIL: $($violations.Count) of $($unique.Count) file(s) are outside '$Owner' paths."
    Write-Host "      Revert them, or ask the owning person for the change (docs/PERMISSIONS.md)."
    Write-Host "      A cross-folder PR the owners approved can be merged with the '$($map.overrideLabel)' label (project owner applies it)."
    exit 1
}
Write-Host "PASS: all $($unique.Count) file(s) are inside '$Owner' paths."
exit 0
