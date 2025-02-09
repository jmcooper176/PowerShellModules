#requires -version 7.4

using module ErrorRecordType
using module MessageSource
using module MessageType
using module Metadata
using module Origin
using module TypeAccelerator

<#
    class:  Message
#>
class Message {
    <#
        Public Properites
    #>
    [string]$ClassName

    [ValidateNotNull()]
    [Orgin]$Origin

    [ValidateSet('CommandLineError', 'CompileTimeWarning', 'CompileTimeError', 'ScriptHost', 'ScriptInfo', 'ScriptVerbose',
        'ScriptWarning', 'ScriptError', 'ScriptDebug', 'ScriptTrace', 'CmdletHost', 'CmdletInfo', 'CmdletVerbose', 'CmdletWarning',
        'CmdletError', 'CmdletDebug', 'CmdletTrace', 'SystemError', 'Exception')]
    [MessageSource]$Source

    [ValidateSet('Console', 'Debug', 'Error', 'Fatal', 'Trace', 'Verbose', 'Warning')]
    [MessageType]$Type

    [ValidateNotNull()]
    [DateTime]$TimeStamp

    [ValidateNotNull()]
    [Metadata]$Metadata

    <#
        Constructor
    #>
    Message($Origin) {
        $this.ClassName = Initialize-PSClass -Name [Message].Name

        $this.Origin = $Origin
        $this.Type = [MessageType]::Console
        $this.TimeStamp = Get-UtcDate
        $this.Metadata = [Metadata]::new($this.Type, 0)
        $this.Source = [MessageSource]::CmdletHost
    }

    Message([Origin]$Origin, [Metadata]$Metadata) {
        $this.ClassName = Initialize-PSClass -Name [Message].Name

        $this.Origin = $Origin
        $this.TimeStamp = Get-UtcDate
        $this.Metadata = $Metadata
        $this.Type = $this.Metadata.MessageType

        switch ($this.Type) {
            [MessageType]::Console { $this.Source = [MessageSource]::CmdletHost; break }
            [MessageType]::Debug { $this.Source = [MessageSource]::ScriptDebug; break }
            [MessageType]::Error { $this.Source = [MessageSource]::ScriptError; break }
            [MessageType]::Fatal { $this.Source = [MessageSource]::SystemError; break }
            [MessageType]::Trace { $this.Source = [MessageSource]::ScriptTrace; break }
            [MessageType]::Verbose { $this.Source = [MessageSource]::ScriptVerbose; break }
            [MessageType]::Warning { $this.Source = [MessageSource]::ScriptWarning; break }
            default { $this.Source = [MessageSource]::ScriptInfo; break }
        }
    }

    Message([Origin]$Origin, [MessageType]$Type, [Metadata]$Metadata) {
        $this.ClassName = Initialize-PSClass -Name [Message].Name

        $this.Origin = $Origin
        $this.Type = $Type
        $this.TimeStamp = Get-UtcDate
        $this.Metadata = $Metadata

        switch ($this.Type) {
            [MessageType]::Console { $this.Source = [MessageSource]::CmdletHost; break }
            [MessageType]::Debug { $this.Source = [MessageSource]::ScriptDebug; break }
            [MessageType]::Error { $this.Source = [MessageSource]::ScriptError; break }
            [MessageType]::Fatal { $this.Source = [MessageSource]::SystemError; break }
            [MessageType]::Trace { $this.Source = [MessageSource]::ScriptTrace; break }
            [MessageType]::Verbose { $this.Source = [MessageSource]::ScriptVerbose; break }
            [MessageType]::Warning { $this.Source = [MessageSource]::ScriptWarning; break }
            default { $this.Source = [MessageSource]::ScriptInfo; break }
        }
    }

    <#
        Public Methods
    #>
    [string]ToString([switch]$Capitalize, [string]$Format, [object[]]$ArgumentList) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $buffer = New-StringBuilder -Value $this.Origin.ToString()

        Add-End -Buffer $buffer -Value ' : '
        Add-End -Buffer $buffer -Value $this.Metadata.ToString($Capitalize)
        Add-End -Buffer $buffer -Value ' : '
        Add-End -Buffer $buffer -String [Message]::FormatString($Format, $ArgumentList)

        return $buffer.ToString()
    }

    <#
        Static Public Methods
    #>
    static [string]FormatCompact([double]$Double, [int]$Significant)

    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Significant -lt 0 -or $Signicant -gt 8) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Significant',
            $Significant,
            "$($MethodName) : Parameter 'Significant' value must be in the range [0, 8].")
    }

    return ("{0:f$($Significant)}" -f $Double)
}

static [string]FormatCompact([float]$float, [int]$Significant)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Significant -lt 0 -or $Signicant -gt 8) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Significant',
            $Significant,
            "$($MethodName) : Parameter 'Significant' value must be in the range [0, 8].")
    }

    return "{0:g$($Significant)}" -f $Float
}

static [string]FormatCurrency([decimal]$Decimal) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:c}' -f $Decimal)
}

static [string]FormatCurrency([double]$Double) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:c}' -f $Double)
}

static [string]FormatCurrency([float]$Float) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:c}' -f $Float)
}

static [string]FormatDateTime([DateTime]$Date, [switch]$Invariant) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Invariant.IsPresent) {
        return ('{0:o}' -f $Date)
    }
    else {
        return ('{0}' -f $Date)
    }
}

static [string]FormatDateTime([DateTime]$Date, [switch]$Iso8601, [switch]$Utc, [switch]$Rfc1123) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Iso8601.IsPresent -and $Utc.IsPresent) {
        return ('{0:u}' -f $Date)
    }
    elseif ($Iso8601.IsPresent) {
        return ('{0:s}' -f $Date)
    }
    elseif ($Rfc1123.IsPresent) {
        return ('{0:r}' -f $Date)
    }
    else {
        return ('{0}' -f $Date)
    }
}

static [string]FormatDateTime([DateTime]$Date, [string]$Format = 'dddd, MMMM d, yyyy hh:mm:ss tt') {
    Initialize-PSMethod -MyInvocation $MyInvocation

    if (-not [string]::IsNullOrEmpty('Format')) {
        return ("{0:$($Format)}" -f $Date)
    }
    else {
        return ('{0}' -f $Date)
    }
}

static [string]FormatFixed (
    [double]
    $Double,

    [ValidateRange(0, 8)]
    [int]
    $Places)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Places -lt 0 -or $Places -gt 8) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Places',
            $Places,
            "$($MethodName) : Parameter 'Places' value must be in the range [0, 8].")
    }

    return ("{0:f$($Places)}" -f $Double)
}

static [string]FormatFixed ([float]$Float, [int]$Places)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Places -lt 0 -or $Places -gt 8) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Places',
            $Places,
            "$($MethodName) : Parameter 'Places' value must be in the range [0, 8].")
    }

    return ("{0:f$($Places)}" -f $Float)
}

static [string]FormatHex([int]$Integer, [int]$Pad, [switch]$UpperCase)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Pad -lt 0 -or $Pad -gt 20) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Pad',
            $Pad,
            "$($MethodName) : Parameter 'Pad' value must be in the range [0, 20].")
    }

    if ($UpperCase.IsPresent) {
        return ('0x{0:X$($Pad)}' -f $Interger)
    }
    else {
        return ('0x{0:x$($Pad)}' -f $Integer)
    }
}

static [string]FormatHex([long]$Long, [int]$Pad, [switch]$UpperCase)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Pad -lt 0 -or $Pad -gt 20) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Pad',
            $Pad,
            "$($MethodName) : Parameter 'Pad' value must be in the range [0, 20].")
    }

    if ($UpperCase.IsPresent) {
        return ('0x{0:X$($Pad)}' -f $Long)
    }
    else {
        return ('0x{0:x$($Pad)}' -f $Long)
    }
}

static [string]FormatNumeric([double]$Double, [int]$Precision)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Precision -lt 0 -or $Precision -gt 8) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Precision',
            $Precision,
            "$($MethodName) : Parameter 'Precision' value must be in the range [0, 8].")
    }

    return ("{0:n$($Precision)}" -f $Double)
}

static [string]FormatNumeric([float]$Float, [int]$Precision)
{
    Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Precision -lt 0 -or $Precision -gt 8) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Precision',
            $Precision,
            "$($MethodName) : Parameter 'Precision' value must be in the range [0, 8].")
    }

    return ("{0:n$($Precision)}" -f $Float)
}

static [string]FormatPadded([int]$Integer, [int]$Pad)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Pad -lt 0 -or $Pad -gt 132) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Pad',
            $Pad,
            "$($MethodName) : Parameter 'Pad' value must be in the range [0, 132].")
    }

    return ("{0:d$($Pad)}" -f $Integer)
}

static [string]FormatPadded([long]$Long, [int]$Pad)
{
    $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

    if ($Pad -lt 0 -or $Pad -gt 132) {
        throw [System.ArgumentOutOfRangeException]::new(
            'Pad',
            $Pad,
            "$($MethodName) : Parameter 'Pad' value must be in the range [0, 132].")
    }

    return ("{0:d$($Pad)}" -f $Long)
}

static [string]FormatPercent ([double]$Double) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:p}' -f $Double)
}

static [string]FormatPercent ([float]$Float) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:p}' -f $Float)
}

static [string]FormatReversible([double]$Double) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:r}' -f $Double)
}

static [string]FormatReversible([float]$Float) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:r}' -f $Float)
}

static [string]FormatScientific([double]$Double) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:e}' -f $Double)
}

static [string]FormatScientific([float]$Float) {
    Initialize-PSMethod -MyInvocation $MyInvocation

    return ('{0:e}' -f $Float)
}

static [string]FormatString([string]$Format, [System.Object[]]$ArgumentList)
{
    Initialize-PSMethod -MyInvocation $MyInvocation

    if (($null -ne $ArgumentList) -and ($ArgumentList.Count -gt 0)) {
        return ($Format -f $ArgumentList)
    }
    else {
        return $Format
    }
}

<#
    Constants
#>
Set-Variable -Name CMDLINE_FMT -Option Constant -Value 'Command line error : {0} : {1}`n{2}'

Set-Variable -Name COMPILER_WARN_FMT -Option Constant -Value '{0} : warning {1} : {2}`n{3}'
Set-Variable -Name COMPILER_ERROR_FMT -Option Constant -Value '{0} : error {1} : {2}`n{3}'

Set-Variable -Name SCRIPT_HOST_FMT -Option Constant -Value '{0} : console : {1}'
Set-Variable -Name SCRIPT_INFO_FMT -Option Constant -Value '{0} : info : {1}'
Set-Variable -Name SCRIPT_VERBOSE_FMT -Option Constant -Value '{0} : verbose : {1}'
Set-Variable -Name SCRIPT_WARN_FMT -Option Constant -Value '{0} : warning : {1}`n{2}'
Set-Variable -Name SCRIPT_ERROR_FMT -Option Constant -Value '{0} : error : {1}`n{2}'
Set-Variable -Name SCRIPT_DEBUG_FMT -Option Constant -Value '{0} : debug : {1}`n{2}'
Set-Variable -Name SCRIPT_TRACE_FMT -Option Constant -Value '{0} : trace : {1}`n{2}'

Set-Variable -Name CMDLET_HOST_FMT -Option Constant -Value '{0} : console : {1}'
Set-Variable -Name CMDLET_INFO_FMT -Option Constant -Value '{0} : info : {1}'
Set-Variable -Name CMDLET_VERBOSE_FMT -Option Constant -Value '{0} : verbose : {1}'
Set-Variable -Name CMDLET_WARN_FMT -Option Constant -Value '{0} : warning : {1}`n{2}'
Set-Variable -Name CMDLET_ERROR_FMT -Option Constant -Value '{0} : error : {1}`n{2}'
Set-Variable -Name CMDLET_DEBUG_FMT -Option Constant -Value '{0} : debug : {1}`n{2}'
Set-Variable -Name CMDLET_TRACE_FMT -Option Constant -Value '{0} : trace : {1}`n{2}'

Set-Variable -Name SYSTEM_ERROR_FMT -Option Constant -Value "{0} : error '0x{1:X8}|{1}' : {2}`n{3}"
Set-Variable -Name EXCEPTION_ERROR_FMT -Option Constant -Value "{0} : threw '{1}' '0x{2:X8}|{2}' : {3}`n{4}"

<#
    Import-Module visible Public Static Methods
#>

<#
    Import-Module supporting Constructor
#>
function New-Message {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([Message])]
    param (
        [Parameter(Mandatory)]
        [Origin]
        $Origin
    )

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[Message] with default constructor", $CmdletName)) {
        [Message]::new($Origin) | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$newTypeAcceleratorSlat = @{
    ExportedTypes = ([System.Type[]]@([Message]))
    Response      = ([ErrorResponseType]::Error -bor [ErrorResponseType]::NonTerminatingErrorOn)
}

New-TypeAccelerator @newTypeAccelerator
