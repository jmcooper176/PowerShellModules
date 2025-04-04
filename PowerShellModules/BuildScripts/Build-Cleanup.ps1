﻿<#
 =============================================================================
<copyright file="Build-Cleanup.ps1" company="John Merryweather Cooper
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
This file "Build-Cleanup.ps1" is part of "BuildScripts".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 9C8986F3-3971-4D5E-A02E-EF2FAEE8A0F6

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
.SYNOPSIS
    Clean up unrelated files before nuget publish

.PARAMETER GenerateDocumentationFile
    Decide whether keeps XML files
#>

[CmdletBinding()]
param
(
    [ValidateSet('Debug', 'Release')]
    [string]
    $BuildConfig = 'Debug',

    [switch]
    $GenerateDocumentationFile
)

$output = Join-Path -Path (Get-Item $PSScriptRoot).Parent.FullName -ChildPath "artifacts\$BuildConfig"
Write-Verbose -Message "The output folder is set to $output"
$resourceManagerPath = $output

$outputPaths = @($output)
$resourcesFolders = @("de", "es", "fr", "it", "ja", "ko", "ru", "zh-Hans", "zh-Hant", "cs", "pl", "pt-BR", "tr")
$keepItems = @("*.dll-Help.xml", "Scaffold.xml", "RoleSettings.xml", "WebRole.xml", "WorkerRole.xml")
$removeItems = @("*.lastcodeanalysissucceeded", "*.dll.config", "*.pdb")
$webdependencies = @("Microsoft.Web.Hosting.dll", "Microsoft.Web.Delegation.dll", "Microsoft.Web.Administration.dll", "Microsoft.Web.Deployment.Tracing.dll")

if (-not $GenerateDocumentationFile.IsPresent) {
    Write-Verbose -Message "Removing *.xml files from $output"
    $removeItems += "*.xml"
}

$outputPaths | ForEach-Object -Process {
    $path = $_

    Write-Verbose -Message "Removing generated NuGet folders from $path"
    Get-ChildItem -Include $resourcesFolders -Recurse -Force -Path $path | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

    Write-Verbose -Message "Removing autogenerated XML help files, code analysis, config files, and symbols."
    Get-ChildItem -Include $removeItems -Exclude $keepItems -Recurse -Path $path | Remove-Item -Force -Recurse
    Get-ChildItem -Recurse -Path $path -Include *.dll-Help.psd1 | Remove-Item -Force

    Write-Verbose -Message "Removing markdown help files and folders"
    Get-ChildItem -Recurse -Path $path -Include *.md | Remove-Item -Force -Confirm:$false
    Get-ChildItem -Directory -Include help -Recurse -Path $path | Remove-Item -Force -Recurse -Confirm:$false -ErrorAction "Ignore"

    Write-Verbose -Message "Removing unneeded web deployment dependencies"
    Get-ChildItem -Include $webdependencies -Recurse -Path $path | Remove-Item -Force
}

@($resourceManagerPath) | ForEach-Object -Process {
    $RMPath = $_

    Get-ChildItem -Path $RMPath -Directory | ForEach-Object -Process {
        $RMFolder = $_

        $psd1 = Get-ChildItem -Path $RMFolder.FullName -Filter "$($RMFolder.Name).psd1"

        if ($null -eq $psd1) {
            Write-Information -MessageData "Could not find .psd1 file in folder $RMFolder" -InformationAction Continue
            continue
        }

        Import-LocalizedData -BindingVariable ModuleMetadata -BaseDirectory $psd1.DirectoryName -FileName $psd1.Name

        $acceptedDlls = @(
            # netcoreapp, can't be in RequiredAssemblies, but we need to pack it
            "Microsoft.Azure.PowerShell.AuthenticationAssemblyLoadContext.dll",

            # customized AutoMapper
            "Microsoft.Azure.PowerShell.AutoMapper.dll"
        )

        # NestedModule Assemblies may have a folder path, just getting the dll name alone
        $ModuleMetadata.NestedModules | ForEach-Object -Process {
            $cmdAssembly = $_

            # if the nested module is script module, we need to keep the dll behind the script module
            if ($cmdAssembly.EndsWith(".psm1")) {
                if (!$cmdAssembly.Contains("/") -and !$cmdAssembly.Contains("\")) {
                    $acceptedDlls += "Microsoft.Azure.PowerShell.Cmdlets." + $cmdAssembly.Split(".")[-2] + ".dll"
                }

                continue
            }

            if ($cmdAssembly.Contains("/")) {
                $acceptedDlls += $cmdAssembly.Split("/")[-1]
            }
            else {
                $acceptedDlls += $cmdAssembly.Split("\")[-1]
            }
        }

        # RequiredAssmeblies may have a folder path, just getting the dll name alone
        $ModuleMetadata.RequiredAssemblies | ForEach-Object -Process {
            $assembly = $_

            if ($assembly.Contains("/")) {
                $acceptedDlls += $assembly.Split("/")[-1]
            }
            else {
                $acceptedDlls += $assembly.Split("\")[-1]
            }
        }

        Write-Information -MessageData "Removing redundant dlls in $($RMFolder.Name)" -InformationAction Continue
        $removedDlls = Get-ChildItem -LiteralPath $RMFolder.FullName -Filter "*.dll" -Recurse |
            Where-Object -FilterScript { $acceptedDlls -notcontains $_.Name -and !$_.FullName.Contains("Assemblies") }

            # do not remove lib dlls (for example Az.Accounts/lib/netcoreapp2.1/Azure.Core.dll)
            $libPattern = [System.IO.Path]::DirectorySeparatorChar + "lib" + [System.IO.Path]::DirectorySeparatorChar;
            $removedDlls |
                Where-Object -FilterScript { -not $_.FullName.Contains($libPattern) } |
                ForEach-Object -Process {
                    Write-Information -MessageData "Removing $($_.Name)" -InformationAction Continue
                    Remove-Item -Path $_.FullName -Force
                }

                Write-Information -MessageData "Removing scripts and psd1 in $($RMFolder.FullName)" -InformationAction Continue

                $exludedPsd1 = @(
                    "PsSwaggerUtility*.psd1",
                    "Az.KeyVault.Extension.psd1"
                )

                $removedPsd1 = Get-ChildItem -Path "$($RMFolder.FullName)" -Include "*.psd1" -Exclude $exludedPsd1 -Recurse |
                    Where-Object -FilterScript {
                        $_.FullName -ne "$($RMFolder.FullName)$([IO.Path]::DirectorySeparatorChar)$($RMFolder.Name).psd1"
                    }
                    $removedPsd1 | ForEach-Object -Process {
                        Write-Information -MessageData "Removing $($_.FullName)"  -InformationAction Continue
                        Remove-Item -Path $_.FullName -Force
                    }
                }
            }
