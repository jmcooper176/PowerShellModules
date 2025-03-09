<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 49D382D5-B67C-47D5-8BD9-75F0B5E008A7

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

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

<#
    .DESCRIPTION
    Update module manifest version.
#>

[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingModuleVersion')]
param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
    [SupportsWildcards()]
    [string]
    $Path,

    [Parameter(Mandatory, ParameterSetName = 'UsingModuleVersion', ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [version]
    $Version,

    [Parameter(Mandatory, ParameterSetName = 'UsingPatchVersion')]
    [ValidateRange(0, 65534)]
    [Alias('Build')]
    [int]
    $Patch,

    [Parameter(Mandatory, ParameterSetName = 'UsingPatchVersion')]
    [ValidateRange(0, 65534)]
    [int]
    $Revision = 0
)

BEGIN {
    $ScriptName = Initialize-PSScript -MyInvocation $MyInvocation
}

PROCESS {
    $ModuleVersion = Test-ModuleManifest -Path $Path -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version

    if ($PSCmdlet.ParameterSetName -eq 'UsingPatchVersion') {
        if ($null -eq $ModuledVersion) {
            Write-Warning -Message "Module manifest not valid at $Path"
            return
        }

        Write-Verbose -Message "$($ScriptName) : Current Module Version: $ModuleVersion"

        if ($ModuleVersion.Major -lt 0) {
            $Major = 0
        }
        else {
            $Major = $ModuleVersion.Major
        }

        if ($ModuleVersion.Minor -lt 0) {
            $Minor = 0
        }
        else {
            $Minor = $ModuleVersion.Minor
        }

        if ($Patch -gt $ModuleVersion.Build){
            $Build = $Patch
        }
        else {
            $Build = $ModuleVersion.Build
        }

        $Version = [version]::new($Major, $Minor, $Build, $Revision)
        Write-Verbose -Message "$($ScriptName) : New Version: $Version"
    }
    else {
        if ($Version -gt $ModuleVersion) {
            Write-Verbose -Message "$($ScriptName) : Version: $Version"
        }
        else {
            Write-Warning -Message "Version $Version is not greater than current module version $ModuleVersion"
            $Version = $ModuleVersion
        }
    }

    if ($PSCmdlet.ShouldProcess($Path, $ScriptName)) {
        Update-ModuleManifest -Path $Path -ModuleVersion $Version
    }
}
