<#
 =============================================================================
<copyright file="CommandLineBuilder.psm1" company="John Merryweather Cooper">
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
This file "CommandLineBuilder.psm1" is part of "ContainersModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#require -version 7.4
#require -Module ErrorRecordModule
#require -Module PowerShellModule

#
# CommandLineBuilder.psm1 -- class
#

class CommandLineBuilder : System.Text.StringBuilder {
    <#
        Properties
    #>
    [string]$ClassName

    [System.Text.StringBuilder]$CommandLine

    [bool]$QuoteDoubleHyphens

    [bool]$QuoteHyphen

    [bool]$UseNewLineSeparator

    <#
        Constructors
    #>
    CommandLineBuilder() {
        $this.CommandLine = [System.Text.StringBuilder]::new()

        $this.QuoteDoubleHyphens = $false
        $this.QuoteHypen = $true
        $this.UseNewLineSeparator = $false
    }

    CommandLineBuilder($UseNewLineSeparator) {
        $this.CommandLine = [System.Text.StringBuilder]::new()

        $this.QuoteDoubleHyphens = $false
        $this.QuoteHypen = $true
        $this.UseNewLineSeparator = $UseNewLineSeparator
    }

    CommandLineBuilder($UseNewLineSeparator, $QuoteDoubleHyphens) {
        $this.CommandLine = [System.Text.StringBuilder]::new()

        $this.UseNewLineSeparator = $UseNewLineSeparator
        $this.QuoteDoubleHypens = $QuoteDoubleHyphens
    }

    CommandLineBuilder($UseNewLineSeparator, $QuoteDoubleHyphens, $QuoteHyphen) {
        $this.CommandLine = [System.Text.StringBuilder]::new()

        $this.UseNewLineSeparator = $UseNewLineSeparator
        $this.QuoteDoubleHypens = $QuoteDoubleHyphens
        $this.QuoteHypen = $QuoteHyphen
    }

    <#
        Hidden Methods
    #>
    hidden [void] Initialize([hashtable] $Properties) {
        $this.ClassName = Initialize-PSClass -Name 'CommandLineBuilder'
    }

    <#
        Public Methods
    #>
    [void] AppendArgument([string]$argument) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([string]::IsNullOrWhiteSpace($argument)) {
            $this.AppendSpaceIfNotEmpty()

            $this.AppendTextWithQuoting($argument)
        }
        else {
            $message = "$($MethodName) : InvalidArgument : Parameter 'argument' is null, empty, or all whitespace"

            $newErrorRecordSplat = @{
                Category     = 'InvalidArgument'
                ErrorId      = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                Exception    = [System.ArgumentNullException]::new('argument', $message)
                TargetObject = $argument
                TargetName   = 'argument'
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
            $this.AppendSpaceIfNotEmpty()

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

            foreach ($item in $items) {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('item', $item.FullName)
                $accumulator.Add([CommandLineBuilder]::WithQuotingText($item.FullName))
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

            foreach ($item in $items) {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('item', $item.FullName)
                $accumulator.Add([CommandLineBuilder]::WithQuotingText($item.FullName))
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

            foreach ($filepath in $filepaths) {
                $accumulator.Add([System.IO.FileInfo]::new($filepath))
            }

            $this.AppendFileNamesIfNotNull($accumulator, $separator)
        }
    }

    [void] AppendFileNameWithQuoting([string]$filename) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ([string]::IsNullOrWhiteSpace($filename)) {
            if ($filename.StartsWith('-')) {
                $this.CommandLine.Append('.').Append([System.IO.Path]::DirectorySeparatorChar)
            }

            [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('filename', $filename)
            $this.AppendTextQuoted($filename)
        }
    }

    [void] AppendSpaceIfNotEmpty() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not ([CommandLineBuilder]::IsNullOrEmpty($this.CommandLine) -or $this.CommandLine.LastCharacterIsWhiteSpace())) {
            if ($this.UseNewLineSeparator) {
                $this.CommandLine.AppendLine()
            }
            else {
                $this.CommandLine.Append(' ')
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
                Category     = 'InvalidArgument'
                ErrorId      = Format-ErrorId -Caller $MethodName -Name 'ArgumentNullException' -Position $MyInvocation.ScriptLineNumber
                Exception    = [System.ArgumentNullException]::new('switch', $message)
                TargetObject = $switch
                TargetName   = 'switch'
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

            foreach ($value in $values) {
                [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('value', $value)
                $accumulator.Add([CommandLineBuilder]::UnquoteText($value))
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

        $this.CommandLine.Append([CommandLineBuilder]::QuoteText($text))
    }

    [void] AppendTextUnquoted([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $this.CommandLine.Append([CommandLineBuilder]::UnquoteText($text))
    }

    [char] GetLastCharacter() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.CommandLine.Length -gt 0) {
            return $this.CommandLine[$this.CommandLine.Length - 1]
        }
        else {
            return [char]::MinValue
        }
    }

    [bool] LastCharacterIsWhiteSpace() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [CommandLineBuilder]::IsNotNullOrEmpty($this.CommandLine)) {
            return [char]::IsWhiteSpace($this.CommandLine[$this.CommandLine.Length - 1])
        }
        else {
            return $false
        }
    }

    [bool] TextRequiresQuoting([string]$text) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if ($text -match '\s') {
            return $true
        }
        elseif ($text.Contains('(') -or $text.Contains(')')) {
            return $true
        }
        elseif ($text.Contains('[') -or $text.Contains(']')) {
            return $true
        }
        elseif ($text.Contains('{') -or $text.Contains('}')) {
            return $true
        }
        elseif ($this.QuoteDoubleHypens -and $text.Contains('--')) {
            return $true
        }
        elseif ($this.QuoteHypen -and $text.Contains('-')) {
            return $true
        }
        elseif ($text.Contains('=') -or $text.Contains('+')) {
            return $true
        }
        elseif ($text.Contains('`') -or $text.Contains('~')) {
            return $true
        }
        else {
            switch ($text) {
                { $_.StartsWith('-') } { return $true }
                { $_.StartsWith('/') } { return $true }
                { $_.Contains('&') } { return $true }
                { $_.Contains('^') } { return $true }
                { $_.Contains(';') } { return $true }
                { $_.Contains('!') } { return $true }
                { $_.Contains("'") } { return $true }

                { $_.Contains('"') } {
                    [CommandLineBuilder]::ValidateNoEmbeddedDoubleQuote('text', $text)
                    return $true
                }

                { $_.Contains(',') } { return $true }
                default { return $false }
            }
        }

        return $false
    }

    [string] ToString() {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        return $this.CommandLine.ToString()
    }

    <#
        Static Public Methods
    #>
    static [bool] IsNullOrEmpty([System.Text.StringBuilder]$buffer) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        return ($null -eq $buffer) -or ($buffer.Length -lt 1)
    }

    static [bool] IndexIsOutOfRange([int]$index, [System.Text.StringBuilder]$buffer) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation
        return ($index -lt 0) -or ($index -ge $buffer.Length)
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
                Category     = 'SecurityError'
                ErrorId      = Format-ErrorId -Caller $MethodName -Name 'SecurityException' -Position $MyInvocation.ScriptLineNumber
                Exception    = [System.Security.SecurityException]::new($message)
                TargetObject = $text
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

<#
    Import-Module supporting Constructor
#>
function New-CommandLineBuilder {
    [CmdletBinding(SupportsShouldProcess)]
    [Outputype([CommandLineBuilder])]
    param (
        [switch]
        $UseNewLineSeparator,

        [switch]
        $QuoteDoubleHyphens,

        [switch]
        $NoQuoteHyphen
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if (-not $UseNewLineSeparator.IsPresent -and -not $QuoteDoubleHyphens.IsPresent -and -not $NoQuoteHyphen.IsPresent) {
        $target = "[CommandLintBuilder] : Default Constructor"

        if ($PSCmdlet.ShouldProcehs($target, $CmdletName)) {
            [CommandLineBuilder]::new() | Write-Output
        }
    }
    elseif ($UseNewLineSeparator.IsPresent -and -not $NoQuoteHyphen.IsPresent) {
        $target = "[CommandLineBuilder] : 'UseNewLineSeparator' is '$($UseNewLineSeparator.IsPresent)' for one-argument constructor"

        if ($PSCmdlet.ShouldProcess($target, $CmdletName)) {
            [CommandLineBuilder]::new($UseNewLineSeparator.IsPresent) | Write-Output
        }
    }
    elseif ($UseNewLineSeparator.IsPresent -and $QuoteDoubleHyphens.IsPresent -and -not $NoQuoteHyphen.IsPresent) {
        $target = "[CommandLineBuilder] : 'UseNewLineSeparator' is '$($UseNewLineSeparator.IsPresent)' for two-argument constructor"

        if ($PSCmdlet.ShouldProcehs($target, $CmdletName)) {
            [CommandLineBuilder]::new($UseNewLineSeparator.IsPresent, $QuoteDoubleHyphens.IsPresent) | Write-Output
        }
    }
    else {
        $target = "[CommandLineBuilder] : 'UseNewLineSeparator' is '$($UseNewLineSeparator.IsPresent)'; 'QuoteDoubleHypens' is $($QuoteDoubleHypens.IsPresent)'; 'NoQuoteHyphen' is '$($NoQuoteHyphen.IsPresent)' for three-argument constructor"

        if ($PSCmdlet.ShouldProcess($target, $CmdletName)) {
            [CommandLineBuilder]::new($UseNewLineSeparator.IsPresent, $QuoteDoubleHyphens.IsPresent, -not $NoQuoteHyphen.IsPresent) | Write-Output
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
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

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

# Initialize this type with TypeAccelerator
$registerTypeAcceleratorSlat = @{
    ExportableType = ([System.Type[]]@([CommandLineBuilder]))
    InvocationInfo = $MyInvocation
}

Register-TypeAccelerator @registerTypeAcceleratorSlat
