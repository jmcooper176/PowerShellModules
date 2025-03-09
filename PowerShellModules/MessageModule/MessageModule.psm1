<#
 =============================================================================
<copyright file="MessageModule.psm1" company="John Merryweather Cooper">
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
<date>Created:  2025-1-9</date>
<summary>
This file "MessageModule.psm1" is part of "MessageModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Add-SeparatorIfNotNullOrEmpty
#>
function Add-SeparatorIfNotNullOrEmpty {
    [CmdletBinding()]
    [OutputType([System.Text.StringBuilder])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Text.StringBuilder]
        $Buffer,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : '
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if (($null -eq $Buffer) -or ($Buffer.Length -le 0)) {
            $Buffer | Write-Output
        }
        else {
            $Buffer.Append($Separator) | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Adds a separator to a string builder if the string builder is not null or empty.

        .DESCRIPTION
        The `Add-SeparatorIfNotNullOrEmpty` function adds a separator to a string builder if the string builder is not null or empty.

        .PARAMETER Buffer
        The string builder to which to add the separator.

        .PARAMETER Separator
        The separator to add to the string builder.

        .INPUTS
        [stringbuilder]  You can pipe a string builder to `Add-SeparatorIfNotNullOrEmpty`.

        .OUTPUTS
        [stringbuilder]  The function returns a string builder to the PowerShell pipeline.

        .EXAMPLE
        PS> $buffer = [System.Text.StringBuilder]::new()
        PS> $buffer.Append('Hello, World!') | Add-SeparatorIfNotNullOrEmpty -Separator ' : ' | Write-Output

        Hello, World! :

        Adds a separator to the string builder 'Hello, World!'.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    Format-Debug
#>
function Format-Debug {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $formatMessageSplat = @{
            Content        = $Message
            InvocationInfo = $InvocationInfo
            Separator      = $Separator
            AsLocal        = $AsLocal.IsPresent
            Timestamp      = $Timestamp.IsPresent
            UseCaller      = $UseCaller.IsPresent
        }

        Format-Message @formatMessageSplat | Write-Output
    }

    <#
        .SYNOPSIS
        Formats a debug stream message.

        .DESCRIPTION
        `Format-Debug` formats a debug stream message for output by `Write-Debug`.

        .PARAMETER InvocationInfo
        The invocation information for the error record.

        .PARAMETER Separator
        The separator to use between the message parts.

        .PARAMETER AsLocal
        Indicates that the timestamp should be formatted as a local time.

        .PARAMETER Timestamp
        Indicates that a timestamp should be included in the message.

        .PARAMETER UseCaller
        Indicates that the caller should be used as the origin of the message.  The default is to use the script path.

        .INPUTS
        [string]  `Format-Debug` accepts string input of the `Message` from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Format-Debug` writes the formatted message string to the PowerShell pipeline.

        .EXAMPLE
        PS> Format-Debug -InvocationInfo $MyInvocation -Message 'Test debug message to format' | Write-Debug

        DEBUG: Test debug message to format

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-Message

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Output
    #>
}

<#
    Format-Error
#>
function Format-Error {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.ErrorRecord[]]
        $ErrorRecord,

        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Category = $ErrorRecord.CategoryInfo.Category
        $ErrorId = $ErrorRecord.FullyQualifiedErrorId
        $ExceptionName = $ErrorRecord.Exception.GetType().FullName
        $HResult = $ErrorRecord.Exception.HResult

        $hr = ('0x{0:X8}|{0}' -f $HResult)

        $formatMessageSplat = @{
            Content        = $ErrorRecord.Exception.Message
            InvocationInfo = $InvocationInfo
            Metadata       = @($ErrorId, $ExceptionName, $Category, $hr)
            Separator      = $Separator
            AsLocal        = $AsLocal.IsPresent
            Timestamp      = $Timestamp.IsPresent
            UseCaller      = $UseCaller.IsPresent
        }

        Format-Message @formatMessageSplat | Write-Output
    }

    <#
        .SYNOPSIS
        Formats an error record as a string message.

        .DESCRIPTION
        The `Format-Error` function formats an error record as a string message.

        .PARAMETER ErrorRecord
        The error record to format.

        .PARAMETER InvocationInfo
        The invocation information for the error record.

        .PARAMETER Separator
        The separator to use between the message and the metadata.

        .PARAMETER AsLocal
        Indicates that the timestamp should be formatted as a local time.

        .PARAMETER Timestamp
        Indicates that a timestamp should be included in the message.

        .PARAMETER UseCaller
        Indicates that the caller should be used as the origin of the message.  The default is to use the script path.

        .INPUTS
        [ErrorRecord]  You can pipe an error record to `Format-Error`.

        .OUTPUTS
        [string]  The function returns a string message to the PowerShell pipeline.

        .EXAMPLE
        PS> Get-ChildItem -Path 'C:\Windows\Temp\DoesNotExist'
        PS> $Error | Format-Error -InvocationInfo $MyInvocation | Write-Error -ErrorAction Continue

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-Message

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Error

        .LINK
        Write-Output
    #>
}

<#
    Format-Information
#>
function Format-Information {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [string[]]
        $Tag,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $formatMessageSplat = @{
            Content        = $Message
            InvocationInfo = $InvocationInfo
            Separator      = $Separator
            AsLocal        = $AsLocal.IsPresent
            Timestamp      = $Timestamp.IsPresent
            UseCaller      = $UseCaller.IsPresent
        }

        if ($PSBoundParameters.ContainsKey('Tag')) {
            $formatMessageSplat.Add('Metadata', $Tag)
        }

        Format-Message @formatMessageSplat | Write-Output
    }

    <#
        .SYNOPSIS
        Formats an information stream message.

        .DESCRIPTION
        `Format-Information` formats an information stream message for output by `Write-Information`.

        .PARAMETER InvocationInfo
        The invocation information for the error record.

        .PARAMETER Separator
        The separator to use between the message and the metadata.

        .PARAMETER Tag
        Specifies an array of strings to associate with the message as metadata.

        .PARAMETER AsLocal
        Indicates that the timestamp should be formatted as a local time.

        .PARAMETER Timestamp
        Indicates that a timestamp should be included in the message.

        .PARAMETER UseCaller
        Indicates that the caller should be used as the origin of the message.  The default is to use the script path.

        .INPUTS
        [string]  `Format-Information` accepts string input of the `Message` from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Format-Information` writes the formatted message string to the PowerShell pipeline.

        .EXAMPLE
        PS> Format-Information -InvocationInfo $MyInvocation -Message 'Test information message to format' | Write-Information -InformationAction Continue

        Test information message to format

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-Message

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Information

        .LINK
        Write-Output
    #>
}

<#
    Format-Message
#>
function Format-Message {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $Content,

        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [Alias('Tag')]
        [string[]]
        $Metadata,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller,

        [switch]
        $UseGccBrief
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        $buffer = [System.Text.StringBuilder]::new()

        $formatOriginSplat = @{
            InvocationInfo = $InvocationInfo
            Separator      = $Separator
            AsLocal        = $AsLocal.IsPresent
            Timestamp      = $Timestamp.IsPresent
            UseCaller      = $UseCaller.IsPresent
            UseGccBrief    = $UseGccBrief.IsPresent
        }

        $origin = Format-Origin @formatOriginSplat
        $buffer.Append($origin) | Add-SeparatorIfNotNullOrEmpty -Separator $Separator | Out-Null

        if (Test-PSParameter -Name 'Metadata' -Parameters $PSBoundParameters) {
            $metaString = Format-Metadata -Metadata $Metadata
            $buffer.Append($metaString) | Add-SeparatorIfNotNullOrEmpty -Separator $Separator | Out-Null
        }
    }

    PROCESS {
        $Content | ForEach-Object -Process {
            ('{0}{1}' -f ($buffer.ToString()), $_) | Write-Output
        }
    }

    END {
        $buffer.Clear() | Out-Null
    }

    <#
        .SYNOPSIS
        Formats a message as a string message loosely following the Microsoft compiler message format.

        .DESCRIPTION
        The `Format-Message` function formats a message as a string message loosely following the Microsoft compiler message format.

        .PARAMETER Content
        The content of the message.

        .PARAMETER InvocationInfo
        The invocation information for the message.

        .PARAMETER Metadata
        The metadata for the message.

        .PARAMETER Separator
        The separator to use between the message and the metadata.

        .PARAMETER AsLocal
        Indicates that the timestamp should be formatted as a local time.

        .PARAMETER Timestamp
        Indicates that a timestamp should be included in the message.

        .PARAMETER UseCaller
        Indicates that the caller should be used as the origin of the message.  The default is to use the script path.

        .INPUTS
        [string]  You can pipe a string message to `Format-Message`.

        .OUTPUTS
        [string]  The function returns a string message to the PowerShell pipeline.

        .EXAMPLE
        PS> Format-Message -Content 'Hello, World!' -InvocationInfo $MyInvocation | Write-Output

        C: \Users\John\Documents\HelloWorld.ps1(42,1): Hello, World!

        Formats a message with the content 'Hello, World!' at line 42, column 1 in the script 'HelloWorld.ps1'.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        ForEach-Object

        .LINK
        Format-Metadata

        .LINK
        Format-Origin

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    Format-Metadata
#>
function Format-Metadata {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [string[]]
        $Metadata,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' '
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $Metadata -join $Separator | Write-Output

    <#
        .SYNOPSIS
        Formats array of metadata for `Format-Message`.

        .DESCRIPTION
        `Format-Metadata` formats an array of metadata for `Format-Message`.

        .PARAMETER Metadata
        Specifies the array of metadata strings to format.

        .PARAMETER Separator
        Specifies the metadata separator.  Defaults to space.

        .INPUTS
        None.  `Format-Metadata` takes no input from the pipeline.

        .OUTPUTS
        [string]  `Format-Metadata` returns a formatted string to the PowerShell pipeline.

        .EXAMPLE
        PS> Format-Metadata -Metadata @('ErrorId', 'ExceptionName', 'Category', 'HResult')

        ErrorId ExceptionName Category HResult

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Write-Output
    #>
}

<#
    Format-Origin
#>
function Format-Origin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller,

        [switch]
        $UseGccBrief
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    # Current use
    Set-Variable -Name MICROSOFT_TWO_PLACE_COMPILER_MESSAGE_FORMAT -Option Constant -Value '{0}({1},{2})'
    Set-Variable -Name MICROSOFT_TWO_PLACE_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -Option Constant -Value '[{0}]{1}({2},{3})'

    Set-Variable -Name GCC_TWO_PLACE_COMPILER_MESSAGE_FORMAT -Option Constant -Value '{0}:{1}:{2:d2}'
    Set-Variable -Name GCC_TWO_PLACE_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -Option Constant -Value '[{0}]{1}:{2}:{3:d2}'

    # For future use
    Set-Variable -Name MICROSOFT_FOUR_PLACE_COMPILER_MESSAGE_FORMAT -Option Constant -Value '{0}({1},{2},{3},{4})'
    Set-Variable -Name MICROSOFT_FOUR_PLACE_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -Option Constant -Value '[{0}]{1}({2},{3},{4},{5})'
    Set-Variable -Name MICROSOFT_THREE_PLACE_COLUMN_COMPILER_MESSAGE_FORMAT -Option Constant -Value '{0}({1},{2}-{3})'
    Set-Variable -Name MICROSOFT_THREE_PLACE_COLUMN_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -Option Constant -Value '[{0}]{1}({2},{3}-{4})'
    Set-Variable -Name MICROSOFT_TWO_PLACE_LINE_COMPILER_MESSAGE_FORMAT -Option Constant -Value '{0}({1}-{2})'
    Set-Variable -Name MICROSOFT_TWO_PLACE_LINE_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -Option Constant -Value '[{0}]{1}({2}-{3})'
    Set-Variable -Name MICROSOFT_ONE_PLACE_COMPILER_MESSAGE_FORMAT -Option Constant -Value '{0}({1})'
    Set-Variable -Name MICROSOFT_ONE_PLACE_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -Option Constant -Value '[{0}]{1}({2})'

    Set-Variable -Name GCC_COMPILER_MESSAGE_FORMAT -Option Constant -Value '{0}:{1}'
    Set-Variable -Name GCC_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -Option Constant -Value '[{0}]{1}:{2}'

    $line = $InvocationINfo.ScriptLineNumber
    $column = $InvocationInfo.OffsetInLine
    $path = ($InvocationInfo.PSCommandPath | Resolve-Path) -replace '\\', '/'
    $fileName = $InvocationInfo.PSCommandPath | Split-Path -Leaf
    $caller = Get-Item -LiteralPath $path | Select-Object -ExpandProperty BaseName

    # For future use
    $baseName = $caller

    if ($UseCaller.IsPresent) {
        Write-Verbose -Message "$($CmdletName) : The caller '$($caller)' is being used as the origin of the message."
        $path = $caller
        $fileName = $caller
    }

    if ($Timestamp.IsPresent -and $AsLocal.IsPresent) {
        $time = Microsoft.PowerShell.Utility\Get-Date -Format 's'
    }
    elseif ($Timestamp.IsPresent) {
        $time = Microsoft.PowerShell.Utility\Get-Date -AsUTC -Format 's'
    }

    if ($column -gt 132 -and -not $UseGccBrief.IsPresent) {
        Write-Verbose -Message "$($CmdletName) : The Microsoft format column number is greater than 132 which is not expected."
    }

    if ($Timestamp.IsPresent -and -not $UseGccBrief.IsPresent) {
        ($MICROSOFT_TWO_PLACE_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -f $time, $path, $line, $column) | Write-Output
    }
    elseif (-not $UseGccBrief.IsPresent) {
        ($MICROSOFT_TWO_PLACE_COMPILER_MESSAGE_FORMAT -f $path, $line, $column) | Write-Output
    }

    if ($column -gt 99 -and $UseGccBrief.IsPresent) {
        Write-Warning -Message "$($CmdletName) : The column number is greater than 99 which overflows the gcc brief format."
        $column = 99
    }

    if ($Timestamp.IsPresent -and $UseGccBrief.IsPresent) {
        ($GCC_TWO_PLACE_COMPILER_MESSAGE_FORMAT_WITH_TIMESTAMP -f $time, $fileName, $line, $column) | Write-Output
    }
    elseif ($UseGccBrief.IsPresent) {
        ($GCC_TWO_PLACE_COMPILER_MESSAGE_FORMAT -f $fileName, $line, $column) | Write-Output
    }

    <#
        .SYNOPSIS
        Formats the origin of a message.

        .DESCRIPTION
        The `Format-Origin` function formats the origin of a message.

        .PARAMETER InvocationInfo
        The invocation information for the origin.

        .PARAMETER Separator
        The separator to use between the message and the metadata.

        .PARAMETER AsLocal
        Indicates that the timestamp should be formatted as a local time.

        .PARAMETER Timestamp
        Indicates that a timestamp should be included in the message.

        .PARAMETER UseCaller
        Indicates that the caller should be used as the origin of the message.  The default is to use the script path.

        .INPUTS
        None.  You cannot pipe input to `Format-Origin`.

        .OUTPUTS
        [string]  The function returns a string message to the PowerShell pipeline.

        .EXAMPLE
        PS> Format-Origin -InvocationInfo $MyInvocation | Write-Output

        C: \Users\John\Documents\HelloWorld.ps1(42,1)

        Formats the origin of a message at line 42, column 1 in the script 'HelloWorld.ps1'.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Get-Date

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output
    #>
}

<#
    Format-Verbose
#>
function Format-Verbose {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $formatMessageSplat = @{
            Content        = $Message
            InvocationInfo = $InvocationInfo
            Separator      = $Separator
            AsLocal        = $AsLocal.IsPresent
            Timestamp      = $Timestamp.IsPresent
            UseCaller      = $UseCaller.IsPresent
        }

        Format-Message @formatMessageSplat | Write-Output
    }

    <#
        .SYNOPSIS
        Formats a verbose stream message.

        .DESCRIPTION
        `Format-Verbose` formats a verbose stream message for output by `Write-Verbose`.

        .PARAMETER InvocationInfo
        The invocation information for the verbose message.

        .PARAMETER Separator
        The separator to use between the message parts.

        .PARAMETER AsLocal
        Indicates that the timestamp should be formatted as a local time.

        .PARAMETER Timestamp
        Indicates that a timestamp should be included in the message.

        .PARAMETER UseCaller
        Indicates that the caller should be used as the origin of the message.  The default is to use the script path.

        .INPUTS
        [string]  `Format-Verbose` accepts string input of the `Message` from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Format-Verbose` writes the formatted message string to the PowerShell pipeline.

        .EXAMPLE
        PS> Format-Verbose -InvocationInfo $MyInvocation -Message 'Test verbose message to format' | Write-Verbose

        VERBOSE: Test verbose message to format

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-Message

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output

        .LINK
        Write-Verbose
    #>
}

<#
    Format-Warning
#>
function Format-Warning {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $Message,

        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $formatMessageSplat = @{
            Content        = $Message
            InvocationInfo = $InvocationInfo
            Separator      = $Separator
            AsLocal        = $AsLocal.IsPresent
            Timestamp      = $Timestamp.IsPresent
            UseCaller      = $UseCaller.IsPresent
        }

        Format-Message @formatMessageSplat | Write-Output
    }

    <#
        .SYNOPSIS
        Formats a warning stream message.

        .DESCRIPTION
        `Format-Warning` formats a warning stream message for output by `Write-Warning`.

        .PARAMETER InvocationInfo
        The invocation information for the verbose message.

        .PARAMETER Separator
        The separator to use between the message parts.

        .PARAMETER AsLocal
        Indicates that the timestamp should be formatted as a local time.

        .PARAMETER Timestamp
        Indicates that a timestamp should be included in the message.

        .PARAMETER UseCaller
        Indicates that the caller should be used as the origin of the message.  The default is to use the script path.

        .INPUTS
        [string]  `Format-Warning` accepts string input of the `Message` from the PowerShell pipeline.

        .OUTPUTS
        [string]  `Format-Warning` writes the formatted message string to the PowerShell pipeline.

        .EXAMPLE
        PS> Format-Warning -InvocationInfo $MyInvocation -Message 'Test warning message to format' | Write-Warning

        WARNING: Test warning message to format

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Format-Message

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Output

        .LINK
        Write-Warning
    #>
}

<#
    Write-DebugIf
#>
function Write-DebugIf {
    [CmdletBinding(DefaultParameterSetName = 'UsingCondition')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingCondition')]
        [bool]
        $Condition,

        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(ParameterSetName = 'UsingScriptBlock')]
        [scriptblock]
        $ScriptBlock,

        [ValidateNotNullOrEmpty()]
        [string]
        $Separator = ' : ',

        [switch]
        $AsLocal,

        [switch]
        $Timestamp,

        [switch]
        $UseCaller
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
        $origin = Format-Origin -InvocationInfo $InvocationInfo -Separator $Separator
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingScriptBlock') {
            $Condition = & $ScriptBlock
        }

        if ((Test-Debug -InvocationInfo $InvocationInfo) -and $Condition) {
            Write-Debug -Message "$($origin) : $($Message)"
        }
        elseif ((Test-Verbose -InvocationInfo $InvocationInfo) -and $Condition) {
            Write-Debug -Message "$($origin) : $($Message)"
            "$($origin) : $($Message)" | Write-Output
        }
    }

    <#
        .SYNOPSIS
        Writes a debug message if a condition is met.

        .DESCRIPTION
        The `Write-DebugIf` function writes a debug message if a condition is met.

        .PARAMETER Condition
        The condition to evaluate.

        .PARAMETER Message
        The message to write.

        .PARAMETER ScriptBlock
        The script block to evaluate.  If the script block returns `$true`, the message is written.

        .INPUTS
        None.  You cannot pipe input to `Write-DebugIf`.

        .OUTPUTS
        None.  The function does not return any output.

        .EXAMPLE
        PS> Write-DebugIf -Condition $true -Message 'This is a debug message.'

        Writes a debug message to the PowerShell host.

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Set-StrictMode

        .LINK
        Set-Variable

        .LINK
        Write-Debug

        .LINK
        Write-Output
    #>
}

<#
    Test-Debug
#>
function Test-Debug {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $debugPreference = $ExecutionContext.SessionState.PSVariable.GetValue('DebugPreference')
    $DebugContextPath = Join-Path -Path Variable: -ChildPath 'DebugContext'
    $DebugParameter = $InvocationInfo.BoundParameters.ContainsKey('Debug')

    ($debugPreference -ne 'SilentlyContinue') -or (Test-Path -LiteralPath $DebugContextPath) -or $DebugParameter | Write-Output

    <#
        .SYNOPSIS
        Determine whether Debug is enabled.

        .DESCRIPTION
        `Test-Debug` determines whether Debug is enabled in the calling process.

        .PARAMETER InvocationInfo
        Specifies the [System.Management.Automation.InvocationInfo] for the calling process.  This parameter is mandatory.

        .INPUTS
        None.  `Test-Debug` takes no input from the pipeline.

        .OUTPUTS
        [bool]  'Test-Debug` returns a boolean value to the PowerShell pipeline that is `True` if -Debug is enabled; otherwise `False`.

        .EXAMPLE
        PS> Test-Debug -InvocationInfo $MyInvocation

        False

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Join-Path

        .LINK
        Test-Path
    #>
}

<#
    Test-Verbose
#>
function Test-Verbose {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [System.Management.Automation.InvocationInfo]
        $InvocationInfo
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    $verbosePreference = $ExecutionContext.SessionState.PSVariable.GetValue('VerbosePreference')
    $VerboseParameter = $InvocationInfo.BoundParameters.ContainsKey('Verbose')
    ($verbosePreference -ne 'SilentlyContinue') -or $VerboseParameter | Write-Output

    <#
        .SYNOPSIS
        Determine whether Verbose is enabled.

        .DESCRIPTION
        `Test-Verbose` determines whether Verbose is enabled in the calling process.

        .PARAMETER InvocationInfo
        Specifies the [System.Management.Automation.InvocationInfo] for the calling process.  This parameter is mandatory.

        .INPUTS
        None.  `Test-Verbose` takes no input from the pipeline.

        .OUTPUTS
        [bool]  'Test-Verbose` returns a boolean value to the PowerShell pipeline that is `True` if -Debug is enabled; otherwise `False`.

        .EXAMPLE
        PS> Test-Verbose -InvocationInfo $MyInvocation

        False

        .NOTES
        Copyright © 2022-2025, John Merryweather Cooper.  All Rights Reserved.

        .LINK
        about_CommonParameters

        .LINK
        about_Functions_Advanced

        .LINK
        Join-Path

        .LINK
        Test-Path
    #>
}
