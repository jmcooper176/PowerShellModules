<#
 =============================================================================
<copyright file="Generate-Help.ps1" company="U.S. Office of Personnel
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
This file "Generate-Help.ps1" is part of "Generate-Help".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 6AE817D5-78EF-4F91-B874-E25840AEB1A5

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/OCIO-DEVSECOPS/PSInstallCom/Generate-ExternalContributors

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES platyPS, HelpGeneration, ErrorRecordModule, PowerShellModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES


    .PRIVATEDATA

#>

#requires -Module platyPS
#requires -Module HelpGeneration
#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

<#
    .DESCRIPTION
    Generate help for cmdlets.
#>


[CmdletBinding()]
param(
    [Switch]
    $ValidateMarkdownHelp,

    [Switch]
    $GenerateMamlHelp,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $BuildConfig,

    [Parameter()]
    [string]
    $FilteredModules
)

$ResourceManagerFolders = Get-ChildItem -Directory -Path "$PSScriptRoot\..\src" |
    Where-Object -FilterScript { $_.Name -ne 'lib' -and $_.Name -ne 'Package' -and $_.Name -ne 'packages' } |
        Where-Object -FilterScript { (Get-ChildItem -Directory -Path $_ -Filter *.psd1).Count -ne 0 }

& ($PSScriptRoot + "\PreloadToolDll.ps1")
$UnfilteredHelpFolders = Get-ChildItem -Include 'help' -Path "$PSScriptRoot\..\artifacts" -Recurse -Directory |
    Where-Object -FilterScript { $_.FullName -like "*$BuildConfig*" -and (-not [Tools.Common.Utilities.ModuleFilter]::IsAzureStackModule($_.FullName)) }

$FilteredHelpFolders = $UnfilteredHelpFolders

if (-not (Test-PSParameter -Name 'FilteredModules' -Parameters $PSBoundParameters))
{
    $FilteredModulesList = $FilteredModules -split ';'
    $FilteredHelpFolders = @()

    foreach ($HelpFolder in $UnfilteredHelpFolders)
    {
        if (($FilteredModulesList | Where-Object -FilterScript { $HelpFolder -like "*\$($_)\*" }) -ne $null)
        {
            $FilteredHelpFolders += $HelpFolder
        }
    }
}

# ---------------------------------------------------------------------------------------------

if ($ValidateMarkdownHelp.IsPresent)
{
    $SuppressedExceptionsPath = "$PSScriptRoot\StaticAnalysis\Exceptions"

    if (!(Test-Path -Path $SuppressedExceptionsPath))
    {
        New-Item -Path "$PSScriptRoot\..\artifacts" -Name "Exceptions" -ItemType Directory
    }

    $Exceptions = @()

    foreach ($ServiceFolder in $ResourceManagerFolders)
    {
        $HelpFolder = (Get-ChildItem -Path $ServiceFolder.FullName -Filter "help" -Recurse -Directory)

        if ($HelpFolder -eq $null)
        {
            $Exceptions += $ServiceFolder.Name
        }
    }

    if ($Exceptions.Count -gt 0)
    {
        $Services = $Exceptions -Join ", "

        $newErrorRecordSplat = @{
            Message = "No help folder found in the following services:  $Services"
            TargetName = 'ValidateHelpIssues'
            TargetType = 'Container'
            ErrorId = Format-ErrorId -Caller $MyInvocation.MyCommand.Name -Name 'DirectoryNotFound' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'ObjectNotFound'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
    }

    $NewExceptionsPath = "$PSScriptRoot\..\artifacts\StaticAnalysisResults"

    if (!(Test-Path -Path $NewExceptionsPath))
    {
        New-Item -Path "$PSScriptRoot\..\artifacts" -Name "StaticAnalysisResults" -ItemType Directory
    }

    Copy-Item -Path "$PSScriptRoot\HelpGeneration\Exceptions\ValidateHelpIssues.csv" -Destination $SuppressedExceptionsPath
    New-Item -Path $NewExceptionsPath -Name ValidateHelpIssues.csv -ItemType File -Force | Out-Null
    Add-Content "$NewExceptionsPath\ValidateHelpIssues.csv" "Target,Description"
    $FilteredHelpFolders | foreach { Test-AzMarkdownHelp $_.FullName $SuppressedExceptionsPath $NewExceptionsPath }
    $Exceptions = Import-Csv "$NewExceptionsPath\ValidateHelpIssues.csv"

    if (($Exceptions | Measure-Object).Count -gt 0)
    {
        $Exceptions | Format-List

        $newErrorRecordSplat = @{
            Message = 'A markdown file containing the help for a cmdlet is incomplete.'
            TargetName = 'ValidateHelpIssues'
            TargetType = 'File'
            ErrorId = Format-ErrorId -Caller $MyInvocation.MyCommand.Name -Name "WriteError" -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'WriteError'
            RecommendedAction = 'Please check the exceptions provided for more details.'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
    }
    else
    {
        New-Item -Path $NewExceptionsPath -Name NoHelpIssues -ItemType File -Force | Out-Null
        Remove-Item -Path "$SuppressedExceptionsPath\ValidateHelpIssues.csv" -Force
        Remove-Item -Path "$NewExceptionsPath\ValidateHelpIssues.csv" -Force
    }
}

# We need to define new version of module instead of hardcode here
$GeneratedModuleListPath = [System.IO.Path]::Combine($PSScriptRoot, "GeneratedModuleList.txt")
$GeneratedModules = Get-Content $GeneratedModuleListPath

if ($GenerateMamlHelp.IsPresent)
{
    foreach ($HelpFolder in $FilteredHelpFolders)
    {
        $ModuleName = ""

        if($HelpFolder -match "(?s)artifacts\\$BuildConfig\\(?<module>.+)\\help")
        {
            $ModuleName = $Matches["module"]
        }

        if($HelpFolder -match "(?s)artifacts/$BuildConfig/(?<module>.+)/help")
        {
            $ModuleName = $Matches["module"]
        }

        if($GeneratedModules -notcontains $ModuleName)
        {
            New-AzMamlHelp $HelpFolder.FullName
        }
    }
}
