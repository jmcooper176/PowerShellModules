<#
 =============================================================================
<copyright file="LinqModule.psm1" company="U.S. Office of Personnel
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
This file "LinqModule.psm1" is part of "LinqModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Find-First
#>
function Find-First {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [System.Collections.ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Indexer
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        $index = -1
    }

    PROCESS {
        $List | ForEach-Object -Process {
            $index = Invoke-Command -ScriptBlock $Indexer -ArgumentList $_

            if ($index -gt -1) {
                break
            }
        }

        if ($index -gt -1) {
            return $Array[$index]
        }
        else {
            $message = "$($CmdletName) : InvalidOperationException : The 'Array' does not have an item satisfying 'Predicate'."

            $newErrorRecordSplat = @{
                ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationException' -Position $MyInvocation.ScriptLineNumber
                Exception    = [System.InvalidOperationException]::new($message)
                Category     = 'InvalidOperation'
                TargetObject = $Array
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
    }
}

<#
    Find-FirstOrDefault
#>
function Find-FirstOrDefault {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [System.Collections.ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Indexer
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | ForEach-Object -Process {
            $index = Invoke-Command -ScriptBlock $Indexer -ArgumentList $_

            if ($index -gt -1) {
                return $List[$index]
            }
            else {
                return $null
            }
        }
    }
}

<#
    Find-Last
#>
function Find-Last {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [System.Collections.ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Indexer
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Get-Reverse | ForEach-Object -Process {
            $index = Invoke-Command -ScriptBlock $Indexer -ArgumentList $_

            if ($index -gt -1) {
                return $List[$index]
            }
            else {
                $message = "$($CmdletName) : InvalidOperationException : The 'List' does not have an item satisfying 'Predicate'."

                $newErrorRecordSplat = @{
                    ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationException' -Position $MyInvocation.ScriptLineNumber
                    Exception    = [System.InvalidOperationException]::new($message)
                    Category     = 'InvalidOperation'
                    TargetObject = $Array
                }

                New-ErrorRecord @newErrorRecordSplat | Write-Fatal
            }
        }
    }
}

<#
    Find-LastOrDefault
#>
function Find-LastOrDefault {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [System.Collections.ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Indexer
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Get-Reverse | ForEach-Object -Process {
            $index = Invoke-Command -ScriptBlock $Indexer -ArgumentList $_

            if ($index -gt -1) {
                return $List[$index]
            }
            else {
                return $null
            }
        }
    }
}

<#
    Find-Singleton
#>
function Find-Singleton {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ((Measure-Predicate -List $List -Predicate $Predicate) -ne 1) {
            $message = "$($CmdletName) : InvalidOperationException : The 'List' does not have exactly one singleton satisfying 'Predicate'."

            $newErrorRecordSplat = @{
                ErrorId      = Format-ErrorId -Caller $CmdletName -Name 'InvalidOperationException' -Position $MyInvocation.ScriptLineNumber
                Exception    = [System.InvalidOperationException]::new($message)
                Category     = 'InvalidOperation'
                TargetObject = $List
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
        else {
            $List | Find-First -ScriptBlock $Predicate | Write-Object
        }
    }
}

<#
    Find-SingletonOrDefault
#>
function Find-SingletonOrDefault {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ((Measure-Predicate -List $List -Predicate $Predicate) -ne 1) {
            return $null
        }
        else {
            $List | Find-First -Predicate $Predicate | Write-Output
        }
    }
}

<#
    Get-Reverse
#>
function Get-Reverse {
    [CmdletBinding()]
    [OutputType([Array])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-ArrayAny -Array $_ })]
        [Array]
        $Array,

        [switch]
        $Fast
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($Fast.IsPresent) {
            # .NET in-place
            [Array]::Reverse($Array)
            $Array | Write-Output
        }
        else {
            # PowerShell re-index
            $startIndex = -1
            $lastIndex = - ($Array.Length)
            $Array[$startIndex..$lastIndex] | Write-Output
        }
    }
}

<#
    Group-Distinct
#>
function Group-Distinct {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Sort-Object -Unique | Write-Output
    }
}

<#
    Group-DistinctBy
#>
function Group-DistinctBy {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [object[]]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Sort-Object -Property $Property -Unique | Write-Output
    }
}

<#
    Group-Each
#>
function Group-Each {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Filter
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | ForEach-Object -Process {
            Invoke-Command -ScriptBlock $Filter -ArgumentList $_ | Write-Output
        }
    }
}

<#
    Group-Ordered
#>
function Group-Ordered {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Sort-Object | Write-Output
    }
}

<#
    Group-OrderedBy
#>
function Group-OrderedBy {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [object[]]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Sort-Object -Property $Property | Write-Output
    }
}

<#
    Group-OrderedByDescending
#>
function Group-OrderedByDescending {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [object[]]
        $Property
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Sort-Object -Property $Property -Descending | Write-Output
    }
}

<#
    Group-OrderedDescending
#>
function Group-OrderedDescending {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | Sort-Object -Descending | Write-Output
    }
}

<#
    Measure-Predicate
#>
function Measure-Predicate {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        $count = 0
    }

    PROCESS {
        $List | ForEach-Object -Process {
            if (Invoke-Command -ScriptBlock $Predicate -ArgumentList $_) {
                $count++
            }
        }

        return $count
    }
}

<#
    New-Range
#>
function New-Range {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int[]])]
    param (
        [Parameter(Mandatory)]
        [int]
        $Start,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Count
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    for ($i = 0; $i -lt $Count; $i++) {
        if ($PSCmdlet.ShouldProcess("Output Range starting with '$($Start)'", $CmdletName)) {
            $Start + $i | Write-Output
        }
    }
}

<#
    New-Repeat
#>
function New-Repeat {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([object])]
    param (
        [Parameter(Mandatory)]
        [object]
        $Value,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Count
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    for ($i = 0; $i -lt $Count; $i++) {
        if ($PSCmdlet.ShouldProcess("Outputting 'Value' 'Count' times", $CmdletName)) {
            $Value | Write-Output
        }
    }
}

<#
    Select-One
#>
function Select-One {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Selector
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | ForEach-Object -Process {
            Invoke-Command -ScriptBlock $Selector -ArgumentList $_ | Write-Output
        }
    }
}

<#
    Skip-First
#>
function Skip-First {
    [CmdletBinding()]
    [OutputType([Array])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-ArrayAny -Array $_ })]
        [Array]
        $Array,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Count
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Array[$Count..($Array.Length - 1)] | Write-Output
    }
}

<#
    Skip-Last
#>
function Skip-Last {
    [CmdletBinding()]
    [OutputType([Array])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-ArrayAny -Array $_ })]
        [Array]
        $Array,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Count
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Array[0..($Array.Length - $Count - 1)] | Write-Output
    }
}

<#
    Skip-While
#>
function Skip-While {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        $skipping = $true
    }

    PROCESS {
        $List | ForEach-Object -Process {
            if ($skipping -and (Invoke-Command -ScriptBlock $Predicate -ArgumentList $_)) {
                continue
            }
            elseif ($skipping) {
                $skipping = false
            }
            else {
                $_ | Write-Output
            }
        }
    }
}

<#
    Test-All
#>
function Test-All {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | ForEach-Object -Process {
            if (-not (Invoke-Command -ScriptBlock $Predicate -ArgumentList $_)) {
                return $false
            }
        }

        return $true
    }
}

<#
    Test-Any
#>
function Test-Any {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ArrayList]
        $List,

        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if (Test-PSParameter -Name 'Predicate' -Parameters $PSBoundParameters) {
            $List | ForEach-Object -Process {
                if (Invoke-Command -ScriptBlock $Predicate -ArgumentList $_) {
                    return $true
                }
            }

            return $false
        }
        else {
            return ($null -ne $List) -and ($List.Length -gt 0)
        }
    }
}

<#
    Test-ArrayAny
#>
function Test-ArrayAny {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Array]
        $Array,

        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if (Test-PSParameter -Name 'Predicate' -Parameters $PSBoundParameters) {
            $Array | ForEach-Object -Process {
                if (Invoke-Command -ScriptBlock $Predicate -ArgumentList $_) {
                    return $true
                }
            }

            return $false
        }
        else {
            return ($null -ne $Array) -and ($Array.Length -gt 0)
        }
    }
}

<#
    Test-Contains
#>
function Test-Contains {
    [CmdletBinding(DefaultParameterSetName = 'UsingPredicate')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory, ParameterSetName = 'UsingValue')]
        [object]
        $Value,

        [Parameter(Mandatory, ParameterSetName = 'UsingPredicate')]
        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingValue') {
            $List.Contains($Value) | Write-Output
        }
        else {
            $List | Test-Any -Predicate $Predicate | Write-Output
        }
    }
}

<#
    Use-First
#>
function Use-First {
    [CmdletBinding()]
    [OutputType([Array])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-ArrayAny -Array $_ })]
        [Array]
        $Array,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Count
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Array[0..($Array.Length - $Count - 1)] | Write-Output
    }
}

<#
    Use-Last
#>
function Use-Last {
    [CmdletBinding()]
    [OutputType([Array])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-ArrayAny -Array $_ })]
        [Array]
        $Array,

        [Parameter(Mandatory)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Count
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Array[($Array.Length - $Count)..($Array.Length - 1)] | Write-Output
    }
}

<#
    Use-While
#>
function Use-While {
    [CmdletBinding()]
    [OutputType([ArrayList])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Any -List $_ })]
        [ArrayList]
        $List,

        [Parameter(Mandatory)]
        [scriptblock]
        $Predicate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $List | ForEach-Object -Process {
            if ($taking -and (Invoke-Command -ScriptBlock $Predicate -ArgumentList $_)) {
                $_ | Write-Output
            }
            else {
                return
            }
        }
    }
}
