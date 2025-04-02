<#PSScriptInfo

    .VERSION 1.0.0

    .GUID EEB92F4A-4EDC-448E-89E0-937FDF30A532

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022, 2023, 2024, 2025, John Merryweather.  All Rights Reserved

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES PowerShellModule VersionModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

#requires -Module PowerShellModule
#requires -Module VersionModule

<#
    .SYNOPSIS
    Updates the module manifest version.

    .DESCRIPTION
    'Update-ModuleManifestVersion` updates the module manifest version.

    .PARAMETER Path
    Specifies the path to the module manifest.  Wildcards are supported.

    .PARAMETER Version
    Specifies the [version] version value to set the module manifest version to.

    .PARAMETER Build
    Specifies the [int] build number to set the module manifest version to.  If specified, `Version` will be ignored.

    .PARAMETER Revision
    Specifies the [int] revision number to set the module manifest version to.  If specified, `Version` will be ignored.

    .INPUTS
    [string]  `Update-ModuleManifestVersion` accepts a string representing the path, possibly with wildcards, to the module manifest.

    [version]  `Update-ModuleManifestVersion` accepts a [version] object representing the version to set the module manifest version to.

    .OUTPUTS
    None.  `Update-ModuleManifestVersion` does not generate any output.

    .EXAMPLE
    PS> New-FileVersion -Major 1 -Minor 0 | Update-ModuleManifestVersion -Path 'C:\MyModule\MyModule.psd1'

    Updates the module manifest version to 1.0.build.revision.

    .NOTES
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

    .LINK
    about_CommonParameters

    .LINK
    ForEach-Object

    .LINK
    Initialize-PSScript

    .LINK
    Initialize-Version

    .LINK
    New-BuildNumber

    .LINK
    New-RevisionNumber

    .LINK
    New-Version

    .LINK
    Resolve-Path

    .LINK
    Select-Object

    .LINK
    Test-ModuleManifest

    .LINK
    Update-ModuleManifest

    .LINK
    Write-Verbose

    .LINK
    Write-Warning
#>

[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingModuleVersion')]
param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf },
        ErrorMessage = "Path '{0}' is not a valid path leaf")]
    [SupportsWildcards()]
    [string[]]
    $Path,

    [Parameter(Mandatory, ParameterSetName = 'UsingModuleVersion', ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [version]
    $Version,

    [Parameter(Mandatory, ParameterSetName = 'UsingBuildVersion')]
    [ValidateRange(0, 65534)]
    [Alias('Patch')]
    [int]
    $Build,

    [Parameter(Mandatory, ParameterSetName = 'UsingRevisionVersion')]
    [ValidateRange(0, 65534)]
    [int]
    $Revision
)

BEGIN {
    $ScriptName = Initialize-PSScript -MyInvocation $MyInvocation
}

PROCESS {
    $Path | Resolve-Path | ForEach-Object -Process {
        $manifest = Test-ModuleManifest -Path $_
        $ModuleVersion = $manifest | Select-Object -ExpandProperty Version | Initialize-Version

        if ($PSCmdlet.ParameterSetName -eq 'UsingBuildVersion') {
            if ($null -eq $manifest) {
                Write-Warning -Message "Module manifest not valid at '$($_)'"
                return
            }

            Write-Verbose -Message "$($ScriptName) : Current Module Version:  '$($ModuleVersion)'"

            $Version = New-Version -Major $ModuleVersion.Major -Minor $ModuleVersion.Minor -Build $Build -Revision $ModuleVersion.Revision
            Write-Verbose -Message "$($ScriptName) : New Version: '$($Version)'"
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingRevisionVersion') {
            if ($null -eq $manifest) {
                Write-Warning -Message "Module manifest not valid at '$($_)'"
                return
            }

            Write-Verbose -Message "$($ScriptName) : Current Module Version:  '$($ModuleVersion)'"
            $Version = New-Version -Major $ModuleVersion.Major -Minor $ModuleVersion.Minor -Build $ModuleVersion.Build -Revision $Revision
            Write-Verbose -Message "$($ScriptName) : New Version:  '$($Version)'"
        }
        else {
            if ($null -eq $manifest) {
                Write-Warning -Message "Module manifest not valid at '$($_)'"
                return
            }

            if ($Version -gt $ModuleVersion) {
                Write-Verbose -Message "$($ScriptName) : Using Version:  '$($Version)'"
            }
            else {
                Write-Warning -Message "Version '$($Version)' is not greater than current module version '$($ModuleVersion)'"
                $Build = New-BuildNumber
                $Revision = New-RevisionNumber
                $Version = $Version = New-Version -Major $ModuleVersion.Major -Minor $ModuleVersion.Minor -Build $Build -Revision $Revision
                Write-Verbose -Message "$($ScriptName) : New Version:  '$($Version)'"
            }
        }

        if ($PSCmdlet.ShouldProcess($_, $ScriptName)) {
            Update-ModuleManifest -Path $_ -ModuleVersion $Version
        }
    }
}
