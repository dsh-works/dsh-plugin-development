<#
.SYNOPSIS
Links the skills of this repository into the DSH skills folder.

.DESCRIPTION
Creates one directory junction per skill in %USERPROFILE%\.dsh\skills, so
the skills are loaded by DSH and updated by git pull in this repository.
Existing real folders are never overwritten; pass -Force to replace them
with a link (the folder is moved aside, not deleted).

.PARAMETER RepoPath
Repository root. Defaults to the folder this script is in.

.PARAMETER Uninstall
Removes only the junctions that point into this repository.

.PARAMETER Force
Replaces an existing folder or link at the destination with the junction.

.EXAMPLE
.\install.ps1
.\install.ps1 -Uninstall
#>
[CmdletBinding()]
param(
    [string] $RepoPath,
    [switch] $Uninstall,
    [switch] $Force
)

$ErrorActionPreference = 'Stop'

if (-not $RepoPath) {
    $RepoPath = $PSScriptRoot
}
if (-not $RepoPath) {
    $RepoPath = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $RepoPath) {
    throw 'cannot determine the repository folder; pass -RepoPath'
}

$repo = (Resolve-Path -LiteralPath $RepoPath).Path
$skillsSource = Join-Path $repo 'skills'
$skillsTarget = Join-Path $env:USERPROFILE '.dsh\skills'

if (-not (Test-Path -LiteralPath $skillsSource)) {
    throw "no skills folder in $repo"
}

$skills = Get-ChildItem -LiteralPath $skillsSource -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md')
}

if (-not $skills) {
    throw "no skill folders with SKILL.md in $skillsSource"
}

if (-not (Test-Path -LiteralPath $skillsTarget)) {
    New-Item -ItemType Directory -Path $skillsTarget -Force | Out-Null
}

function Remove-JunctionLink {
    param([Parameter(Mandatory)][string] $Path)

    # Remove-Item on a junction can throw a NullReferenceException; deleting
    # the reparse point through .NET leaves the target alone.
    try {
        [System.IO.Directory]::Delete($Path, $false)
    } catch {
        cmd /c rmdir "$Path" | Out-Null
    }
}

function Get-JunctionTarget {
    param([Parameter(Mandatory)] $Item)

    $target = $Item.Target
    if ($target -is [array]) {
        $target = $target[0]
    }
    if ($target -is [string] -and $target.StartsWith('Global\')) {
        $target = $target.Substring('Global\'.Length)
    }

    return $target
}

foreach ($skill in $skills) {
    $link = Join-Path $skillsTarget $skill.Name

    if (Test-Path -LiteralPath $link) {
        $item = Get-Item -LiteralPath $link -Force
        $isLink = $item.LinkType -in @('Junction', 'SymbolicLink')
        $target = if ($isLink) { Get-JunctionTarget -Item $item } else { '' }
        $pointsHere = $isLink -and ($target -ieq $skill.FullName)

        if ($Uninstall) {
            if ($pointsHere) {
                Remove-JunctionLink -Path $link
                Write-Host "removed  $link"
            } else {
                Write-Host "skipped  $link (not a link into this repository)"
            }
            continue
        }

        if ($pointsHere) {
            Write-Host "current  $link"
            continue
        }

        if (-not $Force) {
            throw "$link already exists and is not a link to this repository; use -Force to move it aside"
        }

        $backup = "$link.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        if ($isLink) {
            [System.IO.Directory]::Move($link, $backup)
        } else {
            Move-Item -LiteralPath $link -Destination $backup
        }
        Write-Host "moved    $link -> $backup"
    }

    if ($Uninstall) {
        continue
    }

    New-Item -ItemType Junction -Path $link -Target $skill.FullName | Out-Null
    Write-Host "linked   $link -> $($skill.FullName)"
}

if (-not $Uninstall) {
    Write-Host ''
    Write-Host 'Start a new DSH session to load the skills.'
}
