<#
 =============================================================================
<copyright file="HelperModule.psm1" company="U.S. Office of Personnel
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
This file "HelperModule.psm1" is part of "HelperModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Get-HelpProperty
#>
function Get-HelpProperty {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Get-Command -Name $_ -CommandType @('Cmdlet', 'Function', 'Script') })]
        [Alias('CmdletName')]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet('alertSet', 'Category', 'Component', 'description', 'details', 'examples',
        'Functionality', 'inputTypes', 'ModuleName', 'Name', 'Synopsis', 'parameters', 'PSSnapIn',
        'relatedLinks', 'returnValues', 'Role', 'syntax')]
        [Alias('HelpProperty')]
        [string]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Get-Help -Name $Name -Full | Select-Object -ExpandProperty $Property | Write-Output
    }

    <#
        .SYNOPSIS
        Gets a property from the help file for a cmdlet, function, or script.

        .DESCRIPTION
        `Get-HelpProperty` gets a property from the help file for a cmdlet, function, or script.

        .PARAMETER Name
        Specifies the name or path of the cmdlet, function, or script.

        If name is specified as a module name, the module must exist in the current session.

        If name is specified as a relative or absolute path, the path must exist on the file system and must be a leaf.

        .PARAMETER Property
        Specifies the name of the property to retrieve from the help file.

        .INPUTS
        [string]  `Get-HelpProperty` accepts a string value for the Property parameter from the PowerShell pipeline.

        .OUTPUTS
        [object]  `Get-HelpProperty` returns the value of the property to the PowerShell pipeline.

        .EXAMPLE
        PS> Get-HelpProperty -Name 'Get-Process' -Property 'Syntax'

        Get-Process [[-Name] <System.String[]>] [-FileVersionInfo] [-Module] [<CommonParameters>]

        Get-Process [-FileVersionInfo] -Id <System.Int32[]> [-Module] [<CommonParameters>]

        Get-Process [-FileVersionInfo] -InputObject <System.Diagnostics.Process[]> [-Module] [<CommonP

        Get-Process -Id <System.Int32[]> -IncludeUserName [<CommonParameters>]

        Get-Process [[-Name] <System.String[]>] -IncludeUserName [<CommonParameters>]

        Get-Process -IncludeUserName -InputObject <System.Diagnostics.Process[]> [<CommonParameters>]

        Retrieved the Syntax property from the help file for the Get-Process cmdlet.  Returned the syntax.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Command

        .LINK
        Get-Help

        .LINK
        Initialize-PSCmdlet

        .LINK
        Select-Object

        .LINK
        Write-Output
    #>
}

<#
    Get-HelpPropertyLength
#>
function Get-HelpPropertyLength {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Get-Command -Name $_ -CommandType @('Cmdlet', 'Function', 'Script') })]
        [Alias('CmdletName')]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateSet('alertSet', 'Category', 'Component', 'description', 'details', 'examples',
            'Functionality', 'inputTypes', 'ModuleName', 'Name', 'Synopsis', 'parameters', 'PSSnapIn',
            'relatedLinks', 'returnValues', 'Role', 'syntax')]
        [Alias('HelpProperty')]
        [string[]]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName) : Getting length of '$($_)' for '$($Name)'"
        $Property | Get-HelpProperty -Name $Name | Out-String -Stream | Measure-Object -Character | Select-Object -ExpandProperty Characters | Write-Output
    }

    <#
        .SYNOPSIS
        Gets the length of a property from the help file for a cmdlet, function, or script.

        .DESCRIPTION
        `Get-HelpPropertyLength` gets the length of a property from the help file for a cmdlet, function, or script.

        .PARAMETER Name
        Specifies the name or path of the cmdlet, function, or script.

        .PARAMETER Property
        Specifies the one or more property names to retrieve from the help file and measure for length.

        .INPUTS
        [string[]]  `Get-HelpPropertyLength` accepts a string array for the Property parameter from the PowerShell pipeline.

        .OUTPUTS
        [int]  `Get-HelpPropertyLength` returns the length of each property to the PowerShell pipeline.]

        .EXAMPLE
        PS> Get-HelpPropertyLength -Name 'Get-Process' -Property 'Syntax'

        531

        Returns the length of the Syntax property from the help file for the Get-Process cmdlet.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Command

        .LINK
        Get-HelpProperty

        .LINK
        Initialize-PSCmdlet

        .LINK
        Measure-Object

        .LINK
        Out-String

        .LINK
        Select-Object

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Get-ModuleProperty
#>
function Get-ModuleProperty {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingModuleName')]
        [ValidateScript({ Get-Module -ListAvailable | Where-Object -Property Name -EQ -Value $_ })]
        [Alias('ModuleName')]
        [string[]]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet('AccessMode', 'Author', 'ClrVersion', 'CompanyName', 'CompatiblePSEditions',
            'Copyright', 'Definition', 'Description',
            'DotNetFrameworkVersion',
            'ExperimentalFeatures',
            'ExportedAliases', 'ExportedCmdlets', 'ExportedCommands', 'ExportedDscResources', 'ExportedFormatFiles', 'ExportedFunctions', 'ExportedTypeFiles', 'ExportedVariables',
            'FileList',
            'Guid',
            'HelpInfoUri', 'IconUri', 'ImplementingAssembly', 'LicenseUri', 'LogPipelineExecutionDetais', 'ModuleList', 'ModuleType', 'Name', 'NestedModules',
            'OnRemove',
            'Path',
            'PowerShellHostName', 'PowerShellVersion',
            'Prefix',
            'ProcessorArchitecture',
            'ProjectUri', 'ReleaseNotes', 'RepositorySourceLocation',
            'RequiredAssemblies', 'RequiredModules',
            'RootModule', 'Scripts',
            'SessionState', 'Tags', 'Version')]
        [string[]]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingLiteralPath' {
                $LiteralPath | ForEach-Object -Process {
                    $modulePath = $_

                    $Property | ForEach-Object -Process {
                        $moduleProperty = $_
                        Test-ModuleManifest -Path $modulePath | Select-Object -ExpandProperty $moduleProperty | Write-Output
                    }
                }

                break
            }

            'UsingModuleName' {
                $Name | ForEach-Object -Process {
                    $moduleName = $_

                    ForEach-Object -Process {
                        $moduleProperty = $_
                        Get-Module -Name $moduleName | Select-Object -ExpandProperty $moduleProperty | Write-Output
                    }
                }

                break
            }

            default {
                $Path | Resolve-Path | ForEach-Object -Process {
                    $modulePath = $_

                    $Property | ForEach-Object -Process {
                        $moduleProperty = $_

                        Test-ModuleManifest -Path $modulePath | Select-Object -ExpandProperty $moduleProperty | Write-Output
                    }
                }

                break
            }
        }
    }

    <#
        .SYNOPSIS
        Gets a property from a module manifest file.

        .DESCRIPTION
        `Get-ModuleProperty` gets a property from a module manifest file.

        .PARAMETER Path
        Specifies the path to one or more module manifest files.  Wildcards are supported.

        .PARAMETER LiteralPath
        Specifies the literal path to one or more module manifest files.  Characters in the path are taken literally.

        .PARAMETER Name
        Specifies the name of one or more modules.  The module must be available in the current session.

        .PARAMETER Property
        Specifies one or more property names to retrieve from the module manifest file.

        .INPUTS
        [string[]]  `Get-ModuleProperty` accepts a string array for the Path, LiteralPath, or Property parameter from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Get-ModuleProperty` returns the string value each property to the PowerShell pipeline.

        .EXAMPLE
        PS> $Path = 'C:\Program Files\WindowsPowerShell\Modules\MyModule\MyModule.psd1'
        PS> Get-ModuleProperty -Path $Path -Property 'PowerShellVersion'

        5.1

        Retrieved the PowerShellVersion property value from the module manifest file.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Get-Module

        .LINK
        Initialize-PSCmdlet

        .LINK
        Select-Object

        .LINK
        Test-ModuleManifest

        .LINK
        Test-Path

        .LINK
        Where-Object

        .LINK
        Write-Output
    #>
}

<#
    Select-ModuleByFilter
#>
function Select-ModuleByFilter {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]
        $FilterScript
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Test-ModuleManifest | Where-Object -FilterScript $FilterScript | Write-Output
        }
        else {
            $Path | Resolve-Path | Test-ModuleManifest | Where-Object -FilterScript $FilterScript | Write-Output
        }
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Select-ModuleByProperty
#>
function Select-ModuleByProperty {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateSet(
            'AccessMode', 'Author', 'ClrVersion', 'CompanyName', 'CompatiblePSEditions',
            'Copyright', 'Definition', 'Description',
            'DotNetFrameworkVersion',
            'ExperimentalFeatures',
            'ExportedAliases', 'ExportedCmdlets', 'ExportedCommands', 'ExportedDscResources', 'ExportedFormatFiles', 'ExportedFunctions', 'ExportedTypeFiles', 'ExportedVariables',
            'FileList',
            'Guid',
            'HelpInfoUri', 'IconUri', 'ImplementingAssembly', 'LicenseUri', 'LogPipelineExecutionDetais', 'ModuleList', 'ModuleType', 'Name', 'NestedModules',
            'OnRemove',
            'Path',
            'PowerShellHostName', 'PowerShellVersion',
            'Prefix',
            'ProcessorArchitecture',
            'ProjectUri', 'ReleaseNotes', 'RepositorySourceLocation',
            'RequiredAssemblies', 'RequiredModules',
            'RootModule', 'Scripts',
            'SessionState', 'Tags', 'Version'
        )]
        [string]
        $Property,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object]
        $Value
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Test-ModuleManifest | Where-Object -Property $Property -EQ -Value $Value | Write-Output
        }
        else {
            $Path | Resolve-Path | Test-ModuleManifest | Where-Object -Property $Property -EQ -Value $Value | Write-Output
        }
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Test-HasMember
#>
function Test-HasMember {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [PSObject]
        $Object,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process { $Object.PSObject.Members | Where-Object -Property Name -EQ $_ | Write-Output }
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

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

<#
    Test-HasMethod
#>
function Test-HasMethod {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [PSObject]
        $Object,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process { $Object.PSObject.Methods | Where-Object -Property Name -EQ $_ | Write-Output }
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

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

<#
    Test-HasProperty
#>
function Test-HasProperty {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [PSObject]
        $Object,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [switch]
        $Strict
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process { $Object.PSObject.Properties | Where-Object -Property Name -EQ $_ | Write-Output }
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

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

<#
    Test-ModuleProperty
#>
function Test-ModuleProperty {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateSet(
            'AccessMode', 'Author', 'ClrVersion', 'CompanyName', 'CompatiblePSEditions',
            'Copyright', 'Definition', 'Description',
            'DotNetFrameworkVersion',
            'ExperimentalFeatures',
            'ExportedAliases', 'ExportedCmdlets', 'ExportedCommands', 'ExportedDscResources', 'ExportedFormatFiles', 'ExportedFunctions', 'ExportedTypeFiles', 'ExportedVariables',
            'FileList',
            'Guid',
            'HelpInfoUri', 'IconUri', 'ImplementingAssembly', 'LicenseUri', 'LogPipelineExecutionDetais', 'ModuleList', 'ModuleType', 'Name', 'NestedModules',
            'OnRemove',
            'Path',
            'PowerShellHostName', 'PowerShellVersion',
            'Prefix',
            'ProcessorArchitecture',
            'ProjectUri', 'ReleaseNotes', 'RepositorySourceLocation',
            'RequiredAssemblies', 'RequiredModules',
            'RootModule', 'Scripts',
            'SessionState', 'Tags', 'Version'
        )]
        [string[]]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                $modulePath = $_

                $Property | ForEach-Object -Process {
                    $moduleProperty = $_

                    [bool](Test-ModuleManifest -Path $modulePath | Select-Object -ExpandProperty $moduleProperty) | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                $modulePath = $_
                $Property | ForEach-Object -Process {
                    $moduleProperty = $_

                    [bool](Test-ModuleManifest -Path $modulePath | Select-Object -ExpandProperty $moduleProperty) | Write-Output
                }
            }
        }
    }
}
