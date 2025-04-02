<#
 =============================================================================
<copyright file="TypeAcceleratoModule.psm1" company="John Merryweather Cooper
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
This file "TypeAcceleratoModule.psm1" is part of "TypeAcceleratorModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<###########################################
    Add-TypeAccelerator
##########################################>
function Add-TypeAccelerator {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [type[]]
        $ExportableType,

        [switch]
        $Strict
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $TypeAcceleratorsClass = Get-TypeAcceleratorClass
    }

    PROCESS {
        $ExportableType | ForEach-Object -Process {
            if ((Test-TypeAcceleratorRegistered -ExportableType $_) -and $Strict.IsPresent) {
                $newErrorRecordSplat = @{
                    Exception = [System.ArgumentException]::new('The type accelerator is already registered.', 'ExportableType')
                    ErrorId = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                    ErrorCategory = 'ResourceUnavailable'
                    TargetObject = $_.FullName
                    TargetName = 'ExportableType'
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            }
            elseif (Test-TypeAcceleratorRegistered -ExportableType $_) {
                Write-Warning -Message "$($CmdletName) : The type accelerator '$($_.Name)' is already registered."
            }
            else {
                if ($PSCmdlet.ShouldProcess($_.FullName, $CmdletName)) {
                    $TypeAcceleratorsClass::Add($_.FullName, $_)
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Add exportable types as type accelerators.

        .DESCRIPTION
        `Add-TypeAccelerator` adds exportable types as type accelerators to the current session.

        .PARAMETER ExportableType
        Specifies the exportable types to add as type accelerators.

        .PARAMETER InvocationInfo
        Specifies the invocation information of the OnRemove script block.

        .INPUTS
        System.Type[]  You can pipe types to `Add-TypeAccelerator`.

        .OUTPUTS
        None.  `Add-TypeAccelerator` does not generate any output.

        .EXAMPLE
        PS> [Vine] | Add-TypeAccelerator

        This command adds the `[Vine]` type as a type accelerator to the current session.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        The type accelerator is removed when the module is removed.

        The type accelerator is not added if it is already registered.

        The type accelerator is not added if the `-WhatIf` common parameter is used.

        The type accelerator is not added if the `-Confirm` common parameter is used and the user does not confirm the operation.

        .LINK
        about_Advanced_Function

        .LINK
        ForEach-Object

        .LINK
        Get-TypeAcceleratorClass

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}

<###########################################
    Get-TypeAccelerator
##########################################>
function Get-TypeAccelerator {
    [CmdletBinding(DefaultParameterSetName = 'UsingTypeName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingExportableType')]
        [Type[]]
        $ExportableType,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingTypeName')]
        [string[]]
        $TypeName,

        [Parameter(Mandatory, ParameterSetName = 'UsingListAvailable')]
        [switch]
        $ListAvailable
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $TypeAcceleratorsClass = Get-TypeAcceleratorClass
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingExportableType' {
                $ExportableType | ForEach-Object -Process {
                    if (Test-TypeAcceleratorRegistered -ExportableType $_) {
                        $Name = $_.Name

                        $TypeAcceleratorsClass::Get | ForEach-Object -Process {
                            $Key = $_.Key

                            if ($Key -eq $Name) {
                                $Key | Write-Output
                            }
                        }
                    }
                }

                break
            }

            'UsingTypeName' {
                $TypeName | ForEach-Object -Process {
                    if (Test-TypeAcceleratorRegistered -TypeName $_) {
                        $TypeAcceleratorsClass::Get | ForEach-Object -Process {
                            if ($_.Key -in $TypeName) {
                                $_ | Write-Output
                            }
                        }
                    }
                }

                break
            }

            'UsingListAvailable' {
                if ($ListAvailable.IsPresent) {
                    $TypeAcceleratorsClass::Get | ForEach-Object -Process {
                        $_.Key | Write-Output
                    }
                }

                break
            }
        }
    }

    <#
        .SYNOPSIS
        Get type accelerators.

        .DESCRIPTION
        `Get-TypeAccelerator` gets type accelerators from the current session.

        .PARAMETER TypeName
        Specifies the type full names of the type accelerators to get.

        .PARAMETER ListAvailable
        Lists all available type accelerators.

        .INPUTS
        System.String[]  You can pipe type full names to `Get-TypeAccelerator`.

        .OUTPUTS
        System.Collections.Generic.Dictionary`2[System.String,System.Type]  `Get-TypeAccelerator` returns a dictionary of type accelerators.

        .EXAMPLE
        PS> Get-TypeAccelerator -ListAvailable | Format-Table

        This command lists all available type accelerators in the current session.

        .EXAMPLE
        PS> Get-TypeAccelerator -TypeName 'Vine' | Format-Table

        This command gets the type accelerator for the `Vine` type in the current session.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Advanced_Function

        .LINK
        ForEach-Object

        .LINK
        Get-TypeAcceleratorClass

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<###########################################
    Get-TypeAcceleratorClass
#>
function Get-TypeAcceleratorClass {
    [CmdletBinding()]
    [OutputType([Type])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    # Get the internal TypeAccelerators class to use its static methods.
    [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators') | Write-Output

    <#
        .SYNOPSIS
        Get the internal TypeAccelerators class.

        .DESCRIPTION
        `Get-TypeAcceleratorClass` gets the internal TypeAccelerators class to use its static methods.

        .INPUTS
        None.  You cannot pipe objects to `Get-TypeAcceleratorClass`.

        .OUTPUTS
        System.Type  `Get-TypeAcceleratorClass` returns the internal TypeAccelerators class.

        .EXAMPLE
        PS> Get-TypeAcceleratorClass

        This command gets the internal TypeAccelerators class to use its static methods.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Advanced_Function

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<###########################################
    Register-TypeAccelerator
##########################################>
function Register-TypeAccelerator {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [type[]]
        $ExportableType,

        [switch]
        $Strict
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $ExportableType | ForEach-Object -Process {
            if ($PSCmdlet.ShouldProcess($_.FullName, $CmdletName)) {
                $_ | Add-TypeAccelerator -Strict:$Strict.IsPresent
            }
        }
    }

    <#
        .SYNOPSIS
        Register exportable types as type accelerators.

        .DESCRIPTION
        `Register-TypeAccelerator` registers exportable types as type accelerators to the current session.

        .PARAMETER ExportableType
        Specifies the exportable types to register as type accelerators.

        .INPUTS
        System.Type[]  You can pipe types to `Register-TypeAccelerator`.

        .OUTPUTS
        None.  `Register-TypeAccelerator` does not generate any output.

        .EXAMPLE
        PS> [Vine] | Register-TypeAccelerator

        This command registers the `[Vine]` type as a type accelerator to the current session.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        The type accelerator is removed when the module is removed.

        The type accelerator is not registered if it is already registered.

        The type accelerator is not registered if the `-WhatIf` common parameter is used.

        The type accelerator is not registered if the `-Confirm` common parameter is used and the user does not confirm the operation.

        .LINK
        about_Advanced_Function

        .LINK
        Add-TypeAccelerator

        .LINK
        ForEach-Object

        .LINK
        Remove-TypeAccelerator

        .LINK
        Test-TypeAcceleratorRegistered

        .LINK
        Where-Object
    #>
}

<###########################################
    Remove-TypeAccelerator
##########################################>
function Remove-TypeAccelerator {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingTypeName')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'UsingExportableType')]
        [type[]]
        $ExportableType,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingTypeName')]
        [string[]]
        $TypeName
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $PSCmdlet.MyInvocation.MyCommand -WhatIf:$false

        # Get the internal TypeAccelerators class to use its static methods.
        $TypeAcceleratorsClass = Get-TypeAcceleratorClass
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingExportableType') {
            # Remove type accelerators for every exportable type.
            $ExportableType |
                Where-Object -FilterScript { Test-TypeAcceleratorRegistered -ExportableType $_ } |
                    ForEach-Object -Process {
                        if ($PSCmdlet.ShouldProcess($_.FullName, $CmdletName)) {
                            $TypeAcceleratorsClass::Remove($_.FullName)
                        }
                    }
        }
        else {
            # Remove type accelerators for every exportable type name.
            $TypeName |
                Where-Object -FilterScript { Test-TypeAcceleratorRegistered -TypeName $_ } |
                    ForEach-Object -Process {
                        if ($PSCmdlet.ShouldProcess($_, $CmdletName)) {
                            $TypeAcceleratorsClass::Remove($_)
                        }
                    }
        }
    }

    <#
        .SYNOPSIS
        Remove exportable types as type accelerators.

        .DESCRIPTION
        `Remove-TypeAccelerator` removes exportable types as type accelerators from the current session.

        .PARAMETER ExportableType
        Specifies the exportable types to remove as type accelerators.

        .PARAMETER TypeName
        Specifies the type full names of the type accelerators to remove.

        .INPUTS
        System.Type[]  You can pipe types to `Remove-TypeAccelerator`.

        .OUTPUTS
        None.  `Remove-TypeAccelerator` does not generate any output.

        .EXAMPLE
        PS> [Vine] | Remove-TypeAccelerator

        This command removes the `[Vine]` type as a type accelerator from the current session.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        The type accelerator is not removed if it is not registered.

        The type accelerator is not removed if the `-WhatIf` common parameter is used.

        The type accelerator is not removed if the `-Confirm` common parameter is used and the user does not confirm the operation.

        .LINK
        about_Advanced_Function

        .LINK
        ForEach-Object

        .LINK
        Get-TypeAcceleratorClass

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Test-TypeAcceleratorRegistered

        .LINK
        Where-Object
    #>
}

<###########################################
    Test-TypeAcceleratorRegistered
##########################################>
function Test-TypeAcceleratorRegistered {
    [CmdletBinding(DefaultParameterSetName = 'UsingExportableType')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingExportableType')]
        [type[]]
        $ExportableType,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingTypeName')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $TypeName
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $PSCmdlet.MyInvocation.MyCommand

        # Get the internal TypeAccelerators class to use its static methods.
        $TypeAcceleratorsClass = Get-TypeAcceleratorClass
    }

    PROCESS {
        # Check if the type accelerator is registered.
        $ExistingTypeAccelerators = $TypeAcceleratorsClass::Get

        if ($PSCmdlet.ParameterSetName -eq 'UsingTypeName') {
            $TypeName | ForEach-Object -Process {
                if ($_ -in $ExistingTypeAccelerators.Keys) {
                    return $true
                }
            }
        }
        else {
            $ExportableType | ForEach-Object -Process {
                if ($_ -in $ExistingTypeAccelerators.Values) {
                    return $true
                }
            }
        }

        return $false
    }

    <#
        .SYNOPSIS
        Test if type accelerators are registered.

        .DESCRIPTION
        `Test-TypeAcceleratorRegistered` tests if type accelerators are registered in the current session.

        .PARAMETER ExportableType
        Specifies the exportable types to test if they are registered.

        .PARAMETER TypeName
        Specifies the type full name to test if it is registered.

        .INPUTS
        System.Type[]  You can pipe types to `Test-TypeAcceleratorRegistered`.

        .OUTPUTS
        System.Boolean  `Test-TypeAcceleratorRegistered` returns `$true` if the type accelerator is registered; otherwise, `$false`.

        .EXAMPLE
        PS> [Vine] | Test-TypeAcceleratorRegistered

        This command tests if the `[Vine]` type accelerator is registered in the current session.

        .EXAMPLE
        PS> Test-TypeAcceleratorRegistered -TypeName 'Vine'

        This command tests if the `Vine` type accelerator is registered in the current session.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Advanced_Function

        .LINK
        ForEach-Object

        .LINK
        Get-TypeAcceleratorClass

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}
