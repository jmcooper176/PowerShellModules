<#
 =============================================================================
<copyright file="LogModule.psm1" company="John Merryweather Cooper">
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
<date>Created:  2024-9-12</date>
<summary>
This file "LogModule.psm1" is part of "LogModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Write-LogConsole
#>
function Write-LogConsole {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $FilePath,

        [System.ConsoleColor]
        $ForegroundColor = 'Green',

        [System.ConsoleColor]
        $BackgroundColor = 'Black',

        [string]
        $Prefix = 'HOST',

        [string]
        $Separator,

        [ValidateSet('ascii', 'bigendianunicode', 'default', 'oem', 'string', 'string', 'unknown', 'utf7', 'utf8', 'utf32')]
        [string]
        $Encoding,

        [ValidateRange(1, 2147483647)]
        [System.Int32]
        $Width,

        [switch]
        $Append,

        [switch]
        $Force,

        [switch]
        $NoClobber,

        [switch]
        $NoNewline,

        [switch]
        $UseInformation
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        if ($UseInformation.IsPresent) {
            $writeInfoHash = @{
                MessageData       = $Message
                InformationAction = 'Continue'
            }

            Write-Information @writeInfoHash
        } else {
            $writeHostHash = @{
                MessageData          = ('{0}: {1}' -f $Prefix, $Message)
                InformationAction = 'Continue'
            }

            if (Test-PSParameter -Name 'Separator' -Parameters $PSBoundParameters) {
                $writeHostHash.Add('Separator', $Separator)
            }

            Write-Information @writeHostHash
        }

        $timestamp = Microsoft.PowerShell.Utility\Get-Date -Format o | ForEach-Object -Process { $_ -replace ':', '.' }
    }

    PROCESS {
        if (-not [string]::IsNullOrWhiteSpace($Prefix)) {
            $logMessage = ("{0}  {1}: {2}" -f $timestamp, $Prefix, $Message)
        } else {
            $logMessage = ("{0} : {1}" -f $timestamp, $Message)
        }

        $outFileHash = @{
            FilePath  = $FilePath
            Append    = $Append.IsPresent
            Force     = $Force.IsPresent
            NoClobber = $NoClobber.IsPresent
            NoNewline = $NoNewline.IsPresent
        }

        if (Test-PSParameter -Name 'Encoding' -Parameters $PSBoundParameters) {
            $outFileHash.Add('Encoding', $Encoding)
        }

        if (Test-PSParameter -Name 'Width' -Parameters $PSBoundParameters) {
            $outFileHash.Add('Width', $Width)
        }

        $logMessage | Out-File @outFileHash
    }

    <#
        .SYNOPSIS
        Writes customized output to a host and to a log file.

        .DESCRIPTION
        The `Write-LogConsole` cmdlet's primary purpose is to produce for-(host)-display-only output.

        You can specify the color of text by using the `ForegroundColor` parameter, and you can specify the background color by using
        the `BackgroundColor` parameter.

        The Separator parameter lets you specify a string to use to separate displayed objects.  The
        particular result depends on the program that is hosting PowerShell.

        .PARAMETER Message
        The message string to log.

        .PARAMETER FilePath
        Specifies the path to the output file.

        .PARAMETER ForegroundColor
        Specifies the text color. There is no default. The acceptable values for this parameter are:

        - Black
        - DarkBlue
        - DarkGreen
        - DarkCyan
        - DarkRed
        - DarkMagenta
        - DarkYellow
        - Gray
        - DarkGray
        - Blue
        - Green
        - Cyan
        - Red
        - Magenta
        - Yellow
        - White

        .PARAMETER BackgroundColor
        Specifies the background color. There is no default. The acceptable values for this parameter are:

        - Black
        - DarkBlue
        - DarkGreen
        - DarkCyan
        - DarkRed
        - DarkMagenta
        - DarkYellow
        - Gray
        - DarkGray
        - Blue
        - Green
        - Cyan
        - Red
        - Magenta
        - Yellow
        - White

        .PARAMETER Prefix
        The prefix to apply before the message string in logging.

        .PARAMETER Separator
        Specifies a separator string to insert between objects displayed by the host.

        .PARAMETER Encoding
        Specifies the type of encoding for the target file. The default value is `unicode`.

        The acceptable values for this parameter are as follows:

        - `ascii` Uses ASCII (7-bit) character set.
        - `bigendianunicode` Uses UTF-16 with the big-endian byte order.
        - `default` Uses the encoding that corresponds to the system's active code page (usually ANSI).
        - `oem` Uses the encoding that corresponds to the system's current OEM code page.
        - `string` Same as `unicode`.
        - `unicode` Uses UTF-16 with the little-endian byte order.
        - `unknown` Same as `unicode`.
        - `utf7` Uses UTF-7.
        - `utf8` Uses UTF-8.
        - `utf32` Uses UTF-32 with the little-endian byte order.

        .PARAMETER Width
        Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped. If this
        parameter is not used, the width is determined by the characteristics of the host. The default for the PowerShell console
        is 80 characters.

        .PARAMETER Append
        Adds the output to the end of an existing file. If no Encoding is specified, the cmdlet uses the default encoding. That
        encoding may not match the encoding of the target file. This is the same behavior as the redirection operator (`>>`).

        .PARAMETER Force
        Overrides the read-only attribute and overwrites an existing read-only file. The Force parameter does not override
        security restrictions.

        .PARAMETER NoClobber
        NoClobber prevents an existing file from being overwritten and displays a message that the file already exists. By
        default, if a file exists in the specified path, `Write-LogConsole` overwrites the file without warning.

        .PARAMETER NoNewline
        The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted
        between the output strings. No newline is added after the last output string.

        .PARAMETER UseInformation
        If set, use `Write-Information` instead of `Write-Host`.

        .INPUTS
        [System.String].  `Write-LogConsole` accepts message strings as input from the pipeline.

        .OUTPUTS
        None
        `Write-LogConsole` sends the objects to the host. It does not return any objects. However, the host displays the objects that
        `Write-LogConsole` sends to it.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE

        .LINK
        Write-Host

        .LINK
        Write-Information

        .LINK
        Microsoft.PowerShell.Utility\Get-Date

        .LINK
        Out-File
    #>
}

<#
    Write-LogDebug
#>
function Write-LogDebug {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $FilePath,

        [ValidateSet('ascii', 'bigendianunicode', 'default', 'oem', 'string', 'string', 'unknown', 'utf7', 'utf8', 'utf32')]
        [string]
        $Encoding,

        [ValidateRange(1, 2147483647)]
        [System.Int32]
        $Width,

        [switch]
        $Append,

        [switch]
        $Force,

        [switch]
        $NoClobber,

        [switch]
        $NoNewline
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $timestamp = Microsoft.PowerShell.Utility\Get-Date -Format o | ForEach-Object -Process { $_ -replace ':', '.' }
    }

    PROCESS {
        $logMessage = ("{0}  DEBUG: {1}" -f $timestamp, $Message)

        $outFileHash = @{
            FilePath  = $FilePath
            Append    = $Append.IsPresent
            Force     = $Force.IsPresent
            NoClobber = $NoClobber.IsPresent
            NoNewline = $NoNewline.IsPresent
        }

        if (Test-PSParameter -Name 'Encoding' -Parameters $PSBoundParameters) {
            $outFileHash.Add('Encoding', $Encoding)
        }

        if (Test-PSParameter -Name 'Width' -Parameters $PSBoundParameters) {
            $outFileHash.Add('Width', $Width)
        }

        $logMessage | Out-File @outFileHash
        Write-Debug -Message $Message
    }

    <#
        .SYNOPSIS
        Writes a debug message to the console and to the log file.

        .DESCRIPTION
        The `Write-LogDebug` cmdlet writes debug messages to the host from a script or command.

        By default, debug messages are not displayed in the console, but you can display them by using the Debug parameter or the
        `$DebugPreference` variable.

        .PARAMETER Message
        Specifies the debug message to send to the console.

        .PARAMETER FilePath
        Specifies the path to the output file.

        .PARAMETER Encoding
        Specifies the type of encoding for the target file. The default value is `unicode`.

        The acceptable values for this parameter are as follows:

        - `ascii` Uses ASCII (7-bit) character set.
        - `bigendianunicode` Uses UTF-16 with the big-endian byte order.
        - `default` Uses the encoding that corresponds to the system's active code page (usually ANSI).
        - `oem` Uses the encoding that corresponds to the system's current OEM code page.
        - `string` Same as `unicode`.
        - `unicode` Uses UTF-16 with the little-endian byte order.
        - `unknown` Same as `unicode`.
        - `utf7` Uses UTF-7.
        - `utf8` Uses UTF-8.
        - `utf32` Uses UTF-32 with the little-endian byte order.

        .PARAMETER Width
        Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped. If this
        parameter is not used, the width is determined by the characteristics of the host. The default for the PowerShell console
        is 80 characters.

        .PARAMETER Append
        Adds the output to the end of an existing file. If no Encoding is specified, the cmdlet uses the default encoding. That
        encoding may not match the encoding of the target file. This is the same behavior as the redirection operator (`>>`).

        .PARAMETER Force
        Overrides the read-only attribute and overwrites an existing read-only file. The Force parameter does not override
        security restrictions.

        .PARAMETER NoClobber
        NoClobber prevents an existing file from being overwritten and displays a message that the file already exists. By
        default, if a file exists in the specified path, `Write-LogDebug` overwrites the file without warning.

        .PARAMETER NoNewline
        The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted
        between the output strings. No newline is added after the last output string.

        .INPUTS
        [System.String].  `Write-LogDebug` accepts message strings as input from the pipeline.

        .OUTPUTS
        None
        `Write-LogDebug` only writes to the debug stream. It does not write any objects to the pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE

        .LINK
        Get-Date

        .LINK
        Out-File

        .LINK
        Write-Debug
    #>
}

<#
    Write-LogError
#>
function Write-LogError {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingMessage', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(Mandatory, ParameterSetName = 'UsingErrorRecord', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,

        [Parameter(Mandatory, ParameterSetName = 'UsingException', ValueFromPipeLineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Exception]
        $Exception,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $FilePath,

        [string]
        $Prefix = 'ERROR',

        [ValidateSet('ascii', 'bigendianunicode', 'default', 'oem', 'string', 'string', 'unknown', 'utf7', 'utf8', 'utf32')]
        [string]
        $Encoding,

        [ValidateRange(1, 2147483647)]
        [System.Int32]
        $Width,

        [switch]
        $Append,

        [switch]
        $Force,

        [switch]
        $NoClobber,

        [switch]
        $NoNewline
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $writeLogHash = @{
            FilePath        = $FilePath
            Prefix          = $Prefix
            Append          = $Append.IsPresent
            Force           = $Force.IsPresent
            NoNewline       = $NoNewline.IsPresent
            NoClobber       = $NoClobber.IsPresent
            ForegroundColor = 'Red'
            BackgroundColor = 'Cyan'
        }

        if (Test-PSParameter -Name 'Encoding' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Encoding', $Encoding)
        }

        if (Test-PSParameter -Name 'Width' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Width', $Width)
        }
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'UsingMessage' {
                $writeLogHash.Add('Message', $Message)
                break
            }

            'UsingErrorRecord' {
                $writeLogHash.Add('Message', $ErrorRecord.Exception.Message)
                break
            }

            'UsingException' {
                $writeLogHash.Add('Message', $Exception.Message)
                break
            }

            default {
                throw "Illegal ParameterSetName $PSCmdlet.ParameterSetName"
            }
        }

        Write-LogConsole @writeLogHash
    }

    <#
        .SYNOPSIS
        Writes an object to the error stream and the log file.

        .DESCRIPTION
        The `Write-LogError` cmdlet declares a non-terminating error. By default, errors are sent in the error stream to the host program
        to be displayed, along with output.

        To write a non-terminating error, enter an error message string, an ErrorRecord object, or an Exception object. Use the other
        parameters of `Write-LogError` to populate the error record.

        Non-terminating errors write an error to the error stream, but they do not stop command processing. If a non-terminating error
        is declared on one item in a collection of input items, the command continues to process the other items in the collection.

        To declare a terminating error, use the `Throw` keyword. For more information, see about_Throw

        .PARAMETER Message
        Specifies the message text of the error. If the text includes spaces or special characters, enclose it in quotation marks.

        .PARAMETER ErrorRecord
        Specifies an error record object that represents the error. Use the properties of the object to describe the error.

        To create an error record object, use the `New-ErrorRecord` cmdlet or get an error record object from the array in the `$Error`
        automatic variable.

        .PARAMETER Exception
        Specifies an exception object that represents the error. Use the properties of the object to describe the error.

        To create an exception object, use a hash table or use the `New-Object` cmdlet.

        .PARAMETER FilePath
        Specifies the path to the output file.

        .PARAMETER Prefix
        The prefix to apply before the message string in logging.

        .PARAMETER Encoding
        Specifies the type of encoding for the target file. The default value is `unicode`.

        The acceptable values for this parameter are as follows:

        - `ascii` Uses ASCII (7-bit) character set.
        - `bigendianunicode` Uses UTF-16 with the big-endian byte order.
        - `default` Uses the encoding that corresponds to the system's active code page (usually ANSI).
        - `oem` Uses the encoding that corresponds to the system's current OEM code page.
        - `string` Same as `unicode`.
        - `unicode` Uses UTF-16 with the little-endian byte order.
        - `unknown` Same as `unicode`.
        - `utf7` Uses UTF-7.
        - `utf8` Uses UTF-8.
        - `utf32` Uses UTF-32 with the little-endian byte order.

        .PARAMETER Width
        Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped. If this
        parameter is not used, the width is determined by the characteristics of the host. The default for the PowerShell console
        is 80 characters.

        .PARAMETER Append
        Adds the output to the end of an existing file. If no Encoding is specified, the cmdlet uses the default encoding. That
        encoding may not match the encoding of the target file. This is the same behavior as the redirection operator (`>>`).

        .PARAMETER Force
        Overrides the read-only attribute and overwrites an existing read-only file. The Force parameter does not override
        security restrictions.

        .PARAMETER NoClobber
        NoClobber prevents an existing file from being overwritten and displays a message that the file already exists. By
        default, if a file exists in the specified path, `Write-LogDebug` overwrites the file without warning.

        .PARAMETER NoNewline
        The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted
        between the output strings. No newline is added after the last output string.

        .INPUTS
        [System.String].  `Write-LogError` accepts message strings as input from the pipeline.

        [System.Management.Automation.ErrorRecord].  `Write-LogError` accepts [errorrecord] as input from the pipeline.

        [System.Exception].  `Write-LogError` accept exceptions derived from [exception] as input from the pipeline.

        .OUTPUTS
        None
            `Write-LogError` only writes to the error stream. It does not write any objects to the pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE

        .LINK
        Write-LogConsole

        .LINK
        New-ErrorRecord

        .LINK
        about_Throw
    #>
}

<#
    Write-LogEvent
#>
function Write-LogEvent {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [ValidateRange(0, 65535)]
        [System.Int32]
        $EventId,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Source,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $FilePath,

        [string]
        $Prefix = 'EVENT',

        [System.Int16]
        $Category,

        [string]
        $ComputerName,

        [ValidateSet('Error', 'Warning', 'Information', 'SuccessAudit', 'FailureAudit')]
        [System.Diagnostics.EventLogEntryType]
        $EntryType,

        [System.Byte[]]
        $RawData,

        [ValidateSet('ascii', 'bigendianunicode', 'default', 'oem', 'string', 'string', 'unknown', 'utf7', 'utf8', 'utf32')]
        [string]
        $Encoding,

        [ValidateRange(1, 2147483647)]
        [System.Int32]
        $Width,

        [switch]
        $Append,

        [switch]
        $Force,

        [switch]
        $NoClobber,

        [switch]
        $NoNewline
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $writeEventHash = @{
            EventId = $EventId
            LogName = $LogName
            Message = $Message
            Source  = $Source
        }

        if (Test-PSParameter -Name 'Category' -Parameters $PSBoundParameters) {
            $writeEventHash.Add('Category', $Category)
        }

        if (Test-PSParameter -Name 'ComputerName' -Parameters $PSBoundParameters) {
            $writeEventHash.Add('ComputerName', $ComputerName)
        }

        if (Test-PSParameter -Name 'EntryType' -Parameters $PSBoundParameters) {
            $writeEventHash.Add('EntryType', $EntryType)
        }

        if (Test-PSParameter -Name 'RawData' -Parameters $PSBoundParameters) {
            $writeEventHash.Add('RawData', $RawData)
        }

        $writeLogHash = @{
            Message        = $Message
            FilePath       = $FilePath
            Prefix         = $Prefix
            Append         = $Append.IsPresent
            Force          = $Force.IsPresent
            UseInformation = $true
        }

        if (Test-PSParameter -Name 'Encoding' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Encoding', $Encoding)
        }

        if (Test-PSParameter -Name 'Width' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Width', $Width)
        }

        Write-LogConsole @writeLogHash
        Write-EventLog @writeEventHash | Write-Output
    }

    <#
        .SYNOPSIS
        Writes an event to an event log and to a log file.

        .DESCRIPTION
        The `Write-LogEvent` cmdlet writes an event to an event log.

        To write an event to an event log, the event log must exist on the computer and the source must be registered for the event
        log.

        .PARAMETER EventId
        Specifies the event identifier. This parameter is required. The maximum value for the EventId parameter is 65535.

        .PARAMETER LogName
        Specifies the name of the log to which the event is written. Enter the log name. The log name is the value of the Log
        property, not the LogDisplayName . Wildcard characters are not permitted. This parameter is required.

        .PARAMETER Message
        Specifies the event message. This parameter is required.

        .PARAMETER Source
        Specifies the event source, which is typically the name of the application that is writing the event to the log.

        .PARAMETER FilePath
        Specifies the path to the output file.

        .PARAMETER Prefix
        The prefix to apply before the message string in logging.

        .PARAMETER Category
        Specifies a task category for the event. Enter an integer that is associated with the strings in the category message file
        for the event log.

        .PARAMETER ComputerName
        Specifies a remote computer. The default is the local computer.

        Type the NetBIOS name, an IP address, or a fully qualified domain name of a remote computer.

        This parameter does not rely on Windows PowerShell remoting. You can use the ComputerName parameter of the `Get-EventLog`
        cmdlet even if your computer is not configured to run remote commands.

        .PARAMETER EntryType
        Specifies the entry type of the event. The acceptable values for this parameter are: Error, Warning, Information,
        SuccessAudit, and FailureAudit. The default value is Information.

        For a description of the values, see EventLogEntryType Enumeration

        .PARAMETER RawData
        Specifies the binary data that is associated with the event, in bytes.

        .PARAMETER Encoding
        Specifies the type of encoding for the target file. The default value is `unicode`.

        The acceptable values for this parameter are as follows:

        - `ascii` Uses ASCII (7-bit) character set.
        - `bigendianunicode` Uses UTF-16 with the big-endian byte order.
        - `default` Uses the encoding that corresponds to the system's active code page (usually ANSI).
        - `oem` Uses the encoding that corresponds to the system's current OEM code page.
        - `string` Same as `unicode`.
        - `unicode` Uses UTF-16 with the little-endian byte order.
        - `unknown` Same as `unicode`.
        - `utf7` Uses UTF-7.
        - `utf8` Uses UTF-8.
        - `utf32` Uses UTF-32 with the little-endian byte order.

        .PARAMETER Width
        Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped. If this
        parameter is not used, the width is determined by the characteristics of the host. The default for the PowerShell console
        is 80 characters.

        .PARAMETER Append
        Adds the output to the end of an existing file. If no Encoding is specified, the cmdlet uses the default encoding. That
        encoding may not match the encoding of the target file. This is the same behavior as the redirection operator (`>>`).

        .PARAMETER Force
        Overrides the read-only attribute and overwrites an existing read-only file. The Force parameter does not override
        security restrictions.

        .PARAMETER NoClobber
        NoClobber prevents an existing file from being overwritten and displays a message that the file already exists. By
        default, if a file exists in the specified path, `Write-LogDebug` overwrites the file without warning.

        .PARAMETER NoNewline
        The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted
        between the output strings. No newline is added after the last output string.

        .INPUTS
        [System.String].  `Write-LogEvent` accepts string messages as input from the pipeline.

        .OUTPUTS
        [System.Diagnostics.EventLogEntry]
        This cmdlet returns objects that represents the events in the logs as output to the pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE

        .LINK
        Write-LogConsole

        .LINK
        Write-EventLog
    #>
}

<#
    Write-LogVerbose
#>
function Write-LogVerbose {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $FilePath,

        [string]
        $Prefix = 'VERBOSE',

        [ValidateSet('ascii', 'bigendianunicode', 'default', 'oem', 'string', 'string', 'unknown', 'utf7', 'utf8', 'utf32')]
        [string]
        $Encoding,

        [ValidateRange(1, 2147483647)]
        [System.Int32]
        $Width,

        [switch]
        $Append,

        [switch]
        $Force,

        [switch]
        $NoClobber,

        [switch]
        $NoNewline
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $writeLogHash = @{
            Message         = $Message
            FilePath        = $FilePath
            Prefix          = $Prefix
            Append          = $Append.IsPresent
            Force           = $Force.IsPresent
            NoClobber       = $NoClobber.IsPresent
            NoNewline       = $NoNewline.IsPresent
            ForegroundColor = 'Cyan'
            BackgroundColor = 'Black'
        }

        if (Test-PSParameter -Name 'Encoding' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Encoding', $Encoding)
        }

        if (Test-PSParameter -Name 'Width' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Width', $Width)
        }

        Write-LogConsole @writeLogHash
    }

    <#
        .SYNOPSIS
        Writes text to the verbose message stream and the log file.

        .DESCRIPTION
        The `Write-LogVerbose` cmdlet writes text to the verbose message stream in PowerShell. Typically, the verbose message stream is
        used to deliver more in depth information about command processing.

        By default, the verbose message stream is not displayed, but you can display it by changing the value of the
        `$VerbosePreference` variable or using the Verbose common parameter in any command.

        .PARAMETER Message
        Specifies the message to display. This parameter is required.

        .PARAMETER FilePath
        Specifies the path to the output file.

        .PARAMETER Prefix
        The prefix to apply before the message string in logging.

        .PARAMETER Encoding
        Specifies the type of encoding for the target file. The default value is `unicode`.

        The acceptable values for this parameter are as follows:

        - `ascii` Uses ASCII (7-bit) character set.
        - `bigendianunicode` Uses UTF-16 with the big-endian byte order.
        - `default` Uses the encoding that corresponds to the system's active code page (usually ANSI).
        - `oem` Uses the encoding that corresponds to the system's current OEM code page.
        - `string` Same as `unicode`.
        - `unicode` Uses UTF-16 with the little-endian byte order.
        - `unknown` Same as `unicode`.
        - `utf7` Uses UTF-7.
        - `utf8` Uses UTF-8.
        - `utf32` Uses UTF-32 with the little-endian byte order.

        .PARAMETER Width
        Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped. If this
        parameter is not used, the width is determined by the characteristics of the host. The default for the PowerShell console
        is 80 characters.

        .PARAMETER Append
        Adds the output to the end of an existing file. If no Encoding is specified, the cmdlet uses the default encoding. That
        encoding may not match the encoding of the target file. This is the same behavior as the redirection operator (`>>`).

        .PARAMETER Force
        Overrides the read-only attribute and overwrites an existing read-only file. The Force parameter does not override
        security restrictions.

        .PARAMETER NoClobber
        NoClobber prevents an existing file from being overwritten and displays a message that the file already exists. By
        default, if a file exists in the specified path, `Write-LogDebug` overwrites the file without warning.

        .PARAMETER NoNewline
        The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted
        between the output strings. No newline is added after the last output string.

        .INPUTS
        [System.String].  `Write-LogEvent` accepts message strings as input from the pipeline.

        .OUTPUTS
        None
        `Write-LogVerbose` only writes to the error stream. It does not write any objects to the pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE

        .LINK
        Write-LogConsole
    #>
}

<#
    Write-LogWarning
#>
function Write-LogWarning {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [string]
        $FilePath,

        [string]
        $Prefix = 'WARN',

        [ValidateSet('ascii', 'bigendianunicode', 'default', 'oem', 'string', 'string', 'unknown', 'utf7', 'utf8', 'utf32')]
        [string]
        $Encoding,

        [ValidateRange(1, 2147483647)]
        [System.Int32]
        $Width,

        [switch]
        $Append,

        [switch]
        $Force,

        [switch]
        $NoClobber,

        [switch]
        $NoNewline
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $writeLogHash = @{
            Message         = $Message
            FilePath        = $FilePath
            Prefix          = $Prefix
            Append          = $Append.IsPresent
            Force           = $Force.IsPresent
            NoClobber       = $NoClobber.IsPresent
            NoNewline       = $NoNewline.IsPresent
            ForegroundColor = 'Yellow'
            BackgroundColor = 'Black'
        }

        if (Test-PSParameter -Name 'Encoding' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Encoding', $Encoding)
        }

        if (Test-PSParameter -Name 'Width' -Parameters $PSBoundParameters) {
            $writeLogHash.Add('Width', $Width)
        }

        Write-LogConsole @writeLogHash
    }

    <#
        .SYNOPSIS
        Writes a warning message to host and to the logging file.

        .DESCRIPTION
        The `Write-LogWarning` cmdlet writes a warning message to the PowerShell host. The response to the warning depends on the value
        of the user's `$WarningPreference` variable and the use of the WarningAction common parameter.

        .PARAMETER Message
        Specifies the warning message.

        .PARAMETER FilePath
        Specifies the path to the output file.

        .PARAMETER Prefix
        The prefix to apply before the message string in logging.

        .PARAMETER Encoding
        Specifies the type of encoding for the target file. The default value is `unicode`.

        The acceptable values for this parameter are as follows:

        - `ascii` Uses ASCII (7-bit) character set.
        - `bigendianunicode` Uses UTF-16 with the big-endian byte order.
        - `default` Uses the encoding that corresponds to the system's active code page (usually ANSI).
        - `oem` Uses the encoding that corresponds to the system's current OEM code page.
        - `string` Same as `unicode`.
        - `unicode` Uses UTF-16 with the little-endian byte order.
        - `unknown` Same as `unicode`.
        - `utf7` Uses UTF-7.
        - `utf8` Uses UTF-8.
        - `utf32` Uses UTF-32 with the little-endian byte order.

        .PARAMETER Width
        Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped. If this
        parameter is not used, the width is determined by the characteristics of the host. The default for the PowerShell console
        is 80 characters.

        .PARAMETER Append
        Adds the output to the end of an existing file. If no Encoding is specified, the cmdlet uses the default encoding. That
        encoding may not match the encoding of the target file. This is the same behavior as the redirection operator (`>>`).

        .PARAMETER Force
        Overrides the read-only attribute and overwrites an existing read-only file. The Force parameter does not override
        security restrictions.

        .PARAMETER NoClobber
        NoClobber prevents an existing file from being overwritten and displays a message that the file already exists. By
        default, if a file exists in the specified path, `Write-LogDebug` overwrites the file without warning.

        .PARAMETER NoNewline
        The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted
        between the output strings. No newline is added after the last output string.

        .INPUTS
        [System.String].  `Write-LogWarning` accepts message strings as input from the pipeline.

        .OUTPUTS
        None
            `Write-LogWarning` only writes to host. It does not write any objects to the pipeline.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .EXAMPLE

        .LINK
        Write-LogConsole
    #>
}
