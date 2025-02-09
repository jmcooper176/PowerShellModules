<#
 =============================================================================
<copyright file="Push-Package.ps1" company="U.S. Office of Personnel
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
This file "Push-Package.ps1" is part of "Push-Package".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID E9D08D58-B84E-4957-9D5D-3C8295CB74CF

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/OCIO-DEVSECOPS/PSInstallCom/Generate-ExternalContributors

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES PowerShellModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES


    .PRIVATEDATA

#>

<#
    .DESCRIPTION
    Push NuGet package to a NuGet feed.
#>


[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $ApiKey,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Package,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Source
)

Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
Set-StrictMode -Version 3

$fileInfo = Get-Item -LiteralPath $Package
$packageDir = $fileInfo.DirectoryName
$packageName = $fileInfo.Name

$nugetSplat = @(
    'push',
    "$($packageName)",
    "$($ApiKey)",
    '-Source', "$($Source)",
    '-NonInteractive',
    '-SkipDuplicate'
)

if ($PSCmdlet.ShouldProcess($packageName, $ScriptName)) {
    Push-Location -LiteralPath $packageDir
    nuget @nugetSplat
    Pop-Location
}
