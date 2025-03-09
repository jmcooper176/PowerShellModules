<#PSScriptInfo

    .VERSION 1.0.0

    .GUID CF902B25-886F-4AD8-9A2F-3678A4B79AD1

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
    Publish a module to a local PowerShell repository.
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string]
    $Path,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Repository,

    [ValidateNotNullOrEmpty()]
    [string]
    $NuGetApiKey = "API-KEY-NOT-NEEDED-FOR-LOCAL-REPOSITORY"
)

BEGIN {
    $ScriptName = Initialize-PSScript -MyInvocation $MyInvocation
}

PROCESS {
    # Publish to a NuGet Server repository using my NuGet API Key
    $publishModuleSplat = @{
        Path = $Path
        Repository = $Repository
        NuGetApiKey = $nuGetApiKey
    }

    if ($PSCmdlet.ShouldProcess($Path, $ScriptName)) {
        Publish-Module @publishModuleSplat
    }
}
