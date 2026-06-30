# claude-kit terminal helper: `fire <slug>` with Tab-completed roadmap slugs.
#
# Source this from your PowerShell $PROFILE:
#   . "$env:USERPROFILE\.claude\skills\claude-kit\shell\fire.ps1"
#
# Logic lives here (in the repo) so every cloned device behaves the same and
# edits propagate on the next shell reload. `fire <slug>` launches Claude Code
# running /fire on that roadmap id; Tab completes the slug from the nearest
# roadmap.md (current dir or any parent).

function Get-RoadmapFile {
  $dir = (Get-Location).Path
  while ($dir) {
    $f = Join-Path $dir 'roadmap.md'
    if (Test-Path $f) { return $f }
    $parent = Split-Path $dir -Parent
    if ($parent -eq $dir) { break }
    $dir = $parent
  }
  return $null
}

function Get-RoadmapSlugs {
  $f = Get-RoadmapFile
  if (-not $f) { return @() }
  Select-String -Path $f -Pattern '^\s*-\s*\[([a-zA-Z0-9_]+)\]' -AllMatches |
    ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value } |
    Select-Object -Unique
}

function fire {
  [CmdletBinding()]
  param([Parameter(Mandatory)][string]$Slug)
  claude "/fire $Slug"
}

Register-ArgumentCompleter -CommandName fire -ParameterName Slug -ScriptBlock {
  param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
  Get-RoadmapSlugs |
    Where-Object { $_ -like "*$wordToComplete*" } |
    ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
}
