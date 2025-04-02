<#
 =============================================================================
<copyright file="PublishModules.ps1" company="John Merryweather Cooper
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
This file "PublishModules.ps1" is part of "PublishModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 0C36F0A6-E77D-4FEA-8438-77B3E5737708

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES ErrorRecordModule PowerShellModule PublishModules

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .SYNOPSIS
    Publish newly created PowerShell modules.

    .DESCRIPTION
    `PublishModule.ps1` publishes newly created PowerShell modules.
#>

#requires -Module ErrorRecordModule
#requires -Module PowerShellModule
#requires -Module PublishModules

[CmdletBinding()]
param(
    [ValidateSet('Debug', 'Release')]
    [string]
    $Configuration = 'Release',

    [ValidateSet('All', 'Latest', 'Stack', 'NetCore', 'ServiceManagement', 'AzureStorage')]
    [string]
    $Scope,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ApiKey,

    [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
        ErrorMessage = "RepositoryLocation '{0}' is not a valid, absolute PowerShell NuGet repository")]
    [string]
    $RepositoryLocation = 'https://proget.opm.gov/nuget/SkyOps-PowerShell/v2',

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
        ErrorMessage = "NugetExe '{0}' is not a valid path leaf")]
    [string]
    $NugetExe,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $TempRepoName,

    [switch]
    $IsNetCore,

    [switch]
    $PublishLocal
)

<###################################
#
#           Setup/Execute
#
###################################>

Write-Information -MessageData "Publishing $Scope package (and its dependencies)" -InformationAction Continue

Get-PackageProvider -Name NuGet -Force

# NOTE: Can only be Azure or Azure Stack, not both.
$packageFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\artifacts' -Resolve

if ($Scope -eq 'Stack') {
    $packageFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\src\Stack' -Resolve
}

# Set temporary repo location
[string]$tempRepoPath = "$packageFolder"

if ($Scope -eq 'Stack') {
    $tempRepoPath = (Join-Path -Path $RepositoryLocation -ChildPath "Stack")
} else {
    $tempRepoPath = (Join-Path -Path $RepositoryLocation -ChildPath "..\artifacts" -Resolve)
}

New-Item -Path $tempRepoPath -ItemType Directory -Force | Out-Null

$repo = Get-PSRepository | Where-Object -FilterScript { $_.SourceLocation -eq $tempRepoPath }

if ($null -ne $repo) {
    $tempRepoName = $repo.Name
} else {
    Register-PSRepository -Name $tempRepoName -SourceLocation $tempRepoPath -PublishLocation $tempRepoPath -InstallationPolicy Trusted -PackageManagementProvider NuGet
}

$env:PSModulePath += ";$tempRepoPath"

try {
    $modules = Get-AllModules -BuildConfig $Configuration -Scope $Scope -PublishLocal:$PublishLocal.IsPresent -IsNetCore:$IsNetCore.IsPresent
    Add-AllModules -ModulePaths $modules -TempRepo $tempRepoName -TempRepoPath $tempRepoPath -NugetExe $NugetExe
    Publish-AllModules -ModulePaths $modules -ApiKey $ApiKey -TempRepoPath $tempRepoPath -RepoLocation $RepositoryLocation -NugetExe $NugetExe -PublishLocal:$PublishLocal.IsPresent
} catch {
    $Errors | Write-Fatal
} finally {
    Unregister-PSRepository -Name $tempRepoName
}

if ($null -ne $Errors) {
    exit 1
}
else {
    exit 0
}
