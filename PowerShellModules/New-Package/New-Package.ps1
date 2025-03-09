<#
 =============================================================================
<copyright file="New-Package.ps1" company="John Merryweather Cooper">
    Copyright © 2022-2025, John Merryweather Cooper.
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
This file "New-Package.ps1" is part of "New-Package".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID E7F4BC02-873F-4199-9650-BDAC237B02DF

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/Generate-ExternalContributors

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES PowerShellModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

#requires -Module PowerShellModule

<#
    .DESCRIPTION
    Generates a new NuGet package.
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [Alias('PSPath')]
    [string]
    $NuSpecPath,

    [Parameter(Mandatory)]
    [Alias('Version')]
    [System.Version]
    $PackageVersion,

    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $OutputDirectory = (Get-Location),

    [ValidateNotNullOrEmpty()]
    [Alias('Suffix')]
    [string]
    $PreRelease,

    [switch]
    $NotTool
)

Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
Set-StrictMode -Version 3

$fileInfo = Get-Item -LiteralPath $NuSpecPath
$nuspecDir = $fileInfo.DirectoryName
$nuspecName = $fileInfo.Name

$nugetSplat = @(
    'pack',
    "$($nuspecName)",
    '-OutputDirectory', "$OutputDirectory",
    '-Version', "$($PackageVersion.ToString(3))",
    '-NonInteractive'
)

if ((Test-PSParameter -Name 'PreRelease' -Parameters $PSBoundParameters) -and $NotTool.IsPresent) {
    if ($PSCmdlet.ShouldProcess($NuSpecPath, $ScriptName)) {
        Push-Location -LiteralPath $nuspecDir
        & nuget @nugetSplat -Suffix $PreRelease
        Pop-Location
    }
} elseif (Test-PSParameter -Name 'PreRelease' -Parameters $PSBoundParameters) {
    if ($PSCmdlet.ShouldProcess($NuSpecPath, $ScriptName)) {
        Push-Location -LiteralPath $nuspecDir
        & nuget @nugetSplat -Suffix $PreRelease -Tool
        Pop-Location
    }
} elseif ($NotTool.IsPresent) {
    if ($PSCmdlet.ShouldProcess($NuSpecPath, $ScriptName)) {
        Push-Location -LiteralPath $nuspecDir
        & nuget @nugetSplat
        Pop-Location
    }
} else {
    if ($PSCmdlet.ShouldProcess($NuSpecPath, $ScriptName)) {
        Push-Location -LiteralPath $nuspecDir
        & nuget @nugetSplat -Tool
        Pop-Location
    }
}
