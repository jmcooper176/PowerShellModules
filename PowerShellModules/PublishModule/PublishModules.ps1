<#
 =============================================================================
<copyright file="PublishModules.ps1" company="U.S. Office of Personnel
Management">
    Copyright (c) 2022-2025, John Merryweather Cooper.
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

#requires -Module ErrorRecordModule
#requires -Module PublishModules

[CmdletBinding()]
param(
    [ValidateSet('Debug', 'Release')]
    [string]
    $Configuration,

    [ValidateSet('All', 'Latest', 'Stack', 'NetCore', 'ServiceManagement', 'AzureStorage')]
    [string]
    $Scope,

    [ValidateNotNullOrEmpty()]
    [string]
    $ApiKey,

    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $RepositoryLocation,

    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]
    $NugetExe,

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

if (-not $PSBountParameters.ContainsKey('Configuration')) {
    Write-Verbose "Setting build configuration to 'Release'"
    $buildConfig = "Release"
}

if (-not $PSBountParameters.ContainsKey('RepositoryLocation')) {
    Write-Verbose -Message "Setting repository location to 'https://proget.opm.gov/nuget/SkyOps-PowerShell/v2'"
    $repositoryLocation = 'https://proget.opm.gov/nuget/SkyOps-PowerShell/v2'
}

if (-not $PSBoundParameters.ContainsKey('NugetExe')) {
    Write-Verbose -Message "Determining NuGet path"
    $nugetExe = Get-Command -All | Where-Object -FilterScript { $_.Name -eq 'nuget.exe' } | Select-Object -ExpandProperty Source
}

Write-Information -MessageData "Publishing $Scope package (and its dependencies)" -InformationAction Continue

Get-PackageProvider -Name NuGet -Force
Write-Information -MessageData ([Environment]::NewLine) -InformationAction Continue

# NOTE: Can only be Azure or Azure Stack, not both.
$packageFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\artifacts' -Resolve

if ($Scope -eq 'Stack') {
    $packageFolder = Join-Path -Path $PSScriptRoot -ChildPath '..\src\Stack' -Resolve
}

# Set temporary repo location
[string]$tempRepoPath = "$packageFolder"

if (Test-Path -LiteralPath $RepositoryLocation -PathType Container) {
    if ($Scope -eq 'Stack') {
        $tempRepoPath = (Join-Path -Path $RepositoryLocation -ChildPath "Stack")
    } else {
        $tempRepoPath = (Join-Path -Path $RepositoryLocation -ChildPath "..\artifacts" -Resolve)
    }
}

New-Item -Path $tempRepoPath -ItemType Directory -Force | Out-Null

$tempRepoName = ([System.Guid]::NewGuid()).ToString()

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
    Publish-AllModules -ModulePaths $modules -ApiKey $apiKey -TempRepoPath $tempRepoPath -RepoLocation $repositoryLocation -NugetExe $NugetExe -PublishLocal:$PublishLocal.IsPresent
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
