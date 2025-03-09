<#
 =============================================================================
<copyright file="post-build.ps1" company="John Merryweather Cooper">
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
This file "post-build.ps1" is part of "BuildScripts".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 5758B7FA-9405-40FA-A311-255E0FA7A712

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/BuildScripts

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .DESCRIPTION
    Post-build processing.
#>

[CmdletBinding()]
param ()

$DebugPreference = 'SilentlyContinue'
$InformationPreference = 'Continue'
$VerbosePreference = 'SilentlyContinue'
$WarningPreference = 'Continue'
$ErrorActionPreference = 'Continue'
$ConfirmPreference = 'None'

$ScriptName = Initialize-PSScript -MyInvocation $MyInvocation
Write-Information -MessageData "$($ScriptName):  Computing project variables" -Tags @($scriptName, 'Visual Studio', '2022') -InformationAction Continue

$visualStudioVersion = $env:VisualStudioVersion

$dumpList = [System.Collections.ArrayList]::new() | Out-Null
$dumpList.Add("$($ScriptName): + ==================================================") | Out-Null
$dumpList.Add("$($ScriptName): + ") | Out-Null
$dumpList.Add("$($ScriptName): +                                   $($ScriptName.ToUpperInvariant())") | Out-Null
$dumpList.Add("$($ScriptName): + --------------------------------------------------") | Out-Null
$dumpList.Add("$($ScriptName): +      VisualStudioVersion:         $($visualStudioVersion)") | Out-Null
$dumpList.Add("$($ScriptName): + ") | Out-Null
$dumpList.Add("$($ScriptName): + ==================================================") | Out-Null

$dumpList.ToArray() | ForEach-Object -Process { $_ | Write-Output }

Write-Information -MessageData "$($ScriptName):  Post-Build Processing" -Tags @($scriptName, 'Visual Studio', '2022') -InformationAction Continue
