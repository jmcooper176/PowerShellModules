<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 985A4AB6-8B78-4C16-B2D9-2129FBEAC7FE

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/OCIO-DEVSECOPS/PSInstallCom

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


[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [string]
    $Name,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $Location,

    [ValidateSet('Trusted', 'Untrusted')]
    [string]
    $InstallationPolicy = 'Trusted'
)

Set-StrictMode -Version 3.0
Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

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