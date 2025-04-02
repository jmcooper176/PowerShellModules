<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 0F22138E-45AD-4D1B-BD21-FAEC741ACBE1

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

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
    This script performs a reverse integration from the Staging branch to the main branch.
#>

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]
    $Parent = 'main',

    [ValidateNotNullOrEmpty()]
    [string]
    $Child = 'Staging'
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
gh pr create --base $Chile --head $Parent --title "Reverse Integration from '$($childName)' to '$($parentName)'" --body "[$($timestamp)] This pull request is for the reverse integration from '$($childName)' to '$($parentName)'."
