# Mirror the canonical skills (.github/skills) into .claude/skills.
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
if (Test-Path '.claude/skills') { Remove-Item -Recurse -Force '.claude/skills' }
New-Item -ItemType Directory -Force '.claude' | Out-Null
Copy-Item -Recurse '.github/skills' '.claude/skills'
Write-Host 'Synced .github/skills -> .claude/skills'
