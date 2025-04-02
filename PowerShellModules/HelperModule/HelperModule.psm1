<#
 =============================================================================
<copyright file="HelperModule.psm1" company="John Merryweather Cooper
">
    Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.
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
This file "HelperModule.psm1" is part of "HelperModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<##########################################
    Get-AlertSet
##########################################>
function Get-AlertSet {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property alertSet | Write-Output
    }
}

<##########################################
    Get-ErrorCategory
##########################################>
function Get-ErrorCategory {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property ErrorCategory | Write-Output
    }
}

<##########################################
    Get-Component
##########################################>
function Get-Component {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property Component | Write-Output
    }
}

<##########################################
    Get-Copyright
##########################################>
function Get-Copyright {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-Notes | ForEach-Object -Process {
            if (($_ -match '(?<copyright>Copyright.*)') -xor ($_ -match '(?<copyright>\(c\).*)')) {
                return $Matches['copyright']
            }
        }

        return [string]::Empty
    }
}

<##########################################
    Get-Description
##########################################>
function Get-Description {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property description | Write-Output
    }
}

<##########################################
    Get-Details
##########################################>
function Get-Details {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property details | Write-Output
    }
}

<##########################################
    Get-Examples
##########################################>
function Get-Examples {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property examples | Write-Output
    }
}

<##########################################
    Get-Functionality
##########################################>
function Get-Examples {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property Functionality | Write-Output
    }
}

<##########################################
    Get-HelpProperty
##########################################>
function Get-HelpProperty {
    [CmdletBinding([string], [string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelingByPropertyName)]
        [ValidateSet('alertSet', 'ErrorCategory', 'Component', 'description', 'details', 'examples', 'Functionality', 'inputTypes',
            'ModuleName', 'Name', 'parameters', 'PSSnapIn', 'relatedLinks', 'returnValues', 'Role', 'Synopsis', 'syntax')]
        [string[]]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $buffer = [System.Collections.ArrayList]::new()
    }

    PROCESS {
        $Property | Where-Object -FilterScript { Test-HelpProperty -Name $Name -Property $_ } | ForEach-Object -Process {
            $propertyPresent = $_
            $buffer.Clear()

            switch ($propertyPresent) {
                'alertSet' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty alertSet | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'description' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty description | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'details' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty details | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'examples' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty examples | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'inputTypes' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty inputTypes | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'parameters' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty parameters | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'relatedLinks' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty relatedLinks | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'returnValues' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty returnValues | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                'syntax' {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty syntax | ForEach-Object -Process {
                        if (-not [string]::IsNullOrWhiteSpace(([string]$_))) {
                            $buffer.Add(([string]$_)) | Out-Null
                        }
                        else {
                            $buffer.Add([Environment]::NewLine) | Out-Null
                        }
                    }

                    $buffer.ToArray() | Write-Output

                    break
                }

                default {
                    Get-Help -Name $Name -Full | Select-Object -ExpandProperty $propertyPresent | Out-String | Write-Output
                    break
                }
            }
        }
    }

    END {
        $buffer.Clear()
    }

    <#
        .SYNOPSIS
        Tests an object fo the presence of a property.

        .DESCRIPTION
        The `Test-HasProperty` function tests an object for the presence of a property.

        .PARAMETER Object
        Specifies the PowerShell object under test.

        .PARAMETER Name
        Specifies the name of the property to test for.

        .PARAMETER Strict
        Indicates that the function should throw an exception if the Object parameter is null.

        .INPUTS
        [string]  `Test-HasProperty` accepts a string value for the Name parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Test-HasProperty` returns a boolean value indicating the presence or absence of the property.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Name'
        True

        Tested the object for the presence of the Name property.  Returned True.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Type'
        False

        Tested the object for the presence of the Name property.  Returned False.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        You may use this script only in accordance with the terms of the License Agreement that should have been included with this script.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Advanced_Function_Parameters

        .LINK
        about_throw

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<##########################################
    Get-InputTypes
##########################################>
function Get-InputTypes {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property inputTypes | Write-Output
    }
}

<##########################################
    Get-ModuleManifestProperty
##########################################>
function Get-ModuleManifestProperty {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ModuleAccessMode],
        [string],
        [version],
        [System.Collections.Generic.IEnumerable[string]],
        [System.Collections.Generic.IEnumerable[ExperimentalFeature]],
        [System.Collections.Generic.Dictionary[string, System.Management.Automation.AliasInfo]],
        [System.Collections.Generic.Dictionary[string, System.Management.Automation.CmdletInfo]],
        [System.Collections.Generic.Dictionary[string, System.Management.Automation.CommandInfo]],
        [System.Collections.ObjectModel.ReadOnlyCollection[string]],
        [System.Collections.ObjectModel.ReadOnlyCollection[psmoduleinfo]],
        [System.Collections.Generic.Dictionary[string, System.Management.Automation.FunctionInfo]],
        [System.Collections.Generic.Dictionary[string, psvariable]],
        [guid],
        [uri],
        [System.Reflection.Assembly],
        [bool],
        [System.Collections.Generic.IEnumerable[System.Object]],
        [System.Management.Automation.ModuleType],
        [System.Collections.ObjectModel.ReadOnlyCollection[psmoduleinfo]],
        [scriptblock],
        [System.Object],
        [System.Reflection.ProcessorArchitecture],
        [System.Management.Automation.SessionState])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf representing the module manifest")]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet('Author', 'CompanyName', 'Copyright', 'Definition', 'Description', 'HelpInfoUri', 'ModuleBase',
            'Name', 'Path', 'PowerShellHostName', 'Prefix', 'ReleaseNotes', 'RootModule',
            'CompatiblePSEditions', 'FileList', 'RequiredAssemblies', 'Scripts', 'Tags',
            'ClrVersion', 'DotNetFrameworkVersion', 'PowerShellHostVersion', 'PowerShellVersion', 'Version',
            'ExportedDscResources', 'ExportedFormatFiles', 'ExportedTypeFiles',
            'NestedModules', 'RequiredModules',
            'IconUri', 'LicenseUri', 'RepositorySourceLocation', 'ProjectUri',
            'AccessMode',
            'ExperimentalFeatures',
            'ExportedAliases',
            'ExportedCmdlets',
            'ExportedCommands',
            'ExportedVariables',
            'Guid',
            'ImplementingAssembly',
            'LogPipelineExecutionDetails',
            'ModuleList',
            'ModuleType',
            'PrivateData',
            'ProcessorArchitecture',
            'SessionState')]
        [string[]]
        $Property
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        $stringProperties = @('Author', 'CompanyName', 'Copyright', 'Definition', 'Description', 'HelpInfoUri', 'ModuleBase',
            'Name', 'Path', 'PowerShellHostName', 'Prefix', 'ReleaseNotes', 'RootModule')
        $listProperties = @('CompatiblePSEditions', 'FileList', 'RequiredAssemblies', 'Scripts', 'Tags')
        $versionProperties = @('ClrVersion', 'DotNetFrameworkVersion', 'PowerShellHostVersion', 'PowerShellVersion', 'Version')
        $readOnlyCollectionProperties = @('ExportedDscResources', 'ExportedFormatFiles', 'ExportedTypeFiles')
        $psModuleInfoProperties = @('NestedModules', 'RequiredModules')
        $uriProperties = @('IconUri', 'LicenseUri', 'RepositorySourceLocation', 'ProjectUri')
    }

    PROCESS {
        $Property | ForEach-Object -Process {
            $prop = $_

            switch ($prop) {
                { $_ -in $stringProperties } {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                { $_ -in $listProperties } {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                { $_ -in $versionProperties } {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                { $_ -in $readOnlyCollectionProperties } {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                { $_ -in $psModuleInfoProperties } {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                { $_ -in $uriProperties } {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'AccessMode' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ExperimentalFeatures' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ExportedAliases' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ExportedCmdlets' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ExportedCommands' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ExportedVariables' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'Guid' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ImplementingAssembly' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'LogPipelineExecutionDetails' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ModuleList' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ModuleType' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'OnRemove' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'PrivateData' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'ProcessArchitecture' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }

                'SessionState' {
                    $Path | Resolve-Path | Test-ModuleManifest | Select-Object -ExpandProperty $prop | Write-Output
                    break
                }
            }
        }
        $Path | Resolve-Path | Test-ModuleManifest | Select-Object -Property $Property | Write-Output
    }

    <#
        .SYNOPSIS
        Selects a module property(s) or property expression(s).

        .DESCRIPTION
        The `Select-ModuleProperty` function selects a module property(s) or property expression(s)..

        .PARAMETER Path
        Specifies the path to the module manifest file.

        .PARAMETER Property
        Specifies the name of the property to select.

        .INPUTS
        [string]  `Select-ModuleProperty` accepts a string value for the Path parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Select-ModuleProperty` returns a boolean value indicating the presence or absence of the property.

        .EXAMPLE
        PS> $Path = 'C:\Program Files\WindowsPowerShell\Modules\MyModule\MyModule.psd1'
        PS> Select-ModuleProperty -Path $Path -Property 'PowerShellVersion'
        5.1

        Selected the module property.  Returned the property value.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<##########################################
    Get-ModuleName
##########################################>
function Get-ModuleName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property ModuleName | Write-Output
    }
}

<##########################################
    Get-Name
##########################################>
function Get-Name {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property Name | Write-Output
    }
}

<##########################################
    Get-Notes
##########################################>
function Get-Notes {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | ForEach-Object -Process {
            (Get-Help -Name $_ -Full | Out-String) -match '(?ms)NOTES(?<notes>.*?)RELATED'
            (($Matches['notes'] -replace 'NOTES').Trim() -split [Environment]::NewLine) | Write-Output
        }
    }
}

<##########################################
    Get-Parameters
##########################################>
function Get-Parameters {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | Get-HelpProperty -Property parameters | Write-Output
    }
}

<##########################################
    Get-RelatedLinks
##########################################>
function Get-RelatedLinks {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property relatedLinks | Write-Output
    }
}

<##########################################
    Get-ReturnValues
##########################################>
function Get-ReturnValues {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property returnValues | Write-Output
    }
}

<##########################################
    Get-Role
##########################################>
function Get-Role {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property Role | Write-Output
    }
}

<##########################################
    Get-Synopsis
##########################################>
function Get-Synopsis {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property Synopsis | Write-Output
    }
}

<##########################################
    Get-Syntax
##########################################>
function Get-Syntax {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-HelpProperty -Property syntax | Write-Output
    }
}

<##########################################
    Initialize-ModuleManifest
##########################################>
function Initialize-ModuleManifest {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "Path '{0}' is not a valid path leaf representing a module manifest")]
        [string]
        $Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [guid]
        $Guid,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Author,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CompanyName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Copyright,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DefaultCommandPrefix,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PowerShellHostName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Prerelease,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath -Include '*.ps1', '*.psm1', '*.psd1', '*.dll', '*.cdxml', '*.xaml' $_ -PathType Leaf },
            ErrorMessage = "RootModule '{0}' is not a valid path leaf")]
        [Alias('ModuleToProcess')]
        [string]
        $RootModule,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -Include '*.dll', '*.psm1' -PathType Leaf },
            ErrorMessage = "NestedModules '{0}' are not valid path leaves")]
        [object[]]
        $NestedModules = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]
        $ModuleList = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]
        $RequiredModules = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [scriptblock]
        $OnRemove,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'MSIL', 'X86', 'IA64', 'Amd64', 'Arm')]
        [ProcessorArchitecture]
        $ProcessorArchitecture = 'None',

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]
        $PrivateData = @{},

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SessionState]
        $SessionState,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $AliasesToExport = '*',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $CmdletsToExport = '*',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Core', 'Desktop')]
        [string[]]
        $CompatiblePSEditions,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $DscResourcesToExport = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ExternalModuleDependencies = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FileList = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FormatsToProcess = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $FunctionsToExport = '*',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $PackageManagementProviders = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ReleaseNotes = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -Include '*.dll' -PathType Leaf },
            ErrorMessage = "RequiredAssemblies '{0}' are not valid path leaves")]
        [string[]]
        $RequireAssemblies = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $ScriptsToProcess = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $Tags = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -Include '*.ps1xml' -PathType Leaf },
            ErrorMessage = "TypesToProcess '{0}' are not valid path leaves")]
        [string[]]
        $TypesToProcess = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [string[]]
        $VariablesToExport = '*',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ (4.5 -gt $_) -and ($PSVersionTable.PSVersion.Major -le 5) },
            ErrorMessage = "ClrVersion '{0}' is either less than or equal to 4.5 or PowerShell Major version is greater than 5")]
        [version]
        $ClrVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ (4.5 -gt $_) -and ($PSVersionTable.PSVersion.Major -le 5) },
            ErrorMessage = "DotNetFrameworkVersion '{0}' is either less than or equal to 4.5 or PowerShell Major version is greater than 5")]
        [version]
        $DotNetFrameworkVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Version')]
        [version]
        $ModuleVersion = 1.0.0,

        [Parameter(ValueFromPipelineByPropertyName)]
        [version]
        $PowerShellHostVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Version')]
        [version]
        $PowerShellVersion = 5.1,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "HelpInfoUri '{0}' is not a valid, absolute URI")]
        [uri]
        $HelpInfoUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "IconUri '{0}' is not a valid, absolute URI")]
        [uri]
        $IconUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "LicenseUri '{0}' is not a valid, absolute URI")]
        [uri]
        $LicenseUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "ProjectUri '{0}' is not a valid, absolute URI")]
        [uri]
        $ProjectUri,

        [Alias('Force')]
        [switch]
        $AllowClobber,

        [switch]
        $PassThru,

        [switch]
        $RequireLicenseAcceptance
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $newModuleManifestSplat = @{
            Path                       = $Path
            ModuleVersion              = $ModuleVersion
            ModuleList                 = $ModuleList
            NestedModules              = $NestedModules
            RequiredModules            = $RequiredModules
            ProcessorArchitecture      = $ProcessorArchitecture
            PrivateData                = $PrivateData
            AliasesToExport            = $AliasesToExport
            CmdletsToExport            = $CmdletsToExport
            DSCResourcesToExport       = $DscResourcesToExport
            ExternalModuleDependencies = $ExternalModuleDependencies
            FileList                   = $FileList
            FormatsToProcess           = $FormatsToProcess
            FunctionsToExport          = $FunctionsToExport
            PackageManagementProviders = $PackageManagementProviders
            ReleaseNotes               = $ReleaseNotes
            RequiredAssemblies         = $RequireAssemblies
            ScriptsToProcess           = $ScriptsToProcess
            Tags                       = $Tags
            TypesToProcess             = $TypesToProcess
            VariablesToExport          = $VariablesToExport
            PowerShellVersion          = $PowerShellVersion
            PassThru                   = $PassThru.IsPresent
            RequireLicenseAcceptance   = $RequireLicenseAcceptance.IsPresent
            WhatIf                     = $false
        }

        if ($PSBoundParameters.ContainsKey('Author')) {
            $newModuleManifestSplat.Add('Author', $Author)
        }
        else {
            $userName = $env:USERNAME
            $givenName = Get-ADUser -Identity | Select-Object -ExpandProperty GivenName
            $surname = Get-ADUser -Identity | Select-Object -ExpandProperty GivenName
            $Author = ('{0} {1}' -f $givenName, $surname)
            $newModuleManifestSplat.Add('Author', $Author)
        }

        if ($PSBoundParameters.ContainsKey('ClrVersion')) {
            $newModuleManifestSplat.Add('ClrVersion', $ClrVersion)
        }

        if ($PSBoundParameters.ContainsKey('CompanyName')) {
            $newModuleManifestSplat.Add('CompanyName', $CompanyName)
        }
        else {
            $newModuleManifestSplat.Add('CompanyName', $Author)
        }

        if ($PSBoundParameters.ContainsKey('CompatiblePSEditions')) {
            $newModuleManifestSplat.Add('CompatiblePSEditions', $CompatiblePSEditions)
        }

        if ($PSBoundParameters.ContainsKey('Copyright')) {
            $newModuleManifestSplat.Add('Copyright', $Copyright)
        }
        else {
            $Copyright = ('Copyright © {0}, {1}.  All Rights Reserved.' -f $CompanyName, ((Microsoft.PowerShell.Utility\Get-Date).ToUniversalTime().Year))
            $newModuleManifestSplat.Add('Copyright', $Copyright)
        }

        if ($PSBoundParameters.ContainsKey('DefaultCommandPrefix')) {
            $newModuleManifestSplat.Add('DefaultCommandPrefix', $DefaultCommandPrefix)
        }

        if ($PSBoundParameters.ContainsKey('Guid')) {
            $newModuleManifestSplat.Add('Guid', $Guid)
        }
        else {
            $Guid = [guid]::NewGuid()
            $newModuleManifestSplat.Add('Guid', $Guid)
        }

        if ($PSBoundParameters.ContainsKey('PowerShellHostName')) {
            $newModuleManifestSplat.Add('PowerShellHostName', $PowerShellHostName)
        }

        if ($PSBoundParameters.ContainsKey('Prerelease')) {
            $newModuleManifestSplat.Add('Prerelease', $Prerelease)
        }

        if ($PSBoundParameters.ContainsKey('OnRemove')) {
            $newModuleManifestSplat.Add('OnRemove', $OnRemove)
        }

        if ($PSBoundParameters.ContainsKey('RootModule')) {
            $newModuleManifestSplat.Add('RootModule', $RootModule)
        }
        else {
            $fileName = Get-ItemProperty -LiteralPath $Path -Name Name
            $RootModule = $fileName -replace '.psd1', '.psm1'
            $newModuleManifestSplat.Add('RootModule', $RootModule)
        }

        if ($PSBoundParameters.ContainsKey('SessionState')) {
            $newModuleManifestSplat.Add('SessionState', $SessionState)
        }

        if ($PSBoundParameters.ContainsKey('DotNetFrameworkVersion')) {
            $newModuleManifestSplat.Add('DotNetFrameworkVersion', $DotNetFrameworkVersion)
        }

        if ($PSBoundParameters.ContainsKey('PowerShellHostVersion')) {
            $newModuleManifestSplat.Add('PowerShellHostVersion', $PowerShellHostVersion)
        }

        if ($PSBoundParameters.ContainsKey('HelpInfoUri')) {
            $newModuleManifestSplat.Add('HelpInfoUri', $HelpInfoUri)
        }

        if ($PSBoundParameters.ContainsKey('IconUri')) {
            $newModuleManifestSplat.Add('IconUri', $IconUri)
        }

        if ($PSBoundParameters.ContainsKey('LicenseUri')) {
            $newModuleManifestSplat.Add('LicenseUri', $IconUri)
        }

        if ($PSBoundParameters.ContainsKey('ProjectUri')) {
            $newModuleManifestSplat.Add('ProjectUri', $ProjectUri)
        }
        else {
            $ProjectUri = Get-GitRepositoryUrl
            $newModuleManifestSplat.Add('ProjectUri', $ProjectUri)
        }

        if ($PSCmdlet.ShouldProcess($newModuleManifestSplat, $CmdletName)) {
            if ($AllowClobber.IsPresent -and (Test-Path -LiteralPath $Path -PathType Leaf)) {
                Remove-Item -LiteralPath $Path -Force -WhatIf:$false
            }

            if ($PassThru.IsPresent) {
                New-ModuleManifest @newModuleManifestSplat | Write-Output
            }
            else {
                New-ModuleManifest @newModuleManifestSplat
            }
        }
    }

    <#
        .SYNOPSIS
        Selects a module property(s) or property expression(s).

        .DESCRIPTION
        The `Select-ModuleProperty` function selects a module property(s) or property expression(s)..

        .PARAMETER Path
        Specifies the path to the module manifest file.

        .PARAMETER Property
        Specifies the name of the property to select.

        .INPUTS
        [string]  `Select-ModuleProperty` accepts a string value for the Path parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Select-ModuleProperty` returns a boolean value indicating the presence or absence of the property.

        .EXAMPLE
        PS> $Path = 'C:\Program Files\WindowsPowerShell\Modules\MyModule\MyModule.psd1'
        PS> Select-ModuleProperty -Path $Path -Property 'PowerShellVersion'
        5.1

        Selected the module property.  Returned the property value.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<##########################################
    Measure-Description
##########################################>
function Measure-Description {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Measure-HelpProperty -Property description | Write-Output
    }
}

<##########################################
    Measure-HelpProperty
##########################################>
function Measure-HelpProperty {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelingByPropertyName)]
        [ValidateSet('alertSet', 'ErrorCategory', 'Component', 'description', 'details', 'examples', 'Functionality', 'inputTypes',
            'ModuleName', 'Name', 'parameters', 'PSSnapIn', 'relatedLinks', 'returnValues', 'Role', 'Synopsis', 'syntax')]
        [string[]]
        $Property
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Property | Get-HelpProperty -Name $Name | Measure-Object -Character | Select-Object -ExpandProperty Characters | Write-Output
    }

    <#
        .SYNOPSIS
        Tests an object fo the presence of a property.

        .DESCRIPTION
        The `Test-HasProperty` function tests an object for the presence of a property.

        .PARAMETER Object
        Specifies the PowerShell object under test.

        .PARAMETER Name
        Specifies the name of the property to test for.

        .PARAMETER Strict
        Indicates that the function should throw an exception if the Object parameter is null.

        .INPUTS
        [string]  `Test-HasProperty` accepts a string value for the Name parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Test-HasProperty` returns a boolean value indicating the presence or absence of the property.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Name'
        True

        Tested the object for the presence of the Name property.  Returned True.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Type'
        False

        Tested the object for the presence of the Name property.  Returned False.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        You may use this script only in accordance with the terms of the License Agreement that should have been included with this script.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Advanced_Function_Parameters

        .LINK
        about_throw

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<##########################################
    Measure-Notes
##########################################>
function Measure-Notes {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Get-Notes | Measure-Object -Character | Select-Object -ExpandProperty Characters | Write-Output
    }
}

<##########################################
    Measure-Synopsis
##########################################>
function Measure-Synopsis {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Name | Measure-HelpProperty -Property Synopsis | Write-Output
    }
}

<##########################################
    Select-ModuleByFilter
##########################################>
function Select-ModuleByFilter {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path")]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $FilterScript
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Path | Resolve-Path | Test-ModuleManifest | Where-Object -FilterScript $FilterScript | Write-Output
    }

    <#
        .SYNOPSIS
        Selects a module by a filter script.

        .DESCRIPTION
        The `Select-ModuleByFilter` function selects a module by a filter script.

        .PARAMETER Path
        Specifies the path to the module manifest file.

        .PARAMETER FilterScript
        Specifies the script block to use as the filter.

        .INPUTS
        [string]  `Select-ModuleByFilter` accepts a string value for the Path parameter from the PowerShell pipeline.

        .OUTPUTS
        [System.Management.Automation.PSModuleInfo]  `Select-ModuleByFilter` returns a module object to the PowerShell pipeline.

        .EXAMPLE
        PS> $Path = 'C:\Program Files\WindowsPowerShell\Modules\MyModule\MyModule.psd1'
        PS> $FilterScript = { $_.PowerShellVersion -eq '5.1' }
        PS> Select-ModuleByFilter -Path $Path -FilterScript $FilterScript
        ModuleType Version    Name ExportedCommands
        ---------- -------    ---- ----------------
        Script    1.0.0      MyModule {}

        Selected the module by the filter script.  Returned the module object.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<##########################################
    Select-ModuleByProperty
##########################################>
function Select-ModuleByProperty {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [ValidateSet('Path', 'Description', 'PowerShellVersion', 'PowerShellHostName', 'PowerShellHostVersion', 'DotNetFrameworkVersion', 'ClrVersion', 'ProcessorArchitecture', 'RequiredModules', 'RequiredAssemblies', 'ScriptsToProcess', 'TypesToProcess', 'FormatsToProcess', 'NestedModules', 'FunctionsToExport', 'CmdletsToExport', 'VariablesToExport', 'AliasesToExport', 'DscResourcesToExport', 'ModuleList')]
        [string]
        $Property,

        [Parameter(Mandatory)]
        [AllowNull()]
        [object]
        $Value
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Path | Resolve-Path | Test-ModuleManifest | Where-Object -Property $Property -EQ -Value $Value | Write-Output
    }

    <#
        .SYNOPSIS
        Selects a module by a property name and value.

        .DESCRIPTION
        The `Select-ModuleByProperty` function selects a module by a property name and value.

        .PARAMETER Path
        Specifies the path to the module manifest file.

        .PARAMETER Property
        Specifies the name of the property to test for equality.

        .PARAMETER Value
        Specifies the value of the property to test for equality.

        .INPUTS
        [string]  `Select-ModuleByProperty` accepts a string value for the Path parameter from the PowerShell pipeline.

        .OUTPUTS
        [System.Management.Automation.PSModuleInfo]  `Select-ModuleByProperty` returns a module object to the PowerShell pipeline.

        .EXAMPLE
        PS> $Path = 'C:\Program Files\WindowsPowerShell\Modules\MyModule\MyModule.psd1'
        PS> Select-ModuleByProperty -Path $Path -Property 'PowerShellVersion' -Value '5.1'
        ModuleType Version    Name ExportedCommands
        ---------- -------    ---- ----------------
        Script    1.0.0      MyModule {}

        Selected the module by the property value.  Returned the module object.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<##########################################
    Set-ModuleManifestProperty
##########################################>
function Set-ModuleManifestProperty {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [string]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Author,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $CompanyName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Copyright,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [guid]
        $Guid,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "RootModule '{0}' is not a valid path leaf")]
        [string]
        $RootModule,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Version')]
        [version]
        $ModuleVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DefaultCommandPrefix,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $PowerShellHostName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Prerelease,

        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]
        $NestedModules = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]
        $ModuleList = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [object[]]
        $RequiredModules = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [scriptblock]
        $OnRemove,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'MSIL', 'X86', 'IA64', 'Amd64', 'Arm')]
        [ProcessorArchitecture]
        $ProcessorArchitecture = 'None',

        [Parameter(ValueFromPipelineByPropertyName)]
        [hashtable]
        $PrivateData = @{},

        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SessionState]
        $SessionState,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $AliasesToExport = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $CmdletsToExport = '*',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Core', 'Desktop')]
        [string[]]
        $CompatiblePSEditions = @('Core', 'Desktop'),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $DscResourcesToExport = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ExternalModuleDependencies = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FileList = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FormatsToProcess = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $FunctionsToExport = '*',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $PackageManagementProviders = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ReleaseNotes = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $RequireAssemblies = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $ScriptsToProcess = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $Tags = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $TypesToProcess = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $VariablesToExport = @(),

        [Parameter(ValueFromPipelineByPropertyName)]
        [version]
        $ClrVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [version]
        $DotNetFrameworkVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Version')]
        [version]
        $PowerShellHostVersion,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Version')]
        [version]
        $PowerShellVersion = 5.1,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "HelpInfoUri '{0}' is not a valid, absolute URI")]
        [uri]
        $HelpInfoUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "IconUri '{0}' is not a valid, absolute URI")]
        [uri]
        $IconUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "LicenseUri '{0}' is not a valid, absolute URI")]
        [uri]
        $LicenseUri,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateScript({ [uri]::IsWellFormedUriString($_, 'Absolute') },
            ErrorMessage = "ProjectUri '{0}' is not a valid, absolute URI")]
        [uri]
        $ProjectUri,

        [switch]
        $PassThru,

        [switch]
        $RequireLicenseAcceptance
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $updateModuleManifestSplat = @{
            Path                       = $Path
            Author                     = $Author
            CompanyName                = $CompanyName
            Copyright                  = $Copyright
            Description                = $Description
            Guid                       = $Guid
            RootModule                 = $RootModule
            ModuleVersion              = $ModuleVersion
            ModuleList                 = $ModuleList
            NestedModules              = $NestedModules
            RequiredModules            = $RequiredModules
            ProcessorArchitecture      = $ProcessorArchitecture
            PrivateData                = $PrivateData
            AliasesToExport            = $AliasesToExport
            CmdletsToExport            = $CmdletsToExport
            CompatiblePSEditions       = $CompatiblePSEditions
            DSCResourcesToExport       = $DscResourcesToExport
            ExternalModuleDependencies = $ExternalModuleDependencies
            FileList                   = $FileList
            FormatsToProcess           = $FormatsToProcess
            FunctionsToExport          = $FunctionsToExport
            PackageManagementProviders = $PackageManagementProviders
            ReleaseNotes               = $ReleaseNotes
            RequiredAssemblies         = $RequireAssemblies
            ScriptsToProcess           = $ScriptsToProcess
            Tags                       = $Tags
            TypesToProcess             = $TypesToProcess
            VariablesToExport          = $VariablesToExport
            PowerShellVersion          = $PowerShellVersion
            PassThru                   = $PassThru.IsPresent
            RequireLicenseAcceptance   = $RequireLicenseAcceptance.IsPresent
        }

        if ($PSCmdlet.ShouldProcess($updateModuleManifestSplat, $CmdletName)) {
            $Path | Update-ModuleManifest @updateModuleManifestSplat
        }
    }

    <#
        .SYNOPSIS
        Selects a module property(s) or property expression(s).

        .DESCRIPTION
        The `Select-ModuleProperty` function selects a module property(s) or property expression(s)..

        .PARAMETER Path
        Specifies the path to the module manifest file.

        .PARAMETER Property
        Specifies the name of the property to select.

        .INPUTS
        [string]  `Select-ModuleProperty` accepts a string value for the Path parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Select-ModuleProperty` returns a boolean value indicating the presence or absence of the property.

        .EXAMPLE
        PS> $Path = 'C:\Program Files\WindowsPowerShell\Modules\MyModule\MyModule.psd1'
        PS> Select-ModuleProperty -Path $Path -Property 'PowerShellVersion'
        5.1

        Selected the module property.  Returned the property value.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<##########################################
    Test-HasMethod
##########################################>
function Test-HasMember {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [AllowNull()]
        [PSObject]
        $Object,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [switch]
        $Strict
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($null -eq $Object) {
            $message = "$($CmdletName) : ArgumentNullException : The value of the Object parameter cannot be null."

            if ($Strict.IsPresent) {
                $ex = [System.ArgumentNullException]::new('Object', $message)

                Write-Error -Message $message -Exception $ex -ErrorCategory InvalidArgument -TargetObject $Object -ErrorAction Continue

                throw $ex
            }
            else {
                Write-Warning -Message $message
                $false | Write-Output
            }
        }
    }

    PROCESS {
        if ($null -ne $Object) {
            $Object.PSObject.Members | Where-Object -Property Name -EQ $Name | Write-Output
        }
        else {
            $false | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Tests an object fo the presence of a method.

        .DESCRIPTION
        The `Test-HasProperty` function tests an object for the presence of a method.

        .PARAMETER Object
        Specifies the PowerShell object under test.

        .PARAMETER Name
        Specifies the name of the method to test for.

        .PARAMETER Strict
        Indicates that the function should throw an exception if the Object parameter is null.

        .INPUTS
        [string]  `Test-HasMethod` accepts a string value for the Name parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Test-HasProperty` returns a boolean value indicating the presence or absence of the method to the PowerShell pipeline.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'TypeIs'
        True

        Tested the object for the presence of the Name method.  Returned True.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Sort'
        False

        Tested the object for the presence of the Name method.  Returned False.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        You may use this script only in accordance with the terms of the License Agreement that should have been included with this script.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Advanced_Function_Parameters

        .LINK
        about_throw

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<##########################################
    Test-HasMethod
##########################################>
function Test-HasMethod {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [PSObject]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $InputObject | Where-Object -FilterScript { $null -ne $_ } | ForEach-Object -Process {
            $TheObject = $_

            $Name | ForEach-Object -Process {
                $TheObject.PSObject.Methods | Where-Object -Property Name -EQ $_ | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Tests an object fo the presence of a method.

        .DESCRIPTION
        The `Test-HasProperty` function tests an object for the presence of a method.

        .PARAMETER Object
        Specifies the PowerShell object under test.

        .PARAMETER Name
        Specifies the name of the method to test for.

        .PARAMETER Strict
        Indicates that the function should throw an exception if the Object parameter is null.

        .INPUTS
        [string]  `Test-HasMethod` accepts a string value for the Name parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Test-HasProperty` returns a boolean value indicating the presence or absence of the method to the PowerShell pipeline.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'TypeIs'
        True

        Tested the object for the presence of the Name method.  Returned True.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Sort'
        False

        Tested the object for the presence of the Name method.  Returned False.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        You may use this script only in accordance with the terms of the License Agreement that should have been included with this script.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Advanced_Function_Parameters

        .LINK
        about_throw

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<##########################################
    Test-HasProperty
##########################################>
function Test-HasProperty {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [PSObject]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $InputObject | Where-Object -FilterScript { $null -ne $_ } | ForEach-Object -Process {
            $TheObject = $_

            $Name | ForEach-Object -Process {
                $TheObject.PSObject.Properties | Where-Object -Property Name -EQ $_ | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Tests an object fo the presence of a property.

        .DESCRIPTION
        The `Test-HasProperty` function tests an object for the presence of a property.

        .PARAMETER Object
        Specifies the PowerShell object under test.

        .PARAMETER Name
        Specifies the name of the property to test for.

        .PARAMETER Strict
        Indicates that the function should throw an exception if the Object parameter is null.

        .INPUTS
        [string]  `Test-HasProperty` accepts a string value for the Name parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Test-HasProperty` returns a boolean value indicating the presence or absence of the property.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Name'
        True

        Tested the object for the presence of the Name property.  Returned True.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Type'
        False

        Tested the object for the presence of the Name property.  Returned False.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        You may use this script only in accordance with the terms of the License Agreement that should have been included with this script.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Advanced_Function_Parameters

        .LINK
        about_throw

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<##########################################
    Test-HelpProperty
##########################################>
function Test-HelpProperty {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelingByPropertyName)]
        [ValidateSet('alertSet', 'ErrorCategory', 'Component', 'description', 'details', 'examples', 'Functionality', 'inputTypes',
            'ModuleName', 'Name', 'parameters', 'PSSnapIn', 'relatedLinks', 'returnValues', 'Role', 'Synopsis', 'syntax')]
        [string[]]
        $Property
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Property | ForEach-Object -Process {
            if (Get-Help -Name $Name -Full | Get-Member -MemberType Properties | Where-Object -Property Name -EQ $_) {
                $true | Write-Output
            }
            else {
                $false | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Tests an object fo the presence of a property.

        .DESCRIPTION
        The `Test-HasProperty` function tests an object for the presence of a property.

        .PARAMETER Object
        Specifies the PowerShell object under test.

        .PARAMETER Name
        Specifies the name of the property to test for.

        .PARAMETER Strict
        Indicates that the function should throw an exception if the Object parameter is null.

        .INPUTS
        [string]  `Test-HasProperty` accepts a string value for the Name parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `Test-HasProperty` returns a boolean value indicating the presence or absence of the property.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Name'
        True

        Tested the object for the presence of the Name property.  Returned True.

        .EXAMPLE
        PS> $Object = [PSCustomObject]@{Name = 'Test'; Value = 42}
        PS> Test-HasProperty -Object $Object -Name 'Type'
        False

        Tested the object for the presence of the Name property.  Returned False.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        You may use this script only in accordance with the terms of the License Agreement that should have been included with this script.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Advanced_Function_Parameters

        .LINK
        about_throw

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<##########################################
    Test-ModuleProperty
##########################################>
function Test-ModuleProperty {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet('Path', 'Description', 'PowerShellVersion', 'PowerShellHostName', 'PowerShellHostVersion', 'DotNetFrameworkVersion', 'ClrVersion', 'ProcessorArchitecture', 'RequiredModules', 'RequiredAssemblies', 'ScriptsToProcess', 'TypesToProcess', 'FormatsToProcess', 'NestedModules', 'FunctionsToExport', 'CmdletsToExport', 'VariablesToExport', 'AliasesToExport', 'DscResourcesToExport', 'ModuleList')]
        [string[]]
        $Property
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Path | Resolve-Path |
            Test-ModuleManifest |
            Select-Object -Property $Property |
            Measure-Object -Property $Property |
            Where-Object -Property Count -GT 0 |
            Write-Output
    }
}
