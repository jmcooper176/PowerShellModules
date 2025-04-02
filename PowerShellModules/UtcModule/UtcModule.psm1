<#
 =============================================================================
<copyright file="UtcModule.psm1" company="John Merryweather Cooper
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
This file "UtcModule.psm1" is part of "UtcModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<###########################################
    ConvertTo-FileTime
##########################################>
function ConvertTo-FileTime {
    [CmdletBinding()]
    [OutputType([long])]
    param (
        [datetime]
        $DateTime
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime.ToFileTimeUtc() | Write-Output
}

<###########################################
    ConvertTo-LocalTime
##########################################>
function ConvertTo-LocalTime {
    [CmdletBinding()]
    [OutputType([datetime])]
    param (
        [datetime]
        $DateTime
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime.ToLocalTime() | Write-Output
}

<###########################################
    Format-DateTime
##########################################>
function Format-DateTime {
    [CmdletBinding(DefaultParameterSetName = 'UsingCustom')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime,

        [Parameter(Mandatory, ParameterSetName = 'UsingCustom')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Custom,

        [Parameter(Mandatory, ParameterSetName = 'UsingFullLongDate')]
        [switch]
        $FullLongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingFullShortDate')]
        [switch]
        $FullShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingGeneralLongTime')]
        [switch]
        $GeneralLongTime,

        [Parameter(Mandatory, ParameterSetName = 'UsingGeneralShortTime')]
        [switch]
        $GeneralShortTime,

        [Parameter(Mandatory, ParameterSetName = 'UsingLongDate')]
        [switch]
        $LongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingShortDate')]
        [switch]
        $ShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRfc1123LongDate')]
        [switch]
        $Rfc1123LongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRfc1123ShortDate')]
        [switch]
        $Rfc1123ShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRoundTripLongDate')]
        [switch]
        $RoundTripLongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRoundTripShortDate')]
        [switch]
        $RoundTripShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingSortableDate')]
        [switch]
        $SortableDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingUniversalSortableLongDate')]
        [switch]
        $UniversalSortableLongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingUniversalSortableShortDate')]
        [switch]
        $UniversalSortableShortDate
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingFullLongDate') {
            $DateTime.ToString("F") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingFullShortDate') {
            $DateTime.ToString("f") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingGeneralLongTime') {
            $DateTime.ToString("G") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingGeneralShortTime') {
            $DateTime.ToString("g") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingRfc1123LongDate') {
            $DateTime.ToString("R") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingRfc1123ShortDate') {
            $DateTime.ToString("r") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingLongDate') {
            $DateTime.ToString("D") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingShortDate') {
            $DateTime.ToString("d") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingRoundTripLongDate') {
            $DateTime.ToString("O") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingRoundTripShortDate') {
            $DateTime.ToString("o") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingSortableDate') {
            $DateTime.ToString("s") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingUniversalSortableLongDate') {
            $DateTime.ToString("U") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingUniversalSortableShortDate') {
            $DateTime.ToString("u") | Write-Output
        }
        else {
            $DateTime.ToString($Custom) | Write-Output
        }
    }
}

<###########################################
    Format-Now
##########################################>
function Format-Now {
    [CmdletBinding(DefaultParameterSetName = 'UsingCustom')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCustom')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Custom,

        [Parameter(Mandatory, ParameterSetName = 'UsingFullLongDate')]
        [switch]
        $FullLongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingFullShortDate')]
        [switch]
        $FullShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingGeneralLongTime')]
        [switch]
        $GeneralLongTime,

        [Parameter(Mandatory, ParameterSetName = 'UsingGeneralShortTime')]
        [switch]
        $GeneralShortTime,

        [Parameter(Mandatory, ParameterSetName = 'UsingLongDate')]
        [switch]
        $LongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingShortDate')]
        [switch]
        $ShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRfc1123LongDate')]
        [switch]
        $Rfc1123LongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRfc1123ShortDate')]
        [switch]
        $Rfc1123ShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRoundTripLongDate')]
        [switch]
        $RoundTripLongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingRoundTripShortDate')]
        [switch]
        $RoundTripShortDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingSortableDate')]
        [switch]
        $SortableDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingUniversalSortableLongDate')]
        [switch]
        $UniversalSortableLongDate,

        [Parameter(Mandatory, ParameterSetName = 'UsingUniversalSortableShortDate')]
        [switch]
        $UniversalSortableShortDate
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ParameterSetName -eq 'UsingFullLongDate') {
        UtcModule\Get-Date | Format-DateTime -FullLongDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingFullShortDate') {
        UtcModule\Get-Date | Format-DateTime -FullShortDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingGeneralLongTime') {
        UtcModule\Get-Date | Format-DateTime -GeneralLongTime | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingGeneralShortTime') {
        UtcModule\Get-Date | Format-DateTime -GeneralShortTime | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingRfc1123LongDate') {
        UtcModule\Get-Date | Format-DateTime -Rfc1123LongDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingRfc1123ShortDate') {
        UtcModule\Get-Date | Format-DateTime -Rfc1123ShortDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingLongDate') {
        UtcModule\Get-Date | Format-DateTime -LongDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingShortDate') {
        UtcModule\Get-Date | Format-DateTime -ShortDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingRoundTripLongDate') {
        UtcModule\Get-Date | Format-DateTime -RoundTripLongDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingRoundTripShortDate') {
        UtcModule\Get-Date | Format-DateTime -RoundTripShortDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingSortableDate') {
        UtcModule\Get-Date | Format-DateTime -SortableDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingUniversalSortableLongDate') {
        UtcModule\Get-Date | Format-DateTime -UniversalSortableLongDate | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingUniversalSortableShortDate') {
        UtcModule\Get-Date | Format-DateTime -UniversalSortableShortDate | Write-Output
    }
    else {
        UtcModule\Get-Date | Format-DateTime -Custom $Custom | Write-Output
    }
}

<###########################################
    Format-TimeSpan
##########################################>
function Format-TimeSpan {
    [CmdletBinding(DefaultParameterSetName = 'UsingCustom')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [timespan]
        $TimeSpan,

        [Parameter(Mandatory, ParameterSetName = 'UsingCustom')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Custom,

        [Parameter(Mandatory, ParameterSetName = 'UsingInvariantTimeSpan')]
        [switch]
        $Invariant,

        [Parameter(Mandatory, ParameterSetName = 'UsingGeneralLongTimeSpan')]
        [switch]
        $GeneralLong,

        [Parameter(Mandatory, ParameterSetName = 'UsingGeneralShortTimeSpan')]
        [switch]
        $GeneralShort
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingInvariantTimeSpan') {
            $TimeSpan.ToString("c") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingGeneralLongTimeSpan') {
            $TimeSpan.ToString("G") | Write-Output
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'UsingGeneralShortTimeSpan') {
            $TimeSpan.ToString("g") | Write-Output
        }
        else {
            $TimeSpan.ToString($Custom) | Write-Output
        }
    }
}

<###########################################
    Get-Date (Called as Get-UtcDate because of prefixing in the PSD1)
##########################################>
function Get-Date {
    [CmdletBinding()]
    [OutputType([DateTime])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSVersionTable.Major -gt 7) {
        Microsoft.PowerShell.Utility\Get-Date -AsUtc | Write-Output
    }
    elseif ($PSVersionTable.Major -eq 7 -and $PSVersionTable.Minor -ge 2) {
        Microsoft.PowerShell.Utility\Get-Date -AsUtc | Write-Output
    }
    else {
        (Microsoft.PowerShell.Utility\Get-Date).ToUniversalTime() | Write-Output
    }

    <#
        .SYNOPSIS
        Gets the current date and time in Coordinated Universal Time (UTC).

        .DESCRIPTION
        `Get-Date` gets the current date and time in Coordinated Universal Time (UTC).

        .INPUTS
        None.  `Get-Date` does not take input from the pipeline.

        .OUTPUTS
        [DateTime].  `Get-Date` returns a [DateTime] object to the PowerShell pipeline.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Date

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Output
    #>
}

<###########################################
    Get-Day
##########################################>
function Get-Day {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Day | Write-Output
    }
}

<###########################################
    Get-DayOfWeek
##########################################>
function Get-DayOfWeek {
    [CmdletBinding()]
    [OutputType([System.DayOfWeek])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Day | Write-Output
    }
}

<###########################################
    Get-DayOfYear
##########################################>
function Get-DayOfYear {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty DayOfYear | Write-Output
    }
}

<###########################################
    Get-Hour
##########################################>
function Get-Hour {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Hour | Write-Output
    }
}

<###########################################
    Get-Kind
##########################################>
function Get-Kind {
    [CmdletBinding()]
    [OutputType([System.DateTimeKind])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Kind | Write-Output
    }
}

<###########################################
    Get-Microsecond
##########################################>
function Get-Microsecond {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Microsecond | Write-Output
    }
}

<###########################################
    Get-Millisecond
##########################################>
function Get-Millisecond {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Millisecond | Write-Output
    }
}

<###########################################
    Get-Month
##########################################>
function Get-Month {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Month | Write-Output
    }
}

<###########################################
    Get-Nanosecond
##########################################>
function Get-Nanosecond {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Nanosecond | Write-Output
    }
}

<###########################################
    Get-Offset
##########################################>
function Get-Offset {
    [CmdletBinding(DefaultParameterSetName = 'UsingTotalDays')]
    [OutputType([timespan], [double])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime,

        [datetime]
        $ZeroDay = '01/01/2000',

        [Parameter(Mandatory, ParameterSetName = 'UsingTimeSpan')]
        [switch]
        $Default,

        [Parameter(Mandatory, ParameterSetName = 'UsingTotalDays')]
        [switch]
        $TotalDays,

        [Parameter(Mandatory, ParameterSetName = 'UsingTotalHours')]
        [switch]
        $TotalHours,

        [Parameter(Mandatory, ParameterSetName = 'UsingTotalMinutes')]
        [switch]
        $TotalMinutes
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if ($PSCmdlet.ParameterSetName -eq 'UsingTimeSpan') {
        $DateTime - $ZeroDay | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingTotalHours') {
        ($DateTime - $ZeroDaty).TotalHours | Write-Output
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingTotalMinutes') {
        ($DateTime - $ZeroDaty).TotalHours | Write-Output
    }
    else {
        ($DateTime - $ZeroDaty).TotalDays | Write-Output
    }
    }
}

<###########################################
    Get-Second
##########################################>
function Get-Second {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Second | Write-Output
    }
}

<###########################################
    Get-Ticks
##########################################>
function Get-Ticks {
    [CmdletBinding()]
    [OutputType([long])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Ticks | Write-Output
    }
}

<###########################################
    Get-TimeOfDay
##########################################>
function Get-TimeOfDay {
    [CmdletBinding()]
    [OutputType([timespan])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty TimeOfDay | Write-Output
    }
}

<###########################################
    Get-Year
##########################################>
function Get-Year {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [datetime]
        $DateTime
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
    if (-not ($PSBoundParameters.ContainsKey('DateTime'))) {
        $DateTime = UtcModule\Get-Date
    }

    $DateTime | Select-Object -ExpandProperty Year | Write-Output
    }
}

<###########################################
    Resize-TimeOfDay
##########################################>
function Resize-TimeOfDay {
    [CmdletBinding()]
    [OutputType([double])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [timespan]
        $TimeSpan,

        [ValidateRange(127, 2147483647)]
        [int]
        $Scalar
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $TimeSpan.TotalDays * $Scalar | Write-Output
    }
}
