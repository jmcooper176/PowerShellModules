<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 966F784C-741E-4BF1-AA39-A8875BD192C2

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
    This script performs a forward integration from the Development branch to the Feature-COM branch.
#>

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    [string]
    $Parent = 'Development',

    [ValidateNotNullOrEmpty()]
    [string]
    $Child = 'Feature-COM'
)

git checkout main

$parentHash = git rev-parse $Parent
$childHash = git rev-parse $Child

if ($parentHash -eq $childHash) {
    Write-Information -MessageData "'$($Parent)' and '$($Child)' are already in sync." -InformationAction Continue
    exit 0
}

git checkout $Parent
$parentName = git rev-parse --abbrev-ref HEAD
Write-Information -MessageData "Checked out parent branch '$($parentName)'" -InformationAction Continue

git merge $Child

if ($LASTEXITCODE -ne 0) {
    Write-Error -Message "Merge conflict. Resolve conflicts and try again." -ErrorId 'MergeConflict' -Category ResourceUnavailable -TargetObject $Child -ErrorAction Continue
    exit 1
}

git checkout $Child
$childName = git rev-parse --abbrev-ref HEAD
Write-Information -MessageData "Forward Integration from '$($parentName)' to '$($childName)'" -InformationAction Continue

Write-Information -MessageData "Committing merge from '$($parentName)' to '$($childName)'" -InformationAction Continue
$timestamp = Microsoft.PowerShell.Utility\Get-Date -Format 's'
git commit --all --message="[$($timestamp)] Forward Integration from '$($parentName)' to '$($childName)'"

Write-Information -MessageData "Pushing changes to remote for '$($childName)'." -InformationAction Continue
git push origin $Child

git checkout main
