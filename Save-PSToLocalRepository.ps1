<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 6B1A3743-1E84-4141-B2D0-8590885F8110

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/OCIO-DEVSECOPS/PSInstallCom

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


[CmdletBinding()]
param (
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Name,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -Path $_ -PathType Container })]
    [string]
    $Path,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Source = @('https://proget.opm.gov/nuget/unapproved-powershell/', 'https://proget.opm.gov/nuget/approved-powershell/'),

    [ValidateSet('msi', 'msu', 'Programs', 'NuGet', 'PowerShellGet', 'ps1', 'chocolatey')]
    [string[]]
    $ProviderName = 'NuGet'
)

BEGIN {
    Set-StrictMode -Version 3.0
    Set-Variable -Name ScriptName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
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