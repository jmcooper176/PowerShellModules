<#
 =============================================================================
<copyright file="Build-Installer.ps1" company="John Merryweather Cooper">
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
    Build Windows Installer XML (WiX) installer.
#>

$scriptFolder = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. ($scriptFolder + '.\SetupEnv.ps1')

$packageFolder = "$env:AzurePSRoot\artifacts"
if (Test-Path -LiteralPath $packageFolder -PathType Container) {
    Remove-Item -Path $packageFolder -Recurse -Force
}

$keyPath = "HKLM:\SOFTWARE\Microsoft\Windows Installer XML"
if (${env:ADX64Platform}) {
    $keyPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows Installer XML"
}

$allWixVersions = Get-ChildItem $keyPath
if ($null -ne $allWixVersions) {
    foreach ($wixVersion in $allWixVersions) {
        $wixInstallRoot = $wixVersion.GetValue("InstallRoot", $null)
        if ($null -ne $wixInstallRoot) {
            Write-Verbose -Message "WIX tools were installed at $wixInstallRoot"
            break
        }
    }
}

if ($null -eq $wixInstallRoot) {
    Write-Warning -Message "You don't have Windows Installer XML Toolset installed, which is needed to build setup."
    Write-Informatioon -MessageData "Press (Y) to install through codeplex web page we will open for you; (N) to skip" -InformationAction Continue

    $keyPressed = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")

    if ($keyPressed.Character -eq "y" ) {
        Start-Process -FilePath 'cmd.exe' -ArgumentList "/C start http://wix.codeplex.com/downloads/get/762937" -Wait
        Read-Host "Press any key to continue after the installation is finished"
    }
}

#add wix to the PATH. Note, no need to be very accurate here,
#and we just register both 3.8 & 3.5 to simplify the script
$env:path = $env:path + ";$wixInstallRoot"

# Regenerate the installer files
&"$env:AzurePSRoot\tools\Installer\generate.ps1" 'Debug'

# Build the cmdlets and installer in debug mode
msbuild "$env:AzurePSRoot\build.proj" /t:Build

Write-Information -MessageData "MSI file path: $env:AzurePSRoot\setup\build\Debug\AzurePowerShell.msi" -InformationAction Continue
