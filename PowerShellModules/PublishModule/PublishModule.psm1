<#
 =============================================================================
<copyright file="PublishModule.psm1" company="John Merryweather Cooper">
    Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

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
This file "PublishModule.psm1" is part of "PublishModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#################################################
#
#               Helper functions
#
#################################################>

<#
    Out-FileNoBom
#>
function Out-FileNoBom {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [Alias('File')]
        [string]
        $LiteralPath,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [string[]]
        $Value,

        [switch]
        $AsByteStream,

        [switch]
        $Force,

        [switch]
        $NoNewline,

        [switch]
        $PassThru
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $setContentSplat = @{
            LiteralPath = [string]::Empty
            Value       = [string]::Empty
            Encoding    = 'utf8NoBOM'
            Force       = $Force.IsPresent
            NoNewline   = $NoNewline.IsPresent
            PassThru    = $PassThru.IsPresent
        }

        if (Test-PSVersion -Major 6 -Minor 0) {
            $setContentSplat.Add('AsByteStream', $AsByteStream.IsPresent)
        }
    }

    PROCESS {
        $setContentSplat['LiteralPath'] = $LiteralPath
        $setContentSplat['Value'] = $Value

        if ($PassThru.IsPresent) {
            Set-Content @setContentSplat | Write-Output
        }
        else {
            Set-Content @SetContentSplat
        }
    }

    <#
        .SYNOPSIS
        Write out to a file using UTF-8 without BOM.

        .PARAMETER LiteralPath
        Specifies the file to overwrite or set the contents of.

        .PARAMETER Value
        The new file contents.

        .PARAMETER AsByteStream
        If present, write the file as a byte stream.

        .PARAMETER Force
        If present, overwrites the file without prompting even if it is read-only.

        .PARAMETER NoNewline
        If present, `Out-FileNoBOM` does append a newline character either after each string of input or at the end of the file.  The
        entire `Value` is written to the file as a single string.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.  All Rigths Reserved.
    #>
}

<#
    Get-Directory
#>
function Get-Directory {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Debug', 'Release')]
        [string]
        $BuildConfig
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $packageFolder = Join-Path -Path $PSScriptRoot -ChildPath "..\artifacts"
        $resourceManagerRootFolder = Join-Path -Path $packageFolder -ChildPath $buildConfig

        $packageFolder, $resourceManagerRootFolder | Write-Output
    }

    <#
        .SYNOPSIS
        Get the Package and build Output directory.

        .PARAMETER BuildConfig
        Either debug or release.

        .PARAMETER Profile
        Either Latest or Stack.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#################################################
#
#               Get module functions
#
#################################################>

<#
    Get-RollupModule
#>
function Get-RollupModule {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Stack', 'All', 'Latest', 'NetCore')]
        [string]
        $Scope,

        [switch]
        $IsNetCore
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $targets = @()

        switch ($Scope) {
            { ($_ -eq 'All') -or ($_ -eq 'Latest') -or ($_ -eq 'NetCore') } {
                if ($IsNetCore.IsPresent -or ($_ -eq 'NetCore')) {
                    Write-Information -MessageData "Publishing Az and AzPreviw for .NetCore" -InformationAction Continue
                    $targets += Join-Path -Path $PSScriptRoot -ChildPath "Az"
                    $targets += Join-Path -Path $PSScriptRoot -ChildPath "AzPreview"
                }
                else {
                    Write-Information -MessageData "$($CmdletName) : Publishing AzureRM" -InformationAction Continue
                    $targets += Join-Path -Path $PSScriptRoot -ChildPath "AzureRM"
                }

                break
            }

            'Stack' {
                Write-Information -MessageData "$($CmdletName) : Publishing AzureRM and AzureStack" -InformationAction Continue
                $targets += Join-Path -Path $PSScriptRoot -ChildPath "..\src\StackAdmin\AzureRM"
                $targets += Join-Path -Path $PSScriptRoot -ChildPath "..\src\StackAdmin\AzureStack"
                break
            }
        }

        $targets | Write-Output
    }

    <#
        .SYNOPSIS
        Get the list of rollup modules.  Currently AzureRM, for Stack and Azure, or AzureStack.

        .PARAMETER BuildConfig
        Either debug or release.

        .PARAMETER SCOPE
        All, AzureRM, and Stack are valid Rollup modules.

        .PARAMETER IsNetCore
        If built using .NET core.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Get-AdminModule
#>
function Get-AdminModule {
    [CmdletBinding()]
    param
    (
        [ValidateSet('Debug', 'Release')]
        [string]
        $BuildConfig,

        [ValidateSet('Latest', 'Stack')]

        [ValidateSet('Stack', 'All', 'Latest', 'NetCore')]
        [string]
        $Scope
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $targets = @()
        if ($Scope -eq "Stack") {
            $packageFolder, $resourceManagerRootFolder = Get-Directory -BuildConfig $BuildConfig

            $resourceManagerModules = Get-ChildItem -Path $resourceManagerRootFolder -Directory -Filter Azs.*
            foreach ($module in $resourceManagerModules) {
                $targets += $module.FullName
            }
        }
        $targets | Write-Output
    }

    <#
        .SYNOPSIS
        Find and return all admin modules.

        .PARAMETER BuildConfig
        Either debug or release.

        .PARAMETER Profile
        Either Latest or Stack.

        .PARAMETER Scope
        The Module or class of Modules to build.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Get-ClientModule
#>
function Get-ClientModule {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Debug', 'Release')]
        [string]
        $BuildConfig,

        [Parameter(Mandatory)]
        [ValidateSet('Stack', 'All', 'Latest', 'NetCore')]
        [string]
        $Scope,

        [switch]
        $PublishLocal,

        [switch]
        $IsNetCore
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        # Get all module directories
        $getChildItemSplat = @{
            Path      = $resourceManagerRootFolder
            Directory = $true
            Exclude   = 'Azs.*'
        }
    }

    PROCESS {
        $targets = @()

        $packageFolder, $resourceManagerRootFolder = Get-Directory -BuildConfig $BuildConfig

        # Everyone but Storage
        $AllScopes = @('Stack', 'All', 'Latest', 'NetCore')

        if ($Scope -in $AllScopes -or $PublishLocal.IsPresent) {
            if ($Scope -eq "Netcore") {
                $targets += Join-Path -Path $resourceManagerRootFolder -ChildPath "Az.Accounts"
            }
            else {
                $targets += Join-Path -Path $resourceManagerRootFolder -ChildPath "AzureRM.Profile"
            }
        }

        $StorageScopes = @('All', 'Latest', 'Stack', 'AzureStorage')

        if ($Scope -in $StorageScopes) {
            $targets += Join-Path -Path $packageFolder -ChildPath "$buildConfig\Storage\Azure.Storage"
        }

        # Handle things which don't support netcore yet.
        if (-not $IsNetCore.IsPresent) {
            $ServiceScopes = @('All', 'Latest', 'Service')

            if ($Scope -in $ServiceScopes) {
                $targets += Join-Path -Path $packageFolder -ChildPath "$buildConfig\Service\Azure"
            }
        }

        # Get the list of targets
        if ($Scope -in $AllScopes) {
            if ($IsNetCore.IsPresent) {
                $resourceManagerModules = Get-ChildItem @getChildItemSplat | Where-Object -FilterScript { $_.Name -like "*Az.*" -or $_.Name -eq "Az" }
            }
            else {
                $resourceManagerModules = Get-ChildItem @getChildItemSplat | Where-Object -FilterScript { $_.Name -like "*Azure*" }
            }

            # We should ignore these, they are handled separatly.
            $excludedModules = @('AzureRM.Profile', 'Azure.Storage', 'Az.Accounts')

            # Add all modules for AzureRM for Azure
            foreach ($module in $resourceManagerModules) {
                # AzureRM.Profile already added, Azure.Storage built from test dependencies
                if (-not ($module.Name -in $excludedModules)) {
                    $targets += $module.FullName
                }
            }
        }

        $targets | Write-Output
    }

    <#
        .SYNOPSIS
        Get the list of Azure modules.

        .PARAMETER BuildConfig
        Either release or debug.

        .PARAMETER Profile
        Either Latest or Stack

        .PARAMETER Scope
        The scope, either a specific Module or class of modules.

        .PARAMETER PublishLocal
        If publishing locally only.

        .PARAMETER IsNetCore
        If built with .NET core.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Get-AllModule
#>
function Get-AllModule {
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param(
        [ValidateSet('Debug', 'Release')]
        [string]
        $BuildConfig,

        [ValidateNotNullOrEmpty()]
        [string]
        $Scope,

        [switch]
        $PublishLocal,

        [switch]
        $IsNetCore
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Write-Information -MessageData "Getting Azure client modules" -InformationAction Continue

    if ($IsNetCore.IsPresent) {
        $clientModules = Get-ClientModule -BuildConfig $BuildConfig -Scope $Scope -PublishLocal:$PublishLocal.IsPresent -IsNetCore
    }
    else {
        $clientModules = Get-ClientModule -BuildConfig $BuildConfig -Scope $Scope -PublishLocal:$PublishLocal.IsPresent
    }

    Write-Information -MessageData " " -InformationAction Continue

    if ($clientModules.Length -le 2) {
        return @{
            ClientModules = $clientModules
        }
    }

    Write-Information -MessageData "$($CmdletName) : Getting admin modules" -InformationAction Continue
    $adminModules = Get-AdminModule -BuildConfig $BuildConfig -Scope $Scope
    Write-Information -MessageData " " -InformationAction Continue

    Write-Information -MessageData "$($CmdletName) : Getting rollup modules"
    $rollupModules = Get-RollupModule -BuildConfig $BuildConfig -Scope $Scope -IsNetCore:$IsNetCore.IsPresent
    Write-Information -MessageData " " -InformationAction Continue

    return @{
        ClientModules = $clientModules
        AdminModules  = $adminModules
        RollUpModules = $rollUpModules
    }

    <#
        .SYNOPSIS
        Get the modules to publish.

        .PARAMETER BuildConfig
        The build configuration, either Release or Debug

        .PARAMETER Scope
        The module scope, either All, Storage, or Stack.

        .PARAMETER PublishToLocal
        $true if publishing locally only, $false otherwise

        .PARAMETER Profile
        Either Latest or Stack

        .PARAMETER IsNetCore
        If the modules are built using Net Core.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#################################################
#
#       Create and update NuGet functions.
#
#################################################>

<#
    Remove-ModuleDependency
#>
function Remove-ModuleDependency {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $Path,

        [switch]
        $KeepRequiredModules
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if (-not $KeepRequiredModules.IsPresent) {
            $regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList "RequiredModules\s*=\s*@\([^\)]+\)"
            $content = (Get-Content -LiteralPath $Path) -join [Environment]::NewLine
            $text = $regex.Replace($content, "RequiredModules = @()")
            Out-FileNoBom -File $Path -Text $text
        }

        $regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList "NestedModules\s*=\s*@\([^\)]+\)"
        $content = (Get-Content -LiteralPath $Path) -join [Environment]::NewLine

        $file = Get-Item -LiteralPath $Path
        Import-LocalizedData -BindingVariable ModuleMetadata -BaseDirectory $file.DirectoryName -FileName $file.Name
        $ReplacedNestedModules = ""
        foreach ($nestedModule in $ModuleMetadata.NestedModules) {
            if ('.dll' -ne [System.IO.Path]::GetExtension($nestedModule)) {
                $ReplacedNestedModules += "'$nestedModule', "
            }
        }
        if ("" -ne $ReplacedNestedModules) {
            $ReplacedNestedModules = $ReplacedNestedModules.Substring(0, $ReplacedNestedModules.Length - 2)
        }

        $text = $regex.Replace($content, "NestedModules = @($ReplacedNestedModules)")
        Out-FileNoBom -File $Path -Text $text
    }

    <#
        .SYNOPSIS
        Remove the RequiredModules and NestedModules psd1 properties with empty array.

        .PARAMETER Path
        Path to the psd1 file.

        .PARAMETER KeepRequiredModules
        Switch to keep RequiredModules.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    #>
}

<#
    Update-NuGetPackage
#>
function Update-NuGetPackage {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepoPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleName,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $DirPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NuGetPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $regex2 = "<requireLicenseAcceptance>false</requireLicenseAcceptance>"

        $relDir = Join-Path -Path $DirPath -ChildPath "_rels"
        $contentPath = Join-Path -Path $DirPath -ChildPath '`[Content_Types`].xml'
        $packPath = Join-Path -Path $DirPath -ChildPath "package"
        $modulePath = Join-Path -Path $DirPath -ChildPath ($ModuleName + ".nuspec")

        # Cleanup
        Remove-Item -Recurse -Path $relDir -Force
        Remove-Item -Recurse -Path $packPath -Force
        Remove-Item -Path $contentPath -Force

        # Create new output
        $content = (Get-Content -LiteralPath $modulePath) -join [Environment]::NewLine
        $content = $content -replace $regex2, ("<requireLicenseAcceptance>true</requireLicenseAcceptance>")
        Out-FileNoBom -File (Join-Path -Path (Get-Location) -ChildPath $modulePath) -Text $content

        # https://stackoverflow.com/a/36369540/294804
        &$NuGetPath pack $modulePath -OutputDirectory $TempRepoPath -NoPackageAnalysis
    }

    <#
        .SYNOPSIS
        Update license acceptance to be required.

        .PARAMETER TempRepoPath
        Path to the local temporary repository.

        .PARAMETER ModuleName
        Name of the module to update.

        .PARAMETER DirPath
        Path to the directory holding the modules to update.

        .PARAMETER NuGetPath
        Path to the NuGet executable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Add-Module
#>
function Add-Module {
    [CmdletBinding()]
    param(
        [String[]]
        $ModulePaths,

        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepo,

        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepoPath,

        [ValidateNotNullOrEmpty()]
        [string]
        $NuGetPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        foreach ($modulePath in $ModulePaths) {
            Write-Verbose -Message $modulePath
            $module = Get-Item -Path $modulePath
            Write-Verbose -Message "Updating $module module from $modulePath"
            Add-Module -Path $modulePath -TempRepo $TempRepo -TempRepoPath $TempRepoPath -NuGetPath $NuGetPath
            Write-Verbose -Message "Updated $module module"
        }
    }

    <#
        .SYNOPSIS
        Add given modules to local repository.

        .PARAMETER ModulePaths
        List of paths to modules.

        .PARAMETER TempRepo
        Name of local temporary repository.

        .PARAMETER TempRepoPath
        Path to local temporary repository.

        .PARAMETER NuGetPath
        Path to NuGet executable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Save-PackageLocally
#>
function Save-PackageLocally {
    [CmdletBinding()]
    param(
        $Module,

        [string]
        $TempRepo,

        [string]
        $TempRepoPath
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $ModuleName = $module['ModuleName']
    $RequiredVersion = $module['RequiredVersion']

    # Only check for the modules that specifies = required exact dependency version
    if ($null -ne $RequiredVersion) {
        Write-Verbose -Message "Checking for required module $ModuleName, $RequiredVersion"
        if (Find-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Repository $TempRepo -ErrorAction SilentlyContinue) {
            Write-Verbose -Message "Required dependency $ModuleName, $RequiredVersion found in the repo $TempRepo"
        }
        else {
            Write-Warning -Message "Required dependency $ModuleName, $RequiredVersion not found in the repo $TempRepo"
            Write-Verbose -Message "Downloading the package from PsGallery to the path $TempRepoPath"
            # We try to download the package from the PsGallery as we are likely intending to use the existing version of the module.
            # If the module not found in psgallery, the following commnad would fail and hence publish to local repo process would fail as well
            Save-Package -Name $ModuleName -RequiredVersion $RequiredVersion -ProviderName NuGet -Path $TempRepoPath -Source https://www.powershellgallery.com/api/v2 | Out-Null
            $NupkgFilePath = Join-Path -Path $TempRepoPath -ChildPath "$ModuleName.$RequiredVersion.nupkg"
            $ModulePaths = $env:PSModulePath -split ';'
            $DestinationModulePath = [System.IO.Path]::Combine($ModulePaths[0], $ModuleName, $RequiredVersion)
            Expand-Archive -Path $NupkgFilePath -DestinationPath $DestinationModulePath -Force
            Write-Verbose -Message "Downloaded the package sucessfully"
        }
    }

    <#
        .SYNOPSIS
        Saves a module into the local temporary repository

        .PARAMETER Module
        Module information.

        .PARAMETER TempRepo
        Name of the local temporary repository

        .PARAMETER TempRepoPath
        Path to the local temporary repository

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Save-PackagesFromPSGallery
#>
function Save-PackagesFromPsGallery {
    [CmdletBinding()]
    param(
        [String[]]
        $ModulePaths,

        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepo,

        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepoPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Write-Verbose -Message "Saving..."

        foreach ($modulePath in $ModulePaths) {
            Write-Verbose -Message "module path $modulePath"

            $module = (Get-Item -Path $modulePath).Name
            $moduleManifest = $module + ".psd1"

            Write-Information -MessageData "Verifying $module has all the dependencies in the repo $TempRepo" -InformationAction Continue

            $psDataFile = Import-PowerShellDataFile (Join-Path $modulePath -ChildPath $moduleManifest)
            $RequiredModules = $psDataFile['RequiredModules']

            if ($null -ne $RequiredModules) {
                foreach ($tmp in $RequiredModules) {
                    foreach ($module in $tmp) {
                        Save-PackageLocally -Module $module -TempRepo $TempRepo -TempRepoPath $TempRepoPath
                    }
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Save the packages from PsGallery to local repo path

        .DESCRIPTION
        This is typically used in a scenario where we are intending to use the existing publshed version of the module as a dependency
        Checks whether the module is already published in the local temp repo, if not downloads from the PSGallery
        This is used only for the rollup modules AzureRm or AzureStack at the moment

        .PARAMETER ModulePaths
        List of paths to modules.

        .PARAMETER TempRepo
        Name of local temporary repository.

        .PARAMETER TempRepoPath
        Path to local temporary repository.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Add-AllModule
#>
function Add-AllModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]
        $Modules,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepo,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $TempRepoPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NuGetPath
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $Keys = @('ClientModules', 'AdminModules', 'RollupModules')
    Write-Verbose -Message "$($CmdletName) : Adding modules to local repo"

    foreach ($module in $Keys) {
        $modulePath = $Modules[$module]
        Write-Verbose -Message "$($CmdletName) : Adding '$($module)' modules to local repo"

        # Save missing dependencies locally from PS gallery.
        Save-PackagesFromPsGallery -TempRepo $TempRepo -TempRepoPath $TempRepoPath -ModulePaths $modulePath

        # Add the modules to the local repository
        Add-Module -TempRepo $TempRepo -TempRepoPath $TempRepoPath -ModulePath $modulePath -NuGetPath $NuGetPath
        Write-Verbose -Message " "
    }
    Write-Verbose -Message "$($CmdletName) : Removing lower version Az.Accounts packages"
    $packages = Get-ChildItem -LiteralPath "./artifacts" -Filter "Az.Accounts.*.nupkg"
    $latestVersion = [version]"0.0.0"
    $latestPackage = $null

    foreach ($package in $packages) {
        $fileName = $package.Name
        $versionString = $fileName.Replace('Az.Accounts.', '').Replace('.nupkg', '')
        $version = [version]$versionString

        if ($version -gt $latestVersion) {
            $latestVersion = $version
            $latestPackage = $package
        }
    }

    foreach ($package in $packages) {
        if ($package.FullName -ne $latestPackage.FullName) {
            Remove-Item $package.FullName -Force
        }
    }

    Write-Verbose -Message " "

    <#
        .SYNOPSIS
        Add all modules to local repo.

        .PARAMETER Modules
        A hash table of Modules types and paths.

        .PARAMETER TempRepo
        The name of the temporary repository.

        .PARAMETER TempRepoPath
        Path to the temporary reposityroy.

        .PARAMETER NuGetPath
        Location of NuGet executable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#################################################
#
#           Publish module functions.
#
#################################################>

<#
    Add-RootModule
#>
function Add-RootModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [SupportsWildcards()]
        [string]
        $Path)

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Get-Item -Path $Path | ForEach-Object -Process {
            $file = $_

            if ($file.Extension -eq ".psd1") {
                $psm1file = $file.Name -replace ".psd1", ".psm1"
                Update-ModuleManifest -Path $Path -RootModule $psm1file
            }
            elseif ($file.Extension -eq ".psm1") {
                $Path = $file.FullName -replace ".psm1", ".psd1"
                Update-ModuleManifest -Path $Path -RootModule $file.Name
            }
            else {
                $message = "$($CmdletName) : Invalid PowerShell file type by extension '$($file.Extension)'"
                $newErrorRecodSplat = @{
                    Category           = 'InvalidArgument'
                    CategoryActivity   = 'Adding/Updating PowerShell PSM1 root module dependency'
                    CategoryReason     = "Invalid PowerShell file type by extension '$($file.Extension)'"
                    CategoryTargetName = 'Path'
                    CategoryTargetType = 'System.String'
                    ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationExtension' -Position $MyInvocation.ScriptLineNumber
                    Exception          = [System.InvalidOperationException]::new($message)
                    Message            = $message
                    RecommendedAction  = "Please provide a Parameter 'Path' with a valid file extension from { '.psd1', '.psm1' }"
                    TargetObject       = $Path
                }

                $er = New-ErrorRecord @newErrorRecodSplat

                Write-Error -ErrorRecord $er -ErrorAction Continue
                throw $er
            }
        }
    }

    <#
        .SYNOPSIS
        Add or update the RootModule in the module manifest.

        .PARAMETER Path
        Path to the module manifest or module script file.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Add-ModuleVersion
#>
function Add-ModuleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [version]
        $ModuleVersion
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Get-Item -Path $Path | ForEach-Object -Process {
            $file = $_

            if ($file.Extension -eq ".psd1") {
                Update-ModuleManifest -Path $Path -ModuleVersion $ModuleVersion.ToString()
            }
            elseif ($file.Extension -eq ".psm1") {
                $Path = $file.FullName -replace ".psm1", ".psd1"
                Update-ModuleManifest -Path $Path -ModuleVersion $ModuleVersion.ToString()
            }
            else {
                $message = "$($CmdletName) : Invalid PowerShell file type by extension '$($file.Extension)'"
                $newErrorRecordSplat = @{
                    Category           = 'InvalidArgument'
                    CategoryActivity   = 'Adding/Updating PowerShell PSM1 root module dependency'
                    CategoryReason     = "Invalid PowerShell file type by extension '$($file.Extension)'"
                    CategoryTargetName = 'Path'
                    CategoryTargetType = 'System.String'
                    ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationExtension' -Position $MyInvocation.ScriptLineNumber
                    Exception          = [System.InvalidOperationException]::new($message)
                    Message            = $message
                    RecommendedAction  = "Please provide a Parameter 'Path' with a valid file extension from { '.psd1', '.psm1' }"
                    TargetObject       = $Path
                }

                $er = New-ErrorRecord @newErrorRecordSplat

                Write-Error -ErrorRecord $er -ErrorAction Continue
                throw $er
            }
        }
    }

    <#
        .SYNOPSIS
        Add or update the ModuleVersion in the module manifest.

        .PARAMETER Path
        Path to the module manifest or module script file.

        .PARAMETER ModuleVersion
        The version to add or update in the module manifest.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Add-Guid
#>
function Add-Guid {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [guid]
        $Guid
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Get-Item -Path $Path | ForEach-Object -Process {
            $file = $_

            if ($file.Extension -eq ".psd1") {
                Update-ModuleManifest -Path $Path -Guid $Guid.ToString("D")
            }
            elseif ($file.Extension -eq ".psm1") {
                $Path = $file.FullName -replace ".psm1", ".psd1"
                Update-ModuleManifest -Path $Path -Guid $Guid.ToString("D")
            }
            else {
                $message = "$($CmdletName) : Invalid PowerShell file type by extension '$($file.Extension)'"
                $newErrorRecordSplat = @{
                    Category           = 'InvalidArgument'
                    CategoryActivity   = 'Adding/Updating PowerShell Guid module dependency'
                    CategoryReason     = "Invalid PowerShell file type by extension '$($file.Extension)'"
                    CategoryTargetName = 'Path'
                    CategoryTargetType = 'System.String'
                    ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationExtension' -Position $MyInvocation.ScriptLineNumber
                    Exception          = [System.InvalidOperationException]::new($message)
                    Message            = $message
                    RecommendedAction  = "Please provide a Parameter 'Path' with a valid file extension from { '.psd1', '.psm1' }"
                    TargetObject       = $Path
                }

                $er = New-ErrorRecord @newErrorRecordSplat

                Write-Error -ErrorAction $er -ErrorAction Continue
                throw $er
            }
        }
    }

    <#
        .SYNOPSIS
        Add or update the Guid in the module manifest.

        .PARAMETER Path
        Path to the module manifest or module script file.

        .PARAMETER Guid
        The Guid to add or update in the module manifest.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Add-Author
#>
function Add-Author {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Author
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Get-Item -Path $Path | ForEach-Object -Process {
            $file = $_

            if ($file.Extension -eq ".psd1") {
                Update-ModuleManifest -Path $Path -Author $Author
            }
            elseif ($file.Extension -eq ".psm1") {
                $Path = $file.FullName -replace ".psm1", ".psd1"
                Update-ModuleManifest -Path $Path -Author $Author
            }
            else {
                $message = "$($CmdletName) : Invalid PowerShell file type by extension '$($file.Extension)'"
                $newErrorRecordSplat = @{
                    Category           = 'InvalidArgument'
                    CategoryActivity   = 'Adding/Updating PowerShell Author module dependency'
                    CategoryReason     = "Invalid PowerShell file type by extension '$($file.Extension)'"
                    CategoryTargetName = 'Path'
                    CategoryTargetType = 'System.String'
                    ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationExtension' -Position $MyInvocation.ScriptLineNumber
                    Message            = $message
                    RecommendedAction  = "Please provide a Parameter 'Path' with a valid file extension from { '.psd1', '.psm1' }"
                    TargetObject       = $Path
                }

                $er = New-ErrorRecord @newErrorRecordSplat

                Write-Error -ErrorRecord $er -ErrorAction Continue
                throw $er
            }
        }
    }

    <#
        .SYNOPSIS
        Add or update the Author in the module manifest.

        .PARAMETER Path
        Path to the module manifest or module script file.

        .PARAMETER Author
        The Author to add or update in the module manifest.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Add-CompanyName
#>
function Add-CompanyName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CompanyName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Get-Item -Path $Path | ForEach-Object -Process {
            $file = $_

            if ($file.Extension -eq ".psd1") {
                Update-ModuleManifest -Path $Path -CompanyName $CompanyName
            }
            elseif ($file.Extension -eq ".psm1") {
                $Path = $file.FullName -replace ".psm1", ".psd1"
                Update-ModuleManifest -Path $Path -CompanyName $CompanyName
            }
            else {
                $message = "$($CmdletName) : Invalid PowerShell file type by extension '$($file.Extension)'"
                $newErrorRecordSplat = @{
                    Category           = 'InvalidArgument'
                    CategoryActivity   = 'Adding/Updating PowerShell CompanyName module dependency'
                    CategoryReason     = "Invalid PowerShell file type by extension '$($file.Extension)'"
                    CategoryTargetName = 'Path'
                    CategoryTargetType = 'System.String'
                    ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'PSArgumentExtension' -Position $MyInvocation.ScriptLineNumber
                    Exception          = [System.Management.Automation.PSArgumentException]::new($message, 'Path')
                    Message            = $message
                    RecommendedAction  = "Please provide a Parameter 'Path' with a valid file extension from { '.psd1', '.psm1' }"
                    TargetObject       = $Path
                }

                $er = New-ErrorRecord @newErrorRecordSplat

                Write-Error -ErrorRecord $er -ErrorAction Continue
                throw $er
            }
        }
    }

    <#
        .SYNOPSIS
        Add or update the CompanyName in the module manifest.

        .PARAMETER Path
        Path to the module manifest or module script file.

        .PARAMETER CompanyName
        The Author to add or update in the module manifest.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Add-Copyright
#>
function Add-Copyright {
    [CmdletBinding(DefaultParameterSetName = 'UsingCopyright', SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'UsingCopyright')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Copyright,

        [Parameter(Mandatory, ParameterSetName = 'UsingFormat')]
        [ValidateRange(1776, 2147483647)]
        [int]
        $Year,

        [Parameter(Mandatory, ParameterSetName = 'UsingFormat')]
        [ValidateNotNullOrEmpty()]
        [string]
        $CompanyName,

        [Parameter(Mandatory, ParameterSetName = 'UsingCustomFormat')]
        [ValidateNotNullOrEmpty()]
        [string]
        $CustomFormat,

        [Parameter(ParameterSetName = 'UsingCustomFormat')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]
        $Arguments
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Set-Variable -Name CopyrightFormat -Option Constant -Value "Copyright © {0}, {1}.  All Rights Reserved." -WhatIf:$false

        if ($PSCmdlet.ParameterSetName -eq 'UsingFormat') {
            $Copyright = ($CopyrightFormat -eq $Year, $CompanyName)
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingCustomFormat') {
            if ((Test-PSParameter -Name 'Arguments' -Parameters $PSBoundParameters) -and ($null -ne $Arguments) -and ($Arguments.Length -gt 0)) {
                $Copyright = ($CustomFormat -f $Arguments)
            }
            else {
                $Copyright = $CustomFormat
            }
        }
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingFormat' {
                Add-Copyright -Path $Path -Copyright $Copyright
                break
            }

            'UsingCustomFormat' {
                Add-Copyright -Path $Path -Copyright $Copyright
                break
            }

            default {
                Get-Item -Path $Path | ForEach-Object -Process {
                    $file = $_

                    if ($PSCmdlet.ShouldProcess($file.FullName, $CmdletName)) {
                        if ($file.Extension -eq ".psd1") {
                            Update-ModuleManifest -Path $Path -Copyright $Copyright
                        }
                        elseif ($file.Extension -eq ".psm1") {
                            $Path = $file.FullName -replace ".psm1", ".psd1"
                            Update-ModuleManifest -Path $Path -Copyright $Copyright
                        }
                        else {
                            $message = "$($CmdletName) : Invalid PowerShell file type by extension '$($file.Extension)'"
                            $newErrorRecordSplat = @{
                                Category           = 'InvalidArgument'
                                CategoryActivity   = 'Adding/Updating PowerShell Copyright module dependency'
                                CategoryReason     = "Invalid PowerShell file type by extension '$($file.Extension)'"
                                CategoryTargetName = 'Path'
                                CategoryTargetType = 'System.String'
                                ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationExtension' -Position $MyInvocation.ScriptLineNumber
                                Message            = $message
                                RecommendedAction  = "Please provide a Parameter 'Path' with a valid file extension from { '.psd1', '.psm1' }"
                                TargetObject       = $Path
                            }

                            $er = New-ErrorRecord @newErrorRecordSplat

                            Write-Error -ErrorRecord $er -ErrorAction Continue
                            throw $er
                        }
                    }
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Add or update the Copyright in the module manifest.

        .PARAMETER Path
        Path to the module manifest or module script file.

        .PARAMETER Copyright
        The Copyright to add or update in the module manifest.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    New-ModuleManifestError
#>
function New-ModuleManifestError {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $Path,

        [ValidateSet('NotSpecified', 'OpenError', 'CloseError', 'DeviceError',
            'DeadlockDetected', 'InvalidArgument', 'InvalidData',
            'InvalidOperation', 'InvalidResult', 'InvalidType', 'MetadataError',
            'NotImplemented', 'NotInstalled', 'ObjectNotFound',
            'OperationStopped', 'OperationTimeout', 'SyntaxError', 'ParserError',
            'PermissionDenied', 'ResourceBusy', 'ResourceExists',
            'ResourceUnavailable', 'ReadError', 'WriteError', 'FromStdErr',
            'SecurityError', 'ProtocolError', 'ConnectionError',
            'AuthenticationError', 'LimitsExceeded', 'QuotaExceeded',
            'NotEnabled')]
        [System.Management.Automation.ErrorCategory]
        $Category = 'InvalidArgument',

        [string]
        $Key,

        [string]
        $TargetName = 'Path',

        [string]
        $TargetType = 'System.String',

        [System.Exception]
        $ExceptionType = [System.ArgumentException],

        [System.Collections.ArrayList]
        $ExtensionList
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $file = Get-Item -LiteralPath $Path

    $buffer = New-StringBuilder
    $first = $true

    $ExtensionList | ForEach-Object -Process {
        if ($first) {
            Add-Start -Buffer $buffer -String ("'{0}'" -f $_)
            $first = $false
        }
        else {
            Add-End -Buffer $buffer -String ", "
            Add-End -Buffer $buffer -String ("'{0}'" -f $_)
        }
    }

    $extensions = ConvertTo-String -Buffer $buffer

    $message = "$($CmdletName) : Invalid PowerShell file type by extension '$($file.Extension)'"
    $newErrorRecordSplat = @{
        Category           = $Category
        CategoryActivity   = "Adding/Updating PowerShell '$($Key)' module dependency"
        CategoryReason     = "Invalid PowerShell file type by extension '$($file.Extension)'"
        CategoryTargetName = $TargetName
        CategoryTargetType = $TargetType
        ErrorId            = Format-ErrorId -Caller $CmdletName -Name $ExceptionType.Name -Position $MyInvocation.ScriptLineNumber
        Exception          = [System.InvalidOperationException]::new($message)
        InnerException     = $ExceptionType
        Message            = $message
        RecommendAction    = "Please provide a Parameter '$($TargetName)' with a valid file extension from { $($extensions) }"
        TargetObject       = $Path
    }

    $er = New-ErrorRecord @newErrorRecordSplat

    Write-Error -ErrorRecord $er -ErrorAction Continue
    throw $er
}

<#
    Add-Module
#>
function Add-Module {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepo,

        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepoPath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NuGetPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Get-Item -LiteralPath $Path | ForEach-Object -Process {
            $moduleName = $_.BaseName
            $moduleManifest = Join-Path $moduleName -ChildPath '.psd1'
            $moduleSourcePath = Join-Path -Path $_.DirectoryName -ChildPath $moduleManifest

            Get-Item -LiteralPath $moduleSourcePath | ForEach-Object -Process {
                $file = $_
                Import-LocalizedData -BindingVariable ModuleMetadata -BaseDirectory $file.DirectoryName -FileName $file.Name

                $moduleVersion = $ModuleMetadata.ModuleVersion.ToString()
                if ($null -ne $ModuleMetadata.PrivateData.PSData.Prerelease) {
                    $moduleVersion += ("-" + $ModuleMetadata.PrivateData.PSData.Prerelease -replace "--", "-")
                }

                if (Find-Module -Name $moduleName -Repository $TempRepo -RequiredVersion $moduleVersion -AllowPrerelease -ErrorAction SilentlyContinue) {
                    Write-Verbose -Message "Existing module found: $moduleName"
                    $moduleNupkgPath = Join-Path -Path $TempRepoPath -ChildPath ($moduleName + "." + $moduleVersion + ".nupkg")
                    Write-Verbose -Message "Deleting the module: $moduleNupkgPath"
                    Remove-Item -Path $moduleNupkgPath -Force
                }

                Write-Verbose -Message "Publishing the module $moduleName"
                Publish-Module -Path $Path -Repository $TempRepo -Force | Out-Null
                Write-Verbose -Message "$moduleName published"

                # Create a psm1 and alter psd1 dependencies to allow fine-grained
                # control over assembly loading.  Opt out by definitng a RootModule.
                if ($ModuleMetadata.RootModule) {
                    Write-Verbose -Message "Root module found, done"
                    #return
                }
                else {
                    Write-Verbose -Message "No root module found, creating"
                }

                Write-Verbose -Message "Changing to local repository directory for module modifications $TempRepoPath"
                Push-Location $TempRepoPath

                try {
                    # Paths
                    $nupkgPath = Join-Path -Path . -ChildPath ($moduleName + "." + $moduleVersion + ".nupkg")
                    $zipPath = Join-Path -Path . -ChildPath ($moduleName + "." + $moduleVersion + ".zip")
                    $dirPath = Join-Path -Path . -ChildPath $moduleName
                    $unzippedManifest = Join-Path -Path $dirPath -ChildPath ($moduleName + ".psd1")

                    # Validate NuGet is there
                    if (-not (Test-Path -LiteralPath $nupkgPath -PathType Leaf)) {
                        $message = "$($CmdletName) : Module at '$($nupkgPath)' in '$($TempRepoPath)' does not exist"
                        $newErrorRecordSplat = @{
                            Category           = 'ObjectNotFound'
                            CategoryActivity   = 'Publishing PowerShell module to NuGet'
                            CategoryReason     = "Module at '$($nupkgPath)' in '$($TempRepoPath) does not exist"
                            CategoryTargetName = 'nupkgPath'
                            CategoryTargetType = 'System.String'
                            ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                            Exception          = [System.IO.FileNotFoundException]::new($message, $nupkgPath)
                            Message            = $message
                            RecommendedAction  = "Please provide a valid path to the module"
                            TargetObject       = $nupkgPath
                        }

                        $er = New-ErrorRecord @newErrorRecordSplat

                        Write-Error -ErrorRecord $er -ErrorAction Continue
                        throw $er
                    }

                    Write-Verbose -Message "Renaming package $nupkgPath to zip archive $zipPath"
                    Rename-Item $nupkgPath $zipPath

                    Write-Verbose -Message "$($CmdletName) : Expanding $zipPath"
                    Expand-Archive $zipPath -DestinationPath $dirPath

                    if ($ModuleMetadata.RootModule) {
                        Write-Verbose -Message "$($CmdletName) : Adding PSM1 dependency is skipped because root module is found"
                    }
                    else {
                        Write-Verbose -Message "$($CmdletName) : Adding PSM1 dependency to $unzippedManifest"
                        Add-RootModule -Path $unzippedManifest
                    }

                    Write-Verbose -Message "Removing module manifest dependencies for $unzippedManifest"
                    Remove-ModuleDependency -Path (Join-Path $TempRepoPath $unzippedManifest -Resolve)

                    Remove-Item -Path $zipPath -Force

                    Write-Verbose -Message "$($CmdletName) : Repackaging $dirPath"
                    Update-NuGetPackage -TempRepoPath $TempRepoPath -ModuleName $moduleName -DirPath $dirPath -NuGetPath $NuGetPath

                    Write-Verbose -Message "$($CmdletName) : Removing temporary folder $dirPath"
                    Remove-Item -Recurse $dirPath -Force -ErrorAction Stop
                }
                finally {
                    Pop-Location
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Publish module to local temporary repository.  If no RootModule found create and add new psm1.

        .PARAMETER Path
        Path to the local module.

        .PARAMETER TempRepo
        Name of the local temporary repository.

        .PARAMETER TempRepoPath
        Path to the local temporary repository.

        .PARAMETER NuGetPath
        Path to NuGet exectuable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Publish-PowerShellModule
#>
function Publish-PowershellModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $TempRepoPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $RepoLocation,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NuGetPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $moduleName = Get-Item -LiteralPath $Path | Select-Object -ExpandProperty Name
        $moduleManifest = $moduleName + ".psd1"
        $moduleSourcePath = Join-Path -Path $Path -ChildPath $moduleManifest
        $manifest = Test-ModuleManifest -Path $moduleSourcePath
        $nupkgPath = Join-Path -Path $TempRepoPath -ChildPath ($moduleName + "." + $manifest.Version.ToString() + ".nupkg")

        if (-not (Test-Path -LiteralPath $nupkgPath -PathType Leaf)) {
            $message = "$($CmdletName) : Module at '$($nupkgPath)' in '$($TempRepoPath)' does not exist"
            $newErrorRecordSplat = @{
                Category           = 'ObjectNotFound'
                CategoryActivity   = 'Publishing PowerShell module to NuGet'
                CategoryReason     = "Module at '$($nupkgPath)' in '$($TempRepoPath) does not exist"
                CategoryTargetName = 'nupkgPath'
                CategoryTargetType = 'System.String'
                ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                Exception          = [System.IO.FileNotFoundException]::new($message, $nupkgPath)
                Message            = $message
                RecommendedAction  = "Please provide a valid path to the module"
                TargetObject       = $nupkgPath
            }

            $er = New-ErrorRecord @newErrorRecordSplat

            Write-Error -ErrorRecord $er -ErrorAction Continue
            throw $er
        }

        Write-Verbose -Message "$($CmdletName) : Pushing package $moduleName to NuGet source '$($RepoLocation)'"
        &$NuGetPath push $nupkgPath $ApiKey -s $RepoLocation
        $formatLastExitCode = ('0x{0:X8}|{0}' -f $LASTEXITCODE)
        Write-Verbose -Message "$($CmdletName) : Pushed package $moduleName to NuGet source '$($RepoLocation)' with exit code '$($formatLastExitCode)'"
    }

    <#
        .SYNOPSIS Publish the module to PS Gallery.

        .PARAMETER Path
        Path to the module.

        .PARAMETER ApiKey
        Key used to publish.

        .PARAMETER TempRepoPath
        Path to the local temporary repository containing NuGet.

        .PARAMETER RepoLocation
        Repository we are publishing too.

        .PARAMETER NuGetPath
        Path to NuGet executable.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    #>
}

<#
    Publish-AllModule
#>
function Publish-AllModule {
    [CmdletBinding()]
    param(
        $ModulePaths,

        [ValidateNotNullOrEmpty()]
        [string]
        $ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]
        $TempRepoPath,

        [ValidateNotNullOrEmpty()]
        [string]
        $RepoLocation,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $NuGetPath,

        [switch]
        $PublishLocal
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

    if (!$PublishLocal) {
        foreach ($module in $ModulePaths.Keys) {
            $paths = $Modules[$module]
            foreach ($modulePath in $paths) {
                $module = Get-Item -Path $modulePath
                Write-Information -MessageData "Pushing $module module from $modulePath" -InformationAction Continue
                Publish-PowershellModule -Path $modulePath -ApiKey $apiKey -TempRepoPath $TempRepoPath -RepoLocation $RepoLocation -NuGetPath $NuGetPath
                Write-Information -MessageData "Pushed $module module" -InformationAction Continue
            }
        }
    }

    <#
        .SYNOPSIS Publish the NuGets to PSGallery

        .PARAMETER ApiKey
        Key used to publish.

        .PARAMETER TempRepoPath
        Path to the local temporary repository.

        .PARAMETER RepoLocation
        Name of repository we are publishing too.

        .PARAMETER NuGetPath
        Path to NuGet executable.

        .PARAMETER PublishLocal
        If publishing locally we don't do anything.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

    #>
}

<#
    Find-Executable
#>
function Find-Executable {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [ValidateSet('Alias', 'All', 'Application', 'Cmdlet', 'ExternalScript', 'Filter', 'Function', 'Script')]
        $CommandType = 'All',

        [switch]
        $ThrowOnError
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName) : Searching for Parameter 'Name' with value '$($Name)' as Command Type '$($CommandType)' in the PATH."
        $Name | Resolve-Path | ForEach-Object -Process {
            $path = Get-Command -All -CommandType $CommandType | Where-Object -Property Name -Like $_ | Select-Object -First 1 -ExpandProperty Path

            if ([string]::IsNullOrEmpty($path) -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
                $message = "$($CmdletName) : Name '$($_)' with Command Type '$($CommandType)' executable not found in the PATH"
                $newErrorRecordSplat = @{
                    Category           = 'ObjectNotFound'
                    CategoryActivity   = "Searching for Parameter 'Name' '$($_)' with Parameter '$($CommandType)' in the PATH"
                    CategoryReason     = "Object '$($_)' and Command Type '$($CommandType)' not found in the PATH"
                    CategoryTargetName = 'Name'
                    CategoryTargetType = 'System.String[]'
                    ErrorId            = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                    Exception          = [System.IO.FileNotFoundException]::new($message, $_)
                    Message            = $message
                    RecommendedAction  = "Please install '$($_)' and add its location to the PATH"
                    TargetObject       = $_
                }

                $er = New-ErrorRecord @newErrorRecordSplat

                Write-Error -ErrorRecord $er -ErrorAction Continue

                if ($ThrowOnError.IsPresent) {
                    throw $er
                }
            }
            else {
                Write-Verbose -Message "$($CmdletName) : Parameter 'Name' with value '$($Name)' found on the PATH at '$($path)'."
            }

            $path | Write-Output
        }
    }

    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER Name
        .PARAMETER CommandType
        .INPUTS
        .OUTPUTS
        .EXAMPLE
        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}
