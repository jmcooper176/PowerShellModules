<#
 =============================================================================
<copyright file="CommandLineModule.psm1" company="John Merryweather Cooper">
    Copyright (c) 2025 John Merryweather Cooper.
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
<date>Created:  2024-9-18</date>
<summary>
This file "CommandLineModule.psm1" is part of "CommandLineModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -version 7.4

using module ErrorResponseType
using module TypeAccelerator

#
# CommandLine Class
#
class CommandLine {
    <#
        Constructors
    #>
    CommandLine() {
        Initialize-PSClass -Name [CommandLine].Name

        $initializeSplat = @{
            QuoteHyphensOnCommandLine = $false
            UseNewLineSeparator       = $false
        }

        $this.Initialize($initializeSplat)
    }

    CommandLine([bool]$QuoteHyphensOnCommandLine) {
        Initialize-PSClass -Name [CommandLine].Name

        $initializeSplat = @{
            QuoteHyphensOnCommandLine = $QuoteHyphensOnCommandLine
            UseNewLineSeparator       = $false
        }

        $this.Initialize($initializeSplat)
    }

    CommandLine([bool]$QuoteHyphensOnCommandLine, [bool]$UseNewLineSeparator) {
        Initialize-PSClass -Name [CommandLine].Name

        $initializeSplat = @{
            QuoteHyphensOnCommandLine = $QuoteHyphensOnCommandLine
            UseNewLineSeparator       = $UseNewLineSeparator
        }

        $this.Initialize($initializeSplat)
    }

    CommandLine([hashtable]$Properties) {
        $ClassName = Initialize-PSClass -Name [CommandLine].Name

        $Properties.GetEnumerator() | ForEach-Object -Process {
            switch ($_.Key) {
                'CommandLine' {
                    Write-Warning -Message "$($ClassName) : The property 'CommandLine' is read-only and cannot be set."
                    break
                }

                'QuoteHyphensOnCommandLine' {
                    [CommandLine]::Update($Properties, $_.Key, $_.Value)
                    break
                }

                'UseNewLineSeparator' {
                    [CommandLine]::Update($Properties, $_.Key, $_.Value)
                    break
                }

                default {
                    $message = "$($ClassName) : The property '$($_.Key)' is not a valid property for the class '$($ClassName)'."
                    $newErrorRecordSplat = @{
                        Exception    = [System.Management.Automation.MethodInvocationException]::new($message)
                        Message      = $message
                        Category     = 'InvalidOperation'
                        TargetObject = $ClassName
                    }

                    $er = New-ErrorRecord @newErrorRecordSplat
                    Write-Error -ErrorRecord $er -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($er)
                }
            }
        }

        $this.Initialize($Properties)
    }

    <#
        Common Initializer
    #>
    [void]Initialize([hashtable]$Properties) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $this.CommandLine = New-Object -TypeName System.Text.StringBuilder

        $this.QuoteHyphensOnCommandLine = $false
        $this.UseNewLineSeparator = $false

        foreach ($DefinitionSplat in [CommandLine]::PropertyDefinitions) {
            Update-TypeData -TypeName [CommandLine].Name @DefinitionSplat
        }

        $Properties.GetEnumerator() | ForEach-Object -Process {
            switch ($_.Key) {
                'CommandLine' {
                    break
                }

                'QuoteHyphensOnCommandLine' {
                    $this.QuoteHyphensOnCommandLine = $_.Value
                    break
                }

                'UseNewLineSeparator' {
                    $this.UseNewLineSeparator = $_.Value
                    break
                }

                default {
                    $message = "$($MethodName) : The property '$($_.Key)' is not a valid property for the class '$([CommandLine].Name)'."
                    $newErrorRecordSplat = @{
                        Exception    = [System.Management.Automation.MethodInvocationException]::new($message)
                        Message      = $message
                        Category     = 'InvalidOperation'
                        TargetObject = [CommandLine].Name
                    }

                    $er = New-ErrorRecord @newErrorRecordSplat
                    Write-Error -ErrorRecord $er -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($er)
                }
            }
        }
    }

    <#
        Public Properties
    #>
    [System.Text.StringBuilder]$CommandLine
    [bool]$QuoteHyphensOnCommandLine
    [bool]$UseNewLineSeparator

    <#
        Public Script Property Definitions
    #>
    static [hashtable[]] $PropertyDefinitions = @(
        @{
            MemberType = 'ScriptProperty'
            MemberName = 'Length'
            Value      = { $this.CommandLine.Length }
        }
    )

    <#
        Public Methods
    #>
    [void]AppendFileNameIfNotNull([string]$FileName) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrEmpty($FileName) -and -not $FileName.StartsWith('-')) {
            $this.AppendSpaceIfNotEmpty()
            [CommandLine]::VerifyThrowNoEmbeddedDoubleQuotes($MethodName, $FileName, 'FileName')
            $this.AppendTextWithQuoting($FileName)
        }
        elseif (-not [string]::IsNullOrEmpty($FileName) -and $FileName.StartsWith('-')) {
            $this.AppendSpaceIfNotEmpty()
            [CommandLine]::VerifyThrowNoEmbeddedDoubleQuotes($MethodName, $FileName, 'FileName')
            $this.CommandLine.Append('.').Append([System.IO.Path]::DirectorySeparatorChar)
            $this.AppendTextWithQuoting($FileName)
        }
    }

    [void]AppendFileNamesIfNotNull([string[]]$FileNames, [string]$Delimiter) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $cleanFileNames = [System.Collections.ArrayList]::new()

        if ($null -ne $FileNames -and $FileNames.Length -gt 0) {
            $this.AppendSpaceIfNotEmpty()

            foreach ($FileName in $FileNames) {
                [CommandLine]::VerifyThrowNoEmbeddedDoubleQuotes($MethodName, $FileName, 'FileName')

                if (-not $FileName.StartsWith('-')) {
                    $cleanFileNames.Add($FileName) | Out-Null
                }
                elseif ($FileName.StartsWith('-')) {
                    $temp = '.' + [System.IO.Path]::DirectorySeparatorChar + $FileName
                    $cleanFileNames.Add($temp) | Out-Null
                    $temp = [string]::Empty
                }
            }

            [CommandLine]::AppendQuotedTextToBuffer($this.CommandLine, $cleanFileNames.ToArray(), $Delimiter)
        }
    }

    [void]AppendSpaceIfNotEmpty() {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Length -gt 0) {
            if ($this.UseNewLineSeparator) {
                $this.AppendTextUnquoted([Environment]::NewLine)
            }
            else {
                $this.AppendTextUnquoted(' ')
            }
        }
    }

    [void]AppendSwitch([string]$SwitchName) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.AppendSpaceIfNotEmpty()
        $this.AppendTextUnquoted($SwitchName)
    }

    [void]AppendSwitchIfNotNull([string]$SwitchName, [string]$Parameter) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrEmpty($Parameter)) {
            $this.AppendSwitch($SwitchName)
            [CommandLine]::VerifyThrowNoEmbeddedDoubleQuotes($SwitchName, $Parameter, 'Parameter')
            $this.AppendTextWithQuoting($Parameter)
        }
    }

    [void]AppendSwitchIfNotNull([string]$SwitchName, [string[]]$Parameters, [string]$Delimiter) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if ($null -ne $Parameters -and $Parameters.Length -gt 0) {
            $this.AppendSwitch($SwitchName)

            $first = $true

            foreach ($Parameter in $Parameters) {
                [CommandLine]::VerifyThrowNoEmbeddedDoubleQuotes($SwitchName, $Parameter, 'Parameter')

                if ($first) {
                    $this.AppendTextWithQuoting($Parameter)
                    $first = $false
                }
                else {
                    $this.AppendTextUnquoted($Delimiter)
                    $this.AppendTextWithQuoting($Parameter)
                }
            }
        }
    }

    [void]AppendSwitchUnquotedIfNotNull([string]$SwitchName, [string]$Parameter) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if (-not [string]::IsNullOrEmpty($Parameter)) {
            $this.AppendSwitch($SwitchName)
            [CommandLine]::VerifyThrowNoEmbeddedDoubleQuotes($SwitchName, $Parameter, 'Parameter')
            $this.AppendTextUnquoted($Parameter)
        }
    }

    [void]AppendTextUnquoted([string]$TextToAppend) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $this.CommandLine.Append([CommandLine]::Escape($TextToAppend))
    }

    [void]AppendTextWithQuoting([string]$TextToAppend) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.IsQuotingRequired($TextToAppend)) {
            [CommandLine]::AppendQuotedTextToBuffer($this.CommandLine, $TextToAppend)
        }
        else {
            $this.AppendTextUnquoted($TextToAppend)
        }
    }

    [bool]IsQuotingRequired([string]$Parameter) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if ([string]::IsNullOrEmpty($Parameter)) {
            return $false
        }

        foreach ($item in $Parameter.ToCharArray()) {
            switch ($item) {
                { [char]::IsWhiteSpace($_) } { return $true }

                '-' {
                    if ($this.QuoteHyphensOnCommandLine) {
                        return $true
                    }
                }
            }
        }

        return $false
    }

    [string]ToString() {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if ($this.Length -eq 0) {
            return [string]::Empty
        }
        else {
            return $this.CommandLine.ToString()
        }
    }

    <#
        Public Static Methods
    #>
    static [void]AppendQuotedTextToBuffer([System.Text.StringBuilder]$Buffer, [string]$UnquotedTextToAppend) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $Buffer.Append('"').Append([CommandLine]::Escape($UnquotedTextToAppend)).Append('"')
    }

    static [void]AppendQuotedTextToBuffer([System.Text.StringBuilder]$Buffer, [string[]]$UnquotedTextsToAppend, [string]$Delimiter) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $first = $true

        foreach ($Text in $UnquotedTextsToAppend) {
            if ($first) {
                [CommandLine]::AppendQuotedTextToBuffer($Buffer, $Text)
                $first = $false
            }
            else {
                $Buffer.Append($Delimiter)
                [CommandLine]::AppendQuotedTextToBuffer($Buffer, $Text)
            }
        }
    }

    static [string]Escape([string]$Parameter) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        $buffer = New-Object -TypeName System.Text.StringBuilder

        foreach ($item in $Parameter.ToCharArray()) {
            switch ($item) {
                '`' { $buffer.Append('``') }
                '#' { $buffer.Append('`#') }
                "'" { $buffer.Append("`'") }
                '`0' { $buffer.Append('`0') }
                '`a' { $buffer.Append('`a') }
                '`b' { $buffer.Append('`b') }
                '`e' { $buffer.Append('`e') }
                '`f' { $buffer.Append('`f') }
                '`n' { $buffer.Append('`n') }
                '`r' { $buffer.Append('`r') }
                '`t' { $buffer.Append('`t') }
                '`u' { $buffer.Append('`u') }
                '`v' { $buffer.Append('`v') }
                default { $buffer.Append($item) }
            }
        }

        return $buffer.ToString()
    }

    static [bool]IsEscapingRequired([string]$Parameter, [string]$SwitchName, [string]$ParameterName) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        foreach ($item in $Parameter.Trim(@('"', "'")).ToCharArray()) {
            switch ($item) {
                '`' { return $true }
                '#' { return $true }
                "'" { return $true }
                '"' {
                    $message = "$($MethodName) : 'Parameter' '$($ParameterName)' contains embedded double quote(s)."
                    $newErrorRecordSplat = @{
                        Activity          = "Scanning for embedded double quotes in parameter"
                        Exception         = [System.Security.SecurityException]::new($message)
                        Message           = $message
                        Reason            = "Embedded double quotes are not allowed in parameters because they allow code injection attacks."
                        RecommendedAction = "Remove the embedded double quotes from the parameter '$($ParameterName)'."
                        Category          = 'SecurityError'
                        TargetName        = $ParameterName
                        TargetType        = 'System.String'
                        TargetObject      = $Parameter
                    }

                    $er = New-ErrorRecord @newErrorRecordSplat
                    Write-Error -ErrorRecord $er -ErrorAction Continue
                    $PSCmdlet.ThrowTerminatingError($er)
                }
            }
        }

        return $false
    }

    static [bool]IsSpecialCharacter([string]$Parameter) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        foreach ($item in $Parameter.ToCharArray()) {
            switch ($item) {
                '`0' { return $true }
                '`a' { return $true }
                '`b' { return $true }
                '`e' { return $true }
                '`f' { return $true }
                '`n' { return $true }
                '`r' { return $true }
                '`t' { return $true }
                '`u' {
                    $index = $Parameter.IndexOf($item)

                    if ($Parameter[$index + 1] -eq '{') {
                        $openBrace = $index + 1
                        $closeBrace = $Parameter.IndexOf('}', $openBrace)
                        $codePoint = $Parameter.Substring($openBrace + 1, $closeBrace - $openBrace - 1)

                        if ([int]::TryParse($codePoint, [ref]$null)) {
                            return $true
                        }
                    }

                    break
                }
                '`v' { return $true }
            }
        }

        return $false
    }

    static [void]VerifyThrowNoEmbeddedDoubleQuotes([string]$SwitchName, [string]$Parameter, [string]$ParameterName) {
        $MethodName = Initialize-PSMethod -MyInvocation $MyInvocation

        $newErrorRecordSplat = @{
            Activity     = "Scanning for unescaped characters and embedded double quotes in parameter '$($ParameterName)'"
            TargetName   = $ParameterName
            TargetType   = 'System.String'
            TargetObject = $Parameter
        }

        try {
            if ([CommandLine]::IsEscapingRequired($Parameter, $SwitchName, $ParameterName)) {
                $message = "$($MethodName) : 'Parameter' '$($ParameterName)' contains PowerShell unescaped special character(s)."
                [CommandLine]::Update($newErrorRecordSplat, 'Exception', [System.Management.Automation.PSArgumentException]::new($message, $ParameterName))
                [CommandLine]::Update($newErrorRecordSplat, 'Message', $message)
                [CommandLine]::Update($newErrorRecordSplat, 'Reason', "Unescaped PowerShell characters will be interpreted on the command line.")
                [CommandLine]::Update($newErrorRecordSplat, 'RecommendedAction', "Escape characters from parameter '$($ParameterName)'.")
                [CommandLine]::Update($newErrorRecordSplat, 'Category', 'InvalidArgument')
                $er = New-ErrorRecord @newErrorRecordSplat
                Write-Error -ErrorRecord $er -ErrorAction Continue
                $PSCmdlet.ThrowTerminatingError($er)
            }
        }
        catch [System.Security.SecurityException] {
            [CommandLine]::Update($newErrorRecordSplat, 'Exception', [System.Management.Automation.PSArgumentException]::new($_.Exception.Message, $ParameterName, $_.Exception))
            [CommandLine]::Update($newErrorRecordSplat, 'Message', $_.Message)
            [CommandLine]::Update($newErrorRecordSplat, 'Reason', $_.CategoryReason)
            [CommandLine]::Update($newErrorRecordSplat, 'RecommendedAction', $_.RecommendedAction)
            [CommandLine]::Update($newErrorRecordSplat, 'Category', $_.Category)

            $er = New-ErrorRecord @newErrorRecordSplat
            Write-Error -ErrorRecord $er -ErrorAction Continue
            $PSCmdlet.ThrowTerminatingError($er)
        }
    }

    static [void]Update([hashtable]$Properties, [string]$Key, [object]$Value) {
        Initialize-PSMethod -MyInvocation $MyInvocation

        if ($Properties.ContainsKey($Key)) {
            $Properties[$Key] = $Value
        }
        else {
            $Properties.Add($Key, $Value)
        }
    }
}

<#
    Import-Module supporting Constructor
#>
function New-CommandLine {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([CommandLine])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[CommandLine] with default constructor", $CmdletName)) {
        [CommandLine]::new() | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$newTypeAcceleratorSlat = @{
    ExportedTypes = ([System.Type[]]@([CommandLine]))
    Response      = ([ErrorResponseType]::Error -bor [ErrorResponseType]::NonTerminatingErrorOn)
}

New-TypeAccelerator @newTypeAccelerator
