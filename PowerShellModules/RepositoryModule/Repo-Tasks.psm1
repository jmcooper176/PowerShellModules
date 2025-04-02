<#
 =============================================================================
<copyright file="Repo-Tasks.psm1" company="John Merryweather Cooper
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
This file "Repo-Tasks.psm1" is part of "Repo-Tasks".
</summary>
<remarks>description</remarks>
=============================================================================
#>

Import-Module -Name ".\Modules\Build-Tasks.psd1"
Import-Module -Name ".\Modules\TestFx-Tasks.psd1"

$taskScriptDir = Get-Item -LiteralPath $PSCommandPath
$env:repoRoot = Get-Item -LiteralPath $taskScriptDir
$userPsFileDir = [string]::Empty

Function Init() {
    [CmdletBinding()]
    param()

    #Initialize Code
}

<###########################################
We allow users to include any helper powershell scripts they would like to include in the current session
Currently we support two ways to include helper powershell scripts
1) psuserspreferences environment variable
2) $env:USERPROFILE\psFiles directory
We will include all *.ps1 files from any of the above mentioned locations
#>
if (Test-Path -LiteralPath $env:psuserpreferences -PathType Container) {
    $userPsFileDir = $env:psuserpreferences
}
elseif (Test-Path -LiteralPath "$env:USERPROFILE\psFiles" -PathType Container) {
    $userPsFileDir = "$env:USERPROFILE\psFiles"
}

if (-not [string]::IsNullOrEmpty($userPsFileDir)) {
    Get-ChildItem -LiteralPath $userPsFileDir | Where-Object -FilterScript { $_.Name -like "*.ps1" } | ForEach-Object -Process {
        Write-Information -MessageData "Including $_" -InformationAction Continue
        . $userPsFileDir\$_
    }
}
else {
    Write-Information -MessageData "Loading skipped. '$env:PSUSERPREFERENCES' environment variable was not set to load user preferences." -InformationAction Continue
}

Write-Information -MessageData "For more information on the Repo-Tasks module, please see the following: https://github.com/Azure/azure-powershell/blob/preview/documentation/testing-docs/repo-tasks-module.md" -InformationAction Continue

#Execute Init
#Init
