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
    Select-ModuleByFilter
#>
function Select-ModuleByFilter {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Select-ModuleByProperty
#>
function Select-ModuleByProperty {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Select-ModuleProperty
#>
function Select-ModuleProperty {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced
    #>
}

<#
    Test-HasMethod
#>
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

                Write-Error -Message $message -Exception $ex -Category InvalidArgument -TargetObject $Object -ErrorAction Continue

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

                Write-Error -Message $message -Exception $ex -Category InvalidArgument -TargetObject $Object -ErrorAction Continue

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
            $Object.PSObject.Methods | Where-Object -Property Name -EQ $Name | Write-Output
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

                Write-Error -Message $message -Exception $ex -Category InvalidArgument -TargetObject $Object -ErrorAction Continue

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
            $Object.PSObject.Properties | Where-Object -Property Name -EQ $Name | Write-Output
        }
        else {
            $false | Write-Output
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
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
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
        $Result = $Path | Resolve-Path |
        Test-ModuleManifest |
        Select-Object -Property $Property |
        Measure-Object -Property $Property |
        Where-Object -Property Count -GT 0

        if ($Result) {
            $true | Write-Output
        }
        else {
            $false | Write-Output
        }
    }
}
