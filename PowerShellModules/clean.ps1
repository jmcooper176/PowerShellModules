<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 8EB02056-CE95-429D-99D5-A990D73A55B6

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

<#
    .DESCRIPTION
    Clean repository of items not in source control.
#>

[CmdletBinding()]
param (
    [switch]
    $Minimal,

    [switch]
    $Quiet
)

<#
    Functions
#>

<#
    Submit-Build
#>
function Submit-Build {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $Project,

        [ValidateSet('build', 'clean', 'rebuild', 'test')]
        [string]
        $Target = 'build',

        [ValidateSet('quiet', 'minimal', 'normal', 'detailed', 'diagnostic')]
        [string]
        $Verbosity = 'normal'
    )

    Set-StrictMode -Version latest
    Set-Variable -Name CmdletName -Option ReadOnly -Value $PSCmdlet.MyInvocation.MyCommand.Name

    $buffer = [System.Text.StringBuilder]::new()
    $buffer.Append('/t:').Append($Target) | Out-Null
    $buffer.Append(' ').Append($Project) | Out-Null
    $buffer.Append(' ').Append('/v:').Append($Verbosity) | Out-Null

    $arguments = $buffer.ToString()

    if ($PSCmdlet.ShouldProcess($Project, $CmdletName)) {
        $process = Start-Process -FilePath 'msbuild' -ArgumentList $arguments -NoNewWindow -Wait -PassThru
    }

    $buffer.Clear()
    $process.ExitCode | Write-Output
}

<#
    Script
#>
$target = 'clean'

if ($Minimal.IsPresent -and $Quiet.IsPresent) {
    thrown [System.ArgumentException]::new('Cannot specify both -Minimal or -Quiet', 'Minimal')
}

if ($Minimal.IsPresent) {
    Get-ChildItem -Filter '*module' -Directory | Get-ChildItem -Filter '*.pssproj' -File | ForEach-Object -Process {
        Submit-Build -Project $_.FullName -Target $target -Verbosity 'minimal'
    }
}
elseif ($Quiet.IsPresent) {
    Get-ChildItem -Filter '*module' -Directory | Get-ChildItem -Filter '*.pssproj' -File | ForEach-Object -Process {
        Submit-Build -Project $_.FullName -Target $target -Verbosity 'quiet'
    }
}
elseif (Test-PSParameter -Name 'Verbose' -Parameters $PSBoundParameters) {
    Get-ChildItem -Filter '*module' -Directory | Get-ChildItem -Filter '*.pssproj' -File | ForEach-Object -Process {
        Submit-Build -Project $_.FullName -Target $target -Verbosity 'detailed'
    }
}
elseif (Test-PSParameter -Name 'Debug' -Parameters $PSBoundParameters) {
    Get-ChildItem -Filter '*module' -Directory | Get-ChildItem -Filter '*.pssproj' -File | ForEach-Object -Process {
        Submit-Build -Project $_.FullName -Target $target -Verbosity 'diagnostic'
    }
}
else {
    # Normal logging -- the default
    Get-ChildItem -Filter '*module' -Directory | Get-ChildItem -Filter '*.pssproj' -File | ForEach-Object -Process {
        Submit-Build -Project $_.FullName -Target $target -Verbosity 'normal'
    }
}
