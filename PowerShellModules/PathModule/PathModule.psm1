<#
 =============================================================================
<copyright file="PathModule.psm1" company="John Merryweather Cooper
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
<date>Created:  2025-2-20</date>
<summary>
This file "PathModule.psm1" is part of "PurgeNugetFeeds".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# PathModule.psm1
#

<###########################################
    ConvertTo-PathUri
##########################################>
function ConvertTo-PathUri {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
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
            $Path | Resolve-Path | ForEach-Object -Process {
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

<###########################################
    Get-Attribute
##########################################>
function Get-Attribute {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.FileAttributes])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-BaseName
##########################################>
function Get-BaseName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-CommandPath
##########################################>
function Get-CommandPath {
    [CmdletBinding(DefaultParameterSetName = 'UsingName')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingName')]
        [ValidateScript({ Test-Path -Path $_ -IsValid },
            ErrorMessage = "Name '{0}' is not a valid executable base name")]
        [SupportsWildcards()]
        [string[]]
        $Name,

        [ValidateSet('Alias', 'All', 'Application', 'Cmdlet', 'ExternalScript', 'Filter', 'Function', 'Script')]
        [System.Management.Automation.CommandTypes]
        $CommandType = 'All',

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

<###########################################
    Get-CreationTime
##########################################>
function Get-CreationTime {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-CreationTimeUtc
##########################################>
function Get-CreationTimeUtc {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([datetime])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-Directory
##########################################>
function Get-Directory {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.DirectoryInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType File },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-LiteralPath -Path $_ -PathType File },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
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

<###########################################
    Get-DirectoryName
##########################################>
function Get-DirectoryName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType File },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType File },
            ErrorMessage = "LiteralPath '{0}' is not a valid path leaf")]
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

<###########################################
    Get-DriveInfo
##########################################>
function Get-DriveInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([PSDriveInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-Exist
##########################################>
function Get-Exist {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -IsValid },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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
            $Path | Get-Item | ForEach-Object -Process {
                $Path | Get-Item | Select-Object -ExpandProperty Exists | Write-Output
            }
        }
    }
}

<###########################################
    Get-Extension
##########################################>
function Get-Extension {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-FullName
##########################################>
function Get-FullName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-File
#>
function Get-File {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "LiteralPath '{0}' is not a valid path leaf")]
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

<###########################################
    Get-IsContainer
#>
function Get-IsContainer {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-IsReadOnly
#>
function Get-IsReadOnly {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -IsValid },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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
            $Path | Get-Item | ForEach-Object -Process {
                $Path | Get-Item | Select-Object -ExpandProperty IsReadOnly | Write-Output
            }
        }
    }
}

<###########################################
    Get-Length
#>
function Get-Length {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([long])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path eaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "LiteralPath '{0}' is not a valid path leaf")]
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

<###########################################
    Get-LinkTarget
#>
function Get-LinkTarget {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-LinkType
#>
function Get-LinkType {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-Mode
#>
function Get-Mode {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-ModeWithoutHardLink
#>
function Get-ModeWithoutHardLink {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-Name
#>
function Get-Name {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-Parent
#>
function Get-Parent {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container },
            ErrorMessage = "Path '{0}' is not a valid path container or")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "LiteralPath '{0}' is not a valid path container")]
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

<###########################################
    Get-ProviderInfo
#>
function Get-ProviderInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([ProviderInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-PSChildName
#>
function Get-PSChildName {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-PSParentPath
#>
function Get-PSParentPath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-PSPath
#>
function Get-PSPath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-ResolvedTarget
#>
function Get-ResolvedTarget {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-Root
#>
function Get-Root {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container },
            ErrorMessage = "Path '{0}' is not a valid path container")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "LiteralPath '{0}' is not a valid path container")]
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

<###########################################
    Get-UnixFileMode
#>
function Get-UnixFileMode {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.UnixFileMode])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
    Get-VersionInfo
#>
function Get-VersionInfo {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.Diagnostics.FileVersionInfo])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "LiteralPath '{0}' is not a valid path leaf")]
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

<###########################################
    Set-Attribute
#>
function Set-Attribute {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [System.IO.Attributes]
        $Attribute,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name Attributes -Value $Attribute
        }
        else {
            $Path | Set-ItemProperty -Name Attributes -Value $Attribute
        }
    }
}

<###########################################
    Set-CreationTime
#>
function Set-CreationTime {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [datetime]
        $Local,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name CreationTime -Value $Local
        }
        else {
            $Path | Set-ItemProperty -Name CreationTime -Value $Local
        }
    }
}

<###########################################
    Set-CreationTimeUtc
#>
function Set-CreationTimeUtc {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [datetime]
        $Utc,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name CreationTimeUtc -Value $Utc
        }
        else {
            $Path | Set-ItemProperty -Name CreationTimeUtc -Value $Utc
        }
    }
}

<###########################################
    Set-Extension
#>
function Set-Extension {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Extension,

        [switch]
        $PassThru,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            if ($PassThru.IsPresent) {
                $LiteralPath | ForEach-Object -Process { [System.IO.Path]::ChangeExtension($_, $Extension) | Write-Output }
            }
            else {
                $LiteralPath | ForEach-Object -Process { [System.IO.Path]::ChangeExtension($_, $Extension) | Out-Null }
            }
        }
        else {
            if ($PassThru.IsPresent) {
                $Path | Resolve-Path | ForEach-Object -Process { [System.IO.Path]::ChangeExtension($_, $Extension) | Write-Output }
            }
            else {
                $Path | Resolve-Path | ForEach-Object -Process { [System.IO.Path]::ChangeExtension($_, $Extension) | Out-Null }
            }
        }
    }
}

<###########################################
    Set-IsReadOnly
#>
function Set-IsReadOnly {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [bool]
        $Toggle,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name IsReadOnly -Value $Toggle
        }
        else {
            $Path | Set-ItemProperty -Name IsReadOnly -Value $Toggle
        }
    }
}

<###########################################
    Set-LastAccessTime
#>
function Set-LastAccessTime {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [datetime]
        $Local,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name LastAccessTime -Value $Local
        }
        else {
            $Path | Set-ItemProperty -Name LastAccessTime -Value $Local
        }
    }
}

<###########################################
    Set-LastAccessTimeUtc
#>
function Set-LastAccessTimeUtc {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [datetime]
        $Utc,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name LastAccessTimeUtc -Value $Utc
        }
        else {
            $Path | Set-ItemProperty -Name LastAccessTimeUtc -Value $Utc
        }
    }
}

<###########################################
    Set-LastWriteTime
#>
function Set-LastWriteTime {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [datetime]
        $Local,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name LastAccessTime -Value $Local
        }
        else {
            $Path | Set-ItemProperty -Name LastAccessTime -Value $Local
        }
    }
}

<###########################################
    Set-LastWriteTimeUtc
#>
function Set-LastWriteTimeUtc {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [datetime]
        $Utc,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name LastWriteTimeUtc -Value $Utc
        }
        else {
            $Path | Set-ItemProperty -Name LastWriteTimeUtc -Value $Utc
        }
    }
}

<###########################################
    Set-UnixFileMode
#>
function Set-UnixFileMode {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low', DefaultParameterSetName = 'UsingPath')]
    [OutputType([void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath,

        [Parameter(Mandatory)]
        [System.IO.UnixFileMode]
        $FileMode,

        [switch]
        $Force
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        if ($Force.IsPresent -and -not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = 'None'
        }
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Set-ItemProperty -Name UnixFileMode -Value $FileMode
        }
        else {
            $Path | Set-ItemProperty -Name UnixFileMode -Value $FileMode
        }
    }
}

<###########################################
    Test-AbsolutePath
#>
function Test-AbsolutePath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        $sessionState = [System.Management.Automation.SessionState]::new()
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                (Split-Path -LiteralPath $_ -IsAbsolute) -or $sessionState.Path.IsPSAbsolute($_) | Write-Output
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                (Split-Path -Path $_ -IsAbsolute) -or $sessionState.Path.IsPSAbsolute($_) | Write-Output
            }
        }
    }
}

<###########################################
    Test-Exist
#>
function Test-Exist {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -IsValid },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Get-Item | ForEach-Object -Process {
                $_.Exists -or (Test-Path -LiteralPath $_ -PathType Any) | Write-Output
            }
        }
        else {
            $Path | Get-Item | ForEach-Object -Process {
                $_.Exists -or (Test-Path -Path $_ -PathType Any) | Write-Output
            }
        }
    }
}

<###########################################
    Test-IsReadOnly
#>
function Test-IsReadOnly {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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
            $Path | Get-Item | ForEach-Object -Process {
                $Path | Get-Item | Select-Object -ExpandProperty IsReadOnly | Write-Output
            }
        }
    }
}

<###########################################
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
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
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
            $Path | Resolve-Path | ForEach-Object -Process {
                if (Test-NullOrWhiteSpace -LiteralPath $) {
                    $false | Write-Output
                }
                elseif (-not (Test-Valid -Path $_)) {
                    $false | Write-Output
                }
                elseif (-not (Test-PathRooted -Path $_)) {
                    $false | Write-Output
                }
                else {
                    Test-AbsolutePath -Path $_ | Write-Output
                }
            }
        }
    }
}

<###########################################
    Test-IsContainer
#>
function Test-IsContainer {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScript({ Test-Path -Path $_ -PathType Any },
            ErrorMessage = "Path '{0}' is not a valid path that is either container or leaf")]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Any },
            ErrorMessage = "LiteralPath '{0}' is not a valid path that is either container or leaf")]
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

<###########################################
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
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                [string]::IsNullOrEmpty($_) | Write-Output
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                [string]::IsNullOrEmpty($_) | Write-Output
            }
        }
    }
}

<###########################################
    Test-NullOrWhiteSpace
#>
function Test-NullOrWhiteSpace {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [AllowNull()]
        [AllowEmptyString()]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                [string]::IsNullOrWhiteSpace($_) | Write-Output
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                [string]::IsNullOrWhiteSpace($_) | Write-Output
            }
        }
    }
}

<###########################################
    Test-PathRooted
#>
function Test-PathRooted {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScritp({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScritp({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process { [System.IO.Path]::IsPathRooted($_) | Write-Output }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                [System.IO.Path]::IsPathRooted($_) | Write-Output
            }
        }
    }
}

<###########################################
    Test-PathUnqualified
#>
function Test-PathUnqualifed {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScritp({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScritp({ Test-Path -Path $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                $unqualified = Split-Path -Path $_ -NoQualifier
                $normalized = $_ -replace [System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar
                $unqualifed -eq $normalize | Write-Output
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

<###########################################
    Test-PathUri
##########################################>
function Test-PathUri {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScritp({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScritp({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
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

<###########################################
    Test-PathVolume
##########################################>
function Test-PathVolume {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScritp({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScritp({ Test-Path -LiteralPath $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                $qualifier = Split-Path -LiteralPath $_ -Qualifer
                ($qualifier -eq $_.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) -or ($qualifier -eq $_.TrimEnd([System.IO.Path]::AltDirectorySeparatorChar)) | Write-Output
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                $qualifier = Split-Path -Path $_ -Qualifer
                ($qualifier -eq $_.TrimEnd([System.IO.Path]::DirectorySeparatorChar)) -or ($qualifier -eq $_.TrimEnd([System.IO.Path]::AltDirectorySeparatorChar)) | Write-Output
            }
        }
    }
}

<###########################################
    Test-RelativePath
##########################################>
function Test-RelativePath {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateScritp({ Test-Path -Path $_ -PathType Any })]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateScritp({ Test-LiteralPath -Path $_ -PathType Any })]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name

        $sessionState = [System.Management.Automation.SessionState]::new()
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | ForEach-Object -Process {
                (-not (Test-AbsolutePath -LiteralPath $_)) | Write-Output
            }
        }
        else {
            $Path | Resolve-Path | ForEach-Object -Process {
                (-not (Test-AbsolutePath -Path $_)) | Write-Output
            }
        }
    }
}

<###########################################
    Test-Uri
##########################################>
function Test-Uri {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Uri,

        [ValidateSet('Absolute', 'RelativeOrAbsolute', 'Relative')]
        [System.UriKind]
        $UriKind = 'Absolute'
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        $Uri | ForEach-Object -Process {
            [uri]::IsWellFormedUriString($_, $UriKind) | Write-Output
        }
    }
}

<###########################################
    Test-Valid
##########################################>
function Test-Valid {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingPath')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingLiteralPath')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath
    )

    BEGIN {
        Set-StrictMode -Version 3.0
        Set-Variable -Name CmdletName -Option ReadOnly -Value $MyInvocation.MyCommand.Name
    }

    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
            $LiteralPath | Test-Path -IsValid | Write-Output
        }
        else {
            $Path | Test-Path -IsValid | Write-Output
        }
    }
}
