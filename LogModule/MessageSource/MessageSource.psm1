#requires -version 6.2

using module ErrorResponseType
using module TypeAccelerator

<#
    enum:  MessageSource
#>
enum MessageSource {
    CommandLineError    # Command line error : ResourceId : <error text> [<optional context information>]
    CompileTimeWarning  # <filename>(l, c, ll, lc) : warning ResourceId : <warning text> [<optional context information>]
    CompileTimeError    # <filename>(l, c, ll, lc) : error ResourceId : <error text> [<optional context information>]
    ScriptHost          # <scriptname>(l) : console : <info text>
    ScriptInfo          # <scriptname>(l) : info : <info text>
    ScriptVerbose       # <scriptname>(l) : verbose : <vebose text>
    ScriptWarning       # <scriptname>(l) : warning : <warning text> [<optional context information>]
    ScriptError         # <scriptname>(l) : error : <error text> [<optional context information>]
    ScriptDebug         # <scriptname>(l) : debug : <debug text> [<optional context information>]
    ScriptTrace         # <scriptname>(l) : trace : <trace text> [<optional context information>]
    CmdletHost          # <cmdletname>(l) : console : <info text>
    CmdletInfo          # <cmdletname>(l) : info : <info text>
    CmdletVerbose       # <cmdletname>(l) : verbose : <vebose text>
    CmdletWarning       # <cmdletname>(l) : warning : <warning text> [<optional context information>]
    CmdletError         # <cmdletname>(l) : error : <error text> [<optional context information>]
    CmdletDebug         # <cmdletname>(l) : debug : <debug text> [<optional context information>]
    CmdletTrace         # <cmdletname>(l) : debug : <trace text> [<optional context information>]
    SystemError         # <filename>(l, c) : ResourceId <error_hex|error_int> : [<optional context information>]
    Exception           # <filename>(l, c) : threw <exception_name> <error_hex|error_int> : [<optional context information>]
}

<#
    Conventional PowerShell Cmdlets
#>

<#
    Format-MessageSource
#>
function Format-MessageSource {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet([Enum]::GetNames([MessageSource]))]
        [MessageSource]
        $Value,

        [ValidateSet('G', 'g', 'D', 'd', 'X', 'x', 'F', 'f')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $FormatString = 'G'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ([string]::IsNullOrEmpty($FormatString)) {
        $Value.ToString() | Write-Output
    }
    else {
        [System.Enum]::Format([MessageSource], $Value, $FormatString) | Write-Output
    }
}

<#
    Get-EnumName
#>
function Get-EnumName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet([Enum]::GetNames([MessageSource]))]
        [MessageSource]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageSource].GetEnumName($Value) | Write-Output
}

<#
    Get-EnumNames
#>
function Get-EnumNames {
    [CmdletBinding()]
    [OutputType([string[]])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageSource].GetEnumNames() | Write-Output
}

<#
    Get-EnumUnderlyingType
#>
function Get-EnumUnderlyingType {
    [CmdletBinding()]
    [OutputType([System.Type])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageSource].GetEnumUnderlyingType() | Write-Output
}

<#
    Get-EnumValues
#>
function Get-EnumValues {
    [CmdletBinding()]
    [OutputType([int[]])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageSource].GetEnumValues() | Write-Output
}

<#
    Get-EnumValuesAsUnderlyingType
#>
function Get-EnumValuesAsUnderlyingType {
    [CmdletBinding()]
    [OutputType([System.Array])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageSource].GetEnumValuesAsUnderlyingType() | Write-Output
}

<#
    Test-IsDefined
#>
function Test-IsDefined {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Object]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [System.Enum]::IsDefined([MessageSource], $Value) | Write-Output
}

<#
    ConvertTo-EnumString
#>
function ConvertTo-EnumString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet([Enum]::GetNames([MessageSource]))]
        [MessageSource]
        $Value,

        [ValidateSet('G', 'g', 'D', 'd', 'X', 'x', 'F', 'f')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $FormatString = 'G'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ([string]::IsNullOrEmpty($FormatString)) {
        $Value.ToString() | Write-Output
    }
    else {
        $Value.ToString($FormatString) | Write-Output
    }
}

<#
    Import-Module supporting Constructor
#>
function New-MessageSource {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([MessageSource])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[MessageSource] enumeration with default value", $CmdletName)) {
        [MessageSource]::CmdletHost | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$newTypeAcceleratorSlat = @{
    ExportedTypes = ([System.Type[]]@([MessageSource]))
    Response      = ([ErrorResponseType]::Error -bor [ErrorResponseType]::NonTerminatingErrorOn)
}

New-TypeAccelerator @newTypeAccelerator
