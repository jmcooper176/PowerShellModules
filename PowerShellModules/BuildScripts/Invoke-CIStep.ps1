<#
 =============================================================================
<copyright file="Invoke-CIStep.ps1" company="John Merryweather Cooper
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
    Invoke CI Build Step

    Usage:  1. This script can be called by build.proj used in CI pipeline
            2. Can be used to do static analysis in local env. Such as: .\tools\ExecuteCIStep.ps1 -StaticAnalysisSignature -TargetModule "Accounts;Compute"
            3. Can run static analyis for all the module built in artifacts. Such as: .\tools\ExecuteCIStep.ps1 -StaticAnalysisSignature will run static analysis signature check for all the modules under artifacts/debug.
#>

[CmdletBinding()]
param(
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [String]
    $AutorestDirectory,

    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [String]
    $TestOutputDirectory = 'artifacts/TestResults',

    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [String]
    $StaticAnalysisOutputDirectory = 'artifacts/StaticAnalysisResults',

    [ValidateSet('build', 'clean', 'compile', 'publish', 'rebuild', 'restore')]
    [String]
    $BuildAction = 'build',

    [ValidateSet('Debug', 'Release')]
    [String]
    $Configuration = 'Debug',

    [ValidateSet('net40', 'net45', 'net451', 'net452', 'net46', 'net461', 'net462', 'net47', 'net471', 'net427', 'net48', 'net481', 'net6.0', 'net8.0', 'net9.0')]
    [String]
    $TestFramework = 'net6.0',

    [ValidateSet('quiet', 'minimal', 'normal', 'detailed', 'diagnostic')]
    [string]
    $Verbosity = 'quiet',

    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [String]
    $RepoArtifacts = 'artifacts',

    [ValidateNotNullOrEmpty()]
    [String]
    $PullRequestNumber,

    [ValidateNotNullOrEmpty()]
    [String]
    $TargetModule,

    [Switch]
    $Build,

    [switch]
    $GenerateDocumentationFile,

    [swith]
    $EnableTestCoverage,

    [Switch]
    $Test,

    [Switch]
    $TestAutorest,

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
    $StaticAnalysisGeneratedSdk
)

$CIPlanPath = "$RepoArtifacts/PipelineResult/CIPlan.json"
$PipelineResultPath = "$RepoArtifacts/PipelineResult/PipelineResult.json"

$testResults = @{
    Succeeded = 1
    Warning   = 10
    Failed    = 100
}

function Get-PlatformInfo {
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if ([Environment]::OSVersion.Platform -eq 'Win32NT') {
        $OS = 'Windows'
    }
    elseif ([Environment]::OSVersion.Platform -eq 'Unix') {
        $OS = 'Linux'
    }
    elseif ([Environment]::OSVersion.Platform -eq 'MacOSX') {
        $OS = 'MacOS'
    }
    else {
        $OS = 'Others'
    }

    "$($Env:PowerShellPlatform) - $OS" | Write-Output
}

function Get-ModuleFromPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [String]
        $Path
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        'Az.' + $Path.Split([IO.Path]::DirectorySeparatorChar + "src")[1].Split([IO.Path]::DirectorySeparatorChar)[1] | Write-Output
    }
}

function Set-ModuleTestStatusInPipelineResult {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ModuleName,

        [ValidateSet('Succeeded', 'Failed')]
        [String]
        $Status,

        [String]
        $Content = ''
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    Write-Warning -Message "$CmdletName $ModuleName - $Status"

    if (Test-Path -LiteralPath $PipelineResultPath -PathType Leaf) {
        $PipelineResult = Get-Content -LiteralPath $PipelineResultPath | ConvertFrom-Json
        $PipelineResult.test.Details[0].Platform = (Get-PlatformInfo)

        $PipeLineResult.test.Details[0].Modules | ForEach-Object -Process {
            if ($_.Module -Eq $ModuleName) {
                if ([string]::IsNullOrWhiteSpace($_.Status) -or $testResults[$_.Status] -lt $testResults[$Status]) {
                    $_.Status = $Status
                    $_.Content = $Content
                }
            }
        }

        $PipelineResult | ConvertTo-Json -Depth 10 | Tee-Object -FilePath $PipelineResultPath | Out-String | Write-Verbose
    }
}

if ($Build.IsPresent) {
    $LogFile = (Join-Path -Path $RepoArtifacts -ChildPath 'Build.Log' -Resolve)
    $solutionPath = (Join-Path -Path $RepoArtifacts -ChildPath 'Azure.PowerShell.sln' -Resolve)
    $buildCmdResult = "dotnet msbuild -target:$($BuildAction)"
    $buildCmdResult += (' "{0}"' -f $solutionPath)

    $buildCmdResult += "-property:Configuration:$($Configuration)"
    $buildCmdResult += " -property:GenerateDocumentationFile=$(-not $GenerateDocumentationFile.IsPresent)"

    if ($EnableTestCoverage.IsPresent) {
        $buildCmdResult += " -property:TestCoverage=TESTCOVERAGE"
    }

    $buildCmdResult += "-maxCpuCount -restore -nologo"
    $buildCmdResult += "-filelogger '-fileLoggerParameters1:logFile=$($LogFile);verbosity=$($Verbosity)' -terminalLogger:auto"

    & $buildCmdResult

    if (Test-Path -LiteralPath "$RepoArtifacts/PipelineResult" -PathType Container) {
        $BuildResultArray = @()

        Get-Content -LiteralPath $LogFile | ForEach-Object {
            $Position, $ErrorOrWarningType, $Detail = $_.Split(': ')
            $Detail = $Detail | Join-String -Separator ': '

            if ($Position.Contains('src')) {
                $ModuleName = 'Az.' + $Position.Split('src' + [IO.Path]::DirectorySeparatorChar)[1].Split([IO.Path]::DirectorySeparatorChar)[0]
            }
            elseif ($Position.Contains([IO.Path]::DirectorySeparatorChar)) {
                $ModuleName = 'Az.' + $Position.Split([IO.Path]::DirectorySeparatorChar)[0]
            }
            else {
                $ModuleName = 'dotnet'
            }

            $Type, $Code = $ErrorOrWarningType.Split(' ')

            $BuildResultArray += @{
                Position = $Position
                Module   = $ModuleName
                Type     = $Type
                Code     = $Code
                Detail   = $Detail
            }

            $Position, $ErrorOrWarningType, $Detail = $_.Split(': ')
            $Detail = $Detail | Join-String -Separator ': '

            $Type, $Code = $ErrorOrWarningType.Split(' ')

            $BuildResultArray += @{
                Position = $Position
                Module   = $ModuleName
                Type     = $Type
                Code     = $Code
                Detail   = $Detail
            }
        }

        #Region produce result.json for GitHub bot to comsume
        $Platform = Get-PlatformInfo
        $Template = Get-Content -LiteralPath "$PSScriptRoot/PipelineResultTemplate.json" | ConvertFrom-Json

        $ModuleBuildInfoList = @()

        $CIPlan = Get-Content -LiteralPath "$RepoArtifacts/PipelineResult/CIPlan.json" | ConvertFrom-Json

        $CIPlan | Select-Object -ExpandProperty build | ForEach-Object -Process {
            $ModuleName = $_

            $BuildResultOfModule = $BuildResultArray | Where-Object -Property Module -EQ "Az.$ModuleName"

            if ($BuildResultOfModule.Length -eq 0) {
                $ModuleBuildInfoList += @{
                    Module  = "Az.$ModuleName"
                    Status  = 'Succeeded'
                    Content = [string]::Empty
                }
            }
            else {
                $Content = "|Type|Code|Position|Detail|`n|---|---|---|---|`n"
                $ErrorCount = 0

                $BuildResultOfModule | ForEach-Object -Process {
                    if ($_.Type -eq 'Error') {
                        $ErrorTypeEmoji = "❌"
                        $ErrorCount++
                    }
                    elseif ($_.Type -eq 'Warning') {
                        $ErrorTypeEmoji = "⚠️"
                    }

                    $Content += "|$ErrorTypeEmoji|$($BuildResult.Code)|$($BuildResult.Position)|$($BuildResult.Detail)|`n"
                }

                if ($ErrorCount -eq 0) {
                    $Status = 'Warning'
                }
                else {
                    $Status = 'Failed'
                }

                $ModuleBuildInfoList += @{
                    Module  = "Az.$ModuleName"
                    Status  = $Status
                    Content = $Content
                }
            }
        }

        $BuildDetail = @{
            Platform = $Platform
            Modules  = $ModuleBuildInfoList
        }

        $Template.Build.Details += $BuildDetail

        $DependencyStepList = $Template | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Where-Object -FilterScript { $_ -ne 'build' }

        # In generated based branch, the Accounts is cloned from latest main branch but the environment will be cleaned after build job.
        # Also the analysis check and test is not necessary for Az.Accounts in these branches.
        if (($Env:IsGenerateBased -eq 'true') -or ($Env:IsGenerateBase -eq '1')) {
            $CIPlan | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | Where-Object -FilterScript { $_ -ne 'build' } | ForEach-Object -Process {
                $CIPlan.$_ = $CIPlan.$_ | Where-Object -FilterScript { $_ -ne 'Accounts' }
            }

            $CIPlan | ConvertTo-Json -Depth 10 | Tee-Object -FilePath $CIPlanPath | Out-String | Write-Verbose
        }

        $DependencyStepList | ForEach-Object -Process {
            $ModuleInfoList = @()

            $CIPlan.$_ | ForEach-Object -Process {
                $ModuleInfoList += @{
                    Module  = "Az.$ModuleName"
                    Status  = 'Running'
                    Content = [string]::Empty
                }
            }

            $Detail = @{
                Platform = $Platform
                Modules  = $ModuleInfoList
            }

            $Template.$DependencyStep.Details += $Detail
        }

        if (Test-PSParameter -Name 'PullRequestNumber' -Parameters $PSBoundParameters) {
            $Template | Add-Member -NotePropertyName pull_request_number -NotePropertyValue $PullRequestNumber
        }

        $Template | ConvertTo-Json -Depth 10 | Tee-Object -FilePath "$RepoArtifacts/PipelineResult/PipelineResult.json" | Out-String | Write-Verbose
    }
}

if (Test-Path -LiteralPath $CIPlanPath -PathType Leaf) {
    $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
}
elseif (-not (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters)) {
    $TargetModule = Get-ChildItem "$RepoArtifacts/$Configuration" | ForEach-Object -Process { $_.Name.Replace("Az.", [string]::Empty) } | Join-String -Separator ';'
    $PSBoundParameters["TargetModule"] = $TargetModule
}

# Run the test-module.ps1 in current folder and set the test status in pipeline result
if ($TestAutorest.IsPresent) {
    if (-not (Test-Path -LiteralPath "$AutorestDirectory/test-module.ps1" -PathType Leaf)) {
        Write-Warning -Message "There is no test-module.ps1 found in the folder: $AutorestDirectory"
        return
    }

    $ModuleName = Split-Path -Path $AutorestDirectory | Split-Path -Leaf
    $ModuleFolderName = $ModuleName.Split(".")[1]

    if (Test-Path -LiteralPath $CIPlanPath -PathType Leaf) {
        $CIPlan = Get-Content $CIPlanPath | ConvertFrom-Json

        if (-not ($CIPlan.test.Contains($ModuleFolderName))) {
            Write-Debug -Message "Skip test for $ModuleName because it is not in the test plan."
            return
        }

        & $AutorestDirectory/test-module.ps1

        if ($LASTEXITCODE -eq 0) {
            $Status = 'Succeeded'
        }
        else {
            $Status = 'Failed'
        }

        Set-ModuleTestStatusInPipelineResult -ModuleName $ModuleName -Status $Status
    }
}

if ($Test.IsPresent -and (($CIPlan.test.Length -Ne 0) -or (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters))) {
    & dotnet test $RepoArtifacts/Azure.PowerShell.sln --filter "AcceptanceType=CheckIn&RunType!=DesktopOnly" --configuration $Configuration --framework $TestFramework --logger trx --results-directory $TestOutputDirectory

    $FailedTestCases = @{}

    Get-ChildItem "$RepoArtifacts/TestResults/" -Filter '*.trx' | ForEach-Object -Process {
        $Content = Get-Content -Path $TestResultFile
        $XmlDocument = New-Object -TypeName System.Xml.XmlDocument
        $XmlDocument.LoadXml($Content)

        $XmlDocument.TestRun.Results.UnitTestResult | Where-Object -FilterScript { $_.outcome -eq 'Failed' } | ForEach-Object -Process {
            $TestMethod = $XmlDocument.TestRun.TestDefinitions.UnitTest | Where-Object -FilterScript { $_.id -eq $FailedTestId } | ForEach-Object -Process {
                $ModuleName = Get-ModuleFromPath $_.TestMethod.codeBase

                if (-not $FailedTestCases.ContainsKey($ModuleName)) {
                    $FailedTestCases.Add($ModuleName, @($_.TestMethod.name))
                }
                else {
                    $FailedTestCases[$ModuleName] += $_.TestMethod.name
                }
            }

            $Content = Get-Content -LiteralPath $TestResultFile
            $XmlDocument = New-Object -TypeName System.Xml.XmlDocument
            $XmlDocument.LoadXml($Content)

            $XmlDocument.TestRun.Results.UnitTestResult | Where-Object -FilterScript { $_.outcome -eq 'Failed' } | ForEach-Object -Process {
                $FailedTestIdList | ForEach-Object -Process {
                }
            }
        }
    }

    if (Test-Path -LiteralPath $PipelineResultPath -PathType Leaf) {
        $PipelineResult = Get-Content -LiteralPath $PipelineResultPath | ConvertFrom-Json

        $PipelineResult.test.Details[0].Modules | ForEach-Object -Process {
            if ($FailedTestCases.ContainsKey($_.Module)) {
                $Status = 'Failed'
                #TODO We will add the content of failed test cases in the feature.
            }
            else {
                $Status = 'Succeeded'
            }

            Set-ModuleTestStatusInPipelineResult -ModuleName $_.Module -Status $Status
        }
    }

    if ($FailedTestCases.Length -ne 0) {
        return -1
    }
}

if ($StaticAnalysis.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysis -TestModule $TestModule -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysis -CIPlanPath $CIPlanPath -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
}

if ($StaticAnalysisBreakingChange.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysisBreakingChange -TestModule $TestModule -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysisBreakingChange -CIPlanPath $CIPlanPath -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
}

if ($StaticAnalysisDependency.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysisDependency -TestModule $TestModule -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysisDependency -CIPlanPath $CIPlanPath -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
}

if ($StaticAnalysisSignature.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysisSignature -TestModule $TestModule -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysisSignature -CIPlanPath $CIPlanPath -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
}

if ($StaticAnalysisHelp.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysisHelp -TestModule $TestModule -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysisHelp -CIPlanPath $CIPlanPath -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
}

if ($StaticAnalysisUX.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysisUX -TestModule $TestModule -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysisUX -CIPlanPath $CIPlanPath -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
}

if ($StaticAnalysisCmdletDiff.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysisCmdletDiff -TestModule $TestModule -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysisCmdletDiff -CIPlanPath $CIPlanPath -OutputDirectory $StaticAnalysisOutputDirectory -RepoArtifacts $RepoArtifacts -BoundParameters $PSBoundParameters
    }
}

if ($StaticAnalysisGeneratedSdk.IsPresent) {
    if ($PSBoundParameters.ContainsKey('TestModule')) {
        Start-StaticAnlysisGeneratedSdk -TestModule $TestModule -BoundParameters $PSBoundParameters
    }
    else {
        Start-StaticAnlysisGeneratedSdk -CIPlanPath $CIPlanPath -BoundParameters $PSBoundParameters
    }
}

function Start-StaticAnalysis {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [ValidateSet('Debug', 'Release')]
        [string]
        $Configuration = 'Debug',

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [String]
        $RepoArtifacts = 'artifacts'
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $BreakingChangeCheckModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $BreakingChangeCheckModuleList = ($CIPlan.'breaking-change' | Join-String -Separator ';')
    }

    $Parameters = @{
        RepoArtifacts                 = $RepoArtifacts
        StaticAnalysisOutputDirectory = $StaticAnalysisOutputDirectory
        Configuration                 = $Configuration
    }

    if (Test-PSParameter -Name 'TargetModule' -Parameters $PSBoundParameters) {
        $Parameters["TargetModule"] = $TargetModule
    }

    $FailedTasks = @()

    $ErrorLogPath = "$StaticAnalysisOutputDirectory/error.log"

    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisBreakingChange @Parameters 2>$ErrorLogPath

    if ($LASTEXITCODE -ne 0) {
        $FailedTasks += 'BreakingChange'
    }

    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisDependency @Parameters 2>>$ErrorLogPath

    if ($LASTEXITCODE -ne 0) {
        $FailedTasks += 'Dependency'
    }

    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisSignature @Parameters 2>>$ErrorLogPath

    if ($LASTEXITCODE -ne 0) {
        $FailedTasks += 'Signature'
    }

    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisHelp @Parameters 2>>$ErrorLogPath

    if ($LASTEXITCODE -ne 0) {
        $FailedTasks += 'Help'
    }

    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisUX @Parameters 2>>$ErrorLogPath

    if ($LASTEXITCODE -ne 0) {
        $FailedTasks += 'UXMetadata'
    }

    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisCmdletDiff @Parameters 2>>$ErrorLogPath

    if ($LASTEXITCODE -ne 0) {
        $FailedTasks += 'CmdletDiff'
    }

    & ("$PSScriptRoot/ExecuteCIStep.ps1") -StaticAnalysisGeneratedSdk @Parameters 2>>$ErrorLogPath

    if ($LASTEXITCODE -ne 0) {
        $FailedTasks += 'GenertedSdk'
    }

    if ($FailedTasks.Length -gt 0) {
        Write-Information -MessageData "There are failed tasks: $FailedTasks" -InformationAction Continue
        $ErrorLog = Get-Content -LiteralPath $ErrorLogPath | Join-String -Separator "`n"
        Write-Error -Message $ErrorLog -ErrorCategory InvalidResult -ErrorId 'Invoke-CIStep-InvalidResult-01' -TargetObject $FailedTasks.Length -ErrorAction Continue
    }

    $LASTEXITCODE | Write-Output
}

function Start-StaticAnalysisBreakingChange {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [ValidateSet('Debug', 'Release')]
        [string]
        $Configuration = 'Debug',

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [String]
        $RepoArtifacts = 'artifacts'
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $BreakingChangeCheckModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $BreakingChangeCheckModuleList = ($CIPlan.'breaking-change' | Join-String -Separator ';')
    }

    if (-not [string]::IsNullOrEmpty($DependencyCheckModuleList)) {
        Write-Information -MessageData "Running static analysis for breaking change..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $StaticAnalysisOutputDirectory --analyzers breaking-change -u -m $BreakingChangeCheckModuleList
    }

    $LASTEXITCODE | Write-Output
}

function Start-StaticAnalysisDependency {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [ValidateSet('Debug', 'Release')]
        [string]
        $Configuration = 'Debug',

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [String]
        $RepoArtifacts = 'artifacts'
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $DependencyCheckModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $DependencyCheckModuleList = ($CIPlan.signature | Join-String -Separator ';')
    }

    if (-not [string]::IsNullOrEmpty($DependencyCheckModuleList)) {
        Write-Information -MessageData "Running static analysis for dependency..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $OutputDirectory --analyzers dependency -u -m $DependencyCheckModuleList
    }

    $LASTEXITCODE | Write-Output
}

function Start-StaticAnalysisSignature {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [ValidateSet('Debug', 'Release')]
        [string]
        $Configuration = 'Debug',

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [String]
        $RepoArtifacts = 'artifacts'
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $SignatureCheckModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $SignatureCheckModuleList = ($CIPlan.signature | Join-String -Separator ';')
    }

    if (-not [string]::IsNullOrEmpty($SignatureCheckModuleList)) {
        Write-Information -MessageData "Running static analysis for signature..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $OutputDirectory --analyzers signature -u -m $SignatureCheckModuleList
    }

    $LASTEXITCODE | Write-Output
}

function Start-StaticAnalysisHelp {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [ValidateSet('Debug', 'Release')]
        [string]
        $Configuration = 'Debug',

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [String]
        $RepoArtifacts = 'artifacts'
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $HelpCheckModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $HelpCheckModuleList = ($CIPlan.Help | Join-String -Separator ';')
    }

    if (-not [string]::IsNullOrEmpty($HelpCheckModuleList)) {
        Write-Information -MessageData "Running static analysis for help..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $OutputDirectory --analyzers help -u -m $HelpCheckModuleList
    }

    $LASTEXITCODE | Write-Output
}

function Start-StaticAnalysisUX {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [ValidateSet('Debug', 'Release')]
        [string]
        $Configuration = 'Debug',

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [String]
        $RepoArtifacts = 'artifacts'
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $UXModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $UXModuleList = ($CIPlan.ux | Join-String -Separator ';')
    }

    if (-not [string]::IsNullOrEmpty($UXModuleList)) {
        Write-Information -MessageData "Running static analysis for UX metadata..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $OutputDirectory --analyzers ux -u -m $UXModuleList
    }

    $LASTEXITCODE | Write-Output
}

function Start-StaticAnalysisCmdletDiff {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "OutputDirectory '{0}' is not a valid path container")]
        [string]
        $OutputDirectory,

        [ValidateSet('Debug', 'Release')]
        [string]
        $Configuration = 'Debug',

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [String]
        $RepoArtifacts = 'artifacts'
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $CmdletDiffModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $CmdletDiffModuleList = ($CIPlan.'cmdlet-diff' | Join-String -Separator ';')
    }

    if (-not [string]::IsNullOrEmpty($CmdletDiffModuleList)) {
        Write-Information -MessageData "Running static analysis for cmdlet diff..." -InformationAction Continue
        & dotnet $RepoArtifacts/StaticAnalysis/StaticAnalysis.Netcore.dll -p $RepoArtifacts/$Configuration -r $OutputDirectory --analyzers cmdlet-diff -u -m $CmdletDiffModuleList
    }

    $LASTEXITCODE | Write-Output
}

function Start-StaticAnalysisGeneratedSdk {
    [CmdletBinding(DefaultParameterSetName = 'UsingCIPlanPath')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCIPlanPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "CIPlanPath '{0}' is not a valid path leaf")]
        [string]
        $CIPlanPath,

        [Parameter(Mandatory, ParameterSetName = 'UsingTestModule')]
        [ValidateNotNullOrEmpty()]
        [string]
        $TestModule,

        [Parameter(Mandatory)]
        [hashtable]
        $BoundParameters
    )

    Set-StrictMode -Version 3.0
    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    $LASTEXITCODE = 0

    if ($PSCmdlet.ParameterSetName -eq 'UsingTestModule') {
        $GeneratedSdkModuleList = $TargetModule
    }
    else {
        $CIPlan = Get-Content -LiteralPath $CIPlanPath | ConvertFrom-Json
        $GeneratedSdkModuleList = ($CIPlan.'generated-sdk' | Join-String -Separator ';')
    }

    if (-not [string]::IsNullOrEmpty($GeneratedSdkModuleList)) {
        Write-Information -MessageData "Running static analysis to verify generated sdk..." -InformationAction Continue
        & (Join-Path -Path $PSScriptRoot -ChildPath 'StaticAnalysis/GeneratedSdkAnalyzer/SDKGeneratedCodeVerify.ps1' -Resolve)
    }

    $LASTEXITCODE | Write-Output
}
