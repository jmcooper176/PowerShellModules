#
# PathModule.psm1
#

<#
    ConvertTo-PathUri
#>
function ConvertTo-PathUri {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Convert-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    [string]::Empty | Write-Output
                }
                else {
                    $uri = New-Object -TypeName System.Uri -ArgumentList $_
                    $uri.AbsoluteUri | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | Convert-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    [string]::Empty | Write-Output
                }
                else {
                    $uri = New-Object -TypeName System.Uri -ArgumentList $_
                    $uri.AbsoluteUri | Write-Output
                }
            }
        }
    }
}

<#
    Get-CommandPath
#>
function Get-CommandPath {
    [CmdletBinding(DefaultParameterSetName = 'UsingName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingName')]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [ValidateSet('Alias', 'All', 'Application', 'Cmdlet', 'ExternalScript', 'Filter', 'Function', 'Script')]
        [System.Management.Automation.CommandTypes]
        $CommandType,

        [Parameter(Mandatory, ParameterSetName = 'UsingAll')]
        [switch]
        $All
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingAll') {
            $getCommandSplat = @{
                All = $All.IsPresent
            }

            if ($PSBoundParameters.ContainsKey('CommandType')) {
                $getCommandSplat.Add('CommandType', $CommandType)
            }

            Get-Command @getCommandSplat | Select-Object -ExpandProperty Path | Write-Output
        }
        else {
            $getCommandSplat = @{
                Name = $Name
            }

            if ($PSBoundParameters.ContainsKey('CommandType')) {
                $getCommandSplat.Add('CommandType', $CommandType)
            }

            Get-Command @getCommandSplat | Select-Object -ExpandProperty Path | Write-Output
        }
    }
}

<#
    Get-Attribute
#>
function Get-Attribute {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.FileAttributes])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Attributes | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Attributes | Write-Output
        }
    }
}

<#
    Get-BaseName
#>
function Get-BaseName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty BaseName | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty BaseName | Write-Output
        }
    }
}

<#
    Get-CreationTime
#>
function Get-CreationTime {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty CreationTime | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty CreationTime | Write-Output
        }
    }
}

<#
    Get-CreationTimeUtc
#>
function Get-CreationTimeUtc {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty CreationTimeUtc | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty CreationTimeUtc | Write-Output
        }
    }
}

<#
    Get-Directory
#>
function Get-Directory {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Directory | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Directory | Write-Output
        }
    }
}

<#
    Get-DirectoryName
#>
function Get-DirectoryName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty DirectoryName | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty DirectoryName | Write-Output
        }
    }
}

<#
    Get-Exist
#>
function Get-Exist {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Exists | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Exists | Write-Output
        }
    }
}

<#
    Get-Extension
#>
function Get-Extension {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Extension | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Extension | Write-Output
        }
    }
}

<#
    Get-File
#>
function Get-File {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Write-Output
        }
        else {
            $Path | Get-Item | Write-Output
        }
    }
}

<#
    Get-FullName
#>
function Get-FullName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty FullName | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty FullName | Write-Output
        }
    }
}

<#
    Get-IsReadOnly
#>
function Get-IsReadOnly {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty IsReadOnly | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty IsReadOnly | Write-Output
        }
    }
}

<#
    Get-LastAccessTime
#>
function Get-LastAccessTime {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty LastAccessTime | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty LastAccessTime | Write-Output
        }
    }
}

<#
    Get-LastAccessTimeUtc
#>
function Get-LastAccessTimeUtc {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty LastAccessTimeUtc | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty LastAccessTimeUtc | Write-Output
        }
    }
}

<#
    Get-LastWriteTime
#>
function Get-LastWriteTime {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty LastWriteTime | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty LastWriteTime | Write-Output
        }
    }
}

<#
    Get-LastWriteTimeUtc
#>
function Get-LastWriteTimeUtc {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty LastWriteTimeUtc | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty LastWriteTimeUtc | Write-Output
        }
    }
}

<#
    Get-Length
#>
function Get-Length {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([long])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Length | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Length | Write-Output
        }
    }
}

<#
    Get-LinkTarget
#>
function Get-LinkTarget {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty LinkTarget | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty LinkTarget | Write-Output
        }
    }
}

<#
    Get-LinkType
#>
function Get-LinkType {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty LinkType | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty LinkType | Write-Output
        }
    }
}

<#
    Get-Mode
#>
function Get-Mode {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Mode | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Mode | Write-Output
        }
    }
}

<#
    Get-ModeWithoutHardLink
#>
function Get-ModeWithoutHardLink {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty ModeWithoutHardLink | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty ModeWithoutHardLink | Write-Output
        }
    }
}

<#
    Get-Name
#>
function Get-Name {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Name | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Name | Write-Output
        }
    }
}

<#
    Get-Parent
#>
function Get-Parent {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Parent | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Parent | Write-Output
        }
    }
}

<#
    Get-PSChildName
#>
function Get-PSChildName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty PSChildName | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty PSChildName | Write-Output
        }
    }
}

<#
    Get-PSDrive
#>
function Get-PSDrive {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([PSDriveInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty PSDrive | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty PSDrive | Write-Output
        }
    }
}

<#
    Get-PSIsContainer
#>
function Get-PSIsContainer {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty PSIsContainer | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty PSIsContainer | Write-Output
        }
    }
}

<#
    Get-PSParentPath
#>
function Get-PSParentPath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty PSParentPath | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty PSParentPath | Write-Output
        }
    }
}

<#
    Get-PSPath
#>
function Get-PSPath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty PSPath | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty PSPath | Write-Output
        }
    }
}

<#
    Get-PSProvider
#>
function Get-PSProvider {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([ProviderInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty PSProvider | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty PSProvider | Write-Output
        }
    }
}

<#
    Get-ResolvedTarget
#>
function Get-ResolvedTarget {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty ResolvedTarget | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty ResolvedTarget | Write-Output
        }
    }
}

<#
    Get-Root
#>
function Get-Root {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty Root | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty Root | Write-Output
        }
    }
}

<#
    Get-UnixFileMode
#>
function Get-UnixFileMode {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.UnixFileMode])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty UnixFileMode | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty UnixFileMode | Write-Output
        }
    }
}

<#
    Get-VersionInfo
#>
function Get-VersionInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([object])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | Select-Object -ExpandProperty VersionInfo | Write-Output
        }
        else {
            $Path | Get-Item | Select-Object -ExpandProperty VersionInfo | Write-Output
        }
    }
}

<#
    Test-AbsolutePath
#>
function Test-AbsolutePath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        $sessionState = [System.Management.Automation.SessionState]::new()
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Convert-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    (Split-Path -LiteralPath $_ -IsAbsolute) -or $sessionState.Path.IsPSAbsolute($_) | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | Convert-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    (Split-Path -Path $_ -IsAbsolute) -or $sessionState.Path.IsPSAbsolute($_) | Write-Output
                }
            }
        }
    }
}

<#
    Test-FullPath
#>
function Test-FullPath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object {
                if (Test-NullOrWhiteSpace -LiteralPath $) {
                    $false | Write-Output
                }
                elseif (-not (Test-Valid -LiteralPath $_)) {
                    $false | Write-Output
                }
                elseif (-not (Test-PathRooted -LiteralPath $_)) {
                    $false | Write-Output
                }
                else {
                    Test-AbsolutePath -LiteralPath $_ | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object {
                if (Test-NullOrWhiteSpace -LiteralPath $) {
                    $false | Write-Output
                }
                elseif (-not (Test-Valid -Path $_)) {
                    $false | Write-Output
                }
                elseif (-not (Test-PathRooted -LiteralPath $_)) {
                    $false | Write-Output
                }
                else {
                    Test-AbsolutePath -Path $_ | Write-Output
                }
            }
        }
    }
}

<#
    Test-NullOrEmpty
#>
function Test-NullOrEmpty {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Convert-Path | ForEach-Object -Process {
                [string]::IsNullOrEmpty($_) | Write-Output
            }
        }
        else {
            $Path | Resolve-Path | Convert-Path | ForEach-Object -Process {
                [string]::IsNullOrEmpty($_) | Write-Output
            }
        }
    }
}

<#
    Test-NullOrWhiteSpace
#>
function Test-NullOrWhiteSpace {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [AllowNull()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Convert-Path | ForEach-Object -Process {
                [string]::IsNullOrWhiteSpace($_) | Write-Output
            }
        }
        else {
            $Path | Resolve-Path | Convert-Path | ForEach-Object -Process {
                [string]::IsNullOrWhiteSpace($_) | Write-Output
            }
        }
    }
}

<#
    Test-PathRooted
#>
function Test-PathRooted {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Convert-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    [System.IO.Path]::IsPathRooted($_) | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    [System.IO.Path]::IsPathRooted($_) | Write-Output
                }
            }
        }
    }
}

<#
    Test-PathUnqualified
#>
function Test-PathUnqualifed {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    $unqualified = Split-Path -Path $_ -NoQualifier
                    $normalized = $_ -replace [System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar
                    $unqualifed -eq $normalize | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    $unqualified = Split-Path -Path $_ -NoQualifier
                    $normalized = $_ -replace [System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar
                    $unqualifed -eq $normalize | Write-Output
                }
            }
        }
    }
}

<#
    Test-PathUri
#>
function Test-PathUri {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ConvertTo-PathUri | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    Test-Uri -Uri $_ | Write-Output
                }
            }
        }
        else {
            $Path | ConvertTo-PathUri | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    Test-Uri -Uri $_ | Write-Output
                }
            }
        }
    }
}

<#
    Test-PathVolume
#>
function Test-PathVolume {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    $qualifier = Split-Path -LiteralPath $_ -Qualifer
                    ($qualifier -eq $_.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) -or ($qualifier -eq $_.TrimEnd([System.IO.Path]::AltDirectorySeparatorChar)) | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    $qualifier = Split-Path -Path $_ -Qualifer
                    ($qualifier -eq $_.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) -or ($qualifier -eq $_.TrimEnd([System.IO.Path]::AltDirectorySeparatorChar)) | Write-Output
                }
            }
        }
    }
}

<#
    Test-RelativePath
#>
function Test-RelativePath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        $sessionState = [System.Management.Automation.SessionState]::new()
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    (-not Test-AbsolutePath -LiteralPath $_) | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    (-not Test-AbsolutePath -Path $_) | Write-Output
                }
            }
        }
    }
}

<#
    Test-Uri
#>
function Test-Uri {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $Uri,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Uri | ForEach-Object -Process {
            if ([string]::IsNullOrWhiteSpace($_)) {
                $false | Write-Output
            }
            else {
                [uri]::IsWellFormedUriString($_, 'Absolute') | Write-Output
            }
        }
    }
}

<#
    Test-Valid
#>
function Test-Valid {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath,
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    Test-Path -LiteralPath $_ -IsValid | Write-Output
                }
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                if ([string]::IsNullOrWhiteSpace($_)) {
                    $false | Write-Output
                }
                else {
                    Test-Path -Path $_ -IsValid | Write-Output
                }
            }
        }
    }
}
