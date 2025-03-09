<#
 =============================================================================
<copyright file="NuGetModule.psm1" company="John Merryweather Cooper">
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
This file "NuGetModule.psm1" is part of "NuGetModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
  Clear-NuGetCache
#>
function Clear-NuGetCache {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [ValidateSet('all', 'global-packages', 'http-cache', 'temp')]
        [AllowNull()]
        [string]
        $Qualifier = 'all',

        [switch]
        $Quiet
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $nugetPath = Join-Path -Path $PSScriptRoot -ChildPath 'nuget'

    $options = @{
        Clear   = $true
        Verbose = [bool](Test-PSParameter -Name 'Verbose' -Parameters $PSBoundParameters)
    }

    if ($PSCmdlet.ShouldProcess("User $Env:USERDOMAIN\\$Env:USERNAME", $CmdletName)) {
        $commandLine = Build-CommandLine -LiteralPath $nugetPath -Verb 'locals' -Qualifier $Qualifier -Map $Options -SwitchValue '-'
        Start-CommandLine -FilePath $commandLine.Item1 -ArgumentList $commandLine.Item2
    }
}

<#
  Push-NuGetPackage
#>
function Push-NuGetPackage {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_.FullName -PathType Leaf })]
        [System.IO.FileInfo]
        $Package,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-ApiKey -ApiKey $_ })]
        $ApiKey,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Source -Source $_ })]
        [string]
        $Source,

        [ValidateRange(0, 7200)]
        [int]
        $Timeout = 300,

        [switch]
        $SkipDuplicate,

        [switch]
        $Unbuffered,

        [switch]
        $ServiceEndpoint,

        [switch]
        $Quiet
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $nugetPath = Join-Path -Path $PSScriptRoot -ChildPath 'nuget'

    if (Test-PSParameter -Name 'Verbose' -Parameters $PSBoundParameters) {
        $verbosity = 'detailed'
    }
    elseif ($Quiet.IsPresent) {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $Options = @{
        ApiKey            = (Format-Unquoted -Text $ApiKey)
        DisableBuffering  = $Unbuffered.IsPresent
        NonInteractive    = $true
        NoServiceEndpoint = -not $ServiceEndpoint.IsPresent
        SkipDuplicate     = $SkipDuplicate.IsPresent
        Source            = (Format-ConditionalQuoted -Text $Source)
        Timeout           = $Timeout
        Verbosity         = $verbosity
    }

    if ($PSCmdlet.ShouldProcess($Package.Name, "$($CmdletName) to $Source Feed")) {
        $commandLine = Build-CommandLine -LiteralPath $nugetPath -Verb 'push' -Qualifier (Format-ConditionalQuoted -Text $Package.FullName) -Map $Options -SwitchValue '-'
        Start-CommandLine -FilePath $commandLine.Item1 -ArgumentList $commandLine.Item2
    }
}

<#
  Restore-NuGetPackage
#>
function Restore-NuGetPackage {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $LiteralPath,

        [Parameter(Mandatory, ParameterSetName = 'UsingPath')]
        [ValidateScript({ (Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf) -and ((Get-Item -Path $_ | Select-Object -ExpandProperty Extension) -ne '.sln') })]
        [string]
        $Path,

        [ValidateRange(0, 3600)]
        [int]
        $Project2ProjectTimeout = 30,

        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $PackageDirectory = (Join-Path -Path $PSScriptRoot -ChildPath 'packages'),

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $SolutionDirectory,

        [ValidateSet('4', '12', '14', '15.1', '15.3', '15.4', '15.5', '15.6', '15.7', '15.8', '15.9', '16.0')]
        [string]
        $MSBuildVersion,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $MSBuildPath,

        [switch]
        $Recursive,

        [switch]
        $Force,

        [switch]
        $UseLockFile,

        [switch]
        $LockMode,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $LockFilePath = (Join-Path -Path $PSScriptRoot -ChildPath 'packages.lock.json'),

        [switch]
        $ForceEvaluate,

        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $ConfigFile,

        [switch]
        $Quiet
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $nugetPath = Join-Path -Path $PSScriptRoot -ChildPath 'nuget'

    if (Test-PSParameter -Name 'Verbose' -Parameters $PSBoundParameters) {
        $verbosity = 'detailed'
    }
    elseif ($Quiet.IsPresent) {
        $verbosity = 'quiet'
    }
    else {
        $verbosity = 'normal'
    }

    $options = @{
        RequireConsent         = $false
        Project2ProjectTimeout = $Project2ProjectTimeout
        PackagesDirectory      = (Format-ConditionalQuoted -Text $PackageDirectory)
        Recursive              = $Recursive.IsPresent
        Force                  = $Force.IsPresent
        UseLockFile            = $UseLockFile.IsPresent
        LockMode               = $LockMode.IsPresent
        LockFilePath           = (Format-ConditionalQuoted -Text $LockFilePath)
        ForceEvaluate          = $ForceEvaluate.IsPresent
        Verbosity              = $verbosity
        NonInteractive         = $true
        ForceEnglishOutput     = $true
    }

    if ((Test-PSParameter -Name 'SolutionDirectory' -Parameters $PSBoundParameters) -and ((Get-Item -LiteralPath $LiteralPath | Select-Object -ExpandProperty Extension) -ne '.sln')) {
        $options.Add('SolutionDirectory', (Format-ConditionalQuoted -Text $SolutionDirectory))
    }

    if (Test-PSParameter -Name 'MSBuildVersion'-Parameters $PSBoundParameters) {
        $options.Add('MSBuildVersion', (Format-ConditionalQuoted -Text $MSBuildVersion))
    }

    if (Test-PSParameter -Name 'MSBuildPath' -Parameters $PSBoundParameters) {
        $options.Add('MSBuildPath', (Format-ConditionalQuoted -Text $MSBuildPath))
    }

    if (Test-PSParameter -Name 'ConfigFile' -Parameters $PSBoundParameters) {
        $options.Add('ConfigFile', (Format-ConditionalQuoted -Text $ConfigFile))
    }

    if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
        if ($PSCmdlet.ShouldProcess($LiteralPath, $CmdletName)) {
            $commandLine = Build-CommandLine -LiteralPath $nugetPath -Verb 'restore' -Qualifier (Format-ConditionalQuoted -Text $LiteralPath) -Map $options -SwitchValue '-'
            Start-CommandLine -FilePath $commandLine.Item1 -ArgumentList $commandLine.Item2
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess($Path, $CmdletName)) {
            $Path | Get-Item | ForEach-Object -Process {
                $commandLine = Build-CommandLine -LiteralPath $nugetPath -Verb 'restore' -Qualifier (Format-ConditionalQuoted -Text $_) -Map $options -SwitchValue '-'
                Start-CommandLine -FilePath $commandLine.Item1 -ArgumentList $commandLine.Item2
            }
        }
    }
}

    <#
  Test-ApiKey
#>
    function Test-ApiKey {
        [CmdletBinding()]
        [OutputType([bool])]
        param (
            [Parameter(Mandatory)]
            [string]
            $ApiKey
        )

        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Write-Verbose -Message "$($CmdletName): Testing ApiKey '$($ApiKey)'"
  (-not [string]::IsNullOrWhiteSpace($ApiKey)) -and ($ApiKey -ne 'YOU-NEED-AN-API-KEY') -and ($ApiKey.Length -eq 40)
    }

    <#
  Test-Source
#>
    function Test-Source {
        [CmdletBinding()]
        [OutputType([bool])]
        param (
            [Parameter(Mandatory)]
            [string]
            $Source,

            [ValidateSet('Absolute', 'Relative', 'RelativeOrAbsolute')]
            [System.UriKind]
            $Kind = [System.UriKind]::Absolute
        )

        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Write-Verbose -Message "$($CmdletName): Testing Source '$($Source)'"
        -not ([string]::IsNullOrWhiteSpace($Source)) -and [System.Uri]::IsWellFormedUriString($Source, $Kind)
    }

    <#
  Update-NuGet
#>
    function Update-NuGet {
        [CmdletBinding(SupportsShouldProcess)]
        param ()

        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $nugetPath = Join-Path -Path $PSScriptRoot -ChildPath 'nuget'

        $options = @{
            FileConflictAction = 'Overwrite'
            Self               = $true
            Verbose            = [bool](Test-PSParameter -Name 'Verbose' -Parameters $PSBoundParameters)
        }

        if ($PSCmdlet.ShouldProcess("User $Env:USERDOMAIN\$Env:USERNAME", $CmdletName)) {
            $commandLine = Build-CommandLine -LiteralPath $nugetPath -Verb 'update' -Map $options -SwitchValue '-'
            Start-CommandLine -FilePath $commandLine.Item1 -ArgumentList $commandLine.Item2
        }
    }
