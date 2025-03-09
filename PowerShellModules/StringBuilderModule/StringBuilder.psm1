<#
 =============================================================================
<copyright file="StringBuilder.psm1" company="John Merryweather Cooper">
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
<date>Created:  2025-2-3</date>
<summary>
This file "StringBuilder.psm1" is part of "StringBuilderModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -Module ErrorRecordModule
#requires -Module PowerShellModule
#requires -Module TypeAcceleratorModule

<#
    .SYNOPSIS
    This class is a wrapper for the System.Text.StringBuilder class.

    .DESCRIPTION
    `StringBuilder` is a class that wraps the System.Text.StringBuilder class.  It provides a more PowerShell-friendly interface to the StringBuilder class.

    .EXAMPLE
    PS> using module StringBuilder
    PS> $sb = [System.Text.StringBuilder]::new()
    PS> $sb.Append("Hello, ")
    PS> $sb.Append("World!")
    PS> Write-Information -MessageData $sb.ToString() -InformationAction Continue

    Hello, World!

    .NOTES
    Copyright © 2022-2025, John Merryweather Cooper.  All Rigths Reserved.

    .LINK
    about_Classes

    .LINK
    about_Classes_Properties
#>
class StringBuilder {
    <#
        Public Properties
    #>
    [string]$ClassName = ([type]'System.Text.StringBuilder').Name
    [int]$MaxCapacity = [int]::MaxValue

    <#
        Hidden Properties
    #>
    [ValidateRange(0, 2147483647)]
    hidden [int]$DefaultCapacity = 16

    hidden [System.Text.StringBuilder]$Instance

    [ValidateSet('SilentlyContinue', 'Stop', 'Continue', 'Inquire', 'Ignore', 'Suspend', 'Break')]
    hidden [string]$LogToConsole = 'Continue'

    <#
        Public Script or Note Properties
    #>
    [hashtable[]]$PropertyDefinitions = @(
        @{
            MemberType  = 'ScriptProperty'
            MemberName  = 'PSCapacity'
            Value       = { $this.Instance.Capacity }
            SecondValue = {
                $proposedValue = $args[0]

                if ($proposedValue -is [int]) {
                    if ([int]$proposedValue -lt 0 -or [int]$proposedValue -gt [int]::MaxValue) {
                        throw [System.ArgumentOutOfRangeException]::new('args[0]', $args[0], "PSCapacity must be between 0 and $([int]::MaxValue)")
                    }
                    else {
                        $this.Instance.Capacity = [int]$proposedValue
                    }
                }
                else {
                    throw [System.ArgumentException]::new('PSCapacity must be an integer', 'args[0]')
                }
            }
        },

        @{
            MemberType  = 'ScriptProperty'
            MemberName  = 'PSLength'
            Value       = { $this.Instance.Length }
            SecondValue = {
                $proposedValue = $args[0]

                if ($proposedValue -is [int]) {
                    if ([int]$proposedValue -lt 0 -or [int]$proposedValue -gt [int]::MaxValue) {
                        throw [System.ArgumentOutOfRangeException]::new('args[0]', $args[0], "PSLength must be between 0 and $([int]::MaxValue)")
                    }
                    else {
                        $this.Instance.Length = [int]$proposedValue
                    }
                }
                else {
                    throw [System.ArgumentException]::new('PSLength must be an integer', 'args[0]')
                }
            }
        }
    )

    <#
        Constructors
    #>
    StringBuilder() {
        Write-Information -MessageData 'StringBuilder : Default Constructor' -InformationAction $this.LogToConsole

        $initializeSplat = @{
            Capacity = $this.DefaultCapacity  # recommended default capacity for performance
            Length   = 0
        }

        $this.Instance = [System.Text.StringBuilder]::new($initializeSplat['Capacity'])
        $this.Initialize($initializeSplat)
    }

    StringBuilder([int]$capacity) {
        Write-Information -MessageData 'StringBuilder : Capacity Constructor' -InformationAction $this.LogToConsole

        $initializeSplat = @{
            Capacity = [Math]::Max($capacity, $this.DefaultCapacity)
            Length   = 0
        }

        $this.Instance = [System.Text.StringBuilder]::new($capacity)
        $this.Initialize($initializeSplat)
    }

    StringBuilder([string]$value) {
        Write-Information -MessageData 'StringBuilder : Value Constructor' -InformationAction $this.LogToConsole

        $initializeSplat = @{
            Capacity = [Math]::Max($value.Length, $this.DefaultCapacity)
            Length   = $value.Length
        }

        $this.Instance = [System.Text.StringBuilder]::new($value)
        $this.Initialize($initializeSplat)
    }

    StringBuilder([string]$value, [int]$capacity) {
        Write-Information -MessageData 'StringBuilder : Value Capacity Constructor' -InformationAction $this.LogToConsole

        $initializeSplat = @{
            Capacity = [Math]::Max([Math]::Max($value.Length, $this.DefaultCapacity), $capacity)
            Length   = $value.Length
        }

        $this.Instance = [System.Text.StringBuilder]::new($value, $capacity)
        $this.Initialize($initializeSplat)
    }

    StringBuilder([string]$value, [int]$startIndex, [int]$length, [int]$capacity) {
        Write-Information -MessageData 'StringBuilder : Substring Constructor' -InformationAction $this.LogToConsole

        $subString = $value.Substring($startIndex, $length)

        $initializeSplat = @{
            Capacity = [Math]::Max([Math]::Max($subString.Length, $this.DefaultCapacity), $capacity)
            Length   = $subString.Length
        }

        $this.Instance = [System.Text.StringBuilder]::new($subString, $capacity)
        $this.Initialize($initializeSplat)
    }

    StringBuilder([hashtable]$properties) {
        Write-Information -MessageData 'StringBuilder : Hashtable Constructor' -InformationAction $this.LogToConsole

        $isValidCapacity = $properties.ContainsKey('Capacity') -and ($properties['Capacity'] -gt 0)
        $isValidValue = $properties.ContainsKey('Value') -and (-not [string]::IsNullOrEmpty($properties['Value']))
        $isValueCapacityConstructor = $isValidValue -and $isValidCapacity
        $isValidStartIndex = $properties.ContainsKey('StartIndex') -and ($properties['StartIndex'] -ge 0)
        $isValidCount = $properties.ContainsKey('Count') -and ($properties['Count'] -ge 1)
        $isSubstringConstructor = $isValueCapacityConstructor -and $isValidStartIndex -and $isValidCount

        if ($isSubstringConstructor) {
            Write-Information -MessageData 'StringBuilder : Hashtable Constructor Mode Substring' -InformationAction $this.LogToConsole
            $this.Instance = [System.Text.StringBuilder]::new($properties['Value'], $properties['StartIndex'], $properties['Count'], [Math]::Max($properties['Capacity'], $this.DefaultCapacity))
        }
        elseif ($isValueCapacityConstructor) {
            Write-Information -MessageData 'StringBuilder : Hashtable Constructor Mode Value Capacity' -InformationAction $this.LogToConsole
            $this.Instance = [System.Text.StringBuilder]::new($properties['Value'], [Math]::Max($properties['Capacity'], $this.DefaultCapacity))
        }
        elseif ($isValidValue) {
            Write-Information -MessageData 'StringBuilder : Hashtable Constructor Mode Value' -InformationAction $this.LogToConsole
            $this.Instance = [System.Text.StringBuilder]::new($properties['Value'], $this.DefaultCapacity)
        }
        elseif ($isValidCapacity) {
            Write-Information -MessageData 'StringBuilder : Hashtable Constructor Mode Capacity' -InformationAction $this.LogToConsole
            $this.Instance = [System.Text.StringBuilder]::new([Math]::Max($properties['Capacity'], $this.DefaultCapacity))
        }
        else {
            Write-Information -MessageData 'StringBuilder : Hashtable Constructor Mode Default' -InformationAction $this.LogToConsole
            $this.Instance = [System.Text.StringBuilder]::new($this.DefaultCapacity)
        }

        $this.Initialize($properties)
    }

    <#
        Hidden Methods
    #>

    <#
        .SYNPSIS
        Hidden common initializer for constructors.

        .DESCRIPTION
        `Initialize` is a hidden method that initializes the class properties.

        .PARAMETER Properties
        Specifies a [hashtable] of properties to initialize the class.  Only 'Capacity' and 'Length' are supported.

        .OUTPUTS
        None.  The `Initializer` returns nothing.

        .EXAMPLE
        PS> $properties @{Capacity = 100; Length = 50}
        PS> $this.Initialize($properties)

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    hidden [void] Initialize([hashtable]$properties) {
        # inline these as the static method are not available here
        $emptyInstance = ($null -ne $this.Instance) -and ($this.Instance.Length -lt 1)
        $isValidValue = $properties.ContainsKey('Value') -and (-not [string]::IsNullOrEmpty($properties['Value']))
        $isValidCapacity = $properties.ContainsKey('Capacity') -and ($properties['Capacity'] -gt 0)
        $isValidLength = $properties.ContainsKey('Length') -and ($properties['Length'] -ge 0) -and ($properties['Length'] -le $this.MaxCapacity)

        $properties.GetEnumerator() | ForEach-Object -Process {
            Write-Information -MessageData $_ -InformationAction $this.LogToConsole
        }

        if ($isValidCapacity -and $emptyInstance) {
            $this.Instance.Capacity = [Math]::Max($properties['Capacity'], $this.DefaultCapacity)
        }

        if ($isValidLength -and $emptyInstance) {
            $this.Instance.Length = $properties['Length']
        }

        if (Get-TypeData -TypeName $this.ClassName) {
            Remove-TypeData -TypeName $this.ClassName
        }

        foreach ($Definition in $this.PropertyDefinitions) {
            Update-TypeData -TypeName $this.ClassName @Definition -Force
        }
    }

    <#
        Public Methods
    #>

    <#
        .SYNPSIS
        Appends another [System.Text.StringBuilder] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` is a hidden method that initializes the class properties.

        .PARAMETER Value
        Specifies a [System.Text.StringBuilder] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [StringBuilder::("Source StringBuilder:  ")
        PS> $sb1 = [System.Text.StringBuilder]::new('This is a test.  It is only a test.')
        PS> $this.Append(1024)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Source StringBuilder:  This is a test.  It is only a test.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([System.Text.StringBuilder]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value.Instance)
    }

    <#
        .SYNPSIS
        Appends an unsigned short to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a unsigned short to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [UInt16] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [StringBuilder::("Unsigned Short:  ")
        PS> $this.Append([UInt16]1024)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Unsigned Short:  1024

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([UInt16]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends an unsigned integer to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a unsigned integer to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [UInt32] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [StringBuilder::("Unsigned Integer:  ")
        PS> $this.Append([UInt32]214748396)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Unsigned Short:  214748396

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([UInt32]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends an unsigned integer to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a unsigned integer to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [UInt32] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [StringBuilder::("Unsigned Integer:  ")
        PS> $this.Append(214748396)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Unsigned Short:  214748396

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([char]$value, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value, $count)
    }

    <#
        .SYNPSIS
        Appends a char[] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a character array to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [char[]] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Char Array:  ")
        PS> [char[]]$charArray = @('a', 'b', 'c', 'd', 'e')
        PS> $this.Append($charArray)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Character Array:  abcde

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([char[]]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value, $startIndex, $count)
    }

    <#
        .SYNPSIS
        Appends a string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [string] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("String:  ")
        PS> $this.Append('This a test.  It is only a test.')
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        String:  This is a test.  It is only a test.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a substring of a string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a substring of a string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [string] to append to the current [System.Text.StringBuilder].

        .PARAMETER StartIndex
        Specifies the start index of the substring to append.

        .PARAMETER Count
        Specifies the number of characters from the substring to append.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("String:  ")
        PS> $this.Append('This a test.  It is only a test.')
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        String:  This is a test.  It is only a test.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([string]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a substring of a [System.Text.StringBuilder] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a substring of a [System.Text.StringBuilder] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [System.Text.StringBuilder] to append to the current [System.Text.StringBuilder].

        .PARAMETER StartIndex
        Specifies the start index of the substring to append.

        .PARAMETER Count
        Specifies the number of characters from the substring to append.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("String:  ")
        PS> $sb1 = [System.Text.StringBuilder]::new('This a test.  It is only a test.')
        PS> $this.Append($sb1, 14, 18)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        String:  It is only a test.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([System.Text.StringBuilder]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value.Instance, $startIndex, $count)
    }

    <#
        .SYNPSIS
        Appends a [Single] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a [Single], also called a [float]--a four-byte floating point number--to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [Single] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("4-byte Floating Point:  ")
        PS> $this.Append([Single]1.234)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        4-byte Floating Point:  1.234

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([Single]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a [bool] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a [bool] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [bool] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Boolean:  ")
        PS> $this.Append($true)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Boolean:  True

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([bool]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a [byte] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends an unsigned [byte] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the unsigned [byte] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Byte:  ")
        PS> $this.Append([byte]254)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Byte:  254

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([byte]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a Unicode [char] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends an Unicode [char] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the Unicode [char] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Character:  ")
        PS> $this.Append('z')
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Character:  z

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a [char] array to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends an Unicode [char] array to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the Unicode [char] array to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Character Array:  ")
        PS> $this.Append(@('a', ' ', 'c', 'h', 'a', 'r', ' ', 'a', 'r', 'r', 'a', 'y'))
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Character Array:  a char array

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([char[]]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a [Decimal] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a [Decimal] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [Decimal] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Decimal:  ")
        PS> $this.Append([decimal]1.23)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Decimal:  1.23

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([Decimal]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a [Double] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a [Double] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [Double] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Double:  ")
        PS> $this.Append(1.23456e-7)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Double:  1.23456E-07

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([Double]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a [UInt64] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a [UInt64] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [UInt64] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Unsigned Long:  ")
        PS> $this.Append([UInt64]234765981)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Unsigned Long:  234765981

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([UInt64]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a signed [SByte] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a signed [SByte] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the signed [SByte] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Signed Byte:  ")
        PS> $this.Append([SByte]126)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Signed Byte:  126

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([SByte]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a signed [Int16] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a signed [Int16] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the signed [Int16] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Short:  ")
        PS> $this.Append([Int16]32766)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Short:  32766

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([Int16]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a signed [Int32] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a signed [Int32] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the signed [Int32] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Integer:  ")
        PS> $this.Append(66535)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Integer:  66535

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([Int32]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a signed [Int64] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends a signed [Int64] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the signed [Int64] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Long:  ")
        PS> $this.Append(99887766L)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Long:  99887766

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([Int64]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends an [object] to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Append` appends an [object] to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the [object] to append to the current [System.Text.StringBuilder].

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Object:  ")
        PS> $this.Append([object]32766)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Object:  32766

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Append([object]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value)
    }

    <#
        .SYNPSIS
        Appends a formatted string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendFormat` appends a formatted string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Format
        Specifies the format specifier string with exactly three specifiers.

        .PARAMETER FirstArg
        Specifies the first object to format.

        .PARAMETER SecondArg
        Specifies the second object to format.

        .PARAMETER ThirdArg
        Specifies the third object to format.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Formatted String:  ")
        PS> $this.AppendFormat('{0} : {1} - {2}', 'Name', 1, $true)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Formatted String:  Name : 1 - True

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendFormat([string]$format, [object]$firstArg, [object]$secondArg, [object]$thirdArg) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($format -f $firstArg, $secondArg, $thirdArg)
    }

    <#
        .SYNPSIS
        Appends a formatted string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendFormat` appends a formatted string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Format
        Specifies the format specifier string with exactly two specifiers.

        .PARAMETER FirstArg
        Specifies the first object to format.

        .PARAMETER SecondArg
        Specifies the second object to format.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Formatted String:  ")
        PS> $this.AppendFormat('{0} : {1}', 'Name', 1)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Formatted String:  Name : 1

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendFormat([string]$format, [object]$firstArg, [object]$secondArg) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($format -f $firstArg, $secondArg)
    }

    <#
        .SYNPSIS
        Appends a formatted string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendFormat` appends a formatted string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Format
        Specifies the format specifier string with as many specifiers as the length of `arguments`.

        .PARAMETER Arguments
        Specifies the array of objects to format.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Formatted String:  ")
        PS> $this.AppendFormat('{0} : {1} - {2} | {3}', @('Name', 1, $true, 0.99))
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Formatted String:  Name : 1 - True | 0.99

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendFormat([string]$format, [object[]]$arguments) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($format -f $arguments)
    }

    <#
        .SYNPSIS
        Appends a formatted string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendFormat` appends a formatted string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Format
        Specifies the format specifier string with exactly one specifiers.

        .PARAMETER FirstArg
        Specifies the first and only object to format.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Formatted String:  ")
        PS> $this.AppendFormat('{0}', 'Name')
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Formatted String:  Name

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendFormat([string]$format, [object]$firstArg) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($format -f $firstArg)
    }

    <#
        .SYNOPSIS
        Joins an array of strings with a separator and appends the resulting string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendJoin` joins an array of strings with a separator and appends the resulting string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Separator
        Specifies the string separator to use when joining the strings.

        .PARAMETER Values
        Specifies the array of strings to join.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Join:  ")
        PS> $this.AppendJoin(' ', @('This', 'is', 'a', 'test.'))
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Join:  This is a test.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendJoin([string]$separator, [string[]]$values) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.AppendJoin($separator, $values)
    }

    <#
        .SYNOPSIS
        Joins an array of objects with a separator and appends the resulting string to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendJoin` joins an array of objects with a separator and appends the resulting string to the current [System.Text.StringBuilder] instance.

        .PARAMETER Separator
        Specifies the string separator to use when joining the objects.

        .PARAMETER Values
        Specifies the array of objects to join.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Join:  ")
        PS> $this.AppendJoin(' ', @('This', 1, [Decimal]1.00, 1.23468e7))
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Join:  This 1 1.00 12346800

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendJoin([string]$separator, [object[]]$values) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.AppendJoin($separator, $values)
    }

    <#
        .SYNOPSIS
        Appends a system line terminator to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendLine` appends a system line terminator to the current [System.Text.StringBuilder] instance.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Line Terminator:  ")
        PS> $this.AppendLine()
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Line Terminator:

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendLine() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.AppendLine()
    }

    <#
        .SYNOPSIS
        Appends a string followed by a system line terminator to the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `AppendLine` appends a string followed by system line terminator to the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the string to append to the current [System.Text.StringBuilder] instance.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Line Terminator:  ")
        PS> $this.AppendLine("Hello, World!")
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Line Terminator:  Hello, World!

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]AppendLine([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Append($value).AppendLine()
    }

    <#
        .SYNOPSIS
        Clears the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Clear` clears the current [System.Text.StringBuilder] instance.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Clear:  ")
        PS> $this.Clear()
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Clear() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return $this.Instance.Clear()
        }
    }

    <#
        .SYNOPSIS
        Tests whether the current [System.Text.StringBuilder] instance contains the specified value for the given comparison type.

        .DESCRIPTION
        `Contains` tests whether the current [System.Text.StringBuilder] instance contains the specified value for the given comparison type.

        .PARAMETER Value
        Specifies the string to search the current [System.Text.StringBuilder] instance for.

        .PARAMETER ComparisonType
        Specifies the type of comparison to use when searching the current [System.Text.StringBuilder] instance.

        Allowed values are:

        * `CurrentCulture`              : Compare strings using the culture of the current thread.
        * `CurrentCultureIgnoreCase`    : Compare strings using the culture of the current thread, ignoring the case of the strings being compared.
        * `InvariantCulture`            : Compare strings using the invariant culture.
        * `InvariantCultureIgnoreCase`  : Compare strings using the invariant culture, ignoring the case of the strings being compared.
        * `Ordinal`                     : Compare strings using ordinal comparison.
        * `OrdinalIgnoreCase`           : Compare strings using ordinal comparison, ignoring the case of the strings being compared.

        .OUTPUTS
        [bool]  True if `value` is found in the current [System.Text.StringBuilder] instance; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Contains:  ")
        PS> $this.Append('This is a test.')
        PS> $this.Contains('test', [System.StringComparison]::OrdinalIgnoreCase)

        True

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]Contains([string]$value, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().Contains($value, $comparisonType)
        }
    }

    <#
        .SYNOPSIS
        Tests whether the current [System.Text.StringBuilder] instance contains the specified value for the given comparison type.

        .DESCRIPTION
        `Contains` tests whether the current [System.Text.StringBuilder] instance contains the specified value for the given comparison type.

        .PARAMETER Value
        Specifies the Unicode character to search the current [System.Text.StringBuilder] instance for.

        .PARAMETER ComparisonType
        Specifies the type of comparison to use when searching the current [System.Text.StringBuilder] instance.

        Allowed values are:

        * `CurrentCulture`              : Compare strings using the culture of the current thread.
        * `CurrentCultureIgnoreCase`    : Compare strings using the culture of the current thread, ignoring the case of the strings being compared.
        * `InvariantCulture`            : Compare strings using the invariant culture.
        * `InvariantCultureIgnoreCase`  : Compare strings using the invariant culture, ignoring the case of the strings being compared.
        * `Ordinal`                     : Compare strings using ordinal comparison.
        * `OrdinalIgnoreCase`           : Compare strings using ordinal comparison, ignoring the case of the strings being compared.

        .OUTPUTS
        [bool]  True if `value` is found in the current [System.Text.StringBuilder] instance; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Contains:  ")
        PS> $this.Append('This is a test.')
        PS> $this.Contains('x', [System.StringComparison]::OrdinalIgnoreCase)

        False

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]Contains([char]$value, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().Contains($value, $comparisonType)
        }
    }

    <#
        .SYNOPSIS
        Tests whether the current [System.Text.StringBuilder] instance contains the specified value for `OrdinalIgnoreCase`.

        .DESCRIPTION
        `Contains` tests whether the current [System.Text.StringBuilder] instance contains the specified value for the given comparison type.

        .PARAMETER Value
        Specifies the Unicode character to search the current [System.Text.StringBuilder] instance for.

        .OUTPUTS
        [bool]  True if `value` is found in the current [System.Text.StringBuilder] instance; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Contains:  ")
        PS> $this.Append('This is a test.')
        PS> $this.Contains('x')

        False

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]Contains([char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().Contains($value, [System.StringComparison]::OrdinalIgnoreCase)
        }
    }

    <#
        .SYNOPSIS
        Tests whether the current [System.Text.StringBuilder] instance contains the specified value for `CurrentCultureIgnoreCase`.

        .DESCRIPTION
        `Contains` tests whether the current [System.Text.StringBuilder] instance contains the specified value for the given comparison type.

        .PARAMETER Value
        Specifies the string to search the current [System.Text.StringBuilder] instance for.

        .OUTPUTS
        [bool]  True if `value` is found in the current [System.Text.StringBuilder] instance; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Contains:  ")
        PS> $this.Append('This is a test.')
        PS> $this.Contains('test', [System.StringComparison]::OrdinalIgnoreCase)

        True

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]Contains([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().Contains($value, [System.StringComparison]::CurrentCultureIgnoreCase)
        }
    }

    <#
        .SYNOPSIS
        Copies the current [System.Text.StringBuilder] instance starting at `sourceIndex` to a character array starting at
        `destinationIndex` for `count` characters.

        .DESCRIPTION
        `CopyTo` copies the current [System.Text.StringBuilder] instance starting at `sourceIndex` to a character array starting at
        `destinationIndex` for `count` characters.

        .PARAMETER SourceIndex
        Specifies the index in the current [System.Text.StringBuilder] instance at which to start copying.

        .PARAMETER Destination
        Specifies the character array to copy the current [System.Text.StringBuilder] instance to.

        .PARAMETER DestinationIndex
        Specifies the index in the character array at which to start copying.

        .PARAMETER Count
        Specifies the number of characters to copy.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Copy To:  ")
        PS> $this.Append('This is a test.')
        PS> $destination = New-Object -TypeName char[] -ArgumentList 10
        PS> $this.CopyTo(5, $destination, 0, 5)
        PS> Write-Information -MessageData $destination -InformationAction Continue

        Copy To:  is a

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]CopyTo([int]$sourceIndex, [char[]]$destination, [int]$destinationIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.CopyTo($sourceIndex, $destination, $destinationIndex, $count)
    }

    <#
        .SYNOPSIS
        Gets the character at the specified index in the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `ElementAt` gets the character at the specified index in the current [System.Text.StringBuilder] instance.

        .PARAMETER Index
        Specifies the index of the character to get.

        .OUTPUTS
        [char]  `ElementAt` returns the character at `Index`.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Element At:  ")
        PS> $this.Append('This is a test.')
        PS> $this.ElementAt(5)

        i

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.
    #>
    [char]ElementAt([int]$index) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [char]::MinValue
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance[$index]
    }

    <#
        .SYNOPSIS
        Tests the current [System.Text.StringBuilder] instance for whether it ends with the specified character value.

        .DESCRIPTION
        `EndsWith` tests the current [System.Text.StringBuilder] instance for whether it ends with the specified character value.

        .PARAMETER Value
        Specifies the character to test the current [System.Text.StringBuilder] instance for.

        .OUTPUTS
        [bool]  True if the current [System.Text.StringBuilder] instance ends with `value`; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Ends With:  ")
        PS> $this.Append('This is a test.')
        PS> $this.EndsWith('.')

        True
    #>
    [bool]EndsWith([char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().EndsWith($value)
        }
    }

    <#
        .SYNOPSIS
        Tests the current [System.Text.StringBuilder] instance for whether it ends with the specified character value
        using `CurrentCultureIgnoreCase`.

        .DESCRIPTION
        `EndsWith` tests the current [System.Text.StringBuilder] instance for whether it ends with the specified character value.

        .PARAMETER Value
        Specifies the string to test the current [System.Text.StringBuilder] instance for.

        .OUTPUTS
        [bool]  True if the current [System.Text.StringBuilder] instance ends with `value`; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Ends With:  ")
        PS> $this.Append('This is a test.')
        PS> $this.EndsWith("test?")

        False

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]EndsWith([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().EndsWith($value, [System.StringComparison]::CurrentCultureIgnoreCase)
        }
    }

    <#
        .SYNOPSIS
        Tests the current [System.Text.StringBuilder] instance for whether it ends with the specified character value
        using `CurrentCultureIgnoreCase`.

        .DESCRIPTION
        `EndsWith` tests the current [System.Text.StringBuilder] instance for whether it ends with the specified character value.

        .PARAMETER Value
        Specifies the string to test the current [System.Text.StringBuilder] instance for.

        .PARAMETER ComparisonType
        Specifies the type of comparison to use when searching the current [System.Text.StringBuilder] instance.

        Allowed values are:

        * `CurrentCulture`              : Compare strings using the culture of the current thread.
        * `CurrentCultureIgnoreCase`    : Compare strings using the culture of the current thread, ignoring the case of the strings being compared.
        * `InvariantCulture`            : Compare strings using the invariant culture.
        * `InvariantCultureIgnoreCase`  : Compare strings using the invariant culture, ignoring the case of the strings being compared.
        * `Ordinal`                     : Compare strings using ordinal comparison.
        * `OrdinalIgnoreCase`           : Compare strings using ordinal comparison, ignoring the case of the strings being compared.

        .OUTPUTS
        [bool]  True if the current [System.Text.StringBuilder] instance ends with `value`; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Ends With:  ")
        PS> $this.Append('This is a test.')
        PS> $this.EndsWith("test?")

        False

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]EndsWith([string]$value, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().EndsWith($value, $comparisonType)
        }
    }

    <#
        .SYNOPSIS
        Ensures that the capacity of the current [System.Text.StringBuilder] instance is at least the specified value.

        .DESCRIPTION
        `EnsureCapacity` ensures that the capacity of the current [System.Text.StringBuilder] instance is at least the specified value.

        .PARAMETER Capacity
        Specifies the minimum capacity to ensure.

        .OUTPUTS
        [int]  The new capacity of the current [System.Text.StringBuilder] instance.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Ensure Capacity:  ")
        PS> $this.EnsureCapacity(100)
        PS> Write-Information -MessageData $this.Capacity -InformationAction Continue
        Ensure Capacity:  100

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [int]EnsureCapacity([int]$capacity) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.EnsureCapacity($capacity)
    }

    <#
        .SYNOPSIS
        Tests whether the current [System.Text.StringBuilder] instance is equal to the specified [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Equals` tests whether the current [System.Text.StringBuilder] instance is equal to the specified [System.Text.StringBuilder] instance.

        .PARAMETER Other
        Specifies the [System.Text.StringBuilder] instance to compare to the current [System.Text.StringBuilder] instance.

        .OUTPUTS
        [bool]  True if the current [System.Text.StringBuilder] instance is equal to `other`; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Equals:  ")
        PS> $this.Append('This is a test.')
        PS> $other = [System.Text.StringBuilder]::new('This is a test.')
        PS> $this.Equals($other)

        True

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]Equals([System.Text.StringBuilder]$other) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance) -and [StringBuilder]::IsNullOrEmpty($other)) {
            return $true
        }
        elseif ([StringBuilder]::IsNullOrEmpty($this.Instance) -xor [StringBuilder]::IsNullOrEmpty($other)) {
            return $false
        }
        else {
            return $this.Instance.Equals($other)
        }
    }

    <#
        .SYNOPSIS
        Tests whether the current [System.Text.StringBuilder] instance is equal to the specified string.

        .DESCRIPTION
        `Equals` tests whether the current [System.Text.StringBuilder] instance is equal to the specified [System.Text.StringBuilder] instance.

        .PARAMETER Other
        Specifies the string to compare to the current [System.Text.StringBuilder] instance.

        .OUTPUTS
        [bool]  True if the current [System.Text.StringBuilder] instance is equal to `other`; otherwise, false.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Equals:  ")
        PS> $this.Append('This is a test.')
        PS> $other = 'This is a test.'
        PS> $this.Equals($other)

        True

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [bool]Equals([string]$other) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance) -and [string]::IsNullOrEmpty($other)) {
            return $true
        }
        elseif ([StringBuilder]::IsNullOrEmpty($this.Instance) -xor [string]::IsNullOrEmpty($other)) {
            return $false
        }
        else {
            return $this.Instance.ToString().Equals($other)
        }
    }

    <#
        .SYNOPSIS
        Finds the first occurrence of the string `value` in a slice of the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `IndexOf` finds the first occurrence of the string `value` in a slice of current [System.Text.StringBuilder] instance.

        The slice starts at `StartIndex` and has a length of `Count`.

        .PARAMETER Value
        Specifies the string value to search the slice for.

        .PARAMETER StartIndex
        Specifies the start index in the current [System.Text.StringBuilder] instance to start the slice from.

        .PARAMETER Count
        Specifies the character count from `StartIndex` to take the slice from.

        .PARAMETER ComparisonType
        Specifies the type of comparison to use when searching the current [System.Text.StringBuilder] instance slice.

        Allowed values are:

        * `CurrentCulture`              : Compare strings using the culture of the current thread.
        * `CurrentCultureIgnoreCase`    : Compare strings using the culture of the current thread, ignoring the case of the strings being compared.
        * `InvariantCulture`            : Compare strings using the invariant culture.
        * `InvariantCultureIgnoreCase`  : Compare strings using the invariant culture, ignoring the case of the strings being compared.
        * `Ordinal`                     : Compare strings using ordinal comparison.
        * `OrdinalIgnoreCase`           : Compare strings using ordinal comparison, ignoring the case of the strings being compared.

        .OUTPUTS
        [int]  The zero-based index position of the first occurrence of `value` in the current [System.Text.StringBuilder]
        instance slice; or -1 if the `value` is not found in the slice.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Index Of:  ")
        PS> $this.Append('This is a test.')
        PS> $this.IndexOf('test', 0, 14, [System.StringComparison]::OrdinalIgnoreCase)

        -1

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [int]IndexOf([string]$value, [int]$startIndex, [int]$count, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString($startIndex, $count).IndexOf($value, $comparisonType)
        }
    }

    <#
        .SYNOPSIS
        Finds the first occurrence of the specified sub-string in the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `IndexOf` finds the first occurrence of the specified sub-string in the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the whole string to take a slice from.

        .PARAMETER StartIndex
        Specifies the start index in `Value` to start the sub-string from.

        .PARAMETER ComparisonType
        Specifies the type of comparison to use when searching the current [System.Text.StringBuilder] instance.

        Allowed values are:

        * `CurrentCulture`              : Compare strings using the culture of the current thread.
        * `CurrentCultureIgnoreCase`    : Compare strings using the culture of the current thread, ignoring the case of the strings being compared.
        * `InvariantCulture`            : Compare strings using the invariant culture.
        * `InvariantCultureIgnoreCase`  : Compare strings using the invariant culture, ignoring the case of the strings being compared.
        * `Ordinal`                     : Compare strings using ordinal comparison.
        * `OrdinalIgnoreCase`           : Compare strings using ordinal comparison, ignoring the case of the strings being compared.

        .OUTPUTS
        [int]  The zero-based index position of the first occurrence of the sub-string of `value` in the current [System.Text.StringBuilder]
        instance; or -1 if the sub-string of value is not found.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Index Of:  ")
        PS> $this.Append('This is a test.')
        PS> $this.IndexOf('test', 1, [System.StringComparison]::OrdinalIgnoreCase)

        22

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [int]IndexOf([string]$value, [int]$startIndex, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString($startIndex).IndexOf($value, $comparisonType)
        }
    }

    <#
        .SYNOPSIS
        Finds the first occurrence of the specified sub-string in the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `IndexOf` finds the first occurrence of the specified sub-string in the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the whole string to take a slice from.

        .PARAMETER ComparisonType
        Specifies the type of comparison to use when searching the current [System.Text.StringBuilder] instance.

        Allowed values are:

        * `CurrentCulture`              : Compare strings using the culture of the current thread.
        * `CurrentCultureIgnoreCase`    : Compare strings using the culture of the current thread, ignoring the case of the strings being compared.
        * `InvariantCulture`            : Compare strings using the invariant culture.
        * `InvariantCultureIgnoreCase`  : Compare strings using the invariant culture, ignoring the case of the strings being compared.
        * `Ordinal`                     : Compare strings using ordinal comparison.
        * `OrdinalIgnoreCase`           : Compare strings using ordinal comparison, ignoring the case of the strings being compared.

        .OUTPUTS
        [int]  The zero-based index position of the first occurrence of the sub-string of `value` in the current [System.Text.StringBuilder]
        instance; or -1 if the sub-string of value is not found.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Index Of:  ")
        PS> $this.Append('This is a test.')
        PS> $this.IndexOf('test', [System.StringComparison]::OrdinalIgnoreCase)

        21

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [int]IndexOf([string]$value, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().IndexOf($value, $comparisonType)
        }
    }

    <#
        .SYNOPSIS
        Finds the index of the first occurrence of the specified Unicode character in the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `IndexOf` finds the index of the first occurrence of the specified Unicode character in the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the Unicode character to search for.

        .PARAMETER ComparisonType
        Specifies the type of comparison to use when searching the current [System.Text.StringBuilder] instance.

        Allowed values are:

        * `CurrentCulture`              : Compare strings using the culture of the current thread.
        * `CurrentCultureIgnoreCase`    : Compare strings using the culture of the current thread, ignoring the case of the strings being compared.
        * `InvariantCulture`            : Compare strings using the invariant culture.
        * `InvariantCultureIgnoreCase`  : Compare strings using the invariant culture, ignoring the case of the strings being compared.
        * `Ordinal`                     : Compare strings using ordinal comparison.
        * `OrdinalIgnoreCase`           : Compare strings using ordinal comparison, ignoring the case of the strings being compared.

        .OUTPUTS
        [int]  The zero-based index position of the first occurrence of the Unicode character `value` in the current [System.Text.StringBuilder]
        instance; or -1 if the value is not found.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Index Of:  ")
        PS> $this.Append('This is a test.')
        PS> $this.IndexOf('s', [System.StringComparison]::OrdinalIgnoreCase)

        14

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [int]IndexOf([char]$value, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().IndexOf($value, $comparisonType)
        }
    }

    <#
        .SYNOPSIS
        Finds the first occurrence of the specified sub-string in the current [System.Text.StringBuilder] instance using `CurrentCultureIgnoreCase`.

        .DESCRIPTION
        `IndexOf` finds the first occurrence of the specified sub-string in the current [System.Text.StringBuilder] instance using
        `CurrentCultureIgnoreCase` as the string comparison type.

        .PARAMETER Value
        Specifies the whole string to take a slice from.

        .PARAMETER StartIndex
        Specifies the start index in `Value` to start the sub-string from.

        .PARAMETER Count
        Specifies the character count from `StartIndex` to take the sub-string from.

        .OUTPUTS
        [int]  The zero-based index position of the first occurrence of the sub-string of `value` in the current [System.Text.StringBuilder]
        instance; or -1 if the sub-string of value is not found.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Index Of:  ")
        PS> $this.Append('This is a test.')
        PS> $this.IndexOf('test', 0, 4)

        21

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [int]IndexOf([string]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString($startIndex, $count).IndexOf($value, [System.StringComparison]::CurrentCultureIgnoreCase)
        }
    }

    [int]IndexOf([char]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString($startIndex, $count).IndexOf($value)
        }
    }

    [int]IndexOf([char]$value, [int]$startIndex) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString($startIndex).IndexOf($value)
        }
    }

    <#
        .SYNOPSIS
        Finds the index of the first occurrence of the specified string in the current [System.Text.StringBuilder] instance using
        `CurrentCultureIgnoreCase`.

        .DESCRIPTION
        `IndexOf` finds the index of the first occurrence of the specified string in the current [System.Text.StringBuilder] instance.

        .PARAMETER Value
        Specifies the string to search for.

        .OUTPUTS
        [int]  The zero-based index position of the first occurrence of the Unicode character `value` in the current [System.Text.StringBuilder]
        instance; or -1 if the value is not found.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Index Of:  ")
        PS> $this.Append('This is a test.')
        PS> $this.IndexOf('test')

        21

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [int]IndexOf([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().IndexOf($value, [System.StringComparison]::CurrentCultureIgnoreCase)
        }
    }

    <#
        .SYNOPSIS
        Inserts a signed [SByte] value at the specified index in the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Inserts` a signed [SByte] value at the specified index in the current [System.Text.StringBuilder] instance.

        .PARAMETER Index
        Specifies the index in the current [System.Text.StringBuilder] instance at which to insert the value.

        .PARAMETER Value
        Specifies the signed [SByte] value to insert.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance with the value inserted at `index`.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Insert:  ")
        PS> $this.Append('This is a test.')
        PS> $this.Insert(5, [SByte]0x20)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Inser32t:  This  is a test.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Insert([int]$index, [SByte]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    <#
        .SYNOPSIS
        Inserts a slice of a character array at the specified index in the current [System.Text.StringBuilder] instance.

        .DESCRIPTION
        `Inserts` a slice of a character array at the specified index in the current [System.Text.StringBuilder] instance.

        .PARAMETER Index
        Specifies the index in the current [System.Text.StringBuilder] instance at which to insert the slice.

        .PARAMETER Value
        Specifies the character array to be sliced and inserted.

        .PARAMETER StartIndex
        Specifies the start index in `Value` to start the slice from.

        .PARAMETER Count
        Specifies the character count from `StartIndex` to take the slice from.

        .OUTPUTS
        [System.Text.StringBuilder]  The current [System.Text.StringBuilder] instance with the value inserted at `index`.

        .EXAMPLE
        PS> [System.Text.StringBuilder]::new("Insert:  ")
        PS> $this.Append('This is a test.')
        PS> $this.Insert(5, @('t', 'h', 'e', ' ', 'r', 'e', 'd', 'f', 'o', 'x'), 7, 3)
        PS> Write-Information -MessageData $this.ToString() -InformationAction Continue

        Inserfoxt:  This  is a test.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_Classes

        .LINK
        about_Classes_Properties
    #>
    [System.Text.StringBuilder]Insert([int]$index, [char[]]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value, $startIndex, $count)
    }

    [System.Text.StringBuilder]Insert([int]$index, [string]$value, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::LengthIsOutOfRange($count)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('count', $count, 'count is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $count
                TargetName    = 'count'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value, $count)
    }

    [System.Text.StringBuilder]Insert([int]$index, [UInt64]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [UInt32]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [UInt16]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [Single]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [Int16]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [Int64]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [Int32]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [object]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [Double]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [Decimal]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [char[]]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [byte]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [System.Text.StringBuilder]Insert([int]$index, [bool]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Insert($index, $value)
    }

    [int]LastIndexOf([char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().LastIndexOf($value)
        }
    }

    [int]LastIndexOf([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().LastIndexOf($value, [System.StringComparison]::CurrentCultureIgnoreCase)
        }
    }

    [int]LastIndexOf([char]$value, [int]$startIndex) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        elseif ([StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, [StringBuilder]::ComputeImpliedCount($this.Instance, $startIndex))) {
            return -1
        }
        else {
            return $this.ToString($startIndex).LastIndexOf($value, [System.StringComparison]::CurrentCulterIgnoreCase)
        }
    }

    [int]LastIndexOf([string]$value, [int]$startIndex) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        elseif ([StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, [StringBuilder]::ComputeImpliedCount($this.Instance, $startIndex))) {
            return -1
        }
        else {
            return $this.ToString($startIndex).LastIndexOf($value, [System.StringComparison]::CurrentCulterIgnoreCase)
        }
    }

    [int]LastIndexOf([string]$value, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().LastIndexOf($value, $comparisonType)
        }
    }

    [int]LastIndexOf([char]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        elseif ([StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $count)) {
            return -1
        }
        elseif ([StringBuilder]::CountIsOutOfRange($this.Instance, $startIndex, $count)) {
            return -1
        }
        else {
            return $this.ToString($startIndex, $count).LastIndexOf($value, [System.StringComparison]::CurrentCulterIgnoreCase)
        }
    }

    [int]LastIndexOf([string]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        elseif ([StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $count)) {
            return -1
        }
        elseif ([StringBuilder]::CountIsOutOfRange($this.Instance, $startIndex, $count)) {
            return -1
        }
        else {
            return $this.ToString($startIndex, $count).LastIndexOf($value, [System.StringComparison]::CurrentCulterIgnoreCase)
        }
    }

    [int]LastIndexOf([string]$value, [int]$startIndex, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().LastIndexOf($value, $startIndex, $comparisonType)
        }
    }

    [int]LastIndexOf([string]$value, [int]$startIndex, [int]$count, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return -1
        }
        else {
            return $this.ToString().LastIndexOf($value, $startIndex, $count, $comparisonType)
        }
    }

    [System.Text.StringBuilder]Prepend([SByte]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([char[]]$value, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::StartIndexIsOutOfRange($value, $startIndex, $count)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::CountIsOutOfRange($value, $startIndex, $count)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('count', $count, 'count is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $count
                TargetName    = 'count'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value.ToString().Substring($startIndex, $count))
        }
        else {
            return $this.Instance.Insert(0, $value, $startIndex, $count)
        }
    }

    [System.Text.StringBuilder]Prepend([string]$value, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value, $count)
        }
        else {
            return $this.Instance.Insert(0, $value, $count)
        }
    }

    [System.Text.StringBuilder]Prepend([UInt64]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([UInt32]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([UInt16]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([Single]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([Int16]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([Int64]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([Int32]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([object]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([Double]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([Decimal]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([char[]]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([byte]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Prepend([bool]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance)) {
            return $this.Append($value)
        }
        else {
            return $this.Instance.Insert(0, $value)
        }
    }

    [System.Text.StringBuilder]Remove([int]$startIndex, [int]$length) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }

        if ([StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $length)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::CountIsOutOfRange($this.Instance, $startIndex, $length)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('length', $length, 'length is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $length
                TargetName    = 'length'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Remove($startIndex, $length)
    }

    [System.Text.StringBuilder]Replace([char]$oldChar, [char]$newChar) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return $this.Instance.Replace($oldChar, $newChar)
        }
    }

    [System.Text.StringBuilder]Replace([string]$oldValue, [string]$newValue) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return $this.Instance.Replace($oldValue, $newValue)
        }
    }

    [System.Text.StringBuilder]Replace([char]$oldChar, [char]$newChar, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }

        if ([StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $count)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::CountIsOutOfRange($this.Instance, $startIndex, $count)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('count', $count, 'count is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $count
                TargetName    = 'count'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Replace($oldChar, $newChar, $startIndex, $count)
    }

    [System.Text.StringBuilder]Replace([string]$oldValue, [string]$newValue, [int]$startIndex, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }

        if ([StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $count)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::CountIsOutOfRange($this.Instance, $startIndex, $count)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('count', $count, 'count is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $count
                TargetName    = 'count'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.Replace($oldValue, $newValue, $startIndex, $count)
    }

    [System.Text.StringBuilder]ReplaceLineEndings() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().ReplaceLineEndings())
        }
    }

    [void]SetElementAt([int]$index, [char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Instance', 'Instance cannot be null or empty')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'InvalidData'
                TargetObject  = $this.Instance
                TargetName    = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ([StringBuilder]::IsEmpty($this.Instance) -and ($index -eq 0)) {
            this.Append($value) | Out-Null
        }

        if ([System.Text.StringBuilder]::IndexIsOutOfRange($this.Instance, $index)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('index', $index, 'index is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $index
                TargetName    = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        $this.Instance[$index] = $value
    }

    [System.Text.StringBuilder]Slice([int]$startIndex) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }

        if ([System.Text.StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, [System.Text.StringBuilder]::ComputeImpliedCount($this.Instance, $startIndex))) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return [System.Text.StringBuilder]::new($this.ToString($startIndex))
    }

    [System.Text.StringBuilder]Slice([int]$startIndex, [int]$length) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }

        if ([System.Text.StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $length)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex and/or length is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }
            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return [System.Text.StringBuilder]::new($this.ToString($startIndex, $length))
    }

    [string[]] Split([string[]]$separator, [int]$count, [System.StringSplitOptions]$splitOptions) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $count, $splitOptions)
        }
    }

    [string[]] Split([string]$separator, [int]$count, [System.StringSplitOptions]$splitOptions) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $count, $splitOptions)
        }
    }

    [string[]] Split([string]$separator, [System.StringSplitOptions]$splitOptions) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $splitOptions)
        }
    }

    [string[]] Split([string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, [System.StringSplitOptions]::None)
        }
    }

    [string[]] Split([char[]]$separator, [int]$count, [System.StringSplitOptions]$splitOptions) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $count, $splitOptions)
        }
    }

    [string[]] Split([char[]]$separator, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $count, [System.StringSplitOptions]::None)
        }
    }

    [string[]] Split([char[]]$separator, [System.StringSplitOptions]$splitOptions) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $splitOptions)
        }
    }

    [string[]] Split([char[]]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, [System.StringSplitOptions]::None)
        }
    }

    [string[]] Split([char]$separator, [System.StringSplitOptions]$splitOptions) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $splitOptions)
        }
    }

    [string[]] Split([char]$separator, [int]$count) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrWhiteSpace($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().Split($separator, $count, [System.StringSplitOptions]::None)
        }
    }

    [bool]StartsWith([char]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().StartsWith($value)
        }
    }

    [bool]StartsWith([string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().StartsWith($value, [System.StringComparison]::CurrentCultureIgnoreCase)
        }
    }

    [bool]StartsWith([string]$value, [System.StringComparison]$comparisonType) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return $false
        }
        else {
            return $this.ToString().StartsWith($value, $comparisonType)
        }
    }

    [char[]]ToCharArray() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return @()
        }
        else {
            return $this.ToString().ToCharArray()
        }
    }

    [char[]]ToCharArray([int]$startIndex, [int]$length) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return @()
        }

        if ([System.Text.StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $length)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex and/or length is out of range')
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.ToString($startIndex, $length).ToCharArray()
    }

    [System.Text.StringBuilder]ToLower() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().ToLower())
        }
    }

    [System.Text.StringBuilder]ToLowerInvariant() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNull($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().ToLowerInvariant())
        }
    }

    [string]ToString() {
        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [string]::Empty
        }
        else {
            return $this.Instance.ToString()
        }
    }

    [string]ToString([int]$startIndex) {
        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [string]::Empty
        }

        if ([System.Text.StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, [System.Text.StringBuilder]::ComputeImpliedCount($this.Instance, $startIndex))) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex and is out of range')
                ErrorId       = Format-ErrorId -Caller 'ToString' -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.ToString($startIndex, [System.Text.StringBuilder]::ComputeImpliedCount($this.Instance, $startIndex))
    }

    [string]ToString([int]$startIndex, [int]$length) {
        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [string]::Empty
        }

        if ([System.Text.StringBuilder]::StartIndexIsOutOfRange($this.Instance, $startIndex, $length)) {
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'startIndex and/or length is out of range')
                ErrorId       = Format-ErrorId -Caller 'ToString' -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                ErrorCategory = 'LimitsExceeded'
                TargetObject  = $startIndex
                TargetName    = 'startIndex'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance.ToString($startIndex, $length)
    }

    [System.Text.StringBuilder]ToUpper() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().ToUpper())
        }
    }

    [System.Text.StringBuilder]ToUpperInvariant() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().ToUpperInvariant())
        }
    }

    [System.Text.StringBuilder]Trim([char[]]$trimChars) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().Trim($trimChars))
        }
    }

    [System.Text.StringBuilder]Trim([char]$trimChar) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().Trim($trimChar))
        }
    }

    [System.Text.StringBuilder]Trim() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().Trim())
        }
    }

    [System.Text.StringBuilder]TrimEnd([char[]]$trimChars) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().TrimEnd($trimChars))
        }
    }

    [System.Text.StringBuilder]TrimEnd([char]$trimChar) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().TrimEnd($trimChar))
        }
    }

    [System.Text.StringBuilder]TrimStart() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().TrimEnd())
        }
    }

    [System.Text.StringBuilder]TrimStart([char[]]$trimChars) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().TrimStart($trimChars))
        }
    }

    [System.Text.StringBuilder]TrimStart([char]$trimChar) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([StringBuilder]::IsNullOrEmpty($this.Instance)) {
            return [System.Text.StringBuilder]::new()
        }
        else {
            return [System.Text.StringBuilder]::new($this.ToString().TrimStart($trimChar))
        }
    }

    <#
        Static Public Methods
    #>

    static [int]ComputeImpliedCount([System.Text.StringBuilder]$value, [int]$startIndex) {
        return $value.Length - 1 - $startIndex
    }

    static [int]ComputeImpliedCount([string]$value, [int]$startIndex) {
        return $value.Length - 1 - $startIndex
    }

    static [int]ComputeImpliedCount([char[]]$value, [int]$startIndex) {
        return $value.Length - 1 - $startIndex
    }

    static [bool]CountIsOutOfRange([System.Text.StringBuilder]$value, [int]$startIndex, [int]$count) {
        return (($count -lt 1) -or (($startIndex + $count) -ge $value.Length))
    }

    static [bool]CountIsOutOfRange([string]$value, [int]$startIndex, [int]$count) {
        return (($count -lt 1) -or (($startIndex + $count) -ge $value.Length))
    }

    static [bool]CountIsOutOfRange([char[]]$value, [int]$startIndex, [int]$count) {
        return (($count -lt 1) -or (($startIndex + $count) -ge $value.Length))
    }

    static [bool]IndexIsOutOfRange([System.Text.StringBuilder]$value, [int]$index) {
        return (($index -lt 0) -or ($index -ge $value.Length))
    }

    static [bool]IndexIsOutOfRange([string]$value, [int]$index) {
        return (($index -lt 0) -or ($index -ge $value.Length))
    }

    static [bool]IndexIsOutOfRange([char[]]$value, [int]$index) {
        return (($index -lt 0) -or ($index -ge $value.Length))
    }

    static [bool]IsEmpty([System.Text.StringBuilder]$value) {
        return ($value.Length -lt 1)
    }

    static [bool]IsNull([System.Text.StringBuilder]$value) {
        return ($null -eq $value)
    }

    static [bool]IsNullOrEmpty([System.Text.StringBuilder]$value) {
        return [StringBuilder]::IsNull($value) -or [StringBuilder]::IsEmpty($value)
    }

    static [bool]IsNullOrWhiteSpace([System.Text.StringBuilder]$value) {
        if ([StringBuilder]::IsNullOrEmpty($value)) {
            return $true
        }
        else {
            for ($i = 0; $i -lt $value.Length; $i++) {
                if (-not [Char]::IsWhiteSpace($value[$i])) {
                    return $false
                }
            }

            return $true
        }
    }

    static [bool]LengthIsOutOfRange([System.Text.StringBuilder]$value, [int]$length) {
        return ($length -lt 1) -or ($length -gt $value.Length)
    }

    static [bool]LengthIsOutOfRange([string]$value, [int]$length) {
        return ($length -lt 1) -or ($length -gt $value.Length)
    }

    static [bool]LengthIsOutOfRange([char[]]$value, [int]$length) {
        return ($length -lt 1) -or ($length -gt $value.Length)
    }

    static [bool]StartIndexIsOutOfRange([System.Text.StringBuilder]$value, [int]$startIndex, [int]$count) {
        return (($startIndex -lt 0) -or ($startIndex -ge $value.Length) -or (($startIndex + $count) -ge $value.Length))
    }

    static [bool]StartIndexIsOutOfRange([string]$value, [int]$startIndex, [int]$count) {
        return (($startIndex -lt 0) -or ($startIndex -ge $value.Length) -or (($startIndex + $count) -ge $value.Length))
    }

    static [bool]StartIndexIsOutOfRange([char[]]$value, [int]$startIndex, [int]$count) {
        return (($startIndex -lt 0) -or ($startIndex -ge $value.Length) -or (($startIndex + $count) -ge $value.Length))
    }
}

<#
    Import-Module supporting Constructor
#>
function New-StringBuilder {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingDefault')]
    [OutputType([StringBuilder])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCapacity')]
        [int]
        $Capacity,

        [Parameter(Mandatory, ParameterSetName = 'UsingValue')]
        [string]
        $Value,

        [Parameter(Mandatory, ParameterSetName = 'UsingHashtable')]
        [hashtable]
        $Properties,

        [Parameter(Mandatory, ParameterSetName = 'UsingDefault')]
        [switch]
        $Default
    )

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    switch ($PSCmdlet.ParameterSetName) {
        'UsingCapacity' {
            if ($PSCmdlet.ShouldProcess("[StringBuilder] with capacity constructor", $CmdletName)) {
                [StringBuilder]::new($Capacity) | Write-Output
            }

            break
        }

        'UsingHashtable' {
            if ($PSCmdlet.ShouldProcess("[StringBuilder] with hashtable constructor", $CmdletName)) {
                [StringBuilder]::new($Properties) | Write-Output
            }

            break
        }

        'UsingValue' {
            if ($PSCmdlet.ShouldProcess("[StringBuilder] with value constructor", $CmdletName)) {
                [StringBuilder]::new($Value) | Write-Output
            }

            break
        }

        default {
            if ($PSCmdlet.ShouldProcess("[StringBuilder] with default constructor", $CmdletName)) {
                [StringBuilder]::new() | Write-Output
            }

            break
        }
    }
}

# Define the types to export with type accelerators.
$ExportableTypes =@(
    [StringBuilder]
)

$ScriptName = Initialize-PSScript -Invocation $MyInvocation

# Get the TypeAcceleratorsClass
$TypeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')

# Enumerate the existing TypeAccelerators as Key/Value pairs where the Key is the TypeAcclerator FullName and the Value is the
# TypeAccelerator Type
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get

# Block and Throw if already registered
$ExportableTypes | ForEach-Object -Process {
    $Type = $_
    Write-Information -MessageData "$($ScriptName) : Testing whether TypeAccelerator '$($Type.FullName)' is already registered" -InformationAction $this.LogToConsole

    if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
        $Message = @(
            $ScriptName,
            "Unable to register type accelerator '$($Type.FullName)'"
            'Accelerator already exists.'
        ) -join ' : '

        $newErrorRecordSplat = @{
            Exception     = [System.InvalidOperationException]::new($Message)
            ErrorId       = Format-ErrorId -Caller $ScriptName -Name 'InvalidOperationException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'ResourceUnavailable'
            TargetObject  = $Type.FullName
            TargetName    = 'TypeAccelerator'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
    }
    else {
        foreach ($Type in $ExportableTypes) {
            Write-Information -MessageData "$($ScriptName) : Adding TypeAccelerator '$($Type.FullName)'" -InformationAction $this.LogToConsole
            $TypeAcceleratorsClass::Add($Type.FullName, $Type)
        }
    }
}

# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    $ExportableTypes | ForEach-Object -Process {
        $Type = $_
        Write-Information -MessageData "$($ScriptName) : Removing TypeAccelerator '$($Type.FullName)'" -InformationAction $this.LogToConsole
        $TypeAcceleratorsClass::Remove($Type.FullName)
    }
}.GetNewClosure()
