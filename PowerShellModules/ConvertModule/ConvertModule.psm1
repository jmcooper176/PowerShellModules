<#
 =============================================================================
<copyright file="ConvertModule.psm1" company="John Merryweather Cooper">
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
<date>Created:  2025-1-27</date>
<summary>
This file "ConvertModule.psm1" is part of "ConvertModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    ConvertFrom-Type
#>
function ConvertFrom-Type {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [type]
        $Type,

        [switch]
        $Name
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($Name.IsPresent) {
            $Type | ForEach-Object -Process { $_.Name } | Write-Output
        }
        else {
            $Type | ForEach-Object -Process { $_.FullName } | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Converts a type to a string type full name or name.

        .DESCRIPTION
        The `ConvertFrom-Type` function converts a type to a string type full name or name.

        .PARAMETER Type
        Specifies the type object to convert.

        .PARAMETER Name
        Indicates that the function should return the type name instead of the full type name.

        .INPUTS
        [type]  `ConvertFrom-Type` accepts a type object for the Type parameter from the PowerShell pipeline.

        .OUTPUTS
        [string]  `ConvertFrom-Type` returns a string type name to the PowerShell pipeline.

        .EXAMPLE
        PS> $Type = [System.String]
        PS> ConvertFrom-Type -Type $Type

        System.String

        Converted the type to a string type name.  Returned the string type name.

        .EXAMPLE
        PS> $Type = [System.String]
        PS> ConvertFrom-Type -Type $Type -Name

        String

        Converted the type to a string type name.  Returned the string type name.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Type
#>
function ConvertTo-Type {
    [CmdletBinding()]
    [OutputType([type])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TypeName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $TypeName | ForEach-Object -Process { $_ -as [type] } | Write-Output
    }

    <#
        .SYNOPSIS
        Converts a string type name to a type.

        .DESCRIPTION
        The `ConvertTo-Type` function converts a string to a type.

        .PARAMETER TypeName
        Specifies the name or full name of the type name to convert.

        .INPUTS
        [string]  `ConvertTo-Type` accepts a string value for the TypeName parameter from the PowerShell pipeline.

        .OUTPUTS
        [type]  `ConvertTo-Type` returns a type object to the PowerShell pipeline.

        .EXAMPLE
        PS> $TypeName = 'System.String'
        PS> ConvertTo-Type -TypeName $TypeName

        IsPublic IsSerial Name                                     BaseType
        -------- -------- ----                                     --------
        True     False    String                                   System.Object

        Converted the type name to a type object.  Returned the type object.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Boolean
#>
function ConvertTo-Boolean {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToBoolean($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedInteger' {
                $UnsignedInteger | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToBoolean($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToBoolean($_) } | Write-Output
                }

                break
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts a values, strings, or objects to a boolean value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts a values, strings, or objects to a boolean value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Boolean` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Boolean` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Boolean` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Boolean` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Boolean` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Boolean` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Boolean` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Boolean` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Boolean` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Boolean` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Boolean` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Boolean` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Boolean` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Boolean` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [bool]  `ConvertTo-Boolean` returns a boolean value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = 'True'
        PS> ConvertTo-Boolean -Value $Value

        True

        Converted the string to a boolean value.  Returned the boolean value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Byte
#>
function ConvertTo-Byte {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([byte])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(0.0, 255.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(0.0, 255.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(0.0, 255.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(0, 255)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(0, 255)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(0, 255)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(0, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 255)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 255)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 255)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToByte($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToByte($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToByte($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts a values, strings, or objects to an unsigned byte value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts a values, strings, or objects to an unsigned byte value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Byte` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Byte` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Byte` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-Byte` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Byte` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Byte` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Byte` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Byte` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Byte` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Byte` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Byte` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Byte` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Byte` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Byte` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Byte` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [byte]  `ConvertTo-Byte` returns an unsigned byte value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = 'FF'
        PS> ConvertTo-Byte -Value $Value

        255

        Converted the string to an unsigned byte value.  Returned the unsigned byte value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-StrictMode

        .LINK
        ForEach-Object

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Char
#>
function ConvertTo-Char {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([char])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(0, 1114112)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(0, 1114112)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(0, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(0, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 1114112)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 1114112)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToChar($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                }

                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingUnsignedInteger' {
                $UnsignedInteger | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToChar($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToChar($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to a char value.

        .DESCRIPTION
        The `ConvertTo-Char` function converts values, strings, or objects to a char value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Char` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [byte]  `ConvertTo-Char` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-Char` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Char` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Char` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Char` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Char` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Char` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Char` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Char` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Char` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [char]  `ConvertTo-Char` returns a char value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = 'e'
        PS> ConvertTo-Char -Value $Value

        e

        Converted the string to a char value.  Returned the char value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-DateTime
#>
function ConvertTo-DateTime {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDataTime')]
        [datetime]
        $DateTime,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingDataTime' {
                $DateTime | ForEach-Object -Process { [System.Convert]::ToDateTime($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToBateTime($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToDateTime($_) } | Write-Output
                }

                break
            }

            'UsingObject' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToDateTime($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToDateTime($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to a DateTime value.

        .DESCRIPTION
        The `ConvertTo-DateTime` function converts values, strings, or objects to a DateTime value.

        .PARAMETER DateTime
        Specifies the date time value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-DateTime` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [datetime]  `ConvertTo-DateTime` accepts a DateTime value for the 'DateTime' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-DateTime` accepts a string value for the 'Value' parameter from the PowerShell pipeline.

        .OUTPUTS
        [datetime]  `ConvertTo-DateTime` returns a DateTime value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '2024-01-01'
        PS> ConvertTo-Boolean -Value $Value

        Monday, January 1, 2024 12:00:00 AM

        Converted the string to a DateTime value.  Returned the DateTime value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Decimal
#>
function ConvertTo-Decimal {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([decimal])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(-79228162514264337593543950335.0, 79228162514264337593543950335.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(-79228162514264337593543950335.0, 79228162514264337593543950335.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(-2147483648, 2147483647)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(-9223372036854775808, 9223372036854775807)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(-32768, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(-128, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 4294967295)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 18446744073709551615)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToDecimal($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToDecimal($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToDecimal($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts a values, strings, or objects to a decimal value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts a values, strings, or objects to an decimal value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Decimal` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Decimal` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Decimal` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-Decimal` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Decimal` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Decimal` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Decimal` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Decimal` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Decimal` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Decimal` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Decimal` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Decimal` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Decimal` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Decimal` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Decimal` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [decimal]  `ConvertTo-Decimal` returns a decimal value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3.14'
        PS> ConvertTo-Decimal -Value $Value

        3.14

        Converted the string to a decimal value.  Returned the decimal value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Double
#>
function ConvertTo-Double {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([double])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(-79228162514264337593543950335.0, 79228162514264337593543950335.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(-3.402823E+38, 3.4028235E+38)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(-2147483648, 2147483647)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(-9223372036854775808, 9223372036854775807)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(-32768, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(-128, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 4294967295)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 18446744073709551615)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToDouble($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToDouble($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToDouble($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to an double value.

        .DESCRIPTION
        The `ConvertTo-Double` function converts a values, strings, or objects to a double value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Double` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Double` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Double` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-Double` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Double` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Double` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Double` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Double` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Double` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Double` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Double` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Double` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Double` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Double` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Double` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [double]  `ConvertTo-Double` returns a double value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3.14'
        PS> ConvertTo-Double -Value $Value

        3.14

        Converted the string to a double value.  Returned the double value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Float
#>
function ConvertTo-Float {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([float])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(-79228162514264337593543950335.0, 79228162514264337593543950335.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(-3.402823E+38, 3.402823E+38)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(-2147483648, 2147483647)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(-9223372036854775808, 9223372036854775807)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(-32768, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(-128, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 4294967295)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 18446744073709551615)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToSingle($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToSingle($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToSingle($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to an float value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts a values, strings, or objects to a float value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Float` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Float` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Float` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Float` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Float` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Float` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Float` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Float` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Float` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Float` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Float` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Float` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Float` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Float` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [float]  `ConvertTo-Float` returns a float value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3.14'
        PS> ConvertTo-Float -Value $Value

        3.14

        Converted the string to a float value.  Returned the float value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConverTo-Integer
#>
function ConvertTo-Integer {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [ValidateRange([char]0, [char]1114112)]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(-2147483648.0, 2147483647.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(-2147483648.0, 2147483647.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange( - 2147483648.0, 2147483647.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange( - 2147483648, 2147483647)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange( - 32768, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange( - 128, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 2147483647)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 2147483647)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingString' {
                if ((Test-PSParameter -Name 'Culture' -Parameters $PSBoundParameters) -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToInt32($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToInt32($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to an integer value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts values, strings, or objects to an integer value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Integer` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Integer` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Integer` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-Integer` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Integer` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Integer` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Integer` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Integer` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Integer` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Integer` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Integer` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Integer` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Integer` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Integer` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Integer` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [int]  `ConvertTo-Integer` returns an integer value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-Integer -Value $Value

        3

        Converted the string to an integer value.  Returned the integer value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Long
#>
function ConvertTo-Long {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([long])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [ValidateRange([char]0, [char]1114112)]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(-9223372036854775808.0, 9223372036854775807.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(-9223372036854775808.0, 9223372036854775807.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(-3.402823E+38, 3.402823E+38)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(-2147483648, 2147483647)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(-32768, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(-128, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 4294967295)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 9223372036854775807)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingString' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToInt64($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToInt64($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToInt64($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to a long integer value.

        .DESCRIPTION
        The `ConvertTo-Long` function converts values, strings, or objects to an long integer value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Long` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Long` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Long` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-Long` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Long` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Long` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Long` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Long` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Long` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Long` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Long` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Long` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Long` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Long` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Long` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [long]  `ConvertTo-Long` returns an long integer value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-Long -Value $Value

        3

        Converted the string to an long integer value.  Returned the long integer value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-Short
#>
function ConvertTo-Short {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([short])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [ValidateRange([char]0, [char]32767)]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(-32768.0, 32767.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(-32768.0, 32767.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(-32768.0, 32767.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(-32768, 32767)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(-32768, 32767)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(-128, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 32767)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 32767)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 32767)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingString' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToInt16($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToInt16($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToInt16($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to a short integer value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts values, strings, or objects to a short integer value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-Short` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-Short` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-Short` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-Short` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-Short` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-Short` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-Short` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-Short` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-Short` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-Short` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-Short` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-Short` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-Short` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-Short` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-Short` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [short]  `ConvertTo-Short` returns an short integer value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-Short -Value $Value

        3

        Converted the string to a short integer value.  Returned the short integer value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-SignedByte
#>
function ConvertTo-SignedByte {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([sbyte])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 127)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [ValidateRange([char]0, [char]127)]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(-128.0, 127.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(-128.0, 127.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(-128.0, 127.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(-128, 127)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(-128, 127)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(-128, 127)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 127)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 127)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 127)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingString' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToSByte($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToSByte($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToSByte($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to a signed byte value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts values, strings, or objects to a signed byte value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-SignedByte` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-SignedByte` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-SignedByte` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-SignedByte` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-SignedByte` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-SignedByte` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-SignedByte` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-SignedByte` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-SignedByte` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-SignedByte` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-SignedByte` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-SignedByte` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-SignedByte` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-SignedByte` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-SignedByte` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [sbyte]  `ConvertTo-SignedByte` returns an signed byte value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-SignedByte -Value $Value

        3

        Converted the string to an signed byte value.  Returned the signed byte value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
        ConvertTo-String
#>
function ConvertTo-String {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDateTime')]
        [datetime]
        $DateTime,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingDateTime' {
                $DateTime | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingString' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToString($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToString($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToString($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to a string value.

        .DESCRIPTION
        The `ConvertTo-String` function converts values, strings, or objects to a string value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-String` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-String` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-String` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-String` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-String` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-String` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-String` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-String` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-String` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-String` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-String` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-String` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-String` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-String` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-String` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [string]  `ConvertTo-String` returns a string value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-String -Character $Value

        3

        Converted the character to a string value.  Returned the string value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-UnsignedInteger
#>
function ConvertTo-UnsignedInteger {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([uint])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [ValidateRange([char]0, [char]1114112)]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(0.0, 4294967295.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(0.0, 4294967295.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(0.0, 4294967295.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(0, 4294967295)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(0, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(0, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 4294967295)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingString' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToUInt32($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToUInt32($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToUInt32($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to an unsigned integer value.

        .DESCRIPTION
        The `ConvertTo-UnsignedInteger` function converts values, strings, or objects to an unsigned integer value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-UnsignedInteger` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-UnsignedInteger` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-UnsignedInteger` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-UnsignedInteger` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-UnsignedInteger` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-UnsignedInteger` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-UnsignedInteger` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-UnsignedInteger` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-UnsignedInteger` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-UnsighedInteger` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-UnsignedInteger` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-UnsignedInteger` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-UnsignedInteger` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-UnsignedInteger` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-UnsignedInteger` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [uint]  `ConvertTo-UnsignedInteger` returns an unsigned integer value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-UnsignedInteger -Value $Value

        3

        Converted the string to an unsigned integer value.  Returned the unsigned integer value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-UnsignedLong
#>
function ConvertTo-UnsignedLong {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([ulong])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [ValidateRange([char]0, [char]1114112)]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(0.0, 18446744073709551615.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(0.0, 18446744073709551615.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(0.0, 18446744073709551615.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(0, 9223372036854775807)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(0, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(0, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 4294967295)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ValidateRange(0, 65535)]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingString' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToUInt64($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                break
            }

            'UsingObject' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToUInt64($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToUInt64($_) } | Write-Output
                }
            }

            default {
                $writeErrorSplat = @{
                    ErrorAction = 'Continue'
                    ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                        [System.ArgumentException]::new("Invalid parameter set name."),
                        "$($CmdletName)-ArgumentException-01",
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $PSCmdlet.ParameterSetName
                    )
                }

                Write-Error @writeErrorSplat
                $PSCmdlet.ThrowTerminatingError($writeErrorSplat['ErrorRecord'])
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to an unsigned long value.

        .DESCRIPTION
        The `ConvertTo-UnsignedLong` function converts values, strings, or objects to an unsigned long value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-UnsignedLong` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-UnsignedLong` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-UnsignedLong` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-UnsignedLong` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-UnsignedLong` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-UnsignedLong` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-UnsignedLong` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-UnsignedLong` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-UnsignedLong` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-UnsignedLong` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-UnsignedLong` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-UnsignedLong` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-UnsignedLong` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-UnsignedLong` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-UnsignedLong` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [ulong]  `ConvertTo-UnsignedLong` returns an integer value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-UnsignedLong -Value $Value

        3

        Converted the string to an unsigned long value.  Returned the unsigned long value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    ConvertTo-UnsignedShort
#>
function ConvertTo-UnsignedShort {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([ushort])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [ValidateRange(0, 255)]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingChar')]
        [ValidateRange([char]0, [char]65535)]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [ValidateRange(0.0, 65535.0)]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [ValidateRange(0.0, 65535.0)]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [ValidateRange(0.0, 65535.0)]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInt')]
        [ValidateRange(0, 65535)]
        [int]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [ValidateRange(0, 65535)]
        [long]
        $Long,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [ValidateRange(0, 32767)]
        [short]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [ValidateRange(0, 127)]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedInteger')]
        [ValidateRange(0, 65535)]
        [uint]
        $UnsignedInteger,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [ValidateRange(0, 65535)]
        [ulong]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [ushort]
        $UnsignedShort,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [AllowNull()]
        [cultureinfo]
        $Culture = $null
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingBoolean' {
                $Boolean | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingByte' {
                $Byte | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingChar' {
                $Character | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingDecimal' {
                $Decimal | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingDouble' {
                $Double | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingFloat' {
                $Float | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingInt' {
                $Integer | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingLong' {
                $Long | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingShort' {
                $Short | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingSignedByte' {
                $SignedByte | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingString' {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $Value | ForEach-Object -Process { [System.Convert]::ToUInt16($_, $Culture) } | Write-Output
                }
                else {
                    $Value | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                }

                break
            }

            'UsingUnsignedLong' {
                $UnsignedLong | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                break
            }

            'UsingUnsignedShort' {
                $UnsignedShort | ForEach-Object -Process { [System.Convert]::ToInt32($_) } | Write-Output
                break
            }

            default {
                if ($PSBoundParameters.ContainsKey('Culture') -and ($null -ne $Culture)) {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToUInt16($_, $Culture) } | Write-Output
                }
                else {
                    $InputObject | ForEach-Object -Process { [System.Convert]::ToUInt16($_) } | Write-Output
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Converts values, strings, or objects to an unsigned short integer value.

        .DESCRIPTION
        The `ConvertTo-Boolean` function converts values, strings, or objects to an unsigned short integer value.

        .PARAMETER Boolean
        Specifies the boolean value to convert.

        .PARAMETER Byte
        Specifies the byte value to convert.

        .PARAMETER Character
        Specifies the character value to convert.

        .PARAMETER Decimal
        Specifies the decimal value to convert.

        .PARAMETER Double
        Specifies the double value to convert.

        .PARAMETER Float
        Specifies the float value to convert.

        .PARAMETER Integer
        Specifies the integer value to convert.

        .PARAMETER Long
        Specifies the long value to convert.

        .PARAMETER Short
        Specifies the short value to convert.

        .PARAMETER SignedByte
        Specifies the signed byte value to convert.

        .PARAMETER UnsignedInteger
        Specifies the unsigned integer value to convert.

        .PARAMETER UnsignedLong
        Specifies the unsigned long value to convert.

        .PARAMETER UnsignedShort
        Specifies the unsigned short value to convert.

        .PARAMETER InputObject
        Specifies the object to convert.

        .PARAMETER Value
        Specifies the string value to convert.

        .INPUTS
        [object]  `ConvertTo-UnsignedShort` accepts an object by value or by property name for the 'InputObject' parameter from the PowerShell pipeline.

        [bool]  `ConvertTo-UnsignedShort` accepts a boolean value for the 'Boolean' parameter from the PowerShell pipeline.
        [byte]  `ConvertTo-UnsignedShort` accepts a byte value for the 'Byte' parameter from the PowerShell pipeline.
        [char]  `ConvertTo-UnsignedShort` accepts a character value for the 'Character' parameter from the PowerShell pipeline.
        [decimal]  `ConvertTo-UnsignedShort` accepts a decimal value for the 'Decimal' parameter from the PowerShell pipeline.
        [double]  `ConvertTo-UnsignedShort` accepts a double value for the 'Double' parameter from the PowerShell pipeline.
        [float]  `ConvertTo-UnsignedShort` accepts a float value for the 'Float' parameter from the PowerShell pipeline.
        [int]  `ConvertTo-UnsignedShort` accepts an integer value for the 'Integer' parameter from the PowerShell pipeline.
        [long]  `ConvertTo-UnsignedShort` accepts a long value for the 'Long' parameter from the PowerShell pipeline.
        [sbyte]  `ConvertTo-UnsignedShort` accepts a signed byte value for the 'SignedByte' parameter from the PowerShell pipeline.
        [short]  `ConvertTo-UnsignedShort` accepts a short value for the 'Short' parameter from the PowerShell pipeline.
        [string]  `ConvertTo-UnsignedShort` accepts a string value for the 'Value' parameter from the PowerShell pipeline.
        [uint]  `ConvertTo-UnsignedShort` accepts an unsigned integer value for the 'UnsignedInteger' parameter from the PowerShell pipeline.
        [ulong]  `ConvertTo-UnsignedShort` accepts an unsigned long value for the 'UnsignedLong' parameter from the PowerShell pipeline.
        [ushort]  `ConvertTo-UnsignedShort` accepts an unsigned short value for the 'UnsignedShort' parameter from the PowerShell pipeline.

        .OUTPUTS
        [int]  `ConvertTo-UnsignedShort` returns an unsigned short integer value to the PowerShell pipeline.

        .EXAMPLE
        PS> $Value = '3'
        PS> ConvertTo-UnsignedShort -Value $Value

        3

        Converted the string to an unsigned short integer value.  Returned the unsigned short integer value.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable
    #>
}
