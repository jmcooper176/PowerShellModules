<#
 =============================================================================
<copyright file="ApplyVersionToAssemblies.ps1" company="John Merryweather Cooper">
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
This file "ApplyVersionToAssemblies.ps1" is part of "ApplyVersionToAssemblies".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 9C8986F3-3971-4D5E-A02E-EF2FAEE8A0F6

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.apache.org/licenses/LICENSE-2.0

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/ApplyVersionToAssemblies

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES GitHubModule, VersionModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

#requires -Module GitHubModule
#requires -Module VersionModule

<#
    .SYNOPSIS
    Apply the build number to the assembly version and file version.

    .DESCRIPTION
    `ApplyVersionToAssemblies.ps1` applies the build number to the assembly
    version and file version found either in AssemblyInfo.cs-style files or
    in <c>CSPROJ</c> files.

    The script looks for a '(\d{1,5})(\.\d{1,5}){2,3}' regular expression pattern in the build
    number string.

    If found, it used the parsed BuildNumber to initialize processing used to
    version the assemblies.

    .EXAMPLE
    PS> ApplyVersionToAssemblies.ps1 -SourceDirectory "C:\code\FabrikamTFVC\HelloWorld" -BuildNumber "Build HelloWorld_2013.07.19.1"

    For example, if the 'Build number format' parameter BuildNumber is of a
    format:

    $(BuildDefinitionName)_$(Year:yyyy).$(Month).$(DayOfMonth)$(Rev:.r)

    then the build numbers come out like this:
    # "Build HelloWorld_2013.07.19.1"
    # This script would then apply version 2013.07.19.1 to your assemblies.
#>

[CmdletBinding()]
param (
    [ValidatePattern('(\d{1,5})(\.\d{1,5}){2,3}')]
    [string]
    $BuildNumber = $Env:BUILD_BUILDNUMBER,

    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $SourceDirectory = $Env:BUILD_SOURCESDIRECTORY
)

$ScriptName = Initialize-PSScript -MyInvocation $MyInvocation
Set-Variable -Name VERSION_REGEX -Option Constant -Value '(\d{1,5})(\.\d{1,5}){2,3}'

$SourceDirectory = Resolve-Path -LiteralPath $SourceDirectory

Write-Verbose -Message "BUILD_SOURCESDIRECTORY: $SourceDirectory"
Write-Verbose -Message "BUILD_BUILDNUMBER: $BuildNumber"

if ($BuildNumber -match $VERSION_REGEX) {
    $result = [System.Version]::new(1, 0, 0, 0)

    for ($i = 0; $i -lt $Matches.Count; $i++) {
        $versionString += $Matches[$i]
    }

    if ([System.Version]::TryParse($versionString, [ref]$result)) {
        $buildVersion = $result
    }
    else {
        $buildVersion = [System.Version]::new(1, 0, 0, 0)
    }
}

$AssemblyVersion = New-AssemblyVersion -Major $buildVersion.Major -Minor $buildVersion.Minor -Build $buildVersion.Build
$AssemblyFileVersion = New-FileVersion -Major $buildVersion.Major -Minor $buildVersion.Minor
$SemVersion = New-SemanticVersion -Major $buildVersion.Major -Minor $buildVersion.Minor

# Apply the version to the assembly property files
Get-ChildItem -LiteralPath $SourceDirectory -Include "AssemblyVersion.*", "AssemblyInfo.*", "VersionInfo.*" -File -Recurse | ForEach-Object -Process {
    $file = $_.FullName
    Write-Verbose -Message "$($ScriptName):  Applying $($AssemblyVersion.ToString()) and $($AssemblyFileVersion.ToString()) to $($file) AssemblyInfo.cs-style files"
    Set-ItemProperty -LiteralPath $file -Name IsReadOnly -Value $false

    Get-Content -LiteralPath $file | ForEach-Object -Process {
        $line = $_

        if ($line -match "AssemblyVersion\(`"(.*)`"\)") {
            $line = $line -replace "AssemblyVersion\(`"(.*)`"\)", "AssemblyVersion(`"$($AssemblyVersion.ToString())`")"
        }
        elseif ($line -match "AssemblyFileVersion\(`"(.*)`"\)") {
            $line = $line -replace "AssemblyFileVersion\(`"(.*)`"\)", "AssemblyFileVersion(`"$($AssemblyFileVersion.ToString())`")"
        }
        elseif ($line -match "\[assembly: AssemblyInformationalVersion\(`"(.*)`"\)\]") {
            $line = $line -replace "\[assembly: AssemblyInformationalVersion\(`"(.*)`"\)\]", "[assembly: AssemblyInformationalVersion(`"$($SemVersion.ToString())`")]"
        }
        else {
            $line
        }
    } | Out-File -LiteralPath $file
    Write-Verbose -Message "$($scriptName):  AssemblyInfo.cs-style '$($file)' => assembly, file, and informational versions applied"
}

# Apply the version to the assembly property files
Get-ChildItem -LiteralPath $SourceDirectory -Include "*.*proj" -File -Recurse | ForEach-Object -Process {
    $projectFile = $_.FullName

    Write-Verbose -Message "$($ScriptName):  Applying $($AssemblyVersion.ToString()) and $($AssemblyFileVersion.ToString()) to $($projectFile) MsBuild Project file."
    Set-ItemProperty -LiteralPath $projectFile -Name IsReadOnly -Value $false

    Get-Content -LiteralPath $projectFile | ForEach-Object -Process {
        $line = $_

        if ($line -match "\<AssemblyVersion\>(.*)\</AssemblyVersion\>") {
            $line = $line -replace "\<AssemblyVersion\>(.*)\</AssemblyVersion\>", "<AssemblyVersion>$($AssemblyVersion.ToString())</AssemblyVersion>"
        }
        elseif ($line -match "\<FileVersion\>(.*)\</FileVersion\>") {
            $line = $line -replace "\<FileVersion\>(.*)\</FileVersion\>", "<FileVersion>$($AssemblyFileVersion.ToString())</FileVersion>"
        }
        elseif ($line -match "\<InformationalVersion\>(.*)\</InformationalVersion\>") {
            $line = $line -replace "\<InformationalVersion\>(.*)\</InformationalVersion\>", "<InformationalVersion>$($SemVersion.ToString())</InformationalVersion>"
        }
        else {
            $line
        }

        Write-Verbose -Message "$($ScriptName):  MsBuild Project File '$projectFile' => assembly, file, and informational versions applied"
    } | Out-File -LiteralPath $file
}

# Set GitHub Action output variables
Set-OutputParameter -Name 'assembly-version' -Value $AssemblyVersion.ToString()
Set-OutputParameter -Name 'file-version' -Value $AssemblyFileVersion.ToString()
Set-OutputParameter -Name 'semantic-version' -Value $SemVersion
