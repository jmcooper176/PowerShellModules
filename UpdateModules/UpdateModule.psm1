<#
 =============================================================================
<copyright file="UpdateModule.psm1" company="U.S. Office of Personnel
Management">
    Copyright (c) 2022-2025, John Merryweather Cooper.
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
<date>Created:  2025-1-27</date>
<summary>
This file "UpdateModule.psm1" is part of "UpdateModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Constants
#>
Set-Variable -Name TemplateLocation -Option Constant -Value (Join-Path -Path $PSScriptRoot -ChildPath 'AzureRM.Example.psm1')

# Specialty-Scopes used by cmdlets
Set-Variable -Name AzureRMScopes -Option ReadOnly -Value @('All', 'Latest')
Set-Variable -Name StorageScopes -Option ReadOnly -Value @('All', 'Latest', 'AzureStorage')
Set-Variable -Name ServiceScopes -Option ReadOnly -Value @('All', 'Latest', 'ServiceManagement')

# Package locations
Set-Variable -Name AzurePackages -Option ReadOnly -Value (Join-Path -Path $PSScriptRoot -ChildPath '..\artifacts')
Set-Varible -Name StackPackages -Option ReadOnly -Value (Join-Path -Path $PSScriptRoot -ChildPath '..\src\Stack')
Set-Variable -Name StackProjects -Option ReadOnly -Value (Join-Path -Path $PSScriptRoot -ChildPath '..\src\StackAdmin')

# Resource Management folders
Set-Variable -Name AzureRMRoot -Option ReadOnly -Value (Join-Path -Path $AzurePackages -ChildPath $buildConfig)
Set-Variable -Name StackRMRoot -Option ReadOnly -Value (Join-Path -Path $StackPackages -ChildPath $buildConfig)

<#
    New-ModulePsm1
#>
function New-ModulePsm1 {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $ModulePath,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $TemplatePath,

        [switch]
        $IsRMModule,

        [switch]
        $IsNetcore,

        [switch]
        $IgnorePwshVersion  #Ignore pwsh version check in Debug configuration
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $manifestDir = Get-Item -LiteralPath $ModulePath
        $moduleName = $manifestDir.Name + ".psd1"
        $manifestPath = (Get-Item -LiteralPath (Join-Path -Path $manifestDir -ChildPath $moduleName))

        Import-LocalizedData -BindingVariable ModuleMetadata -BaseDirectory $manifestPath.DirectoryName -FileName $manifestPath.Name

        # Do not create a psm1 file if the RootModule dependency already has one.
        if ($ModuleMetadata.RootModule) {
            Write-Information -MessageData "root modules exists, skipping..." -InformationAction Continue
            return
        }

        # Create the actual file and insert import statements.
        $templateOutputPath = $manifestPath.FullName -replace ".psd1", ".psm1"
        [string]$importedModules

        if ($null -ne $ModuleMetadata.RequiredModules) {
            foreach ($mod in $ModuleMetadata.RequiredModules) {
                if ($mod["ModuleVersion"]) {
                    $importedModules += New-MinimumVersionEntry -ModuleName $mod["ModuleName"] -MinimumVersion $mod["ModuleVersion"]
                } elseif ($mod["RequiredVersion"]) {
                    $importedModules += "Import-Module " + $mod["ModuleName"] + " -RequiredVersion " + $mod["RequiredVersion"] + " -Global`r`n"
                }
            }
        }

        # Create imports for nested modules.
        if ($null -ne $ModuleMetadata.NestedModules) {
            foreach ($dll in $ModuleMetadata.NestedModules) {
                if ($dll.EndsWith("dll")) {
                    $importedModules += "Import-Module (Join-Path -Path `$PSScriptRoot -ChildPath " + $dll + ")`r`n"
                } elseif ($dll -eq ($manifestDir.Name + ".psm1")) {
                    $importedModules += "Import-Module (Join-Path -Path `$PSScriptRoot -ChildPath Microsoft.Azure.PowerShell.Cmdlets." + $manifestDir.Name.Split(".")[-1] + ".dll" + ")`r`n"
                }
            }
        }

        # Scripts to preload dependency assemblies on Windows PowerShell
        # https://stackoverflow.com/a/60068470
        $preloadAssemblies = [string]::Empty
        $isAzAccounts = $file.BaseName -ieq 'Az.Accounts'

        if ($isAzAccounts) {
            $preloadAssemblies += 'if ($PSEdition -eq "Desktop") {
    [Microsoft.Azure.PowerShell.AssemblyLoading.ConditionalAssemblyProvider]::GetAssemblies().Values | ForEach-Object {
        $path = $$_.Item1
        try {
            Add-Type -Path $path -ErrorAction Ignore | Out-Null
        }
        catch {
            Write-Verbose "Could not preload $path"
        }
    }
}'
        }

        # Grab the template and replace with information.
        $template = Get-Content -Path $TemplatePath
        $template = $template -replace "%MODULE-NAME%", $manifestPath.BaseName
        $template = $template -replace "%DATE%", [string](Get-Date)
        $template = $template -replace "%IMPORTED-DEPENDENCIES%", $importedModules
        $template = $template -replace "%PRELOAD-ASSEMBLY%", $preloadAssemblies

        #Az.Storage is using Azure.Core, so need to check PS version
        if ($IsNetcore)
        {
            if($IgnorePwshVersion)
            {
                $template = $template -replace "%AZURECOREPREREQUISITE%", ""
            }
            elseif($manifestPath.BaseName -ieq 'Az.Accounts')
            {
                $template = $template -replace "%AZURECOREPREREQUISITE%",
@"
if (%ISAZMODULE% -and (`$PSEdition -eq 'Core'))
{
    if (`$PSVersionTable.PSVersion -lt [Version]'6.2.4')
    {
        throw "Current Az version doesn't support PowerShell Core versions lower than 6.2.4. Please upgrade to PowerShell Core 6.2.4 or higher."
    }
    if (`$PSVersionTable.PSVersion -lt [Version]'7.0.6')
    {
        Write-Warning "This version of Az.Accounts is only supported on Windows PowerShell 5.1 and PowerShell 7.0.6 or greater, open https://aka.ms/install-powershell to learn how to upgrade. For further information, go to https://aka.ms/azpslifecycle."
    }
}
"@
            }
            else
            {
                $template = $template -replace "%AZURECOREPREREQUISITE%",
@"
if (%ISAZMODULE% -and (`$PSEdition -eq 'Core'))
{
    if (`$PSVersionTable.PSVersion -lt [Version]'6.2.4')
    {
        throw "Current Az version doesn't support PowerShell Core versions lower than 6.2.4. Please upgrade to PowerShell Core 6.2.4 or higher."
    }
}
"@
            }
        }
        # Replace Az or AzureRM with correct information
        if ($IsNetcore)
        {
            $template = $template -replace "%AZORAZURERM%", "AzureRM"
            $template = $template -replace "%ISAZMODULE%", "`$true"
        }
        else
        {
            $template = $template -replace "%AZORAZURERM%", "`Az"
            $template = $template -replace "%ISAZMODULE%", "`$false"
        }

        # Register CommandNotFound event in Az.Accounts
        if ($IsNetcore -and $manifestPath.BaseName -ieq 'Az.Accounts')
        {
            $template = $template -replace "%COMMAND-NOT-FOUND%",
@"
[Microsoft.Azure.Commands.Profile.Utilities.CommandNotFoundHelper]::RegisterCommandNotFoundAction(`$ExecutionContext.InvokeCommand)
"@
        }
        else
        {
            $template = $template -replace "%COMMAND-NOT-FOUND%"
        }

        # Handle
        $contructedCommands = Find-DefaultResourceGroupCmdlet -IsRMModule:$IsRMModule -ModuleMetadata $ModuleMetadata -ModulePath $ModulePath
        $template = $template -replace "%DEFAULTRGCOMMANDS%", $contructedCommands

        Write-Information -MessageData "Writing psm1 manifest to $templateOutputPath" -InformationAction Continue

        if ($PSCmdlet.ShouldProcess($templateOutputPath, $CmdletName)) {
            $template | Out-File -FilePath $templateOutputPath -Force
        }

        $manifestPath = Get-Item -LiteralPath $templateOutputPath
    }

    <#
        .SYNOPSIS
        Creates a new psm1 root module if one does not exist.

        .PARAMETER ModulePath
        Path to the module.

        .PARAMETER TemplatePath
        Path to the template

        .PARAMETER IsRMModule
        Specifies if resource management module.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Get-Cmdlet
#>
function Get-Cmdlet {
    [CmdletBinding()]
    param(
        [Hashtable]$ModuleMetadata,
        [string]$ModulePath
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $nestedModules = $ModuleMetadata.NestedModules
    $cmdlets = @()

    foreach ($module in $nestedModules) {
        if('.dll' -ne [System.IO.Path]::GetExtension($module))
        {
            continue;
        }

        $dllPath = Join-Path -Path $ModulePath -ChildPath $module

        if ($dllPath.EndsWith("dll")) {
            $Assembly = [Reflection.Assembly]::LoadFrom($dllPath)
            $dllCmdlets = $Assembly.GetTypes() | Where-Object {$_.CustomAttributes.AttributeType.Name -contains "CmdletAttribute"}
            $cmdlets += $dllCmdlets
        }
    }
    return $cmdlets

    <#
        .SYNOPSIS
        Gets a list of nested module cmdlets

        .PARAMETER ModuleMetadata
        Module metadata for the current module.

        .PARAMETER ModulePath
        Path to the current module.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Find-DefaultResourceGroupCmdlet
#>
function Find-DefaultResourceGroupCmdlet {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [Hashtable]$ModuleMetadata,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $ModulePath,

        [switch]
        $IsRMModule
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $contructedCommands = "@("

        if ($IsRMModule) {
            $AllCmdlets = Get-Cmdlet -ModuleMetadata $ModuleMetadata -ModulePath $ModulePath
            $FilteredCommands = $AllCmdlets | Where-Object {Test-CmdletRequiredParameter -Cmdlet $_ -Parameter "ResourceGroupName"}

            foreach ($command in $FilteredCommands) {
                $contructedCommands += "'" + $command.GetCustomAttributes("System.Management.Automation.CmdletAttribute").VerbName + "-" + $command.GetCustomAttributes("System.Management.Automation.CmdletAttribute").NounName + ":ResourceGroupName" + "',"
            }

            $contructedCommands = $contructedCommands -replace ",$", ""
        }

        $contructedCommands += ")"
        return $contructedCommands
    }

    <#
        .SYNOPSIS
        Handle nested modules for resource management modules which required ResourceGroupName

        .PARAMETER ModuleMetadata
        Module metadata.

        .PARAMETER ModulePath
        Path to the module.

        .PARAMETER IsRMModule
        Specifies if resource management module.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Test-CmdletRequiredParameter
#>
function Test-CmdletRequiredParameter {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [Object]
        $Cmdlet,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Parameter
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $rgParameter = $Cmdlet.GetProperties() | Where-Object -Property Name -EQ $Parameter

        if ($null -ne $rgParameter) {
            $parameterAttributes = $rgParameter.CustomAttributes | Where-Object -Property AttributeType.Name -EQ "ParameterAttribute"

            foreach ($attr in $parameterAttributes) {
                $hasParameterSet = $attr.NamedArguments | Where-Object -Property MemberName -EQ "ParameterSetName"
                $MandatoryParam = $attr.NamedArguments | Where-Object -Property MemberName -EQ "Mandatory"

                if (($null -ne $hasParameterSet) -or (!$MandatoryParam.TypedValue.Value)) {
                    return $false
                }
            }

            return $true
        }

        return $false
    }

    <#
        .SYNOPSIS
        Test to see if parameter is required.

        .PARAMETER Cmdlet
        Cmdlet object.

        .PARAMETER Parameter
        Name of the parameter

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    New-MinimumVersionEntry
#>
function New-MinimumVersionEntry {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $MinimumVersion
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess('Write Import-Module Block', $CmdletName)) {
            return "`$module = Get-Module -Name $ModuleName `
        if (`$module -ne `$null -and `$module.Version -lt [System.Version]`"$MinimumVersion`") `
{ `
    Write-Error `"This module requires $ModuleName version $MinimumVersion. An earlier version of $ModuleName is imported in the current PowerShell session. Please open a new session before importing this module. This error could indicate that multiple incompatible versions of the Azure PowerShell cmdlets are installed on your system. Please see https://aka.ms/azps-version-error for troubleshooting information.`" -ErrorAction Stop `
} `
elseif (`$module -eq `$null) `
{ `
    Import-Module $ModuleName -MinimumVersion $MinimumVersion -Scope Global `
}`r`n"
        }
    }

    <#
        .SYNOPSIS
        Create the code entry to test for the required minimum version to be loaded for the specified module.

        .PARAMETER ModuleName
        Name of the module.

        .PARAMETER MinimumVersion
        The minimum version required for the module.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Update-RMModule
#>
function Update-RMModule {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $Modules
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $Ignore = @('AzureRM.Profile', 'Azure.Storage')

    foreach ($module in $Modules) {
        # filter out AzureRM.Profile which always gets published first
        # And "Azure.Storage" which is built out as test dependencies
        if ( -not ($module.Name -in $Ignore)) {
            $modulePath = $module.FullName
            Write-Information -MessageData "Updating $module module from $modulePath" -InformationAction Continue
            New-ModulePsm1 -ModulePath $modulePath -TemplatePath $script:TemplateLocation -IsRMModule
            Write-Information -MessageData "Updated $module module`n" -InformationAction Continue
        }
    }

    <#
        .SYNOPSIS
        Update the list of given modules' psm1/psd1 files.

        .PARAMETER Modules
        The list of modules.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Update-Azure
#>
function Update-Azure {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Scope,

        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Release')]
        [String]
        $BuildConfig
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($Scope -in $script:AzureRMScopes) {
        Write-Information -MessageData "Updating profile module" -InformationAction Continue
        New-ModulePsm1 -ModulePath (Join-Path -Path $AzureRMRoot -ChildPath 'AzureRM.Profile') -TemplatePath $TemplateLocation -IsRMModule
        Write-Information -MessageData "Updated profile module" -InformationAction Continue
        Write-Information -MessageData " " -InformationAction Continue
    }

    if ($scope -in $StorageScopes) {
        $modulePath = (Join-Path -Path $AzurePackages -ChildPath "$buildConfig\Storage\Azure.Storage")
        Write-Information -MessageData "Updating AzureStorage module from $modulePath" -InformationAction Continue
        New-ModulePsm1 -ModulePath $modulePath -TemplatePath $script:TemplateLocation -IsRMModule:$false
        Write-Information -MessageData " " -InformationAction Continue
    }

    if ($scope -in $script:ServiceScopes) {
        $modulePath = (Join-Path -Path $AzurePackages -ChildPath "$buildConfig\ServiceManagement\Azure")
        Write-Information -MessageData "Updating ServiceManagement(aka Azure) module from $modulePath" -InformationAction Continue
        New-ModulePsm1 -ModulePath $modulePath -TemplatePath $TemplateLocation
        Write-Information -MessageData " " -InformationAction Continue
    }

    # Update all of the modules, if specified.
    if ($Scope -in $AzureRMScopes) {
        $resourceManagerModules = Get-ChildItem -Path $AzureRMRoot -Directory
        Write-Information -MessageData "Updating Azure modules" -InformationAction Continue
        Update-RMModule -Modules $resourceManagerModules
        Write-Information -MessageData " " -InformationAction Continue
    }

    # Update AzureRM
    if ($Scope -in $AzureRMScopes) {
        $modulePath = (Join-Path -Path $PSScriptRoot -ChildPath "AzureRM")
        Write-Information -MessageData "Updating AzureRM module from $modulePath" -InformationAction Continue
        New-ModulePsm1 -ModulePath $modulePath -TemplatePath $TemplateLocation
        Write-Information -MessageData " " -InformationAction Continue
    }

    <#
        .SYNOPSIS
        Update the Azure modules.

        .PARAMETER Scope
        The class of modules or a specific module.

        .PARAMETER BuildConfig
        Debug or Release

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Update-Stack
#>
function Update-Stack {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Release')]
        [String]$BuildConfig
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Write-Information -MessageData "Updating profile module for stack" -InformationAction Continue
    New-ModulePsm1 -ModulePath (Join-Path -Path $StackRMRoot -ChildPath "AzureRM.Profile") -TemplatePath $TemplateLocation -IsRMModule
    Write-Information -MessageData "Updated profile module" -InformationAction Continue
    Write-Information -MessageData " " -InformationAction Continue

    $modulePath = (Join-Path -Path $StackPackages -ChildPath "$buildConfig\Storage\Azure.Storage")
    Write-Information -MessageData "Updating AzureStorage module from $modulePath" -InformationAction Continue
    New-ModulePsm1 -ModulePath $modulePath -TemplatePath $TemplateLocation -IsRMModule:$false
    Write-Information -MessageData " " -InformationAction Continue

    $StackRMModules = Get-ChildItem -Path $StackRMRoot -Directory
    Write-Information -MessageData "Updating stack modules" -InformationAction Continue
    Update-RMModule -Modules $StackRMModules
    Write-Information -MessageData " " -InformationAction Continue

    $modulePath = "$script:StackProjects\AzureRM"
    Write-Information -MessageData "Updating AzureRM module from $modulePath" -InformationAction Continue
    New-ModulePsm1 -ModulePath $modulePath -TemplatePath $TemplateLocation
    Write-Information -MessageData " " -InformationAction Continue

    $modulePath = (Join-Path -Path $StackProjects -ChildPath "AzureStack")
    Write-Information -MessageData "Updating AzureStack module from $modulePath" -InformationAction Continue
    New-ModulePsm1 -ModulePath $modulePath -TemplatePath $TemplateLocation
    Write-Information -MessageData " " -InformationAction Continue

    <#
        .SYNOPSIS
        Update stack modules

        .PARAMETER BuildConfig
        Either Debug or Release

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}

<#
    Update-Netcore
#>
function Update-Netcore {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $AzureRMModules = Get-ChildItem -Path $script:AzureRMRoot -Directory

    # Publish the Netcore modules and rollup module, if specified.
    Write-Information -MessageData "Updating Accounts module" -InformationAction Continue
    New-ModulePsm1 -ModulePath (Join-Path -Path $AzureRMRoot -ChildPath "Az.Accounts") -TemplatePath $TemplateLocation -IsRMModule -IsNetcore
    Write-Information -MessageData "Updated Accounts module" -InformationAction Continue

    Join-EnvironmentVariable -Name 'PSModulePath' -Value (Join-Path -Path $AzureRMRoot -ChildPath "Az.Accounts")

    foreach ($module in $AzureRMModules) {
        if (($module.Name -ne "Az.Accounts")) {
            $modulePath = $module.FullName
            Write-Information -MessageData "Updating $module module from $modulePath" -InformationAction Continue
            New-ModulePsm1 -ModulePath $modulePath -TemplatePath $script:TemplateLocation -IsRMModule -IsNetcore
            Write-Information -MessageData "Updated $module module" -InformationAction Continue
        }
    }

    $modulePath = "$PSScriptRoot\Az"
    Write-Information -MessageData "Updating Netcore module from $modulePath" -InformationAction Continue
    New-ModulePsm1 -ModulePath $modulePath -TemplatePath $script:TemplateLocation -IsNetcore
    Write-Information -MessageData "Updated Netcore module" -InformationAction Continue

    $modulePath = "$PSScriptRoot\AzPreview"
    Write-Information -MessageData "Updating Netcore module from $modulePath" -InformationAction Continue
    New-ModulePsm1 -ModulePath $modulePath -TemplatePath $script:TemplateLocation -IsNetcore
    Write-Information -MessageData "Updated Netcore module" -InformationAction Continue

    <#
        .SYNOPSIS
        Update .NET core modules.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
}
