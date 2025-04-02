<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 293BDCFE-F391-421C-AA23-9EFA27763CE3

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

#requires -Module PowerShellModule

<#
    .DESCRIPTION
    Register a local PowerShell repository.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
        ErrorMessage = "Location '{0}' is not a valid path container")]
    [string]
    $Location,

    [ValidateSet('Trusted', 'Untrusted')]
    [string]
    $InstallationPolicy = 'Trusted',

    [switch]
    $Force
)

Set-StrictMode -Version 3.0
Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
    $ConfirmPreference = 'None'
}

# Register a file share on my local machine
$registerPSRepositorySplat = @{
    Name = $Name
    SourceLocation = $Location | Resolve-Path | Select-Object -ExpandProperty Path
    ScriptSourceLocation = $Location | Resolve-Path | Select-Object -ExpandProperty Path
    InstallationPolicy = $InstallationPolicy
}

if ($PSCmdlet.ShouldProcess($Location, $ScriptName)) {
    Register-PSRepository @registerPSRepositorySplat
}
