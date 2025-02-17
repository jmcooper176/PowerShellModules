<#
 =============================================================================
<copyright file="ArrayList.psm1" company="U.S. Office of Personnel
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
This file "ArrayList.psm1" is part of "ContainersModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -version 7.4

#
# ArrayList.psm1 - class ArrayList
#

class ArrayList : System.Collections.ArrayList {
    <#
        Public Properties
    #>
    [string]$ClassName

    <#
        Hidden Properties
    #>
    hidden [System.Collections.ArrayList]$Instance

    <#
        Constructors
    #>
    ArrayList() {
        $this.Instance = [System.Collections.ArrayList]::new()
        $properties = @{
            'PSCapacity' = 0
        }

        $this.Instance.Initialize($properties)
    }

    ArrayList([System.Collections.ICollection] $collection) {
        if ($null -eq $collection) {
            throw [System.ArgumentNullException]::new('collection', "$($this.ClassName) : Parameter 'Collection' cannot be null")
        }
        elseif ($collection -is [Array] -and ([Array]$collection).Rank -gt 1) {
            throw [System.RankException]::new("$($this.ClassName) : Collection as array must be a single-rank array")
        }

        $this.Instance = [System.Collections.ArrayList]::new($collection)

        $properties = @{
            'PSCapacity' = $collection.Count
        }

        $this.Initialize($properties)
    }

    ArrayList([int]$capacity) {
        $this.Instance = [System.Collections.ArrayList]::new($capacity)

        $properties = @{
            'PSCapacity' = $capacity
        }

        $this.Initialize($properties)
    }

    ArrayList([hashtable]$properties) {
        $this.Instance = [System.Collections.ArrayList]::new()
        $this.Initialize($properties)
    }

    hidden [void]Initialize([hashtable]$properties) {
        $this.ClassName = Initialize-PSClass -Name [ArrayList].Name

        foreach ($Definition in [List]::PropertyDefinitions) {
            Update-TypeData -TypeName [ArrayList].Name @Definition
        }
    }

    <#
        Public Script Properties
    #>
    static [hashtable[]]$PropertyDefinitions = @(
        @{
            MemberType  = 'ScriptProperty'
            MemberName  = 'PSCapacity'
            Value       = { $this.Instance.Capacity }
            SecondValue = {
                $proposedValue = $args[0]

                if ($proposedValue -is [int]) {
                    if ([int]$proposedValue -lt 0 -or [int]$proposedValue -gt [int]::MaxValue) {
                        throw [System.ArgumentOutOfRangeException]::new('args[0]', $args[0], 'Capacity must be between 0 and [int]::MaxValue')
                    }
                    else {
                        $this.Instance.Capacity = [int]$proposedValue
                    }
                }
                else {
                    throw [System.ArgumentException]::new('Capacity must be an integer', 'args[0]')
                }
            }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSCount'
            Value      = { $this.Instance.Count }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSLength'
            Value      = { $this.Instance.Count }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSIsFixedSize'
            Value      = { $this.Instance.IsFixedSize }
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
            MemberType = 'ScriptProperty'
            MemberName = 'PSMaxLength'
            Value      = { $this.Instance.Count }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSRank'
            Value      = { 1 }
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
    [int]Add([object]$value) {
        return $this.Instance.Add($value)
    }

    [void]AddRange([System.Collections.ICollection] $collection) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $collection) {
            throw [System.ArgumentNullException]::new('collection', 'Collection cannot be null')
        }

        if ($this.Instance.IsReadOnly -or $this.Instance.IsFixedSize) {
            throw [System.NotSupportedException]::new('List is read-only or fixed size')
        }

        $this.Instance.AddRange($collection)
    }

    [int]BinarySearch([object] $value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($value -is -not [System.IComparable]) {
            throw [System.ArgumentException]::new('Value must implement System.IComparable', 'value')
        }

        for ($i = 0; $i -lt $this.Instance.Count; $i++) {
            if ($this.Instance.Item[$I] -is -not [System.IComparable]) {
                throw [System.ArgumentException]::new('Item must implement System.IComparable', "Item[$($i)]")
            }
        }

        return $this.Instance.BinarySearch($value)
    }

    [void]Clear() {
        $this.Instance.Clear()
    }

    [object]Clone() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        return $this.Instance.Clone()
    }

    [bool]Contains([object]$value) {
        return $this.Instance.Contains($value)
    }

    [void]CopyTo([Array] $array) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $array) {
            throw [System.ArgumentNullException]::new('array', 'Array cannot be null')
        }
        elseif ($array.Rank -gt 1) {
            throw [System.ArgumentException]::new('Array must have a rank of 1', 'array')
        }

        try {
            $this.Instance.CopyTo($array)
        }
        catch [System.ArgumentException] {
            throw [System.ArgumentException]::new(
                "The number of elements in the source 'ArrayList' is greater than the number of elements that the destination array can contain", 'startIndex')
        }
        catch [System.InvalidCastException] {
            throw [System.InvalidCastException]::new("The type of source 'ArrayList' cannot be cast automatically to the specified type '$($array.GetType().FullName)'")
        }
    }

    [void]CopyTo([int]$index, [Array] $array, [int]$arrayIndex, [int]$count) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $array) {
            throw [System.ArgumentNullException]::new('array', 'Array cannot be null')
        }

        if ($index -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, 'Index must be greater than or equal to 0')
        }

        if ($arrayIndex -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('arrayIndex', $arrayIndex, 'Array index must be greater than or equal to 0')
        }

        if ($count -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('count', $count, 'Count must be greater than or equal to 0')
        }

        if ($index -ge $this.Instance.Count) {
            throw [System.ArgumentException]::new('Index must be less than the list count', 'index')
        }

        try {
            $this.Instance.CopyTo($index, $array, $arrayIndex, $count)
        }
        catch [System.ArgumentException] {
            throw [System.ArgumentException]::new(
                'The number of elements from index to the end of the source ArrayList is greater than the available space from arrayIndex to the end of the destination array', 'index')
        }
        catch [System.InvalidCastException] {
            throw [System.InvalidCastException]::new("The type of source 'ArrayList' cannot be cast automatically to the specified type '$($array.GetType().FullName)'")
        }
    }

    [void]CopyTo([Array] $array, [int] $startIndex) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $array) {
            throw [System.ArgumentNullException]::new('array', 'Array cannot be null')
        }
        elseif ($array.Rank -gt 1) {
            throw [System.ArgumentException]::new('Array must have a rank of 1', 'array')
        }

        if ($startIndex -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'Start index must be greater than or equal to 0')
        }

        try {
            $this.Instance.CopyTo($array, $startIndex)
        }
        catch [System.ArgumentException] {
            throw [System.ArgumentException]::new(
                'The number of elements in the source ArrayList is greater than the available space from arrayIndex to the end of the destination array', 'startIndex')
        }
        catch [System.InvalidCastException] {
            throw [System.InvalidCastException]::new("The type of source 'ArrayList' cannot be cast automatically to the specified type '$($array.GetType().FullName)'")
        }
    }

    [object]ElementAt([int]$index) {
        return $this.Instance[$index]
    }

    [ArrayList]GetRange([int] $index, [int] $count) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($index -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, 'Index must be greater than or equal to 0')
        }

        if ($this.Instance.Count -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('count', $count, 'Count must be greater than or equal to 0')
        }

        try {
            return $this.Instance.GetRange($index, $count)
        }
        catch [System.ArgumentException] {
            throw [System.ArgumentException]::new('index and count do not denote a valid range in the list', 'index')
        }
    }

    [void]Insert([int]$index, [object]$value) {
        $this.Instance.Insert($index, $value)
    }

    [void]InsertRange([int] $index, [System.Collections.ICollection] $collection) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $collection) {
            throw [System.ArgumentNullException]::new('collection', 'Collection cannot be null')
        }

        if ($index -lt 0 -or $index -ge $this.Instance.Count) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, 'Index must be greater than or equal to 0 and less than the list count')
        }

        if ($this.Instance.IsReadOnly -or $this.Instance.IsFixedSize) {
            throw [System.NotSupportedException]::new('List is read-only or fixed size')
        }

        $this.Instance.InsertRange($index, $collection)
    }

    [int]LastIndexOf([object] $value) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        return $this.Instance.LastIndexOf($value)
    }

    [int]LastIndexOf([object] $value, [int] $startIndex) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($startIndex -lt 0 -or $startIndex -ge $this.Instance.Count) {
            throw [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'Start index must be greater than or equal to 0 and less than the list count')
        }

        return $this.Instance.LastIndexOf($value, $startIndex)
    }

    [int]LastIndexOf([object] $value, [int] $startIndex, [int] $count) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($startIndex -lt 0 -or $startIndex -ge $this.Instance.Count) {
            throw [System.ArgumentOutOfRangeException]::new('startIndex', $startIndex, 'Start index must be greater than or equal to 0 and less than the list count')
        }

        if ($count -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('count', $count, 'Count must be greater than or equal to 0')
        }

        try {
            return $this.Instance.LastIndexOf($value, $startIndex, $count)
        }
        catch [System.ArgumentException] {
            throw [System.ArgumentException]::new('startIndex and count do not denote a valid range in the list', 'startIndex')
        }
    }

    [void]Remove([object]$value) {
        $this.Instance.Remove($value)
    }

    [void]RemoveAt([int]$index) {
        $this.Instance.RemoveAt($index)
    }

    [void]RemoveRange([int] $index, [int] $count) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($index -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, 'Index must be greater than or equal to 0')
        }

        if ($count -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('count', $count, 'Count must be greater than or equal to 0')
        }

        if ($this.Instance.IsReadOnly -or $this.Instance.IsFixedSize) {
            throw [System.NotSupportedException]::new('List is read-only or fixed size')
        }

        try {
            $this.Instance.RemoveRange($index, $count)
        }
        catch [System.ArgumentException] {
            throw [System.ArgumentException]::new('index and count do not denote a valid range in the list', 'index')
        }
    }

    [void]Reverse() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Instance.ReadOnly) {
            throw [System.NotSupportedException]::new('List is read-only')
        }

        $this.Instance.Reverse()
    }

    [void]Reverse([int] $index, [int] $count) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($index -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, 'Index must be greater than or equal to 0')
        }

        if ($count -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('count', $count, 'Count must be greater than or equal to 0')
        }

        if ($this.Instance.ReadOnly) {
            throw [System.NotSupportedException]::new('List is read-only')
        }

        try {
            $this.Instance.Reverse($index, $count)
        }
        catch [System.ArgumentException] {
            throw [System.ArgumentException]::new('index and count do not denote a valid range in the list', 'index')
        }
    }

    [void]SetRange([int] $index, [System.Collections.ICollection] $collection) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($index -lt 0) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, 'Index must be greater than or equal to 0')
        }

        if ($index -ge $collection.Count) {
            throw [System.ArgumentOutOfRangeException]::new('index', $index, 'Index must be less than the collection count')
        }

        if ($null -eq $collection) {
            throw [System.ArgumentNullException]::new('collection', 'Collection cannot be null')
        }

        if ($this.Instance.IsReadOnly) {
            throw [System.NotSupportedException]::new('List is read-only')
        }

        $this.Instance.SetRange($index, $collection)
    }

    [void]Sort() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Instance.IsReadOnly) {
            throw [System.NotSupportedException]::new('List is read-only')
        }

        $this.Instance.Sort()
    }

    [Array]ToArray() {
        return $this.Instance.ToArray()
    }

    [void]TrimToSize() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Instance.IsFixedSize -or $this.Instance.IsReadOnly) {
            throw [System.NotSupportedException]::new('List is fixed size or read-only')
        }

        $this.Instance.TrimToSize()
    }

    <#
        Static Methods
    #>
    static [void]ConstrainedCopy(
        [ArrayList]$source,
        [int]$sourceIndex,
        [ArrayList]$destination,
        [int]$destinationIndex,
        [int]$length
    )
    {
        $methodName = Initialize-PSMethod -Invocation $MyInvocation

        $backupSource = [System.Collections.ArrayList]::new($source)
        $backupDestination = [System.Collections.ArrayList]::new($destination)

        try {
            [ArrayList].Copy($source, $sourceIndex, $destination, $destinationIndex, $length)
        } catch {
            $backupSource.CopyTo($source, 0)
            $backupDestination.CopyTo($destination, 0)
        }
    }

    static [void]Copy(
        [ArrayList]$source,
        [int]$sourceIndex,
        [ArrayList]$destination,
        [int]$destinationIndex,
        [int]$length
    ) {

        $methodName = Initialize-PSMethod -Invocation $MyInvocation

        if (-not (Test-PSParameter -Name 'length' -Parameters $PSBoundParameters)) {
            $length = $source.Count
        }

        $source.CopyTo($sourceIndex, $destination, $destinationIndex, $length)
    }

    static [ArrayList]Empty() {
        $methodName = Initialize-PSMethod -Invocation $MyInvocation

        return [System.Collections.ArrayList]::new()
    }
}

<#
    Import-Module supporting Constructor
#>
function New-ArrayList {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([ArrayList])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[ArrayList] with default constructor", $CmdletName)) {
        [ArrayList]::new() | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$registerTypeAcceleratorSlat = @{
    ExportableType = ([System.Type[]]@([ArrayList]))
    InvocationInfo = $MyInvocation
}

Register-TypeAccelerator @registerTypeAcceleratorSlat
