<#PSScriptInfo

    .VERSION 1.0.0

    .GUID B3D90FD4-88CE-43AC-AD5B-17B50F4E90C8

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
    .SYNOPSIS
    Publish a module to a local PowerShell repository.

    .DESCRIPTION
    `Publish-LocalPSRepository.ps1` publishes a module to a local PowerShell repository.

    If the module has not been installed locally, `Publish-LocalPSRepository.ps1` will install the module.

    Otherwise, `Publish-LocalPSRepository.ps1` will update the locally installed module.  This prevents issues with which version
    of the module will actually be loaded by an implicit or explicit `Import-Module` command.

    .PARAMETER Path
    Specifies the path to the module to publish.  This must be a container.  Wildcards are supported.  This parameter is mandatory.

    The `Name` property of `Path` will be the published module name.

    .PARAMETER Repository
    Specifies the name of the repository to publish the module to.  This parameter is mandatory.

    .PARAMETER NuGetApiKey
    Specifies the NuGet API key to use when publishing the module.  This parameter is optional and defaults to a notional value
    suitable for local repositories.

    .INPUTS
    [string[]]  `Publish-LocalPSRepository.ps1` accepts an array of strings representing the path, possibly with wildcards, to the module to publish.

    .OUTPUTS
    None.  `Publish-LocalPSRepository.ps1` does not generate any output.

    .EXAMPLE
    PS> Get-ChildItem -Path 'C:\Path\To\Module' | Publish-LocalPSRepository.ps1 -Repository 'SkyOps-PowerShell'

    Publishes the module at 'C:\Path\To\Module' to the 'SkyOps-PowerShell' repository.

    .NOTES
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

    .LINK
    about_CommonParameters

    .LINK
    Initialize-PSScript

    .LINK
    ForEach-Object

    .LINK
    Get-Item

    .LINK
    Get-Module

    .LINK
    Install-Module

    .LINK
    Publish-Module

    .LINK
    Resolve-Path

    .LINK
    Update-Module

    .LINK
    Where-Object

    .LINK
    Write-Verbose
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Container },
        ErrorMessage = "Path '{0}' is not a valid path container")]
    [SupportsWildcards()]
    [string[]]
    $Path,

    [ValidateNotNullOrEmpty()]
    [string]
    $Repository = 'LocalRepository',

    [ValidateNotNullOrEmpty()]
    [string]
    $NuGetApiKey = "API-KEY-NOT-NEEDED-FOR-LOCAL-REPOSITORY"
)

BEGIN {
    $ScriptName = Initialize-PSScript -MyInvocation $MyInvocation
}

PROCESS {
    $Path | Resolve-Path | ForEach-Object -Process {
        # Publish to a NuGet Server repository using my NuGetAPI key
        $publishModuleSplat = @{
            Path = $_
            Repository = $Repository
            NuGetApiKey = $nuGetApiKey
        }

        if ($PSCmdlet.ShouldProcess($Path, $ScriptName)) {
            Publish-Module @publishModuleSplat

            $name = Get-Item -Path $_ | Select-Object -ExpandProperty Name

            if (Get-Module -ListAvailable | Where-Object -Property Name -EQ $name) {
                Write-Verbose -Message "$($ScriptName) :  Updating module '$($name)'"
                Update-Module -Name $name
            }
            else {
                Write-Verbose -Message "$($ScriptName) : Installing module '$($name)'"
                Install-Module -Name $name -Repository $Repository -AllowClobber
            }
        }
    }
}
