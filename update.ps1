# Pull the latest skills and reinstall them. Idempotent; run any time.
#
#   ./update.ps1                 Update the global install.
#   ./update.ps1 -Repo -Path p   Update a repo-scoped install (same flags as install.ps1).
param(
    [switch]$Repo,
    [string]$Path = (Get-Location).Path,
    [switch]$Shared
)
$ErrorActionPreference = 'Stop'
git -C $PSScriptRoot pull --ff-only
$installArgs = @()
if ($Repo) { $installArgs += '-Repo', '-Path', $Path }
if ($Shared) { $installArgs += '-Shared' }
& (Join-Path $PSScriptRoot 'install.ps1') @installArgs
