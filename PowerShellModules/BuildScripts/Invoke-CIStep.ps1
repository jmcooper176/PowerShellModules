<#
 =============================================================================
<copyright file="Invoke-CIStep.ps1" company="John Merryweather Cooper">
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
This file "Invoke-CIStep.ps1" is part of "BuildScripts".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 704198AC-6345-44A3-9087-C253BC711E26

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
    Invoke CI Build Step

    Usage:  1. This script can be called by build.proj used in CI pipeline
            2. Can be used to do static analysis in local env. Such as: .\tools\ExecuteCIStep.ps1 -StaticAnalysisSignature -TargetModule "Accounts;Compute"
            3. Can run static analyis for all the module built in artifacts. Such as: .\tools\ExecuteCIStep.ps1 -StaticAnalysisSignature will run static analysis signature check for all the modules under artifacts/debug.
#>

[CmdletBinding()]
param(
    [Switch]
    $Build,

    [String]
    $BuildAction='build',

    [String]
    $PullRequestNumber,

    [String]
    $GenerateDocumentationFile,

    [String]
    $EnableTestCoverage,

    [Switch]
    $Test,

    [Switch]
    $TestAutorest,

    [String]
    $AutorestDirectory,

    [Switch]
    $StaticAnalysis,

    [Switch]
    $StaticAnalysisBreakingChange,

    [Switch]
    $StaticAnalysisDependency,

    [Switch]
    $StaticAnalysisSignature,

    [Switch]
    $StaticAnalysisHelp,

    [Switch]
    $StaticAnalysisUX,

    [Switch]
    $StaticAnalysisCmdletDiff,

    [Switch]
    $StaticAnalysisGeneratedSdk,

    [String]
    $RepoArtifacts='artifacts',

    [String]
    $Configuration='Debug',

    [String]
    $TestFramework='net6.0',

    [String]
    $TestOutputDirectory='artifacts/TestResults',

    [String]
    $StaticAnalysisOutputDirectory='artifacts/StaticAnalysisResults',

    [String]
    $TargetModule
)

$CIPlanPath = "$RepoArtifacts/PipelineResult/CIPlan.json"
$PipelineResultPath = "$RepoArtifacts/PipelineResult/PipelineResult.json"

$testResults = @{
    Succeeded = 1
    Warning = 10
    Failed = 100
}

Function Get-PlatformInfo
{
    if ($IsWindows)
    {
        $OS = "Windows"
    }
    elseif ($IsLinux)
    {
        $OS = "Linux"
    }
    elseif ($IsMacOS)
    {
        $OS = "MacOS"
    }
    else
    {
        $OS = "Others"
    }
    return "$($Env:PowerShellPlatform) - $OS"
}

Function Get-ModuleFromPath
{
    param(
        [String]
        $Path
    )
    Return "Az." + $Path.Split([IO.Path]::DirectorySeparatorChar + "src")[1].Split([IO.Path]::DirectorySeparatorChar)[1]
}

Function Set-ModuleTestStatusInPipelineResult
{
    param(
        [String]
        $ModuleName,
        [String]
        $Status,
        [String]
        $Content=""
    )
    Write-Warning -Message "Set-ModuleTestStatusInPipelineResult $ModuleName - $Status"
    if (Test-Path -LiteralPath $PipelineResultPath -PathType Leaf)
    {
        $PipelineResult = Get-Content -LiteralPath $PipelineResultPath | ConvertFrom-Json
        $Platform = Get-PlatformInfo
        $PipelineResult.test.Details[0].Platform = $Platform
        Foreach ($ModuleInfo in $PipelineResult.test.Details[0].Modules)
        {
            if ($ModuleInfo.Module -Eq $ModuleName)
            {
                if ([string]::IsNullOrWhiteSpace($ModuleInfo.Status) -or $testResults[$ModuleInfo.Status] -lt $testResults[$Status]) {
                    $ModuleInfo.Status = $Status
                    $ModuleInfo.Content = $Content
                }
            }
        }
        ConvertTo-Json -Depth 10 -InputObject $PipelineResult | Out-File -FilePath $PipelineResultPath
    }
}

$ErrorActionPreference = 'Stop'

if ($Build)
{
    $LogFile = "$RepoArtifacts/Build.Log"
    $buildCmdResult = "dotnet $BuildAction $RepoArtifacts/Azure.PowerShell.sln -c $Configuration -fl '/flp1:logFile=$LogFile;verbosity=quiet'"

    if ($GenerateDocumentationFile -eq "false")
    {
        $buildCmdResult += " -p:GenerateDocumentationFile=false"
    }

    if ($EnableTestCoverage -eq "true")
    {
        $buildCmdResult += " -p:TestCoverage=TESTCOVERAGE"
    }

    & $buildCmdResult

    if (Test-Path -LiteralPath "$RepoArtifacts/PipelineResult" -PathType Container)
    {
        $LogContent = Get-Content -LiteralPath $LogFile
        $BuildResultArray = @()
        foreach ($Line In $LogContent)
        {
            $Position, $ErrorOrWarningType, $Detail = $Line.Split(": ")
            $Detail = Join-String -Separator ": " -InputObject $Detail
            if ($Position.Contains("src"))
            {
                $ModuleName = "Az." + $Position.Split("src" + [IO.Path]::DirectorySeparatorChar)[1].Split([IO.Path]::DirectorySeparatorChar)[0]
            }
            elseif ($Position.Contains([IO.Path]::DirectorySeparatorChar))
            {
                $ModuleName = "Az." + $Position.Split([IO.Path]::DirectorySeparatorChar)[0]
            }
            else
            {
                $ModuleName = "dotnet"
            }
            $Type, $Code = $ErrorOrWarningType.Split(" ")
            $BuildResultArray += @{
                "Position" = $Position
                "Module" = $ModuleName
                "Type" = $Type
                "Code" = $Code
                "Detail" = $Detail
            }
        }

        #Region produce result.json for GitHub bot to comsume
        $Platform = Get-PlatformInfo
        $Template = Get-Content -LiteralPath "$PSScriptRoot/PipelineResultTemplate.json" | ConvertFrom-Json
        $ModuleBuildInfoList = @()
        $CIPlan = Get-Content -LiteralPath "$RepoArtifacts/PipelineResult/CIPlan.json" | ConvertFrom-Json
        foreach ($ModuleName In $CIPlan.build)
        {
            $BuildResultOfModule = $BuildResultArray | Where-Object -Property Module -EQ "Az.$ModuleName"
            if ($BuildResultOfModule.Length -Eq 0)
            {
                $ModuleBuildInfoList += @{
                    Module = "Az.$ModuleName"
                    Status = "Succeeded"
                    Content = ""
                }
            }
            else
            {
                $Content = "|Type|Code|Position|Detail|`n|---|---|---|---|`n"
                $ErrorCount = 0
                foreach ($BuildResult In $BuildResultOfModule)
                {
                    if ($BuildResult.Type -Eq "Error")
                    {
                        $ErrorTypeEmoji = "❌"
                        $ErrorCount += 1
                    }
                    elseif ($BuildResult.Type -Eq "Warning")
                    {
                        $ErrorTypeEmoji = "⚠️"
                    }
                    $Content += "|$ErrorTypeEmoji|$($BuildResult.Code)|$($BuildResult.Position)|$($BuildResult.Detail)|`n"
                }
                if ($ErrorCount -Eq 0)
                {
                    $Status = "Warning"
                }
                else
                {
                    $Status = "Failed"
                }
                $ModuleBuildInfoList += @{
                    Module = "Az.$ModuleName"
                    Status = $Status
                    Content = $Content
                }
            }
        }
        $BuildDetail = @{
            Platform = $Platform
            Modules = $ModuleBuildInfoList
        }
        $Template.Build.Details += $BuildDetail

        $DependencyStepList = $Template | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Where-Object -FilterScript { $_ -Ne "build" }

        # In generated based branch, the Accounts is cloned from latest main branch but the environment will be cleaned after build job.
        # Also the analysis check and test is not necessary for Az.Accounts in these branches.
        if ($Env:IsGenerateBased -eq "true")
        {
            foreach ($phase In ($CIPlan | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Where-Object -FilterScript { $_ -Ne "build" }))
            {
                $CIPlan.$phase = $CIPlan.$phase | Where-Object -FilterScript { $_ -Ne "Accounts" }
            }
            ConvertTo-Json -Depth 10 -InputObject $CIPlan | Out-File -FilePath $CIPlanPath
        }

        foreach ($DependencyStep In $DependencyStepList)
        {
            $ModuleInfoList = @()
            foreach ($ModuleName In $CIPlan.$DependencyStep)
            {
                $ModuleInfoList += @{
                    Module = "Az.$ModuleName"
                    Status = "Running"
                    Content = ""
                }
            }
            $Detail = @{
                Platform = $Platform
                Modules = $ModuleInfoList
            }
            $Template.$DependencyStep.Details += $Detail
        }
        if (Test-PSParameter -Name 'PullRequestNumber' -Parameters $PSBoundParameters) {
            $Template | Add-Member -NotePropertyName pull_request_number -NotePropertyValue $PullRequestNumber
        }

        ConvertTo-Json -Depth 10 -InputObject $Template | Out-File -FilePath "$RepoArtifacts/PipelineResult/PipelineResult.json"
        #EndRegion
    }
    Return
}

if (Test-Path -LiteralPath $CIPlanPath -PathType Leaf)
{
    $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
}
elseIf (-not (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters))
{
    $TargetModule = Get-ChildItem "$RepoArtifacts/$Configuration" | ForEach-Object -Process { $_.Name.Replace("Az.", "") } | Join-String -Separator ';'
    $PSBoundParameters["TargetModule"] = $TargetModule
}

# Run the test-module.ps1 in current folder and set the test status in pipeline result
if ($TestAutorest)
{
    if (-not (Test-Path -LiteralPath "$AutorestDirectory/test-module.ps1" -PathType Leaf))
    {
        Write-Warning -Message "There is no test-module.ps1 found in the folder: $AutorestDirectory"
        Return
    }
    $ModuleName = Split-Path -Path $AutorestDirectory | Split-Path -Leaf
    $ModuleFolderName = $ModuleName.Split(".")[1]
    if (Test-Path -LiteralPath $CIPlanPath -PathType Leaf)
    {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        if (-not ($CIPlan.test.Contains($ModuleFolderName)))
        {
            Write-Debug -Message "Skip test for $ModuleName because it is not in the test plan."
            Return
        }
        . $AutorestDirectory/test-module.ps1
        if ($LastExitCode -ne 0)
        {
            $Status = "Failed"
        }
        else
        {
            $Status = "Succeeded"
        }
        Set-ModuleTestStatusInPipelineResult -ModuleName $ModuleName -Status $Status
    }
    Return
}

if ($Test.IsPresent -and (($CIPlan.test.Length -Ne 0) -or (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)))
{
    dotnet test $RepoArtifacts/Azure.PowerShell.sln --filter "AcceptanceType=CheckIn&RunType!=DesktopOnly" --configuration $Configuration --framework $TestFramework --logger trx --results-directory $TestOutputDirectory

    $TestResultFiles = Get-ChildItem -LiteralPath "$RepoArtifacts/TestResults/" -Filter *.trx
    $FailedTestCases = @{}
    foreach ($TestResultFile in $TestResultFiles)
    {
        $Content = Get-Content -LiteralPath $TestResultFile
        $XmlDocument = New-Object -TypeName System.Xml.XmlDocument
        $XmlDocument.LoadXml($Content)
        $FailedTestIdList = $XmlDocument.TestRun.Results.UnitTestResult | Where-Object -Property outcome -EQ "Failed" | ForEach-Object -Process { $_.testId }
        Foreach ($FailedTestId in $FailedTestIdList)
        {
            $TestMethod = $XmlDocument.TestRun.TestDefinitions.UnitTest | Where-Object -Property id -EQ $FailedTestId | ForEach-Object -Process {$_.TestMethod}
            $ModuleName = Get-ModuleFromPath $TestMethod.codeBase
            $FailedTestName = $TestMethod.name
            if (-not $FailedTestCases.ContainsKey($ModuleName))
            {
                $FailedTestCases.Add($ModuleName, @($FailedTestName))
            }
            else
            {
                $FailedTestCases[$ModuleName] += $FailedTestName
            }
        }
    }
    if (Test-Path -LiteralPath $PipelineResultPath -PathType Leaf)
    {
        $PipelineResult = Get-Content -LiteralPath $PipelineResultPath | ConvertFrom-Json
        Foreach ($ModuleInfo in $PipelineResult.test.Details[0].Modules)
        {
            if ($FailedTestCases.ContainsKey($ModuleInfo.Module))
            {
                $Status = "Failed"
                #TODO We will add the content of failed test cases in the feature.
            }
            else
            {
                $Status = "Succeeded"
            }
            Set-ModuleTestStatusInPipelineResult -ModuleName $ModuleInfo.Module -Status $Status
        }
    }

    if ($FailedTestCases.Length -ne 0)
    {
        Return -1
    }
    else
    {
        Return
    }
}

if ($StaticAnalysis)
{
    $Parameters = @{
        RepoArtifacts = $RepoArtifacts
        StaticAnalysisOutputDirectory = $StaticAnalysisOutputDirectory
        Configuration = $Configuration
    }
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $Parameters["TargetModule"] = $TargetModule
    }
    $FailedTasks = @()
    $ErrorLogPath = "$StaticAnalysisOutputDirectory/error.log"
    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisBreakingChange @Parameters 2>$ErrorLogPath
    if ($LASTEXITCODE -ne 0)
    {
        $FailedTasks += "BreakingChange"
    }
    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisDependency @Parameters 2>>$ErrorLogPath
    if ($LASTEXITCODE -ne 0)
    {
        $FailedTasks += "Dependency"
    }
    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisSignature @Parameters 2>>$ErrorLogPath
    if ($LASTEXITCODE -ne 0)
    {
        $FailedTasks += "Signature"
    }
    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisHelp @Parameters 2>>$ErrorLogPath
    if ($LASTEXITCODE -ne 0)
    {
        $FailedTasks += "Help"
    }
    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisUX @Parameters 2>>$ErrorLogPath
    if ($LASTEXITCODE -ne 0)
    {
        $FailedTasks += "UXMetadata"
    }
    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisCmdletDiff @Parameters 2>>$ErrorLogPath
    if ($LASTEXITCODE -ne 0)
    {
        $FailedTasks += "CmdletDiff"
    }
    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisGeneratedSdk @Parameters 2>>$ErrorLogPath
    if ($LASTEXITCODE -ne 0)
    {
        $FailedTasks += "GenertedSdk"
    }
    if ($FailedTasks.Length -ne 0)
    {
        Write-Information -MessageData "There are failed tasks: $FailedTasks" -InformationAction Continue
        $ErrorLog = Get-Content -LiteralPath $ErrorLogPath | Join-String -Separator "`n"
        Write-Error $ErrorLog
    }

    Return 0
}

if ($StaticAnalysisBreakingChange)
{
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $BreakingChangeCheckModuleList = $TargetModule
    }
    else
    {
        $BreakingChangeCheckModuleList = Join-String -Separator '' -InputObject $CIPlan.'breaking-change'
    }
    if ("" -Ne $BreakingChangeCheckModuleList)
    {
        Write-Information -MessageData "Running static analysis for breaking change..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $StaticAnalysisOutputDirectory --analyzers breaking-change -u -m $BreakingChangeCheckModuleList

        $LASTEXITCode | Write-Output
    }
}
if ($StaticAnalysisDependency)
{
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $DependencyCheckModuleList = $TargetModule
    }
    else
    {
        $DependencyCheckModuleList = Join-String -Separator ';' -InputObject $CIPlan.dependency
    }
    if ("" -Ne $DependencyCheckModuleList)
    {
        Write-Information -MessageData "Running static analysis for dependency..." -InformationAction Continue
        dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $StaticAnalysisOutputDirectory --analyzers dependency -u -m $DependencyCheckModuleList
        $LASTEXITCODE | Write-Output
        & ($PSScriptRoot + "/CheckAssemblies.ps1") -BuildConfig $Configuration
    }
}

if ($StaticAnalysisSignature)
{
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $SignatureCheckModuleList = $TargetModule
    }
    else
    {
        $SignatureCheckModuleList = Join-String -Separator ';' -InputObject $CIPlan.signature
    }
    if ("" -Ne $SignatureCheckModuleList)
    {
        Write-Information -MessageData "Running static analysis for signature..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $StaticAnalysisOutputDirectory --analyzers signature -u -m $SignatureCheckModuleList
        $LASTEXITCODE | Write-Output
    }
}

if ($StaticAnalysisHelp)
{
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $HelpCheckModuleList = $TargetModule
    }
    else
    {
        $HelpCheckModuleList = Join-String -Separator ';' -InputObject $CIPlan.help
    }
    if ("" -Ne $HelpCheckModuleList)
    {
        Write-Information -MessageData "Running static analysis for help..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $StaticAnalysisOutputDirectory --analyzers help -u -m $HelpCheckModuleList
        $LASTEXITCODE | Write-Output
    }
}

if ($StaticAnalysisUX)
{
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $UXModuleList = $TargetModule
    }
    else
    {
        $UXModuleList = Join-String -Separator ';' -InputObject $CIPlan.ux
    }
    if ("" -Ne $UXModuleList)
    {
        Write-Information -MessageData "Running static analysis for UX metadata..." -InformationAction Continue
        dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $StaticAnalysisOutputDirectory --analyzers ux -u -m $UXModuleList
        if ($LASTEXITCODE -ne 0)
        {
            Return $LASTEXITCODE
        }
    }
    Return 0
}

if ($StaticAnalysisCmdletDiff)
{
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $CmdletDiffModuleList = $TargetModule
    }
    else
    {
        $CmdletDiffModuleList = Join-String -Separator ';' -InputObject $CIPlan.'cmdlet-diff'
    }
    if ("" -Ne $CmdletDiffModuleList)
    {
        Write-Information -MessageData "Running static analysis for cmdlet diff..." -InformationAction Continue
        dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $StaticAnalysisOutputDirectory --analyzers cmdlet-diff -u -m $CmdletDiffModuleList
        if ($LASTEXITCODE -ne 0)
        {
            Return $LASTEXITCODE
        }
    }
    Return 0
}

if ($StaticAnalysisGeneratedSdk)
{
    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)
    {
        $GeneratedSdkModuleList = $TargetModule
    }
    else
    {
        $GeneratedSdkModuleList = Join-String -Separator ';' -InputObject $CIPlan.'generated-sdk'
    }
    if ("" -Ne $GeneratedSdkModuleList)
    {
        Write-Information -MessageData "Running static analysis to verify generated sdk..." -InformationAction Continue
        $result = & ($PSScriptRoot + "/StaticAnalysis/GeneratedSdkAnalyzer/SDKGeneratedCodeVerify.ps1")
        Write-Information -MessageData "Static analysis to verify generated sdk result: $result" -InformationAction Continue
        if ($LASTEXITCODE -ne 0)
        {
            Return $LASTEXITCODE
        }
    }
    Return 0
}
