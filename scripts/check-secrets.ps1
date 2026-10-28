<#
.SYNOPSIS
    Basic secret scan (Common PRD section 6). Owner: project owner. Windows PowerShell 5.1 compatible.
.DESCRIPTION
    Scans tracked files plus untracked files that are not ignored. Fails on tracked .env files and on
    likely secrets. Prints file:line and the rule name only, never the matched value.
    A regex scan is a safety net, not a guarantee.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot

function Invoke-Git([string[]]$GitArgs) {
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = & git -C $repoRoot -c core.quotepath=off @GitArgs 2>$null
    $script:GitExitCode = $LASTEXITCODE
    $ErrorActionPreference = $old
    return @($out | Where-Object { $_ -ne $null -and "$_".Trim() -ne '' })
}

$tracked = @()
$files = @()
Invoke-Git @('rev-parse', '--git-dir') | Out-Null
if ($script:GitExitCode -eq 0) {
    $tracked = Invoke-Git @('ls-files')
    $files = @($tracked) + @(Invoke-Git @('ls-files', '--others', '--exclude-standard'))
} else {
    Write-Host "WARN: not a git repository; scanning the working tree (excluding node_modules, .venv, target)."
    $files = Get-ChildItem -Path $repoRoot -Recurse -File -Force |
        Where-Object { $_.FullName -notmatch '\\(\.git|node_modules|\.venv|target)\\' } |
        ForEach-Object { $_.FullName.Substring($repoRoot.Length + 1).Replace('\', '/') }
}
$files = @($files | Sort-Object -Unique)

$findings = 0

# Tracked .env files (anything named .env or .env.* except .env.example)
foreach ($f in $tracked) {
    $leaf = ($f -split '/')[-1]
    if ($leaf -match '^\.env(\..+)?$' -and $leaf -ne '.env.example') {
        Write-Host "FINDING: ${f}: tracked environment file (remove it from git: git rm --cached `"$f`")"
        $findings++
    }
}

$rules = @(
    @{ Name = 'AWS access key id'; Regex = 'AKIA[0-9A-Z]{16}' },
    @{ Name = 'private key block'; Regex = '-----BEGIN [A-Z ]*PRIVATE KEY-----' },
    @{ Name = 'credential assignment'; Regex = '(?i)(api[_-]?key|secret|token|password)["'']?\s*[=:]\s*["'']?[^\s"''<>]{8,}' }
)
# Lines that read a value from configuration instead of containing one.
$allow = '(?i)(os\.environ|getenv|\$env:|process\.env|import\.meta\.env|\$\{\{)'
$skipExt = @('.png', '.jpg', '.jpeg', '.gif', '.ico', '.webp', '.wav', '.mp3', '.woff', '.woff2', '.zip', '.pdf', '.exe', '.msi', '.dll')

foreach ($f in $files) {
    $full = Join-Path $repoRoot $f
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { continue }
    if ($skipExt -contains ([System.IO.Path]::GetExtension($f).ToLowerInvariant())) { continue }
    if ((Get-Item -LiteralPath $full).Length -gt 1MB) { continue }
    $lines = [System.IO.File]::ReadAllLines($full)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        foreach ($rule in $rules) {
            if ($line -match $rule.Regex) {
                if ($rule.Name -eq 'credential assignment' -and $line -match $allow) { continue }
                Write-Host "FINDING: ${f}:$($i + 1): $($rule.Name)"
                $findings++
            }
        }
    }
}

if ($findings -gt 0) {
    Write-Host "FAIL: $findings likely secret finding(s). Values are not printed."
    exit 1
}
Write-Host "PASS: no likely secrets in $($files.Count) file(s)."
exit 0
