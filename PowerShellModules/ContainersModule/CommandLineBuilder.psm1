<#
 =============================================================================
<copyright file="CommandLineBuilder.psm1" company="John Merryweather Cooper
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
This file "CommandLineBuilder.psm1" is part of "ContainersModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#require -version 5.1
#require -Module ErrorRecordModule
#require -Module PowerShellModule
#require -Module TypeAcceleratorModule

#
# CommandLineBuilder.psm1 -- class
#

class CommandLineBuilder : System.IDisposable {
    <###########################################
        Properties
    ##########################################>
    [string]$ClassName

    [bool]$QuoteDoubleHyphens

    [bool]$UseNewLineSeparator

    <###########################################
        Hidden Properties
    ##########################################>
    hidden [Microsoft.Build.Utilities.CommandLineBuilder]$Builder

    hidden [bool]$Disposed

    <###########################################
        Constructors
    ##########################################>
    CommandLineBuilder() {
        $this.Builder = [Microsoft.Build.Utilities.CommandLineBuilder]::new()

        $initializeHash = @{
            QuotedDoubleHypens  = $false
            UseNewLineSeparator = $false
        }

        $this.Initialize($initializeHash)
    }

    CommandLineBuilder($QuoteDoubleHyphens, $UseNewLineSeparator) {
        $this.Builder = [Microsoft.Build.Utilities.CommandLineBuilder]::new($QuoteDoubleHyphens, $UseNewLineSeparator)

        $initializeHash = @{
            QuotedDoubleHypens  = $QuoteDoubleHyphens
            UseNewLineSeparator = $UseNewLineSeparator
        }

        $this.Initialize($initializeHash)
    }

    CommandLineBuilder($QuoteDoubleHyphens) {
        $this.Builder = [Microsoft.Build.Utilities.CommandLineBuilder]::new($QuoteDoubleHyphens)

        $initializeHash = @{
            QuotedDoubleHypens  = $QuoteDoubleHyphens
            UseNewLineSeparator = $false
        }

        $this.Initialize($initializeHash)
    }

    CommandLineBuilder([hashtable]$Properties) {
        if ($Properties.ContainsKey('QuoteDoubleHyphens') -and $Properties.ContainsKey('UseNewLineSeparator')) {
            $this.Builder = [Microsoft.Build.Utilities.CommandLineBuilder]::new($Properties['QuoteDoubleHyphens'], $Properties['UseNewLineSeparator'])

            $this.Initialize($Properties)
        }
        else {
            $message = "$($this.ClassName) : 'Properties' passed to this constructor must contain 'QuoteDoubleHyphens' and 'UseNewLineSeparator'"
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentException]::new($message, 'Properties')
                ErrorCategory = 'InvalidArgument'
                ErrorId       = Format-ErrorId -Caller $this.ClassName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                Message       = $message
                TargetObject  = $Properties
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
    }

    <###########################################
        Hidden Methods
    ##########################################>
    hidden [void] Initialize([hashtable] $Properties) {
        $this.ClassName = Initialize-PSClass -Name 'CommandLineBuilder'

        if ($null -eq $Properties) {
            $message = "$($this.ClassName) : 'Properties' is null"
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentNullException]::new('Properties', $message)
                ErrorCategory = 'InvalidArgument'
                ErrorId       = Format-ErrorId -Caller $this.ClassName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                Message       = $message
                TargetObject  = $Properties
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ($Properties.Count -ne 2) {
            $message = "$($this.ClassName) : 'Properties' must have 'Count' equal to 2"
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentException]::new($message, 'Properties')
                ErrorCategory = 'InvalidArgument'
                ErrorId       = Format-ErrorId -Caller $this.ClassName -Name 'ArgumentException' -Position $MyInvocation.ScriptLineNumber
                Message       = $message
                TargetObject  = $Properties
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        if ($Properties.ContainsKey('QuoteDoubleHyphens')) {
            $this.QuoteDoubleHyphens = $Properties['QuoteDoubleHyphens']
        }

        if ($Properties.ContainsKey('UseNewLineSeparator')) {
            $this.UseNewLineSeparator = $Properties['UseNewLineSeparator']
        }
    }

    hidden [void] Dispose([bool]$disposing) {
        if ($this.Disposed) {
            return
        }

        if ($disposing) {
            $this.Buffer.CommandLine.Clear()
            $this.Buffer = $null
        }

        $this.Disposed = $true
    }

    <###########################################
        Public Methods
    ##########################################>
    [void] AppendArgument([string]$argument) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrWhiteSpace($argument)) {
            $this.AppendSpaceIfNotEmpty()
            $this.AppendTextWithQuoting($argument)
        }
        else {
            $message = "$($MethodName) : InvalidArgument : Parameter 'argument' is null, empty, or all whitespace"

            $newErrorRecordSplat = @{
                ErrorCategory = 'InvalidArgument'
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                Exception     = [System.ArgumentNullException]::new('argument', $message)
                Message       = $message
                TargetObject  = $argument
                TargetName    = 'argument'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
    }

    [void] AppendArgumentIf([bool]$condition, [string]$argument) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendArgument($argument)
        }
    }

    [void] AppendArgumentIf([bool]$condition, [string]$argument, [string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendArgument($argument)
            $this.AppendTextWithQuoting($value)
        }
    }

    [void] AppendArgumentIf([bool]$condition, [string]$argument, [string]$format, [object[]]$arguments) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            if ($null -ne $arguments -and $arguments.Length -gt 0) {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('item', $argument)
                $this.AppendArgument($argument)
                $this.AppendTextWithQuoting($format -f $arguments)
            }
            else {
                $this.AppendArgumentIf($condition, $argument, $format)
            }
        }
    }

    [void] AppendDirectoryNameIf([bool]$condition, [System.IO.DirectoryInfo]$item) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendDirectoryNameIfNotNull($item)
        }
    }

    [void] AppendDirectoryNamesIf([bool]$condition, [System.IO.DirectoryInfo[]]$items, [string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendDirectoryNamesIfNotNull($items, $separator)
        }
    }

    [void] AppendDirectoryNameIfNotNull([System.IO.DirectoryInfo]$item) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $item) {
            $this.AppendSpaceIfNotEmpty()
            $this.AppendTextWithQuoting($item.FullName)
        }
    }

    [void] AppendDirectoryNamesIfNotNull([System.IO.DirectoryInfo[]]$items, [string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -eq $items -and $items.Length -gt 0) {
            $this.AppendSpaceIfNotEmpty()

            $accumulator = [System.Collections.ArrayList]::new()

            $items | ForEach-Object -Process {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('item', $_.FullName)
                $accumulator.Add([CommandLineBuilder]::WithQuotingText($_.FullName))
            }

            $this.AppendTextUnquoted($accumulator -join $separator)
        }
    }

    [void] AppendFileNameIf([bool]$condition, [string]$filepath) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendFileNameIfNotNull([System.IO.FileInfo]::new($filePath))
        }
    }

    [void] AppendFileNamesIf([bool]$condition, [string[]]$filepaths, [string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendFileNamesIfNotNull($filepaths, $separator)
        }
    }

    [void] AppendFileNamesIf([bool]$condition, [System.IO.FileInfo[]]$items, [string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendFileNamesIfNotNull($items, $separator)
        }
    }

    [void] AppendFileNameIf([bool]$condition, [System.IO.FileInfo]$item) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendFileNameIfNotNull($item)
        }
    }

    [void] AppendFileNameIfNotNull([System.IO.FileInfo]$item) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $item) {
            $this.AppendSpaceIfNotEmpty()
            $this.AppendTextWithQuoting($item.FullName)
        }
    }

    [void] AppendFileNamesIfNotNull([System.IO.FileInfo[]]$items, [string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $items -and $items.Length -gt 0) {
            $this.AppendSpaceIfNotEmpty()

            $accumulator = [System.Collections.ArrayList]::new()

            $items | ForEach-Object -Process {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('item', $_.FullName)
                $accumulator.Add([CommandLineBuilder]::WithQuotingText($_.FullName)) | Out-Null
            }

            $this.AppendTextUnquoted($accumulator -join $separator)
        }
    }

    [void] AppendFileNameIfNotNull([string]$filepath) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([string]::IsNullOrWhiteSpace($filepath)) {
            $this.AppendFileNameIfNotNull([System.IO.FileInfo]::new($filePath))
        }
    }

    [void] AppendFileNamesIfNotNull([string[]]$filepaths, [string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (($null -ne $filepaths) -and ($filepaths.Length -gt 0)) {
            $accumulator = [System.Collections.ArrayList]::new()

            $filePaths | ForEach-Object -Process {
                $accumulator.Add([System.IO.FileInfo]::new($_)) | Out-Null
            }

            $this.AppendFileNamesIfNotNull($accumulator, $separator)
        }
    }

    [void] AppendFileNameWithQuoting([string]$filename) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrWhiteSpace($filename)) {
            if ($filename.StartsWith('-')) {
                $this.Builder.CommandLine.Append('.').Append([System.IO.Path]::DirectorySeparatorChar)
            }

            [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('filename', $filename)
            $this.AppendTextQuoted($filename)
        }
    }

    [void] AppendSpaceIfNotEmpty() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not ([CommandLineBuilder]::IsNullOrEmpty($this.Builder.CommandLine) -or [CommandLineBuilder]::LastCharacterIsWhiteSpace($this.Builder.CommandLine))) {
            if ($this.UseNewLineSeparator) {
                $this.Builder.CommandLine.AppendLine()
            }
            else {
                $this.Builder.CommandLine.Append(' ')
            }
        }
    }

    [void] AppendSwitch([string]$switch) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrWhiteSpace($switch)) {
            $this.AppendSpaceIfNotEmpty()

            [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('switch', $switch)
            $this.AppendTextUnquoted($switch)
        }
        else {
            $message = "$($MethodName) : InvalidArgument : Parameter 'switch' is null, empty, or all whitespace"

            $newErrorRecordSplat = @{
                ErrorCategory = 'InvalidArgument'
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                Exception     = [System.ArgumentNullException]::new('switch', $message)
                Message       = $message
                TargetObject  = $switch
                TargetName    = 'switch'
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
    }

    [void] AppendSwitchIf([bool]$condition, [string]$switch) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendSwitch($switch)
        }
    }

    [void] AppendSwitchIf([bool]$condition, [string]$switch, [string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendSwitch($switch)
            $this.AppendTextWithQuoting($value)
        }
    }

    [void] AppendSwitchIf([bool]$condition, [string]$switch, [string]$format, [object[]]$arguments) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($condition) {
            $this.AppendSwitch($switch)
            $this.AppendTextWithQuoting($format -f $arguments)
        }
    }

    [void] AppendSwitchIfNotNull([string]$switch, [string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrWhiteSpace($value)) {
            $this.AppendSwitch($switch)
            $this.AppendTextWithQuoting($value)
        }
    }

    [void] AppendSwitchUnquotedIfNotNull([string]$switch, [string]$value) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([string]::IsNullOrWhiteSpace($value)) {
            $this.AppendSwitch($switch)

            [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('value', $value)
            $this.AppendTextUnquoted($value)
        }
    }

    [void] AppendSwitchUnquotedIfNotNull([string]$switch, [string[]]$values, [string]$separator) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $values -and $values.Length -gt 0) {
            $accumulator = [System.Collections.ArrayList]::new()

            $this.AppendSwitch($switch)

            $values | ForEach-Object -Process {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('value', $_)
                $accumulator.Add([CommandLineBuilder]::UnquoteText($_))
            }

            $this.AppendTextUnquoted($accumulator -join $separator)
        }
    }

    [void] AppendTextWithQuoting([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote($text)

        if ([CommandLineBuilder]::TextRequiresQuoting($text)) {
            $this.AppendTextQuoted($text)
        }
        else {
            $this.AppendTextUnquoted($text)
        }
    }

    [void] AppendTextQuoted([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $this.Builder.CommandLine.Append([CommandLineBuilder]::QuoteText($text))
    }

    [void] AppendTextUnquoted([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $this.Builder.CommandLine.Append([CommandLineBuilder]::UnquoteText($text))
    }

    [void] Dispose() {
        $this.Dispose($true)
    }

    [char] GetLastCharacter() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Builder.Length -gt 0) {
            return $this.Builder.CommandLine[$this.Builder.Length - 1]
        }
        else {
            return [char]::MinValue
        }
    }

    [bool] TextRequiresQuoting([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([System.Text.Encoding.UTF8]::GetByteCount($text) -gt $text.Length) {
            $message = "$($MethodName) : Multi-byte character string detected"
            $newErrorRecordSplat = @{
                Exception     = [System.ArgumentOutOfRangeException]::new('text', $text, $message)
                ErrorCategory = 'InvalidArgument'
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'ArgumentOutOfRangeException' -Position $MyInvocation.ScriptLineNumber
                Message       = $message
                TargetObject  = $text
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }

        switch ($text) {
            { $_ -match '\s' } { return $true }
            { $_.Contains([System.IO.Path]::AltDirectorySeparatorChar) } { return $true }
            { $_.Contains([System.IO.Path]::VolumeSeparatorChar) } { return $true }
            { $_.Contains('?') } { return $true }
            { $this.QuoteDoubleHypens -and $_.Contains('--') } { return $true }
            { $_.Contains('-') -and -not $_.Contains('--') } { return $true }
            { $_.Contains('(') -or $_.Contains(')') } { return $true }
            { $_.Contains('[') -or $_.Contains(']') } { return $true }
            { $_.Contains('{') -or $_.Contains('}') } { return $true }
            { $_.Contains('<') -or $_.Contains('>') } { return $true }
            { $_.Contains('=') -or $_.Contains('+') } { return $true }
            { $_.Contains('*') } { return $true }
            { $_.Contains('`') -or $_.Contains('~') } { return $true }
            { $_.Contains('&') } { return $true }
            { $_.Contains('^') } { return $true }
            { $_.Contains([System.IO.Path]::PathSeparator) } { return $true }
            { $_.Contains('!') } { return $true }
            { $_.Contains('^') } { return $true }
            { $_.Contains(',') } { return $true }
            { $_.Contains('@') } { return $true }
            { $_.Contains('#') } { return $true }
            { $_.Contains('$') } { return $true }

            { $_.Contains('"') -or $_.Contains("'") } {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('text', $text)
                return $true
            }

            default { return $false }
        }

        return $false
    }

    [string] ToString() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        return $this.Builder.CommandLine.ToString()
    }

    <###########################################
        Static Public Methods
    ##########################################>
    static [bool] IsNullOrEmpty([System.Text.StringBuilder]$buffer) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        return ($null -eq $buffer) -or ($buffer.Length -lt 1)
    }

    static [bool] IndexIsOutOfRange([int]$index, [System.Text.StringBuilder]$buffer) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        return ($index -lt 0) -or ($index -ge $buffer.Length)
    }

    static [bool] LastCharacterIsWhiteSpace([System.Text.StringBuilder]$buffer) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [CommandLineBuilder]::IsNotNullOrEmpty($buffer)) {
            return [char]::IsWhiteSpace($buffer[$buffer.Length - 1])
        }
        else {
            return $false
        }
    }

    static [int]MeasureCharacterInText([char]$target, [string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([string]::IsNullOrEmpty($text)) {
            return 0
        }
        else {
            return $text.ToCharArray() | Where-Object -FilterScript { $_ -eq $target } | Measure-Object | Select-Object -ExpandProperty Count
        }
    }

    static [string] QuoteText([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrWhiteSpace($text) -and $text.EndsWith('\')) {
            return ('"{0}\\"' -f $text.TrimEnd('\'))
        }
        elseif (-not [string]::IsNullOrWhiteSpace($text)) {
            return ('"{0}"' -f $text)
        }
        else {
            return [string]::Empty
        }
    }

    static [string] UnquoteText([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrWhiteSpace($text) -and $text.EndsWith('\')) {
            return ('{0}\' -f $text.TrimEnd('\'))
        }
        elseif (-not [string]::IsNullOrwhiteSpace($text)) {
            return ('{0}' -f $text.Trim())
        }
        else {
            return [string]::Empty
        }
    }

    static [void] ValidateNoEmbeddedDoubleQuote([string]$parameter, [string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $doubleQuoteCount = [CommandLineBuilder]::MeasureCharacterInText('"', $text)

        if ([string]::IsNullOrWhiteSpace($text)) {
            return
        }
        elseif ($doubleQuoteCount -eq 0) {
            return
        }
        elseif ([Math]::IsEven($doubleQuoteCount)) {
            return
        }
        elseif ([Math]::IsOdd($doubleQuoteCount)) {
            $doubleQuoteAt = $text.IndexOf('"')
            $lastDoubleQuoteAt = $text.LastIndexOf('"')
            $message = "$($MethodName) : SecurityException : Parameter '$($parameter)' has embedded double quote at starting at position $($doubleQuoteAt) and ending at position '$($lastDoubleQuoteAt)'"

            $newErrorRecordSplat = @{
                ErrorCategory = 'SecurityError'
                ErrorId       = Format-ErrorId -Caller $MethodName -Name 'SecurityException' -Position $MyInvocation.ScriptLineNumber
                Exception     = [System.Security.SecurityException]::new($message)
                Message       = $message
                TargetObject  = $text
            }

            New-ErrorRecord @newErrorRecordSplat | Write-Fatal
        }
    }

    static [string] WithQuotingText([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote($text)

        if ([CommandLineBuilder]::TextRequiresQuoting($text)) {
            return [CommandLineBuilder]::QuoteText($text)
        }
        else {
            return [CommandLineBuilder]::UnquoteText($text)
        }
    }
}

<###########################################
    Import-Module supporting Constructor
##########################################>
function New-CommandLineBuilder {
    [CmdletBinding(SupportsShouldProcess)]
    [Outputype([CommandLineBuilder])]
    param (
        [switch]
        $UseNewLineSeparator,

        [switch]
        $QuoteDoubleHyphens
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ($UseNewLineSeparator.IsPresent -and $QuoteDoubleHyphens.IsPresent) {
        $target = "'QuoteDoubleHyphens' is '$($QuoteDoubleHyphens)' and 'UseNewLineSeparator' is '$($UseNewLineSeparator.IsPresent)' for two-argument constructor"

        if ($PSCmdlet.ShouldProcehs($target, $CmdletName)) {
            [CommandLineBuilder]::new($UseNewLineSeparator.IsPresent, $QuoteDoubleHyphens.IsPresent) | Write-Output
        }
    }
    elseif ($QuoteDoubleHyphens.IsPresent) {
        $target = "'QuoteDoubleHyphens' is '$($QuoteDoubleHyphens)' for one-argument constructor"

        if ($PSCmdlet.ShouldProcehs($target, $CmdletName)) {
            [CommandLineBuilder]::new($UseNewLineSeparator.IsPresent, $QuoteDoubleHyphens.IsPresent) | Write-Output
        }
    }
    else {
        $target = "Default Constructor"

        if ($PSCmdlet.ShouldProcehs($target, $CmdletName)) {
            [CommandLineBuilder]::new() | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Creates a new instance of the CommandLineBuilder class.

        .DESCRIPTION
        The New-CommandLineBuilder cmdlet creates a new instance of the CommandLineBuilder class.

        .PARAMETER UseNewLineSeparator
        Specifies whether to use a new line separator.  The default is to a space separator when this switch is not specified.

        .PARAMETER QuoteDoubleHyphens
        Specifies whether to quote double hyphens.  The default is to not quote double hyphens when this switch is not specified.

        .PARAMETER NoQuoteHyphen
        Specifies whether to not quote single hyphens.  The default is to quote single hyphens when this switch is not specified.

        There are a number of command line utilities--including most prominently the Resource Compiler ("RC")--that require this setting for command lines.

        .INPUTS
        None.  `New-CommandLineBuilder` does not take any input from the PowerShell pipeline.

        .OUTPUTS
        [CommandLineBuilder]
        `New-CommandLineBuilder` outputs a [CommandLineBuilder] instance to the PowerShell pipeline

        .EXAMPLE
        PS> $clb = New-CommandLineBuilder
        PS> $clb.Length

        0

        Create a new [CommandLineBuilder] instance and gets the value of the `Length` property.

        .NOTES
        Copyright © 2022, 2023, 2024, 2025, John Merryweather Cooper Managment.  All Rights Reserved.

        .LINK
        about_Functions_Advanced

        .LINK
        about_Functions_Advanced_Methods

        .LINK
        about_Functions_Advanced_Parameters

        .LINK
        Initialize-PSCmdlet

        .LINK
        Out-Null

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output

        .LINK
        https://stephanevg.github.io/powershell/class/module/DATA-How-To-Write-powershell-Modules-with-classes/
    #>
}

# Define the types to export with type accelerators.
$ExportableTypes = @(
    [CommandLineBuilder]
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
            Message       = $Message
            TargetObject  = $Type.FullName
            TargetName    = 'TypeAccelerator'
        }

        New-ErrorRecord @newErrorRecordSplat | Write-Fatal
    }
    else {
        $ExportableTypes | ForEach-Object -Process {
            Write-Information -MessageData "$($ScriptName) : Adding TypeAccelerator '$($_.FullName)'" -InformationAction $this.LogToConsole
            $TypeAcceleratorsClass::Add($_.FullName, $_)
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
