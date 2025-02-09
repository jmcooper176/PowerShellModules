<#
 =============================================================================
<copyright file="Queue.psm1" company="U.S. Office of Personnel
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
This file "Queue.psm1" is part of "ContainersModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -version 7.4

<#
    class Queue
#>
class Queue : System.Collections.Queue {
    <#
        Public Properties
    #>
    [string]$ClassName

    <#
        Hidden Properties
    #>
    hidden [System.Collections.Queue]$Instance

    <#
        Constructors
    #>
    Queue() {
        $this.Instance = [System.Collections.Queue]::new()
    }

    Queue([System.Collections.ICollection]$collection) {
        $this.Instance = [System.Collections.Queue]::new($collection)
    }

    Queue([int]$capacity) {
        $this.Instance = [System.Collections.Queue]::new($capacity)
    }

    Queue([int]$capacity, [float]$growFactor) {
        $this.Instance = [System.Collections.Queue]::new($capacity, $growFactor)
    }

    <#
        Hidden Methods
    #>
    hidden [void]Initialize([hashtable]$Properties) {
        $this.ClassName = ([type]'System.Collections.Queue').Name
    }

    <#
        Public Script Properties
    #>
    static [hashtable[]]$PropertyDefinitions = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSCount'
            Value      = { $this.Instance.Count }
        }

        @{
            MemberType = 'ScriptProperty'
            MemberName = 'PSIsSynchronized'
            Value      = { $this.Instance.IsSynchronized }
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
    [void]Clear() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            $this.Instance.Clear()
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
        }
    }

    [object]Clone() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            return $this.Instance.Clone()
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
            return $null
        }
    }

    [bool]Contains([object]$element) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            return $this.Instance.Contains($element)
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
            return $false
        }
    }

    [void]CopyTo([array]$array, [int]$index) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            $this.Instance.CopyTo($array, $index)
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
        }
    }

    [object]Dequeue() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            return $this.Instance.Dequeue()
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
            return $null
        }
    }

    [void]Enqueue([object]$element) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance) {
            $this.Instance.Enqueue($element)
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
        }
    }

    [System.Collections.IEnumerator]GetEnumerator() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance) {
            return $this.Instance.GetEnumerator()
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
            return $null
        }
    }

    [void]Initialize([hashtable]$Properties) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $Properties) {
            throw [System.ArgumentNullException]::new('Properties', "$($methodName) : Properties cannot be null")
        }

        foreach ($property in $Properties.Keys) {
            if ($null -eq $property) {
                throw [System.ArgumentNullException]::new('Properties', "$($methodName) : Properties cannot contain null keys")
            }
        }

        foreach ($Definition in [Queue]::PropertyDefinitions) {
            Update-TypeData -TypeName [List].Name @Definition
        }

        foreach ($property in $Properties.Keys) {
            switch ($property) {
                'Count' {
                    Write-Warning -Message "$($methodName) : Count and PSCount are read-only"
                    break
                }

                'IsSynchronized' {
                    Write-Warning -Message "$($methodName) : IsSynchronized and PSIsSynchronized are read-only"
                    break
                }

                'SyncRoot' {
                    Write-Warning -Message "$($methodName) : SyncRoot and PSSyncRoot are read-only"
                    break
                }

                default {
                    throw [System.ArgumentException]::new("$($methodName) : Property '$($property)' is not a valid property", 'Properties')
                }
            }
        }
    }

    [object]Peek() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            return $this.Instance.Peek()
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
            return $null
        }
    }

    [object[]]ToArray() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            return $this.Instance.ToArray()
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
            return @()
        }
    }

    [void]TrimToSize() {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $this.Instance -and $this.Instance.Count -gt 0) {
            $this.Instance.TrimToSize()
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
        }
    }

    <#
        Static Public Methods
    #>
    static [Queue]Synchronized([Queue]$queue) {
        $methodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $queue -and $queue.Count -gt 0) {
            return [System.Collections.Queue]::Synchronized($queue)
        }
        else {
            Write-Warning -Message "$($methodName) : Queue is null or empty"
            return $queue
        }
    }
}

<#
    Import-Module supporting Constructor
#>
function New-Queue {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Queue])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[Queue] with default constructor", $CmdletName)) {
        [Queue]::new() | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$registerTypeAcceleratorSlat = @{
    ExportableType = ([System.Type[]]@([Queue]))
    InvocationInfo = $MyInvocation
}

Register-TypeAccelerator @registerTypeAcceleratorSlat
