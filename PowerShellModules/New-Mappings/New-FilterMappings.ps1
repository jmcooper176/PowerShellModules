﻿<#
 =============================================================================
<copyright file="New-FilterMappings.ps1" company="John Merryweather Cooper">
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

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

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

function Initialize-Mappings
{
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

    if ($CustomMappings -ne $null)
    {
        $CustomMappings.GetEnumerator() | ForEach-Object -Process { $Mappings[$_.Name] = $_.Value }
    }

    if ($null -ne $PathsToIgnore)
    {
        foreach ($Path in $PathsToIgnore)
        {
            $Mappings[$Path] = $null
            $Mappings.Remove($Path)
        }
    }

    return $Mappings
}

<#
Converts a hashtable into a compressed JSON and formats it for display.
#>
function Format-Json
{
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

<#
Turns a file path into a normalized key (strips out everything before "src").
#>
function Create-Key
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $Key = ""
    $TempFilePath = $FilePath
    while ($true)
    {
        $TempItem = Get-Item -Path $TempFilePath
        $Name = $TempItem.Name
        $Key = $Name + "/" + $Key
        if ($Name -eq "src")
        {
            break
        }

        if ($null -ne $TempItem.Parent)
        {
            $TempFilePath = $TempItem.Parent.FullName
        }
        else
        {
            $TempFilePath = $TempItem.Directory.FullName
        }
    }

    return $Key
}

function Create-ProjectToFullPathMappings
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $Mappings = [ordered]@{}

    foreach ($ServiceFolder in $Script:ServiceFolders)
    {
        $CsprojFiles = Get-ChildItem -Path $ServiceFolder -Filter "*.csproj" -Recurse
        foreach ($CsprojFile in $CsprojFiles)
        {
            if ($Mappings.Contains($CsprojFile.BaseName))
            {
                throw ($CsprojFile.FullName + " is conflicts with " + $Mappings[$CsprojFile.BaseName])
            }
            $Mappings[$CsprojFile.BaseName] = [IO.Path]::GetRelativePath([IO.Path]::Combine($PSScriptRoot, ".."), $CsprojFile.FullName)
        }
    }

    return $Mappings
}

<#
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
#>
function Create-SolutionToProjectMappings
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $Mappings = [ordered]@{}

    foreach ($ServiceFolder in $Script:ServiceFolders)
    {
        $SolutionFiles = Get-ChildItem -Path $ServiceFolder.FullName -Filter "*.sln" -Recurse
        foreach ($SolutionFile in $SolutionFiles)
        {
            $Mappings = Add-ProjectDependencies -Mappings $Mappings -SolutionPath $SolutionFile.FullName
        }
    }

    return $Mappings
}

<#
Parses a solution file to find the projects it is composed of (excluding common projects).
#>
function Add-ProjectDependencies
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable]$Mappings,

        [Parameter(Mandatory = $true)]
        [string]$SolutionPath
    )

    $CommonProjectsToIgnore = @("ScenarioTest.ResourceManager", "TestFx", "Tests" )
    $CsprojList = @()
    $Content = Get-Content -LiteralPath $SolutionPath
    $SolutionFoloderPath = Split-Path -Parent $SolutionPath
    $Content | Select-String -Pattern "`"[a-zA-Z0-9`.`\\`/]*.csproj`"" | ForEach-Object -Process { $_.Matches[0].Value.Trim('"') } | Where-Object -FilterScript { $CommonProjectsToIgnore -notcontains $_ } | ForEach-Object -Process { $CsprojList += $_ }

    foreach ($Csproj in $CsprojList)
    {
        If(-Not (Test-Path -LiteralPath ($SolutionFoloderPath + "\\" + $Csproj) -PathType Leaf)) {
            Write-Error "${SolutionPath}: $Csproj is not found!"
        }
    }
    $Mappings[$SolutionPath] = $CsprojList | ForEach-Object -Process { (Split-Path -Path $_ -Leaf).Replace('.csproj', '') }
    return $Mappings
}

<#
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
#>
function Create-ProjectToSolutionMappings
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    $Mappings = [ordered]@{}

    foreach ($ServiceFolder in $Script:ServiceFolders)
    {
        $Mappings = Add-SolutionReference -Mappings $Mappings -ServiceFolderPath $ServiceFolder.FullName
    }

    return $Mappings
}

<#
Map a project to the solution file it should be build with (e.g., Commands.Compute --> src/Compute/Compute.sln)
#>
function Add-SolutionReference
{
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
    foreach ($CsprojFile in $CsprojFiles)
    {
        $Key = $CsprojFile.BaseName
        $Mappings[$Key] = @()
        $Script:SolutionToProjectMappings.Keys | Where-Object -FilterScript { $Script:SolutionToProjectMappings[$_] -contains $Key } | ForEach-Object -Process { $Mappings[$Key] += $_ }
    }

    return $Mappings
}

<#
Creates the ModuleMappings.json file used during the build to filter StaticAnalysis and help generation by module.
#>
function Create-ModuleMappings
{
    [CmdletBinding()]
    param ()

    $PathsToIgnore = @("tools")
    $CustomMappings = @{}
    $Script:ModuleMappings = Initialize-Mappings -PathsToIgnore $PathsToIgnore -CustomMappings $CustomMappings
    foreach ($ServiceFolder in $Script:ServiceFolders)
    {
        $Key = "src/$($ServiceFolder.Name)/"
        $ModuleManifestFiles = Get-ChildItem -Path $ServiceFolder.FullName -Filter "*.psd1" -Recurse |
            Where-Object -FilterScript { $_.FullName -notlike "*.Test*" -and `
                           $_.FullName -notlike "*Release*" -and `
                           $_.FullName -notlike "*Debug*" -and `
                           $_.Name -like "Az.*" }
        if ($null -ne $ModuleManifestFiles)
        {
            $Value = @()
            $ModuleManifestFiles | ForEach-Object -Process { $Value += $_.BaseName }
            $Script:ModuleMappings[$Key] = $Value
        }
    }
}

<#
Creates the CsprojMappings.json file used during the build to filter the build step by project.
#>
function Create-CsprojMappings
{
    [CmdletBinding()]
    param ()

    $PathsToIgnore = @("tools")
    $CustomMappings = @{}
    $Script:CsprojMappings = Initialize-Mappings -PathsToIgnore $PathsToIgnore -CustomMappings $CustomMappings
    foreach ($ServiceFolder in $Script:ServiceFolders)
    {
        Add-CsprojMappings -ServiceFolderPath $ServiceFolder.FullName
    }
}

<#
Maps a normalized path to the projects to be built based on the service folder provided.
#>

function Get-ModuleFromPath
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    return $FilePath.Replace('/', '\').Split('\src\')[-1].Split('\')[0]
}

function Add-CsprojMappings
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ServiceFolderPath
    )

    $Key = Create-Key -FilePath $ServiceFolderPath

    $CsprojFiles = Get-ChildItem -Path $ServiceFolderPath -Filter "*.csproj" -Recurse
    if ($null -ne $CsprojFiles)
    {
        $Values = New-Object -TypeName System.Collections.Generic.HashSet[string]
        foreach ($CsprojFile in $CsprojFiles)
        {
            $Project = Get-ModuleFromPath $CsprojFile.FullName
            foreach ($ProjectName in $Script:ProjectToSolutionMappings.Keys)
            {
                foreach ($Solution in $Script:ProjectToSolutionMappings[$ProjectName])
                {
                    $ProjectNameFromSolution = Get-ModuleFromPath $Solution
                    if ($ProjectNameFromSolution -eq $Project)
                    {
                        foreach ($ReferencedProject in $Script:SolutionToProjectMappings[$Solution])
                        {
                            $TempValue = $Script:ProjectToFullPathMappings[$ReferencedProject]
                            if (-not [string]::IsNullOrEmpty($TempValue))
                            {
                                $Values.Add($TempValue) | Out-Null
                            }
                        }
                    }
                }
            }
        }

        $Script:CsprojMappings[$Key] = $Values
    }
}

<#
    Script
#>
$Script:RootPath = (Get-Item -Path $PSScriptRoot).Parent.FullName
$Script:SrcPath = Join-Path -Path $Script:RootPath -ChildPath "src"
$Script:ServiceFolders = Get-ChildItem -Path $Script:SrcPath -Directory
$Script:ProjectToFullPathMappings = Create-ProjectToFullPathMappings
$Script:SolutionToProjectMappings = Create-SolutionToProjectMappings
$Script:ProjectToSolutionMappings = Create-ProjectToSolutionMappings

# Create-ModuleMappings
Create-CsprojMappings

# $Script:ModuleMappings | Format-Json | Set-Content -Path (Join-Path -Path $Script:RootPath -ChildPath "ModuleMappings.json")
$Script:CsprojMappings | Format-Json | Set-Content -Path (Join-Path -Path $Script:RootPath -ChildPath "CsprojMappings.json")
