<#
 =============================================================================
<copyright file="StringBuilderModule.psm1" company="U.S. Office of Personnel
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
<date>Created:  2024-9-12</date>
<summary>
This file "StringBuilderModule.psm1" is part of "StringBuilderModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Add-Begin
#>
function Add-Begin {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingCharArray')]
        [char[]]
        $Array,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingCharacter')]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInteger')]
        [int32]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [int64]
        $Long,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [int16]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [string]
        $Value,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsigned')]
        [uint32]
        $Unsigned,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [uint64]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [uint16]
        $UnsignedShort
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName) : Prepending to buffer '$($PSCmdlet.ParameterSetName)'"

        switch ($PSCmdlet.ParameterSetName) {
            'UsingArray' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Array' to buffer"
                $Buffer.Insert(0, $Array) | Write-Output
                break
            }

            'UsingBoolean' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Boolean' to buffer"
                $Buffer.Insert(0, $Boolean) | Write-Output
                break
            }

            'UsingByte' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Byte' to buffer"
                $Buffer.Insert(0, $Byte) | Write-Output
                break
            }

            'UsingDecimal' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Decimal' to buffer"
                $Buffer.Insert(0, $Decimal) | Write-Output
                break
            }

            'UsingDouble' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Double' to buffer"
                $Buffer.Insert(0, $Double) | Write-Output
                break
            }

            'UsingFloat' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Float' to buffer"
                $Buffer.Insert(0, $Float) | Write-Output
                break
            }

            'UsingInteger' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Int32' to buffer"
                $Buffer.Insert(0, $Integer) | Write-Output
                break
            }

            'UsingLong' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Int64' to buffer"
                $Buffer.Insert(0, $Long) | Write-Output
                break
            }

            'UsingShort' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Int16' to buffer"
                $Buffer.Insert(0, $Short) | Write-Output
                break
            }

            'UsingSignedByte' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Signed Byte' to buffer"
                $Buffer.Insert(0, $SignedByte) | Write-Output
                break
            }

            'UsingString' {
                Write-Verbose -Message "$($CmdletName) : Prepending string 'Value' to buffer"
                $Buffer.Insert(0, $Value) | Write-Output
                break
            }

            'UsingUnsigned' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'UInt32' to buffer"
                $Buffer.Insert(0, $Unsigned) | Write-Output
                break
            }

            'UsingUnsignedLong' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'UInt64' to buffer"
                $Buffer.Insert(0, $UnsignedLong) | Write-Output
                break
            }

            'UsingUnsignedShort' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'UInt16' to buffer"
                $Buffer.Insert(0, $UnsignedShort) | Write-Output
                break
            }

            'UsingCharacter' {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Character' to buffer"
                $Buffer.Insert(0, $Character) | Write-Output
                break
            }

            default {
                Write-Verbose -Message "$($CmdletName) : Prepending 'Input Object' to buffer"
                $Buffer.Insert(0, $InputObject) | Write-Output
                break
            }
        }
    }
}

<#
    Add-End
#>
function Add-End {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingCharArray')]
        [char[]]
        $Array,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingByte')]
        [byte]
        $Byte,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingCharacter')]
        [char]
        $Character,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDecimal')]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingDouble')]
        [double]
        $Double,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFloat')]
        [float]
        $Float,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingObject')]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingInteger')]
        [int32]
        $Integer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLong')]
        [int64]
        $Long,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingShort')]
        [int16]
        $Short,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingSignedByte')]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingString')]
        [string]
        $Value,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsigned')]
        [uint32]
        $Unsigned,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedLong')]
        [uint64]
        $UnsignedLong,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingUnsignedShort')]
        [uint16]
        $UnsignedShort,

        [switch]
        $NewLine
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName) : Appending to buffer '$($PSCmdlet.ParameterSetName)'"

        switch ($PSCmdlet.ParameterSetName) {
            'UsingArray' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Array' to buffer"
                $Buffer.Append($Array) | Write-Output
                break
            }

            'UsingBoolean' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Boolean' to buffer"
                $Buffer.Append($Boolean) | Write-Output
                break
            }

            'UsingByte' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Byte' to buffer"
                $Buffer.Append($Byte) | Write-Output
                break
            }

            'UsingDecimal' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Decimal' to buffer"
                $Buffer.Append($Decimal) | Write-Output
                break
            }

            'UsingDouble' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Double' to buffer"
                $Buffer.Append($Double) | Write-Output
                break
            }

            'UsingFloat' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Float' to buffer"
                $Buffer.Append($Float) | Write-Output
                break
            }

            'UsingInteger' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Int32' to buffer"
                $Buffer.Append($Integer) | Write-Output
                break
            }

            'UsingLong' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Int64' to buffer"
                $Buffer.Append($Long) | Write-Output
                break
            }

            'UsingShort' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Int16' to buffer"
                $Buffer.Append($Short) | Write-Output
                break
            }

            'UsingSignedByte' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Signed Byte' to buffer"
                $Buffer.Append($SignedByte) | Write-Output
                break
            }

            'UsingString' {
                Write-Verbose -Message "$($CmdletName) : Appending string 'Value' to buffer"
                $Buffer.Append($Value) | Write-Output
                break
            }

            'UsingUnsigned' {
                Write-Verbose -Message "$($CmdletName) : Appending 'UInt32' to buffer"
                $Buffer.Append($Unsigned) | Write-Output
                break
            }

            'UsingUnsignedLong' {
                Write-Verbose -Message "$($CmdletName) : Appending 'UInt64' to buffer"
                $Buffer.Append($UnsignedLong) | Write-Output
                break
            }

            'UsingUnsignedShort' {
                Write-Verbose -Message "$($CmdletName) : Appending 'UInt16' to buffer"
                $Buffer.Append($UnsignedShort) | Write-Output
                break
            }

            'UsingCharacter' {
                Write-Verbose -Message "$($CmdletName) : Appending 'Character' to buffer"
                $Buffer.Append($Character) | Write-Output
                break
            }

            default {
                Write-Verbose -Message "$($CmdletName) : Appending 'Input Object' to buffer"
                $Buffer.Append($InputObject) | Write-Output
                break
            }
        }

        if ($NewLine.IsPresent) {
            $Buffer.AppendLine() | Write-Output
        }
    }
}

<#
New-Alias -Name Add-AltDirectorySeparator -Value (Add-End -Buffer $Buffer -Character ([System.IO.Path]::AltDirectorySeparatorChar))

New-Alias -Name Add-Alternation -Value (Add-End -Buffer $Buffer -Character '|')

New-Alias -Name Add-Asterisk -Value (Add-End -Buffer $Buffer -Character '*')

New-Alias -Name Add-Backspace -Value (Add-End -Buffer $Buffer -Character '`b')

New-Alias -Name Add-BeginString -Value (Add-End -Buffer $Buffer -Character '^')

New-Alias -Name Add-Bell -Value (Add-End -Buffer $Buffer -Character '`a')

New-Alias -Name Add-CarriageReturn -Value (Add-End -Buffer $Buffer -Character "`r")

New-Alias -Name Add-Colon -Value (Add-End -Buffer $Buffer -Character ':')

New-Alias -Name Add-CurrencyGroupSeparator -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.CurrencyGroupSeparator)

New-Alias -Name Add-CurrencySymbol -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.CurrencySymbol)

New-Alias -Name Add-Dash -Value (Add-End -Buffer $Buffer -Character '-')

New-Alias -Name Add-DirectorySeparator -Value (Add-End -Buffer $Buffer -Character ([System.IO.Path]::DirectorySeparatorChar))

New-Alias -Name Add-EmDash -Value (Add-End -Buffer $Buffer -Value '--')

New-Alias -Name Add-EndLine -Value (Add-End -Buffer $Buffer -Value [System.Envrionment]::NewLine)

New-Alias -Name Add-EndString -Value (Add-End -Buffer $Buffer -Character '$')

New-Alias -Name Add-Escape -Value (Add-End -Buffer $Buffer -Character '`e')

New-Alias -Name Add-FormFeed -Value (Add-End -Buffer $Buffer -Character [char]12)

New-Alias -Name Add-HorizontalTab -Value (Add-End -Buffer $Buffer -Character '`t')

New-Alias -Name Add-ListSeparator -Value (Add-End -Buffer $Buffer -Value [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ListSeparator)

New-Alias -Name Add-MatchAnyAscii -Value (Add-End -Buffer $Buffer -Value '[:ascii:]')

New-Alias -Name Add-MatchAnyBlank -Value (Add-End -Buffer $Buffer -Value '[:blank:]')

New-Alias -Name Add-MatchAnyControl -Value (Add-End -Buffer $Buffer -Value '[:cntrl:]')

New-Alias -Name Add-MatchAnyDigit -Value (Add-End -Buffer $Buffer -Value '\d')

New-Alias -Name Add-MatchAnyDigit2 -Value (Add-End -Buffer $Buffer -Value '[:digit:]')

New-Alias -Name Add-MatchAnyGraph -Value (Add-End -Buffer $Buffer -Value '[:graph:]')

New-Alias -Name Add-MatchAnyHexDigit -Value (Add-End -Buffer $Buffer -Value '[:xdigit:]')

New-Alias -Name Add-MatchAnyLetter -Value (Add-End -Buffer $Buffer -Value '[:alpha:]')

New-Alias -Name Add-MatchAnyLetterOrDigit -Value (Add-End -Buffer $Buffer -Value '[:alnum:]')

New-Alias -Name Add-MatchAnyLowercaseLetter -Value (Add-End -Buffer $Buffer -Value '[:lower:]')

New-Alias -Name Add-MatchAnyNonDigit -Value (Add-End -Buffer $Buffer -Value '\D')

New-Alias -Name Add-MatchAnyNonWhiteSpace -Value (Add-End -Buffer $Buffer -Value '\S')

New-Alias -Name Add-MatchAnyNonWord -Value (Add-End -Buffer $Buffer -Value '\W')

New-Alias -Name Add-MatchAnyNonWordBoundary -Value (Add-End -Buffer $Buffer -Value '\B')

New-Alias -Name Add-MatchAnyPrintable -Value (Add-End -Buffer $Buffer -Value '[:print:]')

New-Alias -Name Add-MatchAnyPunctuation -Value (Add-End -Buffer $Buffer -Value '[:punct:]')

New-Alias -Name Add-MatchAnyUppercaseLetter -Value (Add-End -Buffer $Buffer -Value '[:upper:]')

New-Alias -Name Add-MatchAnyWhitespace -Value (Add-End -Buffer $Buffer -Value '[:space:]')

New-Alias -Name Add-MatchAnyWord -Value (Add-End -Buffer $Buffer -Value '\w')

New-Alias -Name Add-MatchAnyWord2 -Value (Add-End -Buffer $Buffer -Value '[:word:]')

New-Alias -Name Add-MatchAnyWordBoundary -Value (Add-End -Buffer $Buffer -Value '\b')

New-Alias -Name Add-MatchAnyWhiteSpace -Value (Add-End -Buffer $Buffer -Value '\s')

New-Alias -Name Add-MatchOneCharacter -Value (Add-End -Buffer $Buffer -Character '.')

New-Alias -Name Add-MatchOneOrMoreOccurrences -Value (Add-End -Buffer $Buffer -Character '+')

New-Alias -Name Add-MatchZeroOrMoreOccurrences -Value (Add-End -Buffer $Buffer -Character '*')

New-Alias -Name Add-MatchZeroOrOneOccurrences -Value (Add-End -Buffer $Buffer -Character '?')

New-Alias -Name Add-NanSymbol -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.NaNSymbol)

New-Alias -Name Add-NegativeSign -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.NegativeSign)

New-Alias -Name Add-NegativeInfinitySymbol -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.NegativeInfinitySymbol)

New-Alias -Name Add-NewLine -Value (Add-End -Buffer $Buffer -Value [Environment]::NewLine)

New-Alias -Name Add-Null -Value (Add-End -Buffer $Buffer -Character [char]0)

New-Alias -Name Add-NumberDecimalSeparator -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.NumberDecimalSeparator)

New-Alias -Name Add-NumberGroupSeparator -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.NumberGroupSeparator)

New-Alias -Name Add-PathSeparator -Value (Add-End -Buffer $Buffer -Character ([System.IO.Path]::PathSeparator))

New-Alias -Name Add-PercentDecimalSeparator -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.PercentDecimalSeparator)

New-Alias -Name Add-PercentGroupSeparator -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.PercentGroupSeparator)

New-Alias -Name Add-PercentSymbol -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.PercentSymbol)

New-Alias -Name Add-PerMilleSymbol -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.PerMilleSymbol)

New-Alias -Name Add-PostiveInfinitySymbol -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.PositiveInfinitySymbol)

New-Alias -Name Add-PostiveSign -Value (Add-End -Buffer $Buffer -Character [System.Globalization.CultureInfo]::CurrentCulture.NumberFormat.PositiveSign)

New-Alias -Name Add-Plus -Value (Add-End -Buffer $Buffer -Character '+')

New-Alias -Name Add-QuestionMark -Value (Add-End -Buffer $Buffer -Character '?')

New-Alias -Name Add-SemiColon -Value (Add-End -Buffer $Buffer -Character ';')

New-Alias -Name Add-Tab -Value (Add-End -Buffer $Buffer -Character '`t')

New-Alias -Name Add-Tilde -Value (Add-End -Buffer $Buffer -Character '~')

New-Alias -Name Add-Underscore -Value (Add-End -Buffer $Buffer -Character '_')

New-Alias -Name Add-VerticalTab -Value (Add-End -Buffer $Buffer -Character [char]11)

New-Alias -Name Add-VolumeSeparator -Value (Add-End -Buffer $Buffer -Character ([System.IO.Path]::VolumeSeparatorChar))
#>

<#
    Clear-Buffer
#>
function Clear-Buffer {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess("Clear Parameter 'Buffer'", $CmdletName)) {
            $Buffer.Clear()
        }
    }
}

<#
    Close-Buffer
#>
function Close-Buffer {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess("Disposing Parameter 'Buffer'", $CmdletName)) {
            Clear-Buffer -Buffer $Buffer
            $Buffer = $null
        }
    }
}

<#
    ConvertTo-String
#>
function ConvertTo-String {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory, ParameterSetName = 'UsingSubstring')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Start,

        [Parameter(Mandatory, ParameterSetName = 'UsingSubstring')]
        [ValidateRange(1, 2147483647)]
        [int]
        $Length
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        if ($PSCmdlet.ParameterSetName -eq 'UsingSubstring') {
            Confirm-ArgumentInRange -Parameter 'Start' -Index $Start -Minimum 0 -Maximum $Buffer.Length -HalfInclusive
            Confirm-ArgumentInRange -Parameter 'Length' -Index $Length -Minimum 1 -Maximum ($Buffer.Length - $Start)
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingSubstring') {
            $Buffer.ToString($Start, $Length) | Write-Output
        }
        else {
            $Buffer.ToString() | Write-Output
        }
    }
}

<#
    Edit-Buffer
#>
function Edit-Buffer {
    [CmdletBinding(DefaultParameterSetName = 'UsingObject')]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCharArray')]
        [char[]]
        $Array,

        [Parameter(Mandatory, ParameterSetName = 'UsingBoolean')]
        [bool]
        $Boolean,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory, ParameterSetName = 'UsingByte')]
        [byte]
        $Byte,

        [Parameter(Mandatory, ParameterSetName = 'UsingCharacter')]
        [char]
        $Character,

        [Parameter(Mandatory, ParameterSetName = 'UsingDecimal')]
        [decimal]
        $Decimal,

        [Parameter(Mandatory, ParameterSetName = 'UsingDouble')]
        [double]
        $Double,

        [Parameter(Mandatory, ParameterSetName = 'UsingFloat')]
        [float]
        $Float,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Index,

        [Parameter(Mandatory, ParameterSetName = 'UsingObject')]
        [System.Object]
        $InputObject,

        [Parameter(Mandatory, ParameterSetName = 'UsingInteger')]
        [int32]
        $Integer,

        [Parameter(Mandatory, ParameterSetName = 'UsingLong')]
        [int64]
        $Long,

        [Parameter(Mandatory, ParameterSetName = 'UsingShort')]
        [int16]
        $Short,

        [Parameter(Mandatory, ParameterSetName = 'UsingSignedByte')]
        [sbyte]
        $SignedByte,

        [Parameter(Mandatory, ParameterSetName = 'UsingUnsigned')]
        [uint32]
        $Unsigned,

        [Parameter(Mandatory, ParameterSetName = 'UsingUnsignedLong')]
        [uint64]
        $UnsignedLong,

        [Parameter(Mandatory, ParameterSetName = 'UsingUnsignedShort')]
        [uint16]
        $UnsignedShort,

        [Parameter(Mandatory, ParameterSetName = 'UsingString')]
        [string]
        $Value
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Confirm-ArgumentInRange -Parameter 'Index' -Index $Index -Minimum 0 -Maximum $Buffer.Length -HalfInclusive
    }

    PROCESS {
        Write-Verbose -Message "$($CmdletName) : Inserting '$($PSCmdlet.ParameterSetName)' into buffer at index '$($Index)'"

        switch ($PSCmdlet.ParameterSetName) {
            'UsingArray' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Array' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Array) | Write-Output
                break
            }

            'UsingBoolean' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Boolean' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Boolean) | Write-Output
                break
            }

            'UsingByte' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Byte' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Byte) | Write-Output
                break
            }

            'UsingCharacter' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Character' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Character) | Write-Output
                break
            }

            'UsingDecimal' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Decimal' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Decimal) | Write-Output
                break
            }

            'UsingDouble' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Double' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Double) | Write-Output
                break
            }

            'UsingFloat' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Float' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Float) | Write-Output
                break
            }

            'UsingInteger' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Int32' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Integer) | Write-Output
                break
            }

            'UsingLong' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Int64' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Long) | Write-Output
                break
            }

            'UsingShort' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Int16' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Short) | Write-Output
                break
            }

            'UsingSignedByte' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Signed Byte' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $SignedByte) | Write-Output
                break
            }

            'UsingUnsigned' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'UInt32' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Unsigned) | Write-Output
                break
            }

            'UsingUnsignedLong' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'UInt64' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $UnsignedLong) | Write-Output
                break
            }

            'UsingUnsignedShort' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'UInt16' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $UnsignedShort) | Write-Output
                break
            }

            'UsingString' {
                Write-Verbose -Message "$($CmdletName) : Inserting 'String' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $Value) | Write-Output
                break
            }

            default {
                Write-Verbose -Message "$($CmdletName) : Inserting 'Input Object' into buffer at index '$($Index)'"
                $Buffer.Insert($Index, $InputObject) | Write-Output
                break
            }
        }
    }
}

<#
    Find-Replace
#>
function Find-Replace {
    [CmdletBinding(DefaultParameterSetName = 'UsingString', SupportsShouldProcess)]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory, ParameterSetName = 'UsingChar')]
        [char]
        $Search,

        [Parameter(Mandatory, ParameterSetName = 'UsingChar')]
        [char]
        $Replace,

        [Parameter(Mandatory, ParameterSetName = 'UsingString')]
        [string]
        $Target,

        [Parameter(Mandatory, ParameterSetName = 'UsingString')]
        [string]
        $Value
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingChar') {
            if ($PSCmdlet.ShouldProcess("Replace '$($Search)' with '$($Replace)'", $CmdletName)) {
                $Buffer.Replace($Search, $Replace) | Write-Output
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess("Replace '$($Target)' with '$($Value)'", $CmdletName)) {
                $Buffer.Replace($Target, $Value) | Write-Output
            }
        }
    }
}

<#
    Format-End
#>
function Format-End {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Format,

        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $ArgumentList,

        [IFormatProvider]
        [AllowNull()]
        $FormatProvider = [System.Globalization.CultureInfo]::CurrentCulture,

        [switch]
        $NewLine
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        if ($null -eq $FormatProvider) {
            $FormatProvider = [String.Globalization.CultureInfo]::InvariantCulture
        }
    }

    PROCESS {
        if ($PSCmdlet.ShouldProcess("Format to 'Buffer' using 'Format', 'ArgumentList', 'FormatProvider', and 'NewLine'", $CmdletName)) {
            if ((Test-PSParameter -Name 'ArgumentList' -Parameters $PSBoundParameters) -and ($null -ne $ArgumentList) -and ($ArgumentList.Count -gt 0)) {
                $Buffer.AppendFormat($FormatProvider, $Format, $ArgumentList)
            }
            else {
                $Buffer.Append($Format)
            }

            if ($NewLine.IsPresent) {
                $Buffer.AppendLine() | Write-Output
            }
            else {
                $Buffer | Write-Output
            }
        }
    }
}

<#
    Get-Character
#>
function Get-Character {
    [CmdletBinding()]
    [OutputType([char])]
    param (
        [Parameter(Mandatory)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        $Index
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Confirm-ArgumentInRange -Parameter 'Index' -Index $Index -Minimum 0 -Maximum $Buffer.Length -HalfInclusive
    $Buffer[$Index] | Write-Output
}

function Join-AppendString {
    [CmdletBinding(DefaultParameterSetName = 'UsingValues')]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory)]
        [AllowEmpty()]
        [string]
        $Separator,

        [Parameter(Mandatory, ParameterSetName = 'UsingValues')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Values,

        [Parameter(Mandatory, ParameterSetName = 'UsingObjects')]
        [ValidateNotNullOrEmpty()]
        [object[]]
        $Objects
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingObjects') {
            $Buffer.AppendJoin($Separator, $Objects) | Write-Output
        }
        else {
            $Buffer.AppendJoin($Separator, $Values) | Write-Output
        }
    }
}

<#
    New-StringBuilder
#>
function New-StringBuilder {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Text.StringBuilder])]
    param (
        [ValidateRange(0, 2147483647)]
        [int]
        $Capacity,

        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ((Test-PSParameter -Name 'Capacity' -Parameters $PSBoundParameters) -and (Test-PSParameter -Name 'Value' -Parameters $PSBoundParameters)) {
        if ($PSCmdlet.ShouldProcess(@($Value, $Capacity), $CmdletName)) {
            [System.Text.StringBuilder]::new($Value, $Capacity) | Write-Output
        }
    }
    elseif (Test-PSParameter -Name 'Capacity' -Parameters $PSBoundParameters) {
        if ($PSCmdlet.ShouldProcess($Capacity, $CmdletName)) {
            [System.Text.StringBuilder]::new($Capacity) | Write-Output
        }
    }
    elseif (Test-PSParameter -Name 'Value' -Parameters $PSBoundParameters) {
        if ($PSCmdlet.ShouldProcess($Value, $CmdletName)) {
            [System.Text.StringBuilder]::new($Value) | Write-Output
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess('Default', $CmdletName)) {
            [System.Text.StringBuilder]::new() | Write-Output
        }
    }
}

<#
    Remove-Substring
#>
function Remove-Substring {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory)]
        [System.Text.StringBuilder]
        $Buffer,

        [ValidateRange(0, 2147483647)]
        [int]
        $Start,

        [ValidateRange(1, 2147483647)]
        [int]
        $Length
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Confirm-ArgumentInRange -Parameter 'Start' -Index $Start -Minimum 0 -Maximum $Buffer.Length -HalfInclusive
    Confirm-ArgumentInRange -Parameter 'Length' -Index $Length -Minimum 1 -Maximum ($Buffer.Length - $Start)

    if ($PSCmdlet.ShouldProcess("Remove substring from 'Buffer' at index '$($Start)' with length '$($Length)'", $CmdletName)) {
        $Buffer.Remove($Start, $Length) | Write-Output
    }
}

<#
    Set-Character
#>
function Set-Character {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Text.StringBuilder])]
    param (
        [Parameter(Mandatory)]
        [System.Text.StringBuilder]
        $Buffer,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        $Index,

        [Parameter(Mandatory)]
        [char]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    Confirm-ArgumentInRange -Parameter 'Index' -Index $Index -Minimum 0 -Maximum $Buffer.Length -HalfInclusive

    if ($Value, $CmdletName) {
        $Buffer[$Index] = $Value
    }

    if ($PSCmdlet.ShouldProcess("", $CmdletName)) {
        $Buffer | Write-Output
    }
}
