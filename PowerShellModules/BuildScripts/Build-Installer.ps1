<#
 =============================================================================
<copyright file="Build-Installer.ps1" company="John Merryweather Cooper
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
This file "Build-Installer.ps1" is part of "BuildScripts".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID F9FCEFCF-13D9-4113-8534-4353C051CA6C

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

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
    Build Windows Installer XML (WiX) installer.
#>

[CmdletBinding()]
param ()

$scriptFolder = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. ($scriptFolder + '.\SetupEnv.ps1')

$packageFolder = "$env:AzurePSRoot\artifacts"

if (Test-Path $packageFolder) {
    Remove-Item -Path $packageFolder -Recurse -Force
}

if (Get-Command -Name wix) {
    $wixPath = Get-Command -Name wix | Select-Object -ExpandProperty Path
    $wixInstallRoot = Get-ItemProperty -LiteralPath $wixPath -Name DirectoryName

    Write-Verbose -Message "WIX tools was installed at $wixInstallRoot"
    break
}
else {
    Write-Warning -Message "You do not have Windows Installer XML Toolset installed, which is needed to build setup."
    & dotnet tool install wix --global

    if ($LASTEXITCODE -eq 0) {
        Write-Verbose -Message "Install of WiX succeeded"
    }
    elseif ($LASTEXITCODE -gt 0) {
        Write-Warning -Message (("Install of WiX had errors '{0}|0x{0:X8}' that indicate failure") -f $LASTEXITCODE)
    }
    else {
        Write-Error -Message (("Install of WiX had errors '{0}|0x{0:X8}' that indicate system failure") -f $LASTEXITCODE) -ErrorCategory InvalidResult -ErrorId 'BuildInstaller-SystemFailure-01' -TargetObject $LASTEXITCODE
        throw (("Install of WiX had errors '{0}|0x{0:X8}' that indicate system failure") -f $LASTEXITCODE)
    }
}

# Regenerate the installer files
$generatePath = Join-Path -Path $env:AzurePSRoot -ChildPath 'tools\Installer\generate.ps1' -Resolve
& "$generatePath" 'Debug'

# Build the cmdlets and installer in debug mode
$projectPath = Join-Path -Path $env:AzurePSRoot -ChildPath 'build.proj' -Resolve
& msbuild /t:Build "$projectPath"

Write-Information -MessageData "MSI output file path: $env:AzurePSRoot\setup\build\Debug\AzurePowerShell.msi" -InformationAction Continue
