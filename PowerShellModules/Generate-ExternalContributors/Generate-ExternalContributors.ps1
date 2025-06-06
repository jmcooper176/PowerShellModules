﻿<#
 =============================================================================
<copyright file="Generate-ExternalContributors.ps1" company="John Merryweather Cooper
">
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.
    All Rights Reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

       1. Redistributions of source code must retain the above
          copyright notice, this list of conditions and the following
          disclaimer.

       2. Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials
          provided with the distribution.

       3. Neither the name of the copyright holder nor the names of
          its contributors may be used to endorse or promote products
          derived from this software without specific prior written
          permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
</copyright>
<author>John Merryweather Cooper</author>
<date>Created:  2024-9-12</date>
<summary>
This file "Generate-ExternalContributors.ps1" is part of "Generate-ExternalContributors".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 56A0354F-3810-4D63-9236-9C475E9DEAE5

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/Generate-ExternalContributors

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .SYNOPSIS
    Get all extenal contibuting authors.

    .DESCRIPTION
    Get all extenal contibuting authors.

    .PARAMETER AccessToken

    .PARAMETER DaysBack

    .INPUTS
    None.  `Get-ExternalContributors.ps1` does not accept pipeline input.

    .OUTPUTS
    The name, login, commits message of the authors.

    .LINK
    Invoke-WebRequest: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-7

    .LINK
    Invoke-RestMethod: https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Invoke-RestMethod?view=powershell-7
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]
    $AccessToken,

    [Parameter(HelpMessage = 'Days back default 28')]
    [int]
    $DaysBack = 28
)

$SinceDate = (Microsoft.PowerShell.Utility\Get-Date).AddDays((0 - $DaysBack))
$SinceDateStr = $SinceDate.ToString('yyyy-MM-ddTHH:mm:ssZ')
$Branch = git branch --show-current # The Git 2.22 and above support.
$rootPath = "$PSScriptRoot\.."
$changeLogFile = Get-Item -Path "..\ChangeLog.md"
$changeLogContent = Get-Content -Path $changeLogFile.FullName | Out-String

Write-Debug 'Create ExternalContributors.md'
# Create md file to store contributors information.
$contributorsMDFile = Join-Path $PSScriptRoot 'ExternalContributors.md'

if ((Test-Path -LiteralPath $contributorsMDFile -PathType Leaf)) {
    Remove-Item -Path $contributorsMDFile -Force
}

New-Item -ItemType "file" -Path $contributorsMDFile

$commitsUrl = "https://api.github.com/repos/Azure/azure-powershell/commits?since=$SinceDateStr&sha=$Branch"
$token = ConvertTo-SecureString $AccessToken -AsPlainText -Force

# Get last page number of commints.
$commintsPagesLink = (Invoke-WebRequest -Uri $commitsUrl -Authentication Bearer -Token $token).Headers.Link
$commintsLastPageNumber = 1 # Default value

if (![string]::IsNullOrEmpty($commintsPagesLink)) {
    if ($commintsPagesLink.LastIndexOf('&page=') -gt 0) {
        [int]$commintsLastPageNumber = $commintsPagesLink.Substring($commintsPagesLink.LastIndexOf('&page=') + '&page='.Length, 1)
    }
}

$PRs = @()

for ($pageNumber = 1; $pageNumber -le $commintsLastPageNumber; $pageNumber++) {
    $commitsPageUrl = $commitsUrl + "&page=$pageNumber"
    $PRs += Invoke-RestMethod -Uri $commitsPageUrl -Authentication Bearer -Token $token -ResponseHeadersVariable 'ResponseHeaders'
}

Write-Debug "The PR count: $($PRs.Count)"

# Remove already existed commits
$validPRs = @()

$PRs | ForEach-Object -Process {
    $index = $_.commit.message.IndexOf("`n`n")

    if ($index -lt 0) {
        $commitMessage = $_.commit.message
    }
    else {
        $commitMessage = $_.commit.message.Substring(0, $index)
    }

    if (!($changeLogContent.Contains($commitMessage))) {
        $validPRs += $_
    }
}

Write-Debug -Message "The valid PR count: $($validPRs.Count)"

$sortPRs = $validPRs | Sort-Object -Property @{Expression = { $_.author.login }; Descending = $False }

$skipContributors = @('aladdindoc', 'azure-powershell-bot')

# Get team members of the azure-powershell-team.
(Invoke-WebRequest -Uri "https://api.github.com/orgs/Azure/teams/azure-powershell-team/members" -Authentication Bearer -Token $token).Content |
    ConvertFrom-Json |
    ForEach-Object -Process {
        $skipContributors += $_.login
    }

# Output external contributors information.
Write-Debug -Message 'Output external contributors information.'
'### Thanks to our community contributors' | Out-File -FilePath $contributorsMDFile -Force
Write-Information -MessageData '### Thanks to our community contributors' -InformationAction Continue

for ($i = 0; $i -lt $sortPRs.Length; $i++) {
    $account = $sortPRs[$i].author.login
    $name = $sortPRs[$i].commit.author.name
    $index = $sortPRs[$i].commit.message.IndexOf("`n`n")

    if ($skipContributors.Contains($account)) {
        continue
    }

    # Skip if commit author exists in skipContributors list.
    if ([System.String]::IsNullOrEmpty($account) -and $skipContributors.Contains($name)) {
        continue
    }

    # Check whether the contributor belongs to the Azure organization.
    Invoke-RestMethod -Uri "https://api.github.com/orgs/Azure/members/$($sortPRs[$PR].author.login)" -Authentication Bearer -Token $token -ResponseHeadersVariable 'ResponseHeaders' -StatusCodeVariable 'StatusCode' -SkipHttpErrorCheck > $null
    if ($StatusCode -eq '204') {
        # Add internal contributors to skipContributors to reduce the number of https requests sent.
        $skipContributors += $sortPRs[$i].author.login
        continue
    }

    if ($index -lt 0) {
        $commitMessage = $sortPRs[$i].commit.message
    }
    else {
        $commitMessage = $sortPRs[$i].commit.message.Substring(0, $index)
    }

    # Contributors have many commits.
    if ( ($account -eq $sortPRs[$i - 1].author.login) -or ($account -eq $sortPRs[$i + 1].author.login)) {
        # Firt commit.
        if (!($sortPRs[$i].author.login -eq $sortPRs[$i - 1].author.login)) {
            if (($account -eq $name)) {
                "* @$account" | Tee-Object -FilePath $contributorsMDFile -Append | Out-String | Write-Information -InformationAction Continue
                "  * $commitMessage" | Tee-Object -FilePath $contributorsMDFile -Append | Out-String | Write-Information -InformationAction Continue
            }
            else {
                "* $($name) (@$account)" | Tee-Object -FilePath $contributorsMDFile -Append | Out-String | Write-Information -InformationAction Continue
                "  * $commitMessage" | Tee-Object -FilePath $contributorsMDFile -Append | Out-String | Write-Information -InformationAction Continue
            }
        }
        else {
            "  * $commitMessage" | Tee-Object -FilePath $contributorsMDFile -Append | Out-String | Write-Information -InformationAction Continue
        }
    }
    else {
        if (($account -eq $name)) {
            "* @$account, $commitMessage" | Tee-Object -FilePath $contributorsMDFile -Append | Out-String | Write-Information -InformationAction Continue
        }
        else {
            "* $name (@$account), $commitMessage" | Tee-Object -FilePath $contributorsMDFile -Append | Out-String | Write-Information -InformationAction Continue
        }
    }
}
