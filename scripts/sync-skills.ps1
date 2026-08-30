# Mirror the canonical skills (skills/<category>/) into the agent-facing
# directories: .claude/skills and .github/skills (flattened, no category).
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
foreach ($mirror in '.claude/skills', '.github/skills') {
    if (Test-Path $mirror) { Remove-Item -Recurse -Force $mirror }
    New-Item -ItemType Directory -Force $mirror | Out-Null
}
Get-ChildItem 'skills' -Directory | Get-ChildItem -Directory | ForEach-Object {
    Copy-Item -Recurse $_.FullName (Join-Path '.claude/skills' $_.Name)
    Copy-Item -Recurse $_.FullName (Join-Path '.github/skills' $_.Name)
}
Write-Host 'Synced skills/*/* -> .claude/skills and .github/skills'
