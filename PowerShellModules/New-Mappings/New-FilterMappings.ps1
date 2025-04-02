<#
 =============================================================================
<copyright file="New-FilterMappings.ps1" company="John Merryweather Cooper
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
This file "New-FilterMappings.ps1" is part of "New-Mappings".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID B5319C07-CB71-4A9E-9BEA-E72CDEBC863D

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES PowerShellModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

#requires -Version 7.4

<#
    .SYNOPSIS
    Generate new file mappings for cmdlets to documentation groups.

    .DESCRIPTION
    `New-Mappings.ps1` generates new file mappings for cmdlets to documentation groups.

    .OUTPUTS
    [hashtable]  Returns an ordered hashtable with the following paths having empty mappings:
    - All files at the root of the repository
    - All folders at the root of the repository (except "src")
    - All files in the "src" folder
#>

function Initialize-Mappings {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $false)]
        [string[]]$PathsToIgnore,

        [Parameter(Mandatory = $false)]
        [Hashtable]$CustomMappings
    )

    $Mappings = [ordered]@{}
    Get-ChildItem -Path $Script:RootPath -File | ForEach-Object -Process { $Mappings[$_.Name] = @() }
    Get-ChildItem -Path $Script:RootPath -Directory | Where-Object -FilterScript { $_.Name -ne "src" } | ForEach-Object -Process { $Mappings[$_.Name] = @() }
    Get-ChildItem -Path $Script:SrcPath -File | ForEach-Object -Process { $Mappings["src/$_.Name"] = @() }

    if ($CustomMappings -ne $null) {
        $CustomMappings.GetEnumerator() | ForEach-Object -Process { $Mappings[$_.Name] = $_.Value }
    }

    $PathsToIgnore | ForEach-Object -Process {
        $Mappings[$_] = $null
        $Mappings.Remove($_)
    }

    $Mappings | Write-Output
}

<##########################################
Converts a hashtable into a compressed JSON and formats it for display.
##########################################>
function Format-Json {
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [hashtable]$InputObject
    )

    $Tab = "    "
    return $InputObject | ConvertTo-Json -Depth 4 -Compress | ForEach-Object -Process { $_.Replace("{", "{`n$Tab").Replace("],", "],`n$Tab").Replace(":[", ":[`n$Tab$Tab").Replace("`",", "`",`n$Tab$Tab").Replace("`"]", "`"`n$Tab]").Replace("]}", "]`n}") }
}

<##########################################
Turns a file path into a normalized key (strips out everything before "src").
##########################################>
function Create-Key {
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $Key = ""
    $TempFilePath = $FilePath
    while ($true) {
        $TempItem = Get-Item -Path $TempFilePath
        $Name = $TempItem.Name
        $Key = $Name + "/" + $Key
        if ($Name -eq "src") {
            break
        }

        if ($null -ne $TempItem.Parent) {
            $TempFilePath = $TempItem.Parent.FullName
        }
        else {
            $TempFilePath = $TempItem.Directory.FullName
        }
    }

    return $Key
}

function Create-ProjectToFullPathMappings {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $Mappings = [ordered]@{}

    $script:ServiceFolders | ForEach-Object {
        Get-ChildItem -LiteralPath $_ -Filter "*.csproj" -Recurse | ForEach-Object -Process {
            if ($Mappings.Contains($_.BaseName)) {
                throw ($_.FullName + " is conflicts with " + $Mappings[$_.BaseName])
            }

            $Mappings[$_.BaseName] = Resolve-Path -Path $_.FullName -RelativeBasePath $PSScriptRoot -Relative
        }
    }

    $Mappings | Write-Output
}

<##########################################
Creates a mapping from a solution file to the projects it references. For example:

{
    "C:\\azure-powershell\\src\\Aks\\Aks.sln":[
        "Commands.Aks",
        "Commands.Resources.Rest",
        "Commands.Resources"
    ],
    "C:\\azure-powershell\\src\\AnalysisServices\\AnalysisServices.sln":[
        "Commands.AnalysisServices",
        "Commands.AnalysisServices.Dataplane"
    ],
    ...
}
##########################################>
function Create-SolutionToProjectMappings {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $Mappings = [ordered]@{}

    $script:ServiceFolders | ForEach-Object -Process {
        Get-ChildItem -LiteralPath $_.FullName -Filter "*.sln" -Recurse | ForEach-Object -Process {
            $Mappings = Add-ProjectDependencies -Mappings $Mappings -SolutionPath $_.FullName
        }
    }

    $Mappings | Write-Output
}

<##########################################
Parses a solution file to find the projects it is composed of (excluding common projects).
##########################################>
function Add-ProjectDependencies {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]
        $Mappings,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "SolutionPath '{0}' is not a valid path leaf"
        )]
        [string]
        $SolutionPath
    )

    $CommonProjectsToIgnore = @("ScenarioTest.ResourceManager", "TestFx", "Tests" )
    $CsprojList = @()
    $Content = Get-Content -Path $SolutionPath
    $SolutionFoloderPath = Split-Path -Parent $SolutionPath
    $Content | Select-String -Pattern "`"[a-zA-Z0-9`.`\\`/]*.csproj`"" | ForEach-Object -Process { $_.Matches[0].Value.Trim('"') } | Where-Object -FilterScript { $CommonProjectsToIgnore -notcontains $_ } | ForEach-Object -Process { $CsprojList += $_ }

    $CsprojList | ForEach-Object -Process {
        if (-not (Test-Path -LiteralPath (Join-Path -Path $SolutionFoloderPath -ChildPath $_) -PathType Leaf)) {
            Write-Error -Message "$($SolutionPath):  $_ is not found!" -ErrorCategory ObjectNotFound -ErrorId 'Add-ProjectDependencies-FileNotFoundException-01' -TargetObject $_
        }
    }

    $Mappings[$SolutionPath] = $CsprojList | ForEach-Object -Process { (Split-Path -Path $_ -Leaf).Replace('.csproj', '') }
    $Mappings | Write-Output
}

<##########################################
Creates a mapping from a project to its parent solution. For example:

{
    "Commands.Aks":[
        "C:\\azure-powershell\\src\\Aks\\Aks.sln"
    ],
    "Commands.AnalysisServices":[
        "C:\\azure-powershell\\src\\AnalysisServices\\AnalysisServices.sln"
    ],
    "Commands.AnalysisServices.Dataplane":[
        "C:\\azure-powershell\\src\\AnalysisServices\\AnalysisServices.sln"
    ],
    ...
}
##########################################>
function Create-ProjectToSolutionMappings {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $Mappings = [ordered]@{}

    $script:SeviceFolders | ForEach-Object -Process {
        $Mappings = Add-SolutionReference -Mappings $Mappings -ServiceFolderPath $_.FullName
    }

    $Mappings | Write-Output
}

<##########################################
Map a project to the solution file it should be build with (e.g., Commands.Compute --> src/Compute/Compute.sln)
##########################################>
function Add-SolutionReference {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable]$Mappings,

        [Parameter(Mandatory = $true)]
        [string]$ServiceFolderPath
    )

    & ($PSScriptRoot + "\PreloadToolDll.ps1")
    $CsprojFiles = Get-ChildItem -Path $ServiceFolderPath -Filter "*.csproj" -Recurse | Where-Object -FilterScript { (-not [Tools.Common.Utilities.ModuleFilter]::IsAzureStackModule($_.FullName)) -and $_.FullName -notlike "*.Test*" }

    $CsprojFiles | ForEach-Object -Process {
        $Key = $_.BaseName
        $Mappings[$Key] = @()
        $script:SolutionToProjectMappings.Keys | Where-Object -FilterScript { $script:SolutionToProjectMappings[$_] -contains $Key } | ForEach-Object -Process { $Mappings[$Key] += $_ }
    }

    $Mappings | Write-Output
}

<##########################################
Creates the ModuleMappings.json file used during the build to filter StaticAnalysis and help generation by module.
##########################################>
function Create-ModuleMappings {
    [CmdletBinding()]
    param ()

    $PathsToIgnore = @("tools")
    $CustomMappings = @{}
    $script:ModuleMappings = Initialize-Mappings -PathsToIgnore $PathsToIgnore -CustomMappings $CustomMappings

    $script:ServiceFolders | ForEach-Object -Process {
        $Key = "src/$($_.Name)/"
        $ModuleManifestFiles = Get-ChildItem -Path $_.FullName -Filter "*.psd1" -Recurse |
            Where-Object -FilterScript { $_.FullName -notlike "*.Test*" -and `
                    $_.FullName -notlike "*Release*" -and `
                    $_.FullName -notlike "*Debug*" -and `
                    $_.Name -like "Az.*" }

            if ($null -ne $ModuleManifestFiles) {
                $Value = @()
                $ModuleManifestFiles | ForEach-Object -Process { $Value += $_.BaseName }
                $Script:ModuleMappings[$Key] = $Value
            }
        }
    }

    <##########################################
Creates the CsprojMappings.json file used during the build to filter the build step by project.
##########################################>
    function Create-CsprojMappings {
        [CmdletBinding()]
        param ()

        $PathsToIgnore = @("tools")
        $CustomMappings = @{}
        $script:CsprojMappings = Initialize-Mappings -PathsToIgnore $PathsToIgnore -CustomMappings $CustomMappings

        $script:ServiceFolders | ForEach-Object -Process {
            Add-CsprojMappings -ServiceFolderPath $_.FullName
        }
    }

    <##########################################
Maps a normalized path to the projects to be built based on the service folder provided.
##########################################>

    function Get-ModuleFromPath {
        [CmdletBinding()]
        [OutputType([string])]
        param
        (
            [Parameter(Mandatory)]
            [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
                ErrorMessage = "FilePath '{0}' is not a valid path leaf"
            )]
            [string]
            $FilePath
        )

        $FilePath.Replace('/', '\').Split('\src\')[-1].Split('\')[0] | Write-Output
    }

    function Add-CsprojMappings {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory)]
            [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
                ErrorMessage = "ServiceFolderPath '{0}' is not a valid path container")]
            [string]
            $ServiceFolderPath
        )

        $Key = Create-Key -FilePath $ServiceFolderPath
        $Values = New-Object -TypeName System.Collections.Generic.HashSet[string]

        Get-ChildItem -Path $ServiceFolderPath -Filter "*.csproj" -Recurse | ForEach-Object -Process {
            $Project = Get-ModuleFromPath $_.FullName

            $script:ProjectToSolutionMappings.Keys | ForEach-Object -Process {
                $Script:ProjectToSolutionMappings[$_] | ForEach-Object -Process {
                    $ProjectNameFromSolution = Get-ModuleFromPath $_

                    if ($ProjectNameFromSolution -eq $Project) {
                        $script:SolutionToProjectMappings[$_] | ForEach-Object -Process {
                            $TempValue = $script:ProjectToFullPathMappings[$_]

                            if (-not [string]::IsNullOrEmpty($TempValue)) {
                                $Values.Add($TempValue) | Out-Null
                            }
                        }
                    }
                }

                $script:CsprojMappings[$_] = $Values
            }
        }
    }

    <##########################################
    Script
##########################################>
    $script:RootPath = Get-ItemProperty -LiteralPath $PSScriptRoot -Name Parent | Select-Object -ExpandProperty FullName
    $script:SrcPath = Join-Path -Path $script:RootPath -ChildPath 'src'
    $script:ServiceFolders = Get-ChildItem -LiteralPath $script:SrcPath -Directory
    $script:ProjectToFullPathMappings = Create-ProjectToFullPathMappings
    $script:SolutionToProjectMappings = Create-SolutionToProjectMappings
    $script:ProjectToSolutionMappings = Create-ProjectToSolutionMappings

    # Create-ModuleMappings
    Create-CsprojMappings

    # $Script:ModuleMappings | Format-Json | Set-Content -Path (Join-Path -Path $Script:RootPath -ChildPath "ModuleMappings.json")
    $script:CsprojMappings | Format-Json | Set-Content -Path (Join-Path -Path $Script:RootPath -ChildPath "CsprojMappings.json")
