<#
 =============================================================================
<copyright file="ErrorRecordModule.psm1" company="U.S. Office of Personnel
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
This file "ErrorRecordModule.psm1" is part of "ErrorRecordModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Confirm-ArgumentInRange
#>
function Confirm-ArgumentInRange {
    [CmdletBinding(DefaultParameterSetName = 'UsingInt')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [scriptblock]
        $Condition,

        [Parameter(Mandatory)]
        [ValidateNotNullEmptyOrEmpty()]
        [string]
        $Parameter,

        [Parameter(Mandatory, ParameterSetName = 'UsingInt')]
        [int]
        $Index,

        [Parameter(Mandatory, ParameterSetName = 'UsingLong')]
        [long]
        $LongIndex,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ParameterSetName -eq 'UsingLong') {
        $exception = [System.ArgumentOutOfRangeException]::new($Parameter, $LongIndex, $Message)
    }
    else {
        $exception = [System.ArgumentOutOfRangeException]::new($Parameter, $Index, $Message)
    }

    $newErrorRecordSplat = @{
        ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
        ErrorCategory = 'LimitsExceeded'
        Exception     = $exception
        TargetObject  = $Condition
        TargetName    = $Parameter
    }

    if (Invoke-Command -ScriptBlock $Condition -ArgumentList $Index) {
        Write-Verbose -Message "$($CmdletName) : Parameter '$($Parameter)' is in range"
        $true | Write-Output
    }
    else {
        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $false | Write-Output
    }

    <#
        .SYNOPSIS
        Tests whether parameter `Index` or `LongIndex` is in range as specified by [scriptblock] `Condition`.

        .DESCRIPTION
        `Confirm-ArgumentInRange` tests whether parameter `Index` or `LongIndex` is in range as specified by [scriptblock] `Condition`.

        .PARAMETER Condition
        Specifies the [scriptblock] that defines the range of values for `Index` or `LongIndex`.  I must take a single positional argument representing `Index` or `LongIndex`.

        .PARAMETER Parameter
        Specifies the name of the parameter being tested.

        .PARAMETER Index
        Specifies the integer index to test.

        .PARAMETER LongIndex
        Specifies the long index to test.

        .PARAMETER Message
        Specifies the message assigned to the `ArgumentOutOfRangeException` constructor for the message parameter.

        .INPUTS
        None.  `Confirm-ArgumentInRange` does not accept pipeline input.

        .OUTPUTS
        [bool]  `Confirm-ArgumentInRange` outputs a boolean value indicating whether the index is in range.

        .EXAMPLE
        PS> Confirm-ArgumentInRange -Condition { param($Index) $Index -ge 0 -and $Index -lt 10 } -Parameter 'Index' -Index 5 -Message 'Index must be greater then or equal to  0 and less than 9'

        True

        Index of 5 is in range [0, 9).

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-ErrorId

        .LINK
        Initialize-PSCmdlet

        .LINK
        Invoke-Command

        .LINK
        New-ErrorRecord

        .LINK
        Write-Error

       .LINK
       Write-Output
    #>
}

<#
    Confirm-ArgumentNotEmpty
#>
function Confirm-ArgumentNotEmpty {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullEmptyOrEmpty()]
        [string]
        $Parameter,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Collections.ICollection]
        $Collection,

        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (($null -eq $Collection) -or ($Collection.Count -lt 1)) {
        if (Test-PSParameter -Name 'Message' -Parameters $PSBoundParameters) {
            $exception = [System.ArgumentNullException]::new($Parameter, $Message)
        }
        else {
            $exception = [System.ArgumentNullException]::new($Parameter)
        }

        $newErrorRecordSplat = @{
            Exception     = $exception
            ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'InvalidArgument'
            TargetObject  = $Value
            TargetName    = $Parameter
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $false | Write-Output
    }
    else {
        Write-Verbose -Message "$($CmdletName) : Parameter '$($Parameter)' is not empty"
        $true | Write-Output
    }
}

<#
    Confirm-ArgumentNotNull
#>
function Confirm-ArgumentNotNull {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Parameter,

        [Parameter(Mandatory)]
        [AllowNull()]
        [System.Object]
        $Value,

        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($null -eq $Value) {
        if (Test-PSParameter -Name 'Message' -Parameters $PSBoundParameters) {
            $exception = [System.ArgumentNullException]::new($Parameter, $Message)
        }
        else {
            $exception = [System.ArgumentNullException]::new($Parameter)
        }

        $newErrorRecordSplat = @{
            Exception     = $exception
            ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'InvalidArgument'
            TargetObject  = $Value
            TargetName    = $Parameter
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
    }
    else {
        Write-Verbose -Message "$($CmdletName) : Parameter '$($Parameter)' is not null"
    }
}

<#
    Confirm-ArgumentNotNullOrEmpty
#>
function Confirm-ArgumentNotNullOrEmpty {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Parameter,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ([string]::IsNullOrEmpty($Value)) {
        if (Test-PSParameter -Name 'Message' -Parameters $PSBoundParameters) {
            $exception = [System.ArgumentNullException]::new($Parameter, $Message)
        }
        else {
            $exception = [System.ArgumentNullException]::new($Parameter)
        }

        $newErrorRecordSplat = @{
            Exception     = $exception
            ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'InvalidArgument'
            TargetObject  = $Value
            TargetName    = $Parameter
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $false | Write-Output
    }
    else {
        Write-Verbose -Message "$($CmdletName) : Parameter '$($Parameter)' is not null or empty"
        $true | Write-Output
    }
}

<#
    Confirm-ArgumentNotNullOrWhiteSpace
#>
function Confirm-ArgumentNotNullOrWhiteSpace {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Parameter,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Value,

        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ([string]::IsNullOrWhiteSpace($Value)) {
        if (Test-PSParameter -Name 'Message' -Parameters $PSBoundParameters) {
            $exception = [System.ArgumentNullException]::new($Parameter, $Message)
        }
        else {
            $exception = [System.ArgumentNullException]::new($Parameter)
        }

        $newErrorRecordSplat = @{
            Exception     = $exception
            ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'InvalidArgument'
            TargetObject  = $Value
            TargetName    = $Parameter
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $false | Write-Output
    }
    else {
        Write-Verbose -Message "$($CmdletName) : Parameter '$($Parameter)' is not null or empty or all whitespace"
        $true | Write-Output
    }
}

<#
    Confirm-ArgumentValid
#>
function Confirm-ArgumentValid {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [scriptblock]
        $Condition,

        [Parameter(Mandatory)]
        [ValidateNotNullEmpty()]
        [string]
        $Parameter,

        [Parameter(Mandatory)]
        [psobject]
        $Value,

        [ValidateNotNullOrEmpty()]
        [string]
        $Message
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Invoke-Command -ScriptBlock $Condition -ArgumentList $Value) {
        Write-Verbose -Message "$($CmdletName) : Parameter '$($Parameter)' with Value '$($Value)' is valid"
        $true | Write-Output
    }
    else {
        if (Test-PSParameter -Name 'Message' -Parameters $PSBoundParameters) {
            $exception = [System.ArgumentException]::new($Message, $Parameter)
        }
        else {
            $exception = [System.ArgumentException]::new("Parameter '$($Parameter)' with Value '$($Value)' is invalid", $Parameter)
        }

        $newErrorRecordSplat = @{
            Exception     = $exception
            ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'InvalidArgument'
            TargetObject  = $Value
            TargetName    = $Parameter
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $false | Write-Output
    }
}

<#
    Confirm-CommandFound
#>
function Confirm-CommandFound {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [switch]
        $All,

        [ValidateSet('Alias', 'All', 'Application', 'Cmdlet', 'ExternalScript', 'Filter', 'Function','Script')]
        [System.Management.Automation.CommandTypes]
        $CommandType = 'All'
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Name | ForEach-Object -Process {
            if ($All.IsPresent -or ($CommandType -eq 'All')) {
                if (Get-Command -All | Where-Object -Property Name -EQ $_ | Measure-Object | Select-Object -ExpandProperty Count) {
                    Write-Verbose -Message "$($CmdletName) : Command Name '$($_)' found"
                    $true | Write-Output
                }
                else {
                    $message = "Command Name '$($_)' not found"
                    $exception = [System.Management.Automation.CommandNotFoundException]::new($nessage)

                    $newErrorRecordSplat = @{
                        Exception     = $exception
                        ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'CommandNotFoundException' -Position $MyInvocation.ScriptLineNumber
                        ErrorCategory = 'ObjectNotFound'
                        TargetObject  = $_
                        TargetName    = 'Name'
                    }

                    New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    $false | Write-Output
                }
            }
            else {
                if (Get-Command -CommandType $CommandType | Where-Object -Property Name -EQ $_ | Measure-Object | Select-Object -ExpandProperty Count) {
                    Write-Verbose -Message "$($CmdletName) : Command Name '$($_)' of Command Type '$($CommandType)' found"
                    $true | Write-Output
                }
                else {
                    $message = "Command Name '$($_)' of CommandType '$($CommandType)' not found"
                    $exception = [System.Management.Automation.CommandNotFoundException]::new($message)

                    $newErrorRecordSplat = @{
                        Exception     = $exception
                        ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'CommandNotFoundException' -Position $MyInvocation.ScriptLineNumber
                        ErrorCategory = 'ObjectNotFound'
                        TargetObject  = $_
                        TargetName    = 'Name and CommandType'
                    }

                    New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    $false | Write-Output
                }
            }
        }
    }
}

<#
    Confirm-DirectoryFound
#>
function Confirm-DirectoryFound {
    [CmdletBinding(DefaultParameterSet = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                if (Test-Path -LiteralPath $_ -PathType Container) {
                    Write-Verbose -Message "$($CmdletName) : Directory Path '$($_)' found"
                    $true | Write-Output
                }
                else {
                    $message = "Directory Path '$($_)' not found"
                    $exception = [System.IO.DirectoryNotFoundException]::new($message)

                    $newErrorRecordSplat = @{
                        Exception     = $exception
                        ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
                        ErrorCategory = 'ObjectNotFound'
                        TargetObject  = $_
                        TargetName    = 'LiteralPath'
                    }

                    New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
                    $false | Write-Output
                }
            }
        }
        else {
            $LiteralPath = $Path | Resolve-Path
            Confirm-DirectoryFound -LiteralPath $LiteralPath | Write-Output
        }
    }
}

<#
    Confirm-FileFound
#>
function Confirm-FileFound {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Verbose -Message "$($CmdletName) : File Path '$($Path)' found"
        $true | Write-Output
    }
    else {
        $message = "File Path '$($Path)' not found"
        $exception = [System.IO.FileNotFoundException]::new($message, $Path)

        $newErrorRecordSplat = @{
            Exception     = $exception
            ErrorId       = Format-ErrorId -Caller $CmdletName -Name 'FileNotFoundException' -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'ObjectNotFound'
            TargetObject  = $Path
            TargetName    = 'Path'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $false | Write-Output
    }
}

<#
    Format-CategoryActivity
#>
function Format-CategoryActivity {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Exception]
        $Exception
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ("Source '$($Exception.Source)' threw Exception '$($Exception.GetType().Name)'") | Write-Output
}

<#
    Format-CategoryReason
#>
function Format-CategoryReason {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Exception]
        $Exception
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ("Exception '$($Exception.GetType().Name)' thrown") | Write-Output
}

<#
    Format-CategoryTargetName
#>
function Format-CategoryTargetName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Exception]
        $Exception
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ("TargetSite Name '$($Exception.TargetSite.Name)'") | Write-Output
}

<#
    Format-ErrorId
#>
function Format-ErrorId {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Caller,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483647)]
        [int]
        $Position
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ('{0}-{1}-{2:d2}' -f $Caller, $Name, $Position) | Write-Output
}

<#
    Format-Exception
#>
function Format-Exception {
    [CmdletBinding(DefaultParameterSetName = 'UsingErrorRecord')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingErrorRecord')]
        [System.Management.Automation.ErrorRecord[]]
        $ErrorRecord,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingException')]
        [System.Exception[]]
        $Exception
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingException') {
            $Exception | ForEach-Object -Process {
                $name = $_.GetType().Name
                Write-Warning -Message "$($CmdletName) : Exception $($name) thrown"
                $_.ToString() | Write-Output
            }
        }
        else {
            $ErrorRecord | ForEach-Object -Process {
                $name = $_.Exception.GetType().Name

                Write-Warning -Message "$($CmdletName) : ErrorRecord with Exception $($Name) thrown"
                $_.Exception.ToString() | Write-Output
            }
        }
    }

    <#
        .SYNOPSIS
        Formats an Exception object for output to the pipeline as a string.

        .DESCRIPTION
        `Format-Exception` formats an Exception object for output to the pipeline as a string.

        .PARAMETER ErrorRecord
        Specifies the ErrorRecord containing the Exception object to format.

        .PARAMETER Exception
        Specifies the Exception object to format.

        .INPUTS
        [System.Management.Automation.ErrorRecord[]]  `Format-Exception` accepts ErrorRecord objects from the pipeline.

        [System.Exception[]]  `Format-Exception` accepts Exception objects from the pipeline by property name.

        .OUTPUTS
        [string]  `Format-Exception` outputs a string representation of the Exception object to the pipeline.

        .EXAMPLE
        PS> $Exception = [System.InvalidOperationException]::new('An invalid operation was attempted')

        System.InvalidOperationException: An invalid operation was attempted

        The string representation of the Exception object is output to the pipeline.

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Initialize-PSCmdlet

        .LINK
        ForEach-Object

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<#
    Format-LastExitCode
#>
function Format-LastExitCode {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [int[]]
        $Success = 0,

        [int[]]
        $Failure = 1,

        [int]
        $SystemError = -1
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $exitCode = ('0x{0:X8}|{0}' -f $LASTEXITCODE)

    if ($LASTEXITCODE -in $Success) {
        ("Last Exit Code '$($exitCode)' indicates success") | Write-Output
    } elseif ($LASTEXITCODE -in $Failure) {
        $message = "Last Exit Code '$($exitCode)' indicates failure"

        $newErrorRecordSplat = @{
            Exception = [System.InvalidOperationException]::new($message)
            ErrorId = Format-ErrorId -Caller $CmdletName -Name $Name -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'InvalidResult'
            TargetObject = $Name
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $message | Write-Output
    } elseif ($LASTEXITCODE -le $SystemError) {
        $exception = [System.Runtime.InteropServices.Marshal]::GetExceptionForHR($LASTEXITCODE)

        if ($null -ne $exception) {
            $exceptionName = $exception.GetType().Name
        } else {
            $exception = [System.InvalidOperationException]::new()
            $exceptionName = 'Unknown'
        }

        $message = "Last Exit Code '$($exitCode)' indicates either a Win32 or System Error"

        $newErrorRecordSplat = @{
            Exception = $exception
            ErrorId = Format-ErrorId -Caller $CmdletName -Name $exceptionName -Position $MyInvocation.ScriptLineNumber
            ErrorCategory = 'InvalidOperation'
            Message = $message
            TargetObject = $Name
            TargetName = 'Name'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Error -ErrorAction Continue
        $message | Write-Output
    }

    <#
        .SYNOPSIS
        Processes the `LASTEXITCODE` automatic variable for `Success`, `Failure`, or `SystemError`.

        .DESCRIPTION
        `Format-LastExitCode` processes the `LASTEXITCODE` automatic variable for `Success`, `Failure`, or `SystemError`.

        .PARAMETER Name
        Specifies the name of the process or script that exited with `LASTEXITCODE`.

        .PARAMETER Success
        Specifies the array of integers that membership in indicates success.

        .PARAMETER Failure
        Specifies the array of integers that memberhip in indicates failure.

        .PARAMETER SystemError
        Specifies the integer that, if `LASTEXITCODE` is less than or equal to, indicates a Win32 or System Error.

        .INPUTS
        None.  `Format-LastExitCode` does not accept input from the pipeline.

        .OUTPUTS
        None.  `Format-LastExitCode` does not output objects to the pipeline.

        .EXAMPLE
        PS> Format-LastExitCode -Name 'MyScript' -Success 0 -Failure 1 -SystemError -1 -Verbose
        PS> $LASTEXITCODE -eq 0

        . . . "Last Exit Code '0x00000000|0' indicates success"

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-ErrorId

        .LINK
        Initialize-PSCmdlet

        .LINK
        New-ErrorRecord

        .LINK
        Write-Error

        .LINK
        Write-Fatal

        .LINK
        Write-Verbose
    #>
}

<#
    Format-RecommendedAction
#>
function Format-RecommendedAction {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Exception]
        $Exception
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    ("Fix cause of exception '$($Exception.GetType().Name)'") | Write-Output
}

<#
    Get-Exception
#>
function Get-Exception {
    [CmdletBinding()]
    [OutputType([System.Exception])]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $ErrorRecord.Exception | Write-Output
}

<#
    Get-FullyQualifiedErrorId
#>
function Get-FullyQualifiedErrorId {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $ErrorRecord.FullyQualifiedErrorId | Write-Output
}

<#
    Get-ErrorCategory
#>
function Get-ErrorCategory {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ErrorCategory])]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $ErrorRecord.CategoryInfo.Category | Write-Output
}

<#
    Get-TargetObject
#>
function Get-TargetObject {
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $ErrorRecord.TargetObject | Write-Output
}

<#
    New-ErrorDetail
#>
function New-ErrorDetail {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.ErrorDetails])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [ValidateNotNullOrEmpty()]
        [string]
        $RecommendedAction
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($PSCmdlet.ShouldProcess($Message, $CmdletName)) {
        $errDetails = [System.Management.Automation.ErrorDetails]::new($Message)
    }

    if (Test-PSParameter -Name 'RecommendedAction' -Parameters $PSBoundParameters) {
        if ($PSCmdlet.ShouldProcess($RecommendedAction, $CmdletName)) {
            $errDetails.RecommendedAction = $RecommendedAction
        }
    }

    if ($PSCmdlet.ShouldProcess("Output New Error Details to PowerShell Pipeline", $CmdletName)) {
        $errDetails | Write-Output
    }
    else {
        $null | Write-Output
    }
}

<#
    New-ErrorRecord
#>
function New-ErrorRecord {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingException')]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('NotSpecified', 'OpenError', 'CloseError', 'DeviceError',
            'DeadlockDetected', 'InvalidArgument', 'InvalidData',
            'InvalidOperation', 'InvalidResult', 'InvalidType', 'MetadataError',
            'NotImplemented', 'NotInstalled', 'ObjectNotFound',
            'OperationStopped', 'OperationTimeout', 'SyntaxError', 'ParserError',
            'PermissionDenied', 'ResourceBusy', 'ResourceExists',
            'ResourceUnavailable', 'ReadError', 'WriteError', 'FromStdErr',
            'SecurityError', 'ProtocolError', 'ConnectionError',
            'AuthenticationError', 'LimitsExceeded', 'QuotaExceeded',
            'NotEnabled')]
        [Alias('Category')]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ErrorId,

        [Parameter(Mandatory, ParameterSetName = 'UsingException')]
        [System.Exception]
        $Exception,

        [Parameter(Mandatory, ParameterSetName = 'UsingHResult')]
        [ValidateRange(-2147483648, 0)]
        [int]
        $HResult,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [System.Object]
        $TargetObject,

        [ValidateNotNullOrEmpty()]
        [Alias('CategoryActivity')]
        [string]
        $Activity,

        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [ValidateNotNullOrEmpty()]
        [Alias('CategoryReason')]
        [string]
        $Reason,

        [ValidateNotNullOrEmpty()]
        [string]
        $RecommendedAction,

        [ValidateNotNullOrEmpty()]
        [Alias('CategoryTargetName')]
        [string]
        $TargetName,

        [ValidateNotNullOrEmpty()]
        [Alias('CategoryTargetType')]
        [string]
        $TargetType
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (-not (Test-PSParameter -Name 'Message' -Parameters $PSBoundParameters)) {
        $Message = $Exception.Message
    }

    if (($PSCmdlet.ParameterSetName -eq 'UsingHResult') -and ($HResult -lt 0)) {
        $Exception = [System.Runtime.InteropServices.Marshal]::GetExceptionForHR($HResult)

        if ($null -eq $Exception) {
            $Exception = [System.InvalidOperationException]::new($Message)
        }
    }

    # used only by ShouldProcess() for it's target string
    $exText = $Exception.GetType().Name
    $category = $ErrorCategory.ToString()
    $target = [System.Type]::GetType($TargetObject).FullName

    if ($PSCmdlet.ShouldProcess(@($exText, $ErrorId, $category, $target), $CmdletName)) {
        $err = [System.Management.Automation.ErrorRecord]::new($Exception, $ErrorId, $ErrorCategory, $TargetObject)

        if (Test-PSParameter -Name 'Activity' -Parameters $PSBoundParameters) {
            $err.CategoryInfo.Activity = $Activity
        }
        else {
            $err.CategoryInfo.Activity = (Format-CategoryActivity -Exception $Exception)
        }

        if (Test-PSParameter -Name 'Reason' -Parameters $PSBoundParameters) {
            $err.CategoryInfo.Reason = $Reason
        }
        else {
            $err.CategoryInfo.Reason = (Format-CategoryReason -Exception $Exception)
        }

        if (Test-PSParameter -Name 'TargetName' -Parameters $PSBoundParameters) {
            $err.CategoryInfo.TargetName = $TargetName
        }
        else {
            $err.CategoryInfo.TargetName = (Format-CategoryTargetName -Exception $Exception)
        }

        if (Test-PSParameter -Name 'TargetType' -Parameters $PSBoundParameters) {
            $err.CategoryInfo.TargetType = $TargetType
        }
        else {
            $err.CategoryInfo.TargetType = [System.Type]::GetType($TargetObject).FullName
        }

        if (Test-PSParameter -Name 'RecommendedAction' -Parameters $PSBoundParameters) {
            $err.ErrorDetails = New-ErrorDetail -Message $Message -RecommendedAction $RecommendedAction
        }
        else {
            $err.ErrorDetails = New-ErrorDetail -Message $Message -RecommendedAction (Format-RecommendedAction -Exception $Exception)
        }
    }

    $err | Write-Output

    <#
        .SYNOPSIS
        Creates a new ErrorRecord object.

        .DESCRIPTION
        `New-ErrorRecord` creates a new ErrorRecord object.

        .PARAMETER ErrorCategory
        Specifies the [System.Management.Automation.ErrorCategory] for the ErrorRecord.

        Allowed values are:

          Error Category        Description
          --------------        -----------
        * NotSpecified:         This should never be used.
        * OpenError:            An error occurred while opening a file.
        * CloseError:           An error occurred while closing a file.
        * DeviceError:          An error occurred while accessing a device.
        * DeadlockDetected:     A deadlock condition was detected.
        * InvalidArgument:      An invalid argument was passed to a cmdlet.
        * InvalidData:          Invalid data was passed to a cmdlet.
        * InvalidOperation:     An invalid operation was attempted.
        * InvalidResult:        An invalid result was returned from a cmdlet.
        * InvalidType:          An invalid type was passed to a cmdlet.
        * MetadataError:        An error occurred while accessing metadata.
        * NotImplemented:       The requested operation is not implemented.
        * NotInstalled:         The requested operation is not installed.
        * ObjectNotFound:       The requested object was not found.
        * OperationStopped:     The operation was stopped.
        * OperationTimeout:     The operation timed out.
        * SyntaxError:          A syntax error occurred.
        * ParserError:          A parser error occurred.
        * PermissionDenied:     Permission was denied.
        * ResourceBusy:         A resource was busy.
        * ResourceExists:       A resource already exists.
        * ResourceUnavailable:  A resource was unavailable.
        * ReadError:            An error occurred while reading a file.
        * WriteError:           An error occurred while writing a file.
        * FromStdErr:           An error occurred either while reading from standard error, or an error was parsed on standard error.
        * SecurityError:        A security error occurred.
        * ProtocolError:        A protocol error occurred.
        * ConnectionError:      A connection error occurred.
        * AuthenticationError:  An authentication error occurred.
        * LimitsExceeded:       Limits were exceeded.
        * QuotaExceeded:        A quota was exceeded.
        * NotEnabled:           The requested operation is not enabled.
        * NotSupported:         The requested operation is not supported.

        This parameter is mandatory.  Use of `NotSpecified` deprives the script stack trace of useful debugging information and is strongly discouraged.

        .PARAMETER ErrorId
        Specifies a unique string identifying this [errorrecord] used to generate the `FullyQualifiedErrorId`.  This parameter is mandatory.

        .PARAMETER Exception
        Specifies the exception to be wrapped by this [errorrecord].  Either `Exception` or `HRresult` are mandatory with `Exception` preferred.  Do not pass a general exception such as [System.Exception], but be as specific as possible.  If `Exception` is used, the `HRresult` parameter is ignored.

        .PARAMETER HResult
        Specifies the HResult to search for a [System.Exception] which will be assigned to the `Exception` parameter.  Either `Exception` or `HRresult` are mandatory with `Exception` preferred.  If `HRresult` is used, the `Exception` parameter is ignored.  If `HResult` is zero or [Systeml.Runtime.InteropServices.Marshal]::GetExceptionForHR($HResult) returns `$null`, $Exception is set to a new instance of [System.InvalidOperationException].

        .PARAMETER TargetObject
        Specifies the object or value that is the root cause of the error.  This parameter is mandatory.  Setting this value to $null, while legal, is highly discouraged.  This parameter is mandatory.

        .PARAMETER Activity
        Specifies the activity that was being performed when the error occurred.  This parameter is optional.  If it is not privded, the result of `Format-CategoryActivity` will be used instead.  `Activity` is stored in `CategoryInfo`.

        .PARAMETER Message
        Specifies the Message wrapped by the [errorrecord].  `Message` is optional.  If it is not provided, `Exception.Message` will be used instead.  `Message` is stored in `ErrorDetails`.

        .PARAMETER Reason
        Specifies the reason for the error.  This parameter is optional.  If it is not provided, the result of `Format-CategoryReason` will be used instead.  `Reason` is stored in `CategoryInfo`.

        .PARAMETER RecommendedAction
        Specifies the recommend action for the error.  This parameter is optional.  If it is not provided, the result of `Format-RecommendedAction` will be used instead.  `RecommendedAction` is stored in `ErrorDetails`.

        .PARAMETER TargetName
        Specifies the target name of the `TargetObject`.  This parameter is optional.  If it is not provided, the result of `Format-CategoryTargetName` will be used instead.  `TargetName` is stored in `CategoryInfo`.  It is typically set to a parameter name.

        .PARAMETER TargetType
        Specifies the target type of the `TargetObject`.  This parameter is optional.  If it is not provided, the type of the `TargetObject` will be used instead.  `TargetType` is stored in `CategoryInfo`.

        .INPUTS
        None.  `ErrorRecord` does not accept input from the pipeline.

        .OUTPUTS
        [errorrecord]  `ErrorRecord` outputs an [errorrecord] object to the pipeline.

        .EXAMPLE
        PS> $Exception = [System.InvalidOperationException]::new('An invalid operation was attempted')
        PS> $ErrorId = Format-ErrorId -Caller 'Some-Cmdlet' -Name 'InvalidOperationException' -Position $MyInvocation.ScriptLineNumber
        PS> $ErrorRecord = New-ErrorRecord -Exception $Exception -ErrorCategory 'InvalidOperation' -ErrorId $ErrorId -TargetObject $Some-Object-In-Error

        A new [errorrecord] object is created and stored in the variable `$ErrorRecord`.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ConvertTo-String

        .LINK
        Format-CategoryActivity

        .LINK
        Format-CategoryReason

        .LINK
        Format-CategoryTargetName

        .LINK
        Format-RecommendAction

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Test-ObjectNotFound
#>
function Test-ObjectNotFound {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingFilterScript')]
        [switchblock]
        $FilterScript,

        [Parameter(Mandatory, ParameterSetName = 'UsingProperty')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Property,

        [Parameter(Mandatory, ParameterSetName = 'UsingProperty')]
        [AllowNull()]
        [System.Object]
        $Value,

        [Parameter(Mandatory)]
        [AllowNull()]
        [System.Object]
        $TargetObject
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (($PSCmdlet.ParameterSetName -eq 'UsingFilterScript') -and ($TargetObject | Where-Object -FilterScript $FilterScript)) {
        Write-Verbose -Message "$($CmdletName) : TargetObject found according to FilterScript"
        $false | Write-Output
    } elseif ($PSCmdlet.ParameterSetName -eq 'UsingProperty' -and ($TargetObject | Where-Object -Property $Property -NE $Value)) {
        Write-Verbose -Message "$($CmdletName) : TargetObject found because at least one instance has 'Property' != 'Value'"
        $false | Write-Output
    } else {
        Write-Warning -Message "$($CmdletName) : TargetObject not found"
        $true | Write-Output
    }

    <#
        .SYNOPSIS
        Tests `TargetObject` for existence based on either `FilterScript` or `Property` and `Value`.

        .DESCRIPTION
        `Test-ObjectNotFound` tests `TargetObject` for existence based on either `FilterScript` or `Property` and `Value`.

        If `FilterScript` is used, the script block must return `$true` for the object to be found.

        If `Property` and `Value` are used, the object is found if at least one instance has `Property` not equal to `Value`.

        .PARAMETER FilterScript
        Specifies the script block to use to test `TargetObject`.  If the script block returns `$true`, the object is found.

        .PARAMETER Property
        Specifies the property to test for `Value`.

        .PARAMETER Value
        Specifies the value to test for `Property`.  If `Property` is not equal to `Value`, the object is found.

        .PARAMETER TargetObject
        Specifies the object to test for existence.

        .INPUTS
        None.  `Test-ObjectNotFound` does not accept input from the pipeline.

        .OUTPUTS
        [bool]  `Test-ObjectNotFound` outputs a boolean value indicating whether the object was found.  It returns `$true` if the object was not found; otherwise, it returns `$false` if the object was found.

        .EXAMPLE
        PS> $Value = 'Red'
        PS> @('Red', 'Green', 'Blue') | ForEach-Object -Process { Test-ObjectNotFound -FilterScript { $_ -eq 'Value' } -TargetObject $Value -Verbose }

        True

        . . . Target object not found

        .NOTES
        Copyright © 2025, John Merryweather Cooper.  All Rights Reserved.

        .LINKS
        about_CommonParameters

        .LINKS
        about_Functions_Advanced

        .LINKS
        Initialize-PSCmdlet

        .LINKS
        Where-Object

        .LINKS
        Write-Output

        .LINKS
        Write-Verbose

        .LINKS
        Write-Warning
    #>
}

<#
    Write-Fatal
#>
function Write-Fatal {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,

        [switch]
        $Throw
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $ErrorRecord | ForEach-Object -Process {
            $_ | Write-Error -ErrorAction Continue

            $target = ("Throwing Terminating Error for '{0}'" -f $_.Exception.GetType().Name)

            if ($PSCmdlet.ShouldProcess($target, $CmdletName)) {
                if ($Throw.IsPresent) {
                    throw $_.Exception
                }
                else {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            }
        }
    }

    <#
        .SYNOPSIS
        Write [errorrecord] and throw either a hard exception or a soft exception.

        .DESCRIPTION
        `Write-Fatal` writes an [errorrecord] and throws either a hard exception or a soft exception.

        .PARAMETER ErrorRecord
        Specifies the [errorrecord] to write and throw.

        .PARAMETER Throw
        If present, Write-Fatal throws a hard exception by rethrowing the exception contained by `ErrorRecord`; otherwise, a soft exception by calling `$PSCmdlet.ThrowTerminatingError(`ErrorRecrod`) is thrown.

        .INPUTS
        [errorrecord]  `Write-Fatal` receives error records from the pipeline.

        .OUTPUTS
        None.  `Write-Fatal` does not output objects to the pipeline.

        .EXAMPLE
        PS> New-ErrorRecord -ErrorCategory 'InvalidOperation' -ErrorId 'MyError' -Exception ([System.InvalidOperationException]::new('An invalid operation was attempted')) | Write-Fatal
        PS> $Error[0].Exception.GetType().Name -eq 'InvalidOperationException'

        True

        $ErrorRecord is written to the error stream and a soft terminating error is thrown.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        about_Throw

        .LINK
        ForEach-Object

        .LINK
        Initialize-PSCmdlet

        .LINK
        Write-Error
    #>
}
