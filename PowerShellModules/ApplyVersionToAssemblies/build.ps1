<#
 =============================================================================
<copyright file="build.ps1" company="U.S. Office of Personnel
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
This file "build.ps1" is part of "ApplyVersionToAssemblies".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID F65C5682-EDAF-4124-BECC-B6AB48DCF671

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/OCIO-DEVSECOPS/PSInstallCom/Generate-ExternalContributors

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES ErrorRecordModule, PowerShellModule

    .REQUIREDSCRIPTS ApplyVersionToAssemblies

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES


    .PRIVATEDATA

#>

#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

<#
    .DESCRIPTION
    Build script for dotnet projects.
#>


[CmdletBinding()]
param (
    [switch]
    $Minimal,

    [switch]
    $Quiet
)

Set-StrictMode -Version 3
Set-Variable -Name scriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

if ($Minimal.IsPresent -and $Quiet.IsPresent)
{
    $newErrorRecordSplat = @{
        Exception = [System.ArgumentException]::new("The Minimal and Quiet parameters are mutually exclusive.")
        ErrorId = Format-ErrorId -Caller $scriptName -Name 'ArgumentException' -Postion $MyInvocation.ScriptLineNumber
        Category = 'InvalidArgument'
        TargetObject = $Minimal
        TargetName = 'Minimal xor Quiet'
    }

    New-ErrorRecord @newErrorRecordSplat | Write-Fatal
}

if (Test-PSParameter -Name 'Verbose' -Parameters $PSBoundParameters)
{
    $verbosity = 'detailed'
}
elseif (Test-PSParameter -Name 'Debug' -Parameters $PSBoundParameters)
{
    $verbosity = 'diagnostic'
}
elseif ($Minimal.IsPresent)
{
    $verbosity = 'minimal'
}
elseif ($Quiet.IsPresent)
{
    $verbosity = 'quiet'
}
else
{
    $verbosity = 'normal'
}

git pull
Push-Location -Path (Get-Location).Path
.\src\ApplyVersionToAssemblies.ps1 -SourceDirectory .\src -BuildNumber 'Build SFS-Main_19.5.0.0'
Set-Location -Path .\src
dotnet build --verbosity $verbosity
Pop-Location
