<#
 =============================================================================
<copyright file="pre-build.ps1" company="John Merryweather Cooper">
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
This file "pre-build.ps1" is part of "BuildScripts".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 4D3E9AD7-1C20-4536-9262-A156B57EB6AE

    .AUTHOR John Merryweather Cooper

    .COMPANYNAME John Merryweather Cooper

    .COPYRIGHT Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    .TAGS

    .LICENSEURI https://www.opensource.org/licenses/BSD-3-Clause

    .PROJECTURI https://github.com/jmcooper176/PowerShellModules/BuildScripts

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES PowerShellModule VersionModule

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES

    .PRIVATEDATA

#>

#requires -Module EnvironmentModule
#requires -Module ErrorRecordModule
#requires -Module MessageModule
#requires -Module PowerShellModule
#requires -Module UtcModule
#requires -Module VersionModule

<#
    .DESCRIPTION
    Pre-build processing.
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Project,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
    [string]
    $Solution,

    [ValidateRange(-1, 65534)]
    [int]
    $Major = 1,

    [ValidateRange(-1, 65534)]
    [int]
    $Minor = 2,

    [switch]
    $UpdateModules,

    [switch]
    $UpdateVersionInfo
)

<#
    Functions
#>
function Get-CommandPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $path = Get-Command -All | Where-Object -FilterScript { $_.Name -like 'vswhere.exe' } | Select-Object -ExpandProperty Path

    if (($null -eq $path) -and (Test-Path -LiteralPath $path -PathType Leaf)) {
        $path | Write-Output
    }
    else {
        $newErrorRecordSplat = @{
            Exception       = [System.IO.FileNotFoundException]::new("Command '$Name' not found.")
            ErrorId         = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory   = 'ObjectNotFound'
            TargetObject    = $Name
            TargetName      = 'Name'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
    }
}

function Get-CscToolDir {
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $vcInstallDir = Get-EnvironmentVariable -Name 'VCINSTALLDIR'
    Join-Path -Path $vcInstallDir -ChildPath 'MSBuild\Current\Bin\Roslyn' -Resolve | Write-Output
}

function Get-ManifestPath {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $ProjectDir,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Get-ChildItem -LiteralPath $ProjectDir -Include '*.psd1' -File -Recurse |
        Where-Object -FilterScript { $_.BaseName -like "*$Name" } |
            Select-Object -ExpandProperty FullName | Write-Output
}

function Get-ProjectDir {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $Project
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $result = Get-ChildItem -LiteralPath $PSScriptRoot -Include '*.*proj' -File -Recurse | Where-Object -FilterScript { $_.Name -like "*$Project" }

    if ($result) {
        $result.FullName | Write-Output
    }
    else {
        $UpOneDirectory = Join-Path -Path $PSScriptRoot -ChildPath '..' -Resolve
        $result = Get-ChildItem -LiteralPath $UpOneDirectory -Include '*.*proj' -File -Recurse | Where-Object -FilterScript { $_.Name -like "*$Project" }

        if ($result) {
            $result.FullName | Write-Output
        }
        else {
            $newErrorRecordSplat = @{
                Exception       = [System.IO.FileNotFoundException]::new("Project file '$Project' not found.")
                ErrorId         = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory   = 'ObjectNotFound'
                TargetObject    = $Project
                TargetName      = 'Project'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
    }
}

function Get-SolutionDir {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $Solution
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    $InitalSolutionDir = Join-Path -Path $PSScriptRoot -ChildPath '..\..\' -Resolve

    $result = Get-ChildItem -LiteralPath $PSScriptRoot -Include '*.sln' -File -Recurse | Where-Object -FilterScript { $_.Name -like "*$Solution" }

    if ($result) {
        $result.FullName | Write-Output
    }
    else {
        $UpOneDirectory = Join-Path -Path $InitialSolutionDir -ChildPath '..' -Resolve
        $result = Get-ChildItem -LiteralPath $UpOneDirectory -Include '*.sln' -File -Recurse | Where-Object -FilterScript { $_.Name -like "*$Solution" }

        if ($result) {
            $result.FullName | Write-Output
        }
        else {
            $newErrorRecordSplat = @{
                Exception       = [System.IO.FileNotFoundException]::new("Solution file '$Solution' not found.")
                ErrorId         = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory   = 'ObjectNotFound'
                TargetObject    = $Solution
                TargetName      = 'Solution'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
    }
}

function Get-VcToolsVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Get-EnvironmentVariable -Name 'VCtoolsInstallDir' | Split-Path -Leaf | ForEach-Object -Process { [version]$_ } | Write-Output
}

function Get-VisualStudioBuildVersion {
    [CmdletBinding()]
    [OutputType([version])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-EnvironmentVariable -Name 'VisualStudioVersion') {
        $versionString = Get-EnvironmentVariable -Name 'VisualStudioVersion'
    }
    else {
        $vswhere = Get-CommandPath -Name 'vswhere.exe'
        $versionString = & $vswhere -latest -property catalog_BuildVersion
    }

    [version]$versionString | Write-Output
}

function Get-VsCmdVer {
    [CmdletBinding()]
    [OutputType([version])]
    param ()

    if (Test-EnvironmentVariable -Name 'VSCMD_VER') {
        $versionString = Get-EnvironmentVariable -Name 'VSCMD_VER'
    }
    else {
        $vswhere = Get-CommandPath -Name 'vswhere.exe'
        $versionString = & $vswhere -latest -property catalog_ProductDisplayVersion
    }

    [version]$versionString | Write-Output
}

function Set-DevEnvDir {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Set-Variable -Name DEV_ENV_DIR -Option Constant -Value 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE'

    if (-not (Test-EnvironmentVariable -Name 'DevEnvDir')) {
        if (Test-Path -LiteralPath $DEV_ENV_DIR -PathType Container) {
            $value = $DEV_ENV_DIR
        }
        else {
            $vswhere = Get-CommandPath -Name 'vswhere.exe'
            $root = & $vswhere -latest -property resolvedInstalltionPath
            $value = Join-Path -Path $root -ChildPath 'Common7\IDE' -Resolve
        }

        if ($PSCmdlet.ShouldProcess($value, $CmdletName)) {
            Set-EnvironmentVariable -Name 'DevEnvDir' -Value $value
        }
    }
}

function Set-VcInstallDir {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Set-Variable -Name VC_INSTALL_DIR -Option Constant -Value 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC'

    if (-not (Test-EnvironmentVariable -Name 'VCINSTALLDIR')) {
        if (Test-Path -LiteralPath $VC_INSTALL_DIR -PathType Container) {
            $value = $VC_INSTALL_DIR
        }
        else {
            $vswhere = Get-CommandPath -Name 'vswhere.exe'
            $root = & $vswhere -latest -property resolvedInstalltionPath
            $value = Join-Path -Path $root -ChildPath 'VC' -Resolve
        }

        if ($PSCmdlet.ShouldProcess($value, $CmdletName)) {
            Set-EnvironmentVariable -Name 'VCINSTALLDIR' -Value $value
        }
    }
}

function Set-VcIdeInstallDir {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Set-Variable -Name VC_IDE_INSTALL_DIR -Option Constant -Value 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VC'

    if (-not (Test-EnvironmentVariable -Name 'VCIDEInstallDir')) {
        if (Test-Path -LiteralPath $VC_IDE_INSTALL_DIR -PathType Container) {
            $value = $VC_IDE_INSTALL_DIR
        }
        else {
            $vswhere = Get-CommandPath -Name 'vswhere.exe'
            $installationPath = & $vswhere -latest -property resolvedInstalltionPath
            $value = Join-Path -Path $installationPath -ChildPath 'Common7\IDE\VC' -Resolve
        }

        if ($PSCmdlet.ShouldProcess($value, $CmdletName)) {
            Set-EnvironmentVariable -Name 'VCIDEInstallDir' -Value $value
        }
    }
}

function Set-VcPkgRoot {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Set-Variable -Name VC_PKG_ROOT -Option Constant -Value 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\vcpkg'

    if (-not (Test-EnvironmentVariable -Name 'VCPKG_ROOT')) {
        if (Test-Path -LiteralPath $VC_PKG_ROOT -PathType Container) {
            $value = $VC_PKG_ROOT
        }
        else {
            $vswhere = Get-CommandPath -Name 'vswhere.exe'
            $installationPath = & $vswhere -latest -property resolvedInstalltionPath
            $value = Join-Path -Path $installationPath -ChildPath 'VC\vcpkg' -Resolve
        }

        if ($PSCmdlet.ShouldProcess($value, $CmdletName)) {
            Set-EnvironmentVariable -Name 'VCPKG_ROOT' -Value $value
        }
    }
}

function Set-VcToolsInstallDir {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $toolsRoot = Join-Path -Path (Get-EnvironmentVariable -Name 'VCINSTALLDIR') -ChildPath 'Tools\MSVC' -Resolve

    $clPath = Get-ChildItem -LiteralPath $toolsRoot -Include 'cl.exe' -File -Recurse |
        Where-Object -FilterScript { $_.DirectoryName -like '*Hostx64\x64' } |
            Select-Object -ExpandProperty DirectoryName

    if ($PSCmdlet.ShouldProcess('VCToolsInstallDir', $CmdletName)) {
        Join-Path -Path $clPath -ChildPath '..\..\..\' -Resolve | Set-EnvironmentVariable -Name 'VCToolsInstallDir'
    }
}

function Set-VcToolsRedistDir {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $toolsRoot = Join-Path -Path (Get-EnvironmentVariable -Name 'VCINSTALLDIR') -ChildPath 'Redist\MSVC' -Resolve

    $toolsRedistDir = Get-ChildItem -LiteralPath $toolsRoot -Include 'vc_redixt.x64.exe' -File -Recurse |
        Where-Object -FilterScript { $_.DirectoryName -like 'Redist\MSVC\*' } |
            Select-Object -ExpandProperty DirectoryName

    if ($PSCmdlet.ShouldProcess($toolsRedistDir, $CmdletName)) {
        Set-EnvironmentVariable -Name 'VCToolsRedistDir' -Value $toolsRedistDir
    }
}

function Set-Vs170ComnTools {
    [CmdletBinding()]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Set-Variable -Name VS_170_COMN_TOOLS -Option Constant -Value 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools'

    if (-not (Test-EnvironmentVariable -Name 'VS170COMNTOOLS')) {
        if (Test-Path -LiteralPath $VS_170_COMN_TOOLS -PathType Container) {
            Set-EnvironmentVariable -Name 'VS170COMNTOOLS' -Value $VS_170_COMN_TOOLS
        }
        else {
            $installationDir = Get-EnvironmentVariable -Name 'VSINSTALLDIR'
            Join-Path -Path $installationDir -ChildPath 'Common7\Tools' -Resolve | Set-EnvironmentVariable -Name 'VS170COMNTOOLS'
        }
    }
}

function Set-VsInstallDir {
    [CmdletBinding(SupportsShouldProcess)]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Set-Variable -Name VS_INSTALL_DIR -Option Constant -Value 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\'

    if (-not (Test-EnvironmentVariable -Name 'VSINSTALLDIR')) {
        if (Test-Path -LiteralPath $VS_INSTALL_DIR -PathType Container) {
            Set-EnvironmentVariable -Name 'VSINSTALLDIR' -Value $VS_INSTALL_DIR
        }
        else {
            $vswhere = Get-CommandPath -Name 'vswhere.exe'
            & $vswhere -latest -property resolvedInstalltionPath | Set-EnvironmentVariable -Name 'VSINSTALLDIR'
        }
    }
}

<#
    Script
#>

$ScriptName = Initialize-PSScript -MyInvocation $MyInvocation

$DebugPreference = 'SilentlyContinue'
$InformationPreference = 'Continue'
$VerbosePreference = 'SilentlyContinue'
$WarningPreference = 'Continue'
$ErrorActionPreference = 'Continue'
$ConfirmPreference = 'None'

Write-Information -MessageData ("{0}:  Computing project variables" -f $ScriptName) -Tags @($ScriptName, 'Visual Studio', '2022') -InformationAction Continue

$ProjectDir = Get-ProjectDir -Project $Project
$ProjectPath = Join-Path -Path $ProjectDir -ChildPath $Project -Resolve
$SolutionDir = Get-SolutionDir -Solution $Solution
$SolutionPath = Join-Path -ChildPath $SolutionDir -Path $Solution -Resolve

$manifestPath = Get-ModulePath -ProjectDir $ProjectDir -Name [System.IO.Path]::ChangeExtension($Project, '.psd1')

Set-DevEnvDir
Set-VcInstallDir
Set-VsInstallDir
Set-VcIdeInstallDir
Set-VcPkgRoot
Set-VcToolsInstallDir
Set-VcToolsRedistDir
(Get-VcToolsVersion).ToString() | Set-EnvironmentVariable -Name 'VCToolsVersion'
(Get-VisualStudioBuildVersion).ToString(2) | Set-EnvironmentVariable -Name 'VisualStudioVersion'
Set-Vs170ComnTools
(Get-VsCmdVer).ToString(3) | Set-EnvironmentVariable -Name 'VSCMD_VER'
$cscToolDir = Get-CscToolDir
$cscToolPath = Join-Path -Path $cscToolDir -ChildPath 'csc.exe' -Resolve
$devEnvDir = Get-EnvironmentVariable -Name DevEnvDir

$visualStudioVersion = Get-EnvironmentVariable -Name 'VisualStudioVersion'

$dumpList = [System.Collections.ArrayList]::new()
$dumpList.Add("$($ScriptName): + ==================================================") | Out-Null
$dumpList.Add("$($ScriptName): + ") | Out-Null
$dumpList.Add("$($ScriptName): +                                   $($ScriptName.ToUpperInvariant())") | Out-Null
$dumpList.Add("$($ScriptName): + --------------------------------------------------") | Out-Null

if (Test-Path -LiteralPath $cscToolPath -PathType Leaf) {
    $dumpList.Add("$($ScriptName): +      CscToolPath:                 $($cscToolPath)") | Out-Null
}

if (Test-Path -LiteralPath $devEnvDir -PathType Container) {
    $dumpList.Add("$($ScriptName): +      DevEnvDir:                   $($devEnvDir)") | Out-Null
}

if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
    $dumpList.Add("$($ScriptName): +      ManifestPath:                $($manifestPath)") | Out-Null
}

if (Test-Path -LiteralPath $ProjectDir -PathType Container) {
    $dumpList.Add("$($ScriptName): +      ProjectDir:                  $($ProjectDir)") | Out-Null
}

if (Test-Path -LiteralPath $SolutionDir -PathType Container) {
    $dumpList.Add("$($ScriptName): +      SolutionDir:                 $($SolutionDir)") | Out-Null
}

if (Test-Path -LiteralPath $SolutionPath -PathType Container) {
    $dumpList.Add("$($ScriptName): +      SolutionPath:                $($SolutionPath)") | Out-Null
}

$dumpList.Add("$($ScriptName): +      VisualStudioVersion:         $($visualStudioVersion)") | Out-Null
$dumpList.Add("$($ScriptName): + ") | Out-Null
$dumpList.Add("$($ScriptName): + ==================================================") | Out-Null

$dumpList.ToArray() | ForEach-Object -Process { $_ | Write-Output }

Write-Information -MessageData ("{0}:  Pre-Build Processing" -f $ScriptName) -Tags @($ScriptName, 'Visual Studio', '2022') -InformationAction Continue

if ($UpdateModules.IsPresent -or $UpdateVersionInfo.IsPresent) {
    $assemblyVersion = New-AssemblyVersion -Major $Major -Minor $Minor -Build 0
    $fileVersion = New-FileVersion -Major $Major -Minor $Minor
    $informationalVersion = New-SemanticVersion -Major $Major -Minor $Minor

    Write-Information -MessageData ("{0}:  Assembly Version '{1}'" -f $ScriptName, $assemblyVersion.ToString()) -Tags @($ScriptName, 'Assembly', 'Version') -InformationAction Continue
    Write-Information -MessageData ("{0}:  File Version '{1}'" -f $ScriptName, $fileVersion.ToString()) -Tags @($ScriptName, 'File', 'Version') -InformationAction Continue
    Write-Information -MessageData ("{0}:  Informational or Product Version '{1}'" -f $ScriptName, $informationalVersion.ToString()) -Tags @($ScriptName, 'Informational', 'Product', 'Version') -InformationAction Continue
}

if ($UpdateModules.IsPresent) {
    Get-ChildItem -LiteralPath $SolutionDir -Filter '*.psd1' -Recurse -File | ForEach-Object -Process {
        if ($PSCmdlet.ShouldProcess($_.FullName, $ScriptName)) {
            $moduleVersion = Test-ModuleManifest -Path $_.FullName | Select-Object -Property 'ModuleVersion'
            $oldVersion = [version]$moduleVersion

            $updateModuleManifestHash = @{
                Path          = $_.FullName
                Author        = 'John Merryweather Cooper'
                Company       = 'John Merryweather Cooper'
                Copyright     = 'Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.'
                LicenseUri    = 'https://opensource.org/license/BSD-3-clause'
                ModuleVersion = ('{0}.{1}.{2}.{3}' -f $oldVersion.Major, $oldVersion.Minor, $fileVersion.Build, $fileVersion.Revision)
                ProjectUri    = 'https://github.com/jmcooper176/PowerShellModules'
                ReleaseNotes  = ('{0:s} - Development Release' -f (Get-UtcDate))
                Verbose       = Test-Verbose -InvocationInfo $MyInvocation
            }

            Update-ModuleManifest @updateModuleManifestHash
        }
    }
}

if ($UpdateVersionInfo.IsPresent) {
    Get-ChildItem -LiteralPath $SolutionDir -Filter 'VersionInfo.cs' -Recurse -File | Where-Object -FilterScript { $_.DirectoryName.Contains('PSInstallCom') } | ForEach-Object -Process {
        if ($PSCmdlet.ShouldProcess($_.FullName, $ScriptName)) {
            Write-AssemblyVersion -LiteralPath $_.FullName -Version $assemblyVersion.ToString()
            Write-FileVersion -LiteralPath $_.FullName -Version $fileVersion.ToString()
            Write-InformationalVersion -LiteralPath $_.FullName -Version $informationalVersion.ToString()
        }
    }
}
