<#
    Compare-Enum
#>
function Compare-Enum {
    [CmdletBinding()]
    [OutputType([int])]
    param (
        [Parameter(Mandatory)]
        [Enum]
        $Instance,

        [Parameter(Mandatory)]
        [System.Object]
        [AllowNull()]
        $Target
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    $Instace.CompareTo($Target) | Write-Output
}

<#
    ConvertFrom-Int
#>
function ConvertFrom-Int {
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType,

        [Parameter(Mandatory)]
        [int]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::ToObject($EnumType, $Value) | Write-Output
}

<#
    ConvertFrom-String
#>
function ConvertFrom-String {
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType,

        [Parameter(Mandatory)]
        [string]
        $Value,

        [switch]
        $CaseSensitive
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::Parse($EnumType, $Value, (-not $CaseSensitive.IsPresent)) | Write-Output
}

<#
    ConvertTo-String
#>
function ConvertTo-String {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [Enum]
        $Instance,

        [Parameter(Mandatory)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Format
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    $Instance.ToString($Format) | Write-Output
}

<#
    Format-Enum
#>
function Format-Enum {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumTYpe,

        [Parameter(Mandatory)]
        [System.Object]
        $Value,

        [Parameter(Mandatory)]
        [string]
        $Format
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::Format($EnumType, $Value, $Format) | Write-Output
}

<#
    Get-AllEnumName
#>
function Get-AllEnumName {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::GetNames($EnumType) | Write-Output
}

<#
    Get-AllEnumValue
#>
function Get-AllEnumValue {
    [CmdletBinding()]
    [OutputTYpe([Array])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::GetValues($EnumType) | Write-Output
}

<#
    Get-AllEnumValueAsUnderlyingType
#>
function Get-AllEnumValueAsUnderlyingType {
    [CmdletBinding()]
    [OutputType([Array])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::GetValuesAsUnderlyingType($EnumType) | Write-Output
}

<#
    Get-EnumName
#>
function Get-EnumName {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType,

        [Parameter(Mandatory)]
        [System.Object]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::GetName($EnumType, $Value) | Write-Output
}

<#
    Get-EnumUnderlyingType
#>
function Get-EnumUnderlyingType {
    [CmdletBinding()]
    [OutputType([System.Type])]
    param (
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::GetUnderlyingType($EnumType) | Write-Output
}

<#
    Test-Enum
#>
function Test-Enum {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [Enum]
        $Instance,

        [Parameter(Mandatory)]
        [System.Object]
        [AllowNull()]
        $Obj
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    $Instance.Equals($Obj) | Write-Output
}

<#
    Test-EnumHasFlag
#>
function Test-EnumHasFlag {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [Enum]
        $Instance,

        [Parameter(Mandatory)]
        [Enum]
        $Flag
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    $Instance.HasFlag($Flag) | Write-Output
}

<#
    Test-EnumIsDefined
#>
function Test-EnumIsDefined {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [System.Type]
        $EnumType,

        [Parameter(Mandatory)]
        [System.Object]
        $Value
    )

    $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    [Enum]::IsDefined($EnumType, $Value) | Write-Output
}