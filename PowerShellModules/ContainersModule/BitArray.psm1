<#
 =============================================================================
<copyright file="BitArray.psm1" company="John Merryweather Cooper">
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
This file "BitArray.psm1" is part of "ContainersModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -version 7.4
#requires -Module ErrorRecordModule
#requires -Module PowerShellModule

<#
    class BitArray
#>
class BitArray : System.Collections.BitArray {
    <#
        Public Properties
    #>
    [string]$ClassName

    <#
        Hidden Properties
    #>
    hidden [System.Collections.BitArray]$Instance

    <#
        Constructors
    #>
    BitArray([bool[]] $values) {
        $this.Instance = [System.Collections.BitArray]::new($values)
    }

    BitArray([byte[]] $bytes) {
        $this.Instance = [System.Collections.BitArray]::new($bytes)
    }

    BitArray([System.Collections.BitArray] $bits) {
        $this.Instance = [System.Collections.BitArray]::new($bits)
    }

    BitArray([int] $value) {
        $stringValue = [Convert]::ToString($value, 2)
        [ref]$result = $null

        if ([System.Collections.BitArray]::TryParse($stringValue, [ref] $result)) {
            $this.Instance = $result.Value
        }
        else {
            throw [System.ArgumentException]::new("$($this.ClassName) : stringValue must be a string of 0s and 1s", 'stringValue')
        }
    }

    BitArray([int] $length, [bool] $defaultValue) {
        $this.Instance = [System.Collections.BitArray]::new($length, $defaultValue)
    }

    BitArray([int[]] $values) {
        $this.Instance = [System.Collections.BitArray]::new($values)
    }

    BitArray([long] $value) {
        $stringValue = [Convert]::ToString($value, 2)
        [ref]$result = $null

        if ([BitArray]::TryParse($stringValue, [ref] $result)) {
            $this.Instance = $result.Value
        }
        else {
            throw [System.ArgumentException]::new("$($this.ClassName) : stringValue must be a string of 0s and 1s", 'stringValue')
        }
    }

    BitArray([string] $value) {
        [ref]$result = $null

        if ([string]::IsNullOrWhiteSpace($value)) {
            throw [System.ArgumentNullException]::new('value', "$($this.ClassName) : value cannot be null or empty")
        }

        if ([BitArray]::TryParse($value, [ref] $result)) {
            $this.Instance = $result.Value
        }
        else {
            throw [System.ArgumentException]::new("$($this.ClassName) : stringValue must be a string of 0s and 1s", 'stringValue')
        }
    }

    <#
        Hidden Methods
    #>
    hidden [void] Initialize([hastable]$Properties) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation
        $this.ClassName = Initialize-PSClass -Name ([type]'System.Collections.BitArray').Name

        $this.ClassName = Initialize-PSClass -Name ([type]'System.Collections.BitArray').Name
    }

    <#
        Public Script Properties
    #>
    static [hashtable[]] $PropertyDefinitions = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSCount'
            Value      = { $this.Instance.Count }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSIsReadOnly'
            Value      = { $this.Instance.IsReadOnly }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSIsSynchronized'
            Value      = { $this.Instance.IsSynchronized }
        }

        @{
            MemberType  = 'ScriptProperty'
            MemberName  = 'PSLength'
            Value       = { $this.Instance.Length }
            SecondValue = {
                $proposedValue = $args[0]

                if ($proposedValue -is [int]) {
                    if ([int]$proposedValue -lt 0 -or [int]$proposedValue -gt [int]::MaxValue) {
                        throw [System.ArgumentOutOfRangeException]::new('args[0]', $args[0], 'Length must be between 0 and [int]::MaxValue')
                    }
                    else {
                        $this.Instance.Capacity = [int]$proposedValue
                    }
                }
                else {
                    throw [System.ArgumentException]::new('Length must be an integer', 'args[0]')
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSSyncRoot'
            Value      = { $this.Instance.SyncRoot }
        }
    )

    <#
        Public Methods
    #>
    [BitArray] BinaryAnd([BitArray] $value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $value -or $value.Count -eq 0) {
            throw [System.ArgumentNullException]::new('value', "$($methodName) : value cannot be null or empty")
        }

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('this', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.And($value)
    }

    [object] Clone() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.Clone()
    }

    [void] CopyTo([Array] $array, [int] $index) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        if ($null -eq $array -or $array.Length -eq 0) {
            throw [System.ArgumentNullException]::new('array', "$($methodName) : array cannot be null or empty")
        }
        elseif ($array.Rank -gt 1) {
            throw [System.ArgumentException]::new("$($methodName) : Array must have a rank of 1", 'array')
        }
        elseif ($array.Length -lt $this.Instance.Count) {
            throw [System.ArgumentException]::new('array must be at least as long as this', 'array')
        }

        $this.Instance.CopyTo($array, $index)
    }

    [bool] BitElementAt([int]$index) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            $newErrorRecordSplat = @{
                Exception       = [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
                Category        = 'InvalidData'
                ErrorId         = Format-ErrorId -Caller $methodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                TargetObject    = $this.Instance
                TargetName      = 'Instance'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
        elseif ([BitArray]::IndexIsOutOfRange($index, $this.Instance)) {
            $newErrorRecordSplat = @{
                Exception       = [System.ArgumentNullException]::new('Instance', "$($methodName) : index must be between 0 and $($this.Instance.Count - 1)")
                Category        = 'LimitsExceeded'
                ErrorId         = Format-ErrorId -Caller $methodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                TargetObject    = $index
                TargetName      = 'index'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        return $this.Instance[$index]
    }

    [bool] GetBit([int] $index) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('this', "$($methodName) : this cannot be null or empty")
        }
        elseif ([BitArray]::IndexIsOutOfRange($index, $this.Instance)) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, "$($methodName) : index must be between 0 and $($this.Instance.Count - 1)")
        }

        return $this.Instance.Get($index)
    }

    [System.Collections.IEnumerator] GetEnumerator() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.GetEnumerator()
    }

    [bool] HasAllSet() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.HasAllSet()
    }

    [bool] HasAnySet() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.HasAnySet()
    }

    [bool] HasAllUnset() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return -not $this.Instance.HasAnySet()
    }

    [bool] HasAnyUnset() {
        Initialize-PSMethod -MyInvocation $MyInvocation

        return -not $this.Instance.HasAllSet()
    }

    [bool] IsFalse() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.HasAllUnset()
    }

    [bool] IsFalse([int] $index) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }
        elseif ([BitArray]::IndexIsOutOfRange($index, $this.Instance)) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, "$($methodName) : index must be between 0 and $($this.Instance.Count - 1)")
        }

        return -not $this.Instance.Get($index)
    }

    [bool] IsTrue() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.HasAnySet()
    }

    [bool] IsTrue([int] $index) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }
        elseif ([BitArray]::IndexIsOutOfRange($index, $this.Instance)) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, "$($methodName) : index must be between 0 and $($this.Instance.Count - 1)")
        }

        return $this.Instance.Get($index)
    }

    [System.Collections.BitArray] LeftShift([int] $count) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }
        elseif ($count -lt 0 -or $count -ge $this.Instance.Count) {
            throw [System.ArgumentOutOfRangeException]::new('count', $count, "$($methodName) : count must be between 0 and $($this.Instance.Count - 1)")
        }

        return $this.Instance.LeftShift($count)
    }

    [System.Collections.BitArray] BinaryNot() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.Not()
    }

    [System.Collections.BitArray] BinaryOr([System.Collections.BitArray] $value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $value -or $value.Count -eq 0) {
            throw [System.ArgumentNullException]::new('value', "$($methodName) : value cannot be null or empty")
        }

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        return $this.Instance.Or($value)
    }

    [System.Collections.BitArray] RightShift([int] $count) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }
        elseif ($count -lt 0 -or $count -ge $this.Instance.Count) {
            throw [System.ArgumentOutOfRangeException]::new('count', $count, "$($methodName) : count must be between 0 and $($this.Instance.Count - 1)")
        }

        return $this.Instance.RightShift($count)
    }

    [void] SetBit([int]$index, [bool]$value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }
        elseif ([BitArray]::IndexIsOutOfRange($index, $this.Instance)) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, "$($methodName) : index must be between 0 and $($this.Instance.Count - 1)")
        }

        $this.Instance.Set($index, $value)
    }

    [void] SetAll([bool]$value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }

        $this.Instance.SetAll($value)
    }

    [void] SetElement([int]$index, [bool]$value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([BitArray]::IsNullOrEmpty($this.Instance)) {
            throw [System.ArgumentNullException]::new('Instance', "$($methodName) : this cannot be null or empty")
        }
        elseif ([BitArray]::IndexIsOutOfRange($index, $this.Instance)) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, "$($methodName) : index must be between 0 and $($this.Instance.Count - 1)")
        }

        $this.Instance[$index] = $value
    }

    [void] Swap([System.Collections.BitArray]$left, [System.Collections.BitArray]$right) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $left) {
            throw [System.ArgumentNullException]::new('left', "$($methodName) : left cannot be null")
        }

        if ($null -eq $right) {
            throw [System.ArgumentNullException]::new('right', "$($methodName) : right cannot be null")
        }

        if ($left.Count -ne $right.Count) {
            throw [System.ArgumentException]::new("$($methodName) : left and right must be the same length", 'right')
        }
        else {
            $left = $left.Xor($right)
            $right = $left.Xor($right)
            $left = $left.Xor($right)
        }
    }

    [byte] ToByte() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        [byte]$accumulator = 0

        if ($this.Instance.Count -ne 8) {
            throw [System.ArgumentOutOfRangeException]::new('Instance', $this.Instance.Count, "$($methodName) : BitArray must be 8 bits long")
        }

        for ($i = 0; $i -lt $this.Instance.Count; $i++) {
            if ($this.Instance.Get($i)) {
                $accumulator += [Math]::Pow(2, $i)
            }
        }

        return $accumulator
    }

    [int32] ToInteger() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        [int32]$accumulator = 0

        if ($this.Instance.Count -ne 32) {
            throw [System.ArgumentOutOfRangeException]::new('Instance', $this.Instance.Count, "$($methodName) : BitArray must be 32 bits long")
        }

        for ($i = 0; $i -lt $this.Instance.Count; $i++) {
            if ($this.Instance.Get($i)) {
                $accumulator += [Math]::Pow(2, $i)
            }
        }

        return $accumulator
    }

    [int64] ToLong() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        [int64]$accumulator = 0

        if ($this.Instance.Count -ne 64) {
            throw [System.ArgumentOutOfRangeException]::new('Instance', $this.Instance.Count, "$($methodName) : BitArray must be 64 bits long")
        }

        for ($i = 0; $i -lt $this.Instance.Count; $i++) {
            if ($this.Instance.Get($i)) {
                $accumulator += [Math]::Pow(2, $i)
            }
        }

        return $accumulator
    }

    [int16] ToShort() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        [int16]$accumulator = 0

        if ($this.Instance.Count -ne 16) {
            throw [System.ArgumentOutOfRangeException]::new('Instance', $this.Instance.Count, "$($methodName) : BitArray must be 16 bits long")
        }

        for ($i = 0; $i -lt $this.Instance.Count; $i++) {
            if ($this.Instance.Get($i)) {
                $accumulator += [Math]::Pow(2, $i)
            }
        }

        return $accumulator
    }

    [string] ToString() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $this -or $this.Instance.Count -eq 0) {
            return [string]::Empty
        }

        $buffer = New-Object -TypeName System.Text.StringBuilder

        for ($i = 0; $i -lt $this.Instance.Count; $i++) {
            if ($this.Instance.Get($i)) {
                $buffer.Append(1)
            }
            else {
                $buffer.Append(0)
            }
        }

        return $buffer.ToString()
    }

    [System.Collections.BitArray] BinaryXor([System.Collections.BitArray] $value) {
        return $this.Instance.Xor($value)
    }

    <#
        Static Public Methods
    #>
    static [bool] IndexIsOutOfRange([int] $index, [System.Collextions.BitArray] $instance) {
        return ($index -lt 0) -or ($index -ge $instance.Count)
    }

    static [bool] IsNullOrEmpty([System.Collections.BitArray] $instance) {
        return ($null -eq $instance) -or ($instance.Count -lt 1)
    }

    static [System.Collections.BitArray] Parse([string] $value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([string]::IsNullOrWhiteSpace($value)) {
            $newErrorRecordSplat = @{
                Exception       = [System.ArgumentNullException]::new('value', "$($methodName) : value cannot be null or empty")
                Category        = 'InvalidArgument'
                ErrorId         = Format-ErrorId -Caller $methodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                TargetObject    = $value
                TargetName      = 'value'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        $charArray = $value.ToCharArray()
        $accumulator = New-Object -TypeName System.Collections.BitArray -ArgumentList $charArray.Length

        for ($i = 0; $i -lt $charArray.Length; $i++) {
            if ($charArray[$i] -eq '1') {
                $accumulator.Set($i, $true)
            }
            elseif ($charArray[$i] -eq '0') {
                $accumulator.Set($i, $false)
            }
            else {
                throw [System.ArgumentException]::new("$($methodName) : value must be a string of 0s and 1s", 'value')
            }
        }

        return $accumulator
    }

    static [bool] TryParse([string] $value, [ref] $result) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        try {
            $result.Value = [System.Collections.BitArray]::Parse($value)
            return $true
        }
        catch {
            $result.Value = $null
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            return $false
        }
    }
}

<#
    Import-Module supporting Constructor
#>
function New-BitArray {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([BitArray])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[BitArray] with default constructor", $CmdletName)) {
        [BitArray]::new() | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$registerTypeAcceleratorSlat = @{
    ExportableType = ([System.Type[]]@([BitArray]))
    InvocationInfo = $MyInvocation
}

Register-TypeAccelerator @registerTypeAcceleratorSlat
