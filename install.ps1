# Install the repository-convention layer.
#
#   ./install.ps1                             Global (default): always-on policy + skills for
#                                             every supported agent on this machine.
#   ./install.ps1 -Repo [-Path p]             Repo-scoped: one repository only (default: current
#                                             directory). Everything it creates is added to a
#                                             managed .gitignore section by default, so the
#                                             layer stays local to this machine.
#   ./install.ps1 -Repo [-Path p] -Shared     Repo-scoped, opted out of .gitignore: the layer is
#                                             left to be committed so collaborators get it too.
#
# Idempotent: only writes inside the managed repo-conventions blocks and
# preserves everything else in existing files.
param(
    [switch]$Repo,
    [string]$Path = (Get-Location).Path,
    [switch]$Shared
)
$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot

$htmlBegin = '<!-- repo-conventions:begin v2 -->'
$htmlEnd   = '<!-- repo-conventions:end -->'
$hashBegin = '# repo-conventions:begin v2'
$hashEnd   = '# repo-conventions:end'
$blockPattern = '(?sm)^[^\r\n]*repo-conventions:begin.*?repo-conventions:end[^\r\n]*'

function Write-Block([string]$Target, [string]$Body, [string]$Begin = $htmlBegin, [string]$End = $htmlEnd) {
    $dir = Split-Path -Parent $Target
    if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $block = "$Begin`n$($Body.TrimEnd())`n$End"
    if (Test-Path $Target) {
        $content = (Get-Content -Raw $Target).Replace("`r`n", "`n")
        if ($content -match 'repo-conventions:begin') {
            $content = [regex]::Replace($content, $blockPattern, { param($m) $block }.GetNewClosure())
        } else {
            $content = $content.TrimEnd() + "`n`n$block`n"
        }
    } else {
        $content = "$block`n"
    }
    [System.IO.File]::WriteAllText($Target, $content)
    Write-Host "Updated $Target"
}

function Remove-Block([string]$Target) {
    if (-not (Test-Path $Target)) { return }
    $content = (Get-Content -Raw $Target).Replace("`r`n", "`n")
    if ($content -notmatch 'repo-conventions:begin') { return }
    $content = [regex]::Replace($content, "$blockPattern`n?", '')
    [System.IO.File]::WriteAllText($Target, $content)
    Write-Host "Removed managed section from $Target"
}

# Test-Ours: true when the file consists only of a managed block (safe to gitignore)
function Test-Ours([string]$File) {
    if (-not (Test-Path $File)) { return $false }
    $c = (Get-Content -Raw $File).Replace("`r`n", "`n")
    if ($c -notmatch 'repo-conventions:begin') { return $false }
    $rest = [regex]::Replace($c, "$blockPattern`n?", '')
    return ($rest.Trim() -eq '')
}

function Install-Skills([string]$Target) {
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    foreach ($skill in 'repo-conventions-bootstrap', 'repo-conventions-curator') {
        $dest = Join-Path $Target $skill
        if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
        Copy-Item -Recurse (Join-Path $src ".github/skills/$skill") $dest
    }
    Write-Host "Installed skills into $Target"
}

if (-not $Repo) {
    $policy = Get-Content -Raw (Join-Path $src 'global/agent-policy.md')
    Write-Block "$HOME/.copilot/copilot-instructions.md" $policy   # GitHub Copilot CLI
    Write-Block "$HOME/.claude/CLAUDE.md" $policy                  # Claude Code
    Write-Block "$HOME/.codex/AGENTS.md" $policy                   # OpenAI Codex
    Write-Block "$HOME/.gemini/GEMINI.md" $policy                  # Gemini CLI
    Install-Skills "$HOME/.copilot/skills"
    Install-Skills "$HOME/.claude/skills"
    Install-Skills "$HOME/.agent-conventions/skills"               # neutral copy any agent can be pointed at
    Write-Host 'Global install complete. Start a new agent session to pick it up.'
} else {
    if (-not (Test-Path $Path)) { throw "No such directory: $Path" }

    Install-Skills (Join-Path $Path '.github/skills')
    Install-Skills (Join-Path $Path '.claude/skills')

    # Seed AGENTS.md only when it has no managed block yet; an agent completes
    # the bootstrap from repository evidence on the first session.
    $agents = Join-Path $Path 'AGENTS.md'
    $hasBlock = (Test-Path $agents) -and ((Get-Content -Raw $agents) -match 'repo-conventions:begin')
    if (-not $hasBlock) {
        Write-Block $agents (@'
# Repository conventions

> Managed by the repo-conventions skills. Not bootstrapped yet: run the `repo-conventions-bootstrap` skill (or follow `.github/skills/repo-conventions-bootstrap/SKILL.md`) to fill this block from repository evidence.
'@)
    }

    Write-Block (Join-Path $Path 'CLAUDE.md') (@'
@AGENTS.md

If `AGENTS.md` has no completed managed `repo-conventions` block, run the `repo-conventions-bootstrap` skill before other work.
'@)

    Write-Block (Join-Path $Path '.github/copilot-instructions.md') (@'
Read and follow the repository policy in `AGENTS.md` at the repository root before any work; it is required context for the whole conversation. If it has no completed managed `repo-conventions` block, run the `repo-conventions-bootstrap` skill first.
'@)

    if ($Shared) {
        Remove-Block (Join-Path $Path '.gitignore')
        Write-Host "Repo-scoped install complete in $Path (shared). Commit the new files to share the layer."
    } else {
        # Ignore only files the layer owns outright; files carrying user content stay tracked.
        $entries = @(
            '# Convention layer, local to this machine by default; rerun with -Shared to commit it'
            '.github/skills/repo-conventions-bootstrap/'
            '.github/skills/repo-conventions-curator/'
            '.claude/skills/repo-conventions-bootstrap/'
            '.claude/skills/repo-conventions-curator/'
        )
        if (Test-Ours (Join-Path $Path 'AGENTS.md'))  { $entries += 'AGENTS.md' }
        if (Test-Ours (Join-Path $Path 'CLAUDE.md'))  { $entries += 'CLAUDE.md' }
        if (Test-Ours (Join-Path $Path '.github/copilot-instructions.md')) { $entries += '.github/copilot-instructions.md' }
        Write-Block (Join-Path $Path '.gitignore') ($entries -join "`n") $hashBegin $hashEnd
        Write-Host "Repo-scoped install complete in $Path. The layer is gitignored; rerun with -Shared to commit it."
    }
}
