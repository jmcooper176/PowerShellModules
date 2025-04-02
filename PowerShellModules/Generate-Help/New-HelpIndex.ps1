<#
 =============================================================================
<copyright file="New-HelpIndex.ps1" company="John Merryweather Cooper
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
This file "New-HelpIndex.ps1" is part of "Generate-Help".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 59512078-FE9F-43D6-A817-59592B371E9A

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/Generate-ExternalContributors

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .DESCRIPTION
    Generate help index.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]
    $Version,

    [ValidateSet('Latest', 'Stack')]
    [string]
    $Target = 'Latest',

    [string]
    $SourceBaseUri,

    [string]
    $EditBaseUri,

    [ValidateSet('Debug', 'Release')]
    [string]
    $BuildConfig = 'Debug',

    [string]
    $OutputFile = "$PSScriptRoot/index.json"
)

Import-LocalizedData -BindingVariable "Azpsd1" -BaseDirectory $PSScriptRoot/Az -FileName "Az.psd1"

if ([string]::isNullOrEmpty($Version)) {
    $Version = $Azpsd1.ModuleVersion
    Write-Host "Using version obtained from Az.psd1: $Version." -ForegroundColor Green;
}

if ([string]::isNullOrEmpty($SourceBaseUri)) {
    $tag = $Azpsd1.PrivateData.PSData.ReleaseNotes.Split("`n")[0].Replace(" ", "").Trim("`r")
    $SourceBaseUri = "https://github.com/Azure/azure-powershell/tree/v$tag"
    Write-Host "Using default SourceBaseUri: $SourceBaseUri." -ForegroundColor Green;
}

if ([string]::isNullOrEmpty($EditBaseUri)) {
    $EditBaseUri = "https://github.com/Azure/azure-powershell/blob/main"
    Write-Host "Using default EditBaseUri: $EditBaseUri." -ForegroundColor Green;
}

$output = @{}
$output.Add("name", "Az")
$output.Add("target", "$Target")
$output.Add("version", "$Version")

$outputModules = @{}

#Create mappings file
& "$PSScriptRoot/CreateMappings.ps1" -OutputFile $OutputFile/../groupMapping.json -WarningFile $OutputFile/../groupMappingWarnings.json
$labelMapping = Get-Content -Raw $OutputFile/../groupMapping.json | ConvertFrom-Json

$RMpsd1s = @()
$HelpFolders = @()

$resourceManagerPath = "$PSScriptRoot/../artifacts/$BuildConfig/"

$RMpsd1s += Get-ChildItem -Path $resourceManagerPath -Depth 1 | Where-Object -FilterScript {
    $_.Name -like "*.psd1" -and $_.FullName -notlike "*dll-Help*"
}

& ($PSScriptRoot + "\PreloadToolDll.ps1")
$HelpFolders += Get-ChildItem -Path "$PSScriptRoot/../src" -Recurse -Directory | where { $_.Name -eq "help" -and (-not [Tools.Common.Utilities.ModuleFilter]::IsAzureStackModule($_.FullName)) -and $_.FullName -notlike "*\bin\*" -and (-not $_.Parent.BaseName.EndsWith(".Autorest")) }

# Map the name of the cmdlet to the location of the help file
$HelpFileMapping = @{}
$HelpFolders | ForEach-Object -Process {
    $helpFiles = Get-ChildItem -Path $_.FullName
    $helpFiles | ForEach-Object -Process {
        if ($HelpFileMapping.Contains($_.Name)) {
            throw "Two files exist with the name $_ in $($_.FullName)"
        }
        else {
            $HelpFileMapping.Add("$($_.Name)", $_.FullName)
        }
    }
}

$outputModules = @{}

$RMpsd1s | ForEach-Object -Process {
    Import-LocalizedData -BindingVariable "parsedPsd1" -BaseDirectory $_.DirectoryName -FileName $_.Name

    $outputCmdlets = @{}

    $cmdletsToExport = $parsedPsd1.CmdletsToExport | Where-Object -FilterScript { $_ }
    $functionsToExport = $parsedPsd1.FunctionsToExport | Where-Object -FilterScript { $_ }
    $cmdletsToExport = @() + $cmdletsToExport + $functionsToExport

    $cmdletsToExport | ForEach-Object -Process {
        $cmdletHelpFile = $HelpFileMapping["$_.md"]
        if ($cmdletHelpFile -eq $null -and $Target -eq "Latest") {
            throw "No help file found for cmdlet $_"
        }

        $cmdletLabel = $labelMapping.$_
        if ($cmdletLabel -eq $null -and $Target -eq "Latest") {
            throw "No label found for cmdlet $_"
        }

        $helpSourceUrl = "$SourceBaseUri\src\$(($cmdletHelpFile -split "\\src\\*")[1])".Replace("\", "/")
        $helpEditUrl = "$EditBaseUri\src\$(($cmdletHelpFile -split "\\src\\*")[1])".Replace("\", "/")
        $outputCmdlets.Add("$_", @{"service" = $cmdletLabel; "sourceUrl" = $helpSourceUrl; "editUrl" = $helpEditUrl })
    }

    $moduleHelpFile = $HelpFileMapping["$($_.BaseName).md"]

    if ($moduleHelpFile -eq $null -and $Target -eq "Latest") {
        throw "No module help file found for module $($_.BaseName)"
    }

    $moduleSourceUrl = "$SourceBaseUri\src\$(($moduleHelpFile -split "\\src\\*")[1])".Replace("\", "/")
    $moduleEditUrl = "$EditBaseUri\src\$(($moduleHelpFile -split "\\src\\*")[1])".Replace("\", "/")

    if ($moduleHelpFile -ne $null) {
        $outputModules.Add("$($_.BaseName)", @{"module" = @{"sourceUrl" = $moduleSourceUrl; "editUrl" = $moduleEditUrl }; "cmdlets" = $outputCmdlets })
    }
}

$output.Add("modules", $outputModules)
$json = ConvertTo-Json $output -Depth 4
Write-Host "Index file successfully created: $OutputFile." -ForegroundColor Green;
$json | Out-File $OutputFile
