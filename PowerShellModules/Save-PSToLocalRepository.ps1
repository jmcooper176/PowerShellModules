<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 861F8FAA-1D31-4E37-9F1A-E550F6197F77

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

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
    Save external PowerShell module or script to local repository.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
param (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Name,

    [Parameter(Mandatory)]
    [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Container },
        ErrorMessage = "Path '{0}' is not a valid path container")]
    [string]
    $Path,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
        ErrorMessage = "Source '{0}' is not a valid, absolute PowerShell NuGet repository")]
    [string[]]
    $Source = @('https://proget.opm.gov/nuget/unapproved-powershell/', 'https://proget.opm.gov/nuget/approved-powershell/'),

    [ValidateSet('msi', 'msu', 'Programs', 'NuGet', 'PowerShellGet', 'ps1', 'chocolatey')]
    [string[]]
    $ProviderName = 'NuGet',

    [switch]
    $Force
)

BEGIN {
    Set-StrictMode -Version 3.0
    Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
        $ConfirmPreference = 'None'
    }
}

PROCESS {
    # Publish from the PSGallery to your local Repository
    $savePackageSplat = @{
        Name = $Name
        ProviderName = $ProviderName
        Source = $Source
        Path = $Path
    }

    Save-Package @savePackageSplat
}
