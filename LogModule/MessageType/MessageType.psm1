#requires -version 6.2

using module ErrorResponseType
using module TypeAccelerator

<#
    enum:  MessageType
#>
enum MessageType {
    Console
    Debug
    Error
    Fatal
    Trace
    Verbose
    Warning
}

<#
    Private Type Accelerator registration
#>
hidden $registerTypeAccelerators = New-Object -TypeName TypeAccelerator -ArgumentList
[System.Type[]]@([MessageType]),
    ([ErrorResponseType]::Error + [ErrorResponseType]::NonTerminatingErrorOn)

<#
    Conventional PowerShell Cmdlets
#>

<#
    Format-MessageType
#>
function Format-MessageType {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Console', 'Debug', 'Error', 'Fatal', 'Trace', 'Verbose', 'Warning')]
        [MessageType]
        $Value,

        [ValidateSet('G', 'g', 'D', 'd', 'X', 'x', 'F', 'f')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $FormatString = 'G'
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    if ([string]::IsNullOrEmpty($FormatString)) {
        $Value.ToString() | Write-Output
    }
    else {
        [System.Enum]::Format([MessageType], $Value, $FormatString) | Write-Output
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
        [ValidateSet('Console', 'Debug', 'Error', 'Fatal', 'Trace', 'Verbose', 'Warning')]
        [MessageType]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageType].GetEnumName($Value) | Write-Output
}

<#
    Get-EnumNames
#>
function Get-EnumNames {
    [CmdletBinding()]
    [OutputType([string[]])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageType].GetEnumNames() | Write-Output
}

<#
    Get-EnumUnderlyingType
#>
function Get-EnumUnderlyingType {
    [CmdletBinding()]
    [OutputType([System.Type])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageType].GetEnumUnderlyingType() | Write-Output
}

<#
    Get-EnumValues
#>
function Get-EnumValues {
    [CmdletBinding()]
    [OutputType([int[]])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageType].GetEnumValues() | Write-Output
}

<#
    Get-EnumValuesAsUnderlyingType
#>
function Get-EnumValuesAsUnderlyingType {
    [CmdletBinding()]
    [OutputType([System.Array])]
    param ()

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

    [MessageType].GetEnumValuesAsUnderlyingType() | Write-Output
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

    [System.Enum]::IsDefined([MessageType], $Value) | Write-Output
}

<#
    ConvertTo-EnumString
#>
function ConvertTo-EnumString {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Console', 'Debug', 'Error', 'Fatal', 'Trace', 'Verbose', 'Warning')]
        [MessageType]
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
function New-MessageType {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([MessageType])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[MessageType] enumeration with default value", $CmdletName)) {
        [MessageType]::Console | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$newTypeAcceleratorSlat = @{
    ExportedTypes = ([System.Type[]]@([MessageType]))
    Response      = ([ErrorResponseType]::Error -bor [ErrorResponseType]::NonTerminatingErrorOn)
}

New-TypeAccelerator @newTypeAccelerator
