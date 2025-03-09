<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 870A6EBE-CD45-45E4-9D74-C7474C0F0BE2

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2025 John Merryweather Cooper.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .DESCRIPTION
    This script performs a reverse integration from the Feature-PowerShell branch to the Development branch.
#>


[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]
    $Parent = 'Development',

    [ValidateNotNullOrEmpty()]
    [string]
    $Child = 'Feature-PowerShell'
)

git checkout main

$parentHash = git rev-parse $Parent
$childHash = git rev-parse $Child

if ($parentHash -eq $childHash) {
    Write-Information -MessageData "'$($Parent)' and '$($Child)' are already in sync." -InformationAction Continue
    exit 0
}

git checkout $Child
$childName = git rev-parse --abbrev-ref HEAD
Write-Information -MessageData "Checked out child branch '$($childName)'" -InformationAction Continue

git merge $Parent

if ($LASTEXITCODE -ne 0) {
    Write-Error -Message "Merge conflict. Resolve conflicts and try again." -ErrorId 'MergeConflict' -Category ResourceUnavailable -TargetObject $Parent -ErrorAction Continue
    exit 1
}

git checkout $Parent
$parentName = git rev-parse --abbrev-ref HEAD
Write-Information -MessageData "Reverse Integration from '$($childName)' to '$($parentName)'" -InformationAction Continue

Write-Information -MessageData "Committing merge from '$($childName)' to '$($parentName)'" -InformationAction Continue
$timestamp = Microsoft.PowerShell.Utility\Get-Date -Format 's'
git commit --all --message="[$($timestamp)] Forward Integration from '$($childName)' to '$($parentName)'"

Write-Information -MessageData "Pushing changes to remote for '$($parentName)'." -InformationAction Continue
git push origin $Parent
gh pr create --base $Child --head $Parent --title "Reverse Integration from '$($childName)' to '$($parentName)'" --body "[$($timestamp)] This pull request is for the reverse integration from '$($childName)' to '$($parentName)'."
