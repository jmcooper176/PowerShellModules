<#
 =============================================================================
<copyright file="ZipFileModule.psm1" company="John Merryweather Cooper">
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
This file "ZipFileModule.psm1" is part of "ZipModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Get-Comment
#>
function Get-Comment {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath', ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $LiteralPath,

        [Parameter(Mandatory, ParameterSetName = 'UsingPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [string]
        $Path
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
                $zip = [System.IO.Compression.ZipFile]::OpenRead($LiteralPath)
                $zip | Select-Object -ExpandProperty Comment | Write-Output
            } else {
                $Path | Resolve-Path | ForEach-Object -Process { Get-Entry -LiteralPath $_ }
            }
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        } finally {
            $zip.Dispose()
        }
    }
}

<#
    Get-Entry
#>
function Get-Entry {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.Compress.ZipArchiveEntry])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath', ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $LiteralPath,

        [Parameter(Mandatory, ParameterSetName = 'UsingPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [string]
        $Path
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
                $zip = [System.IO.Compression.ZipFile]::OpenRead($LiteralPath)
                $zip | Select-Object -ExpandProperty Entries | Write-Output
            } else {
                $Path | Resolve-Path | ForEach-Object -Process { Get-Entry -LiteralPath $_ }
            }
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        } finally {
            $zip.Dispose()
        }
    }
}

<#
    Get-Entry
#>
function Get-Entry {
    [CmdletBinding(DefaultParameterSetName = 'UsingPath')]
    [OutputType([System.IO.Compress.ZipArchiveMode])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingLiteralPath', ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]
        $LiteralPath,

        [Parameter(Mandatory, ParameterSetName = 'UsingPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Get-ChildItem -Path $_ -Recurse | Test-Path -PathType Leaf })]
        [string]
        $Path
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'UsingLiteralPath') {
                $zip = [System.IO.Compression.ZipFile]::OpenRead($LiteralPath)
                $zip | Select-Object -ExpandProperty Mode | Write-Output
            } else {
                $Path | Resolve-Path | ForEach-Object -Process { Get-Entry -LiteralPath $_ }
            }
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        } finally {
            $zip.Dispose()
        }
    }
}

<#
    New-ZipFile
#>
function New-ZipFile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [Alias('Source')]
        [string]
        $SourceDirectory,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid })]
        [Alias('Destination')]
        [string]
        $DestinationArchive,

        [ValidateSet('Fastest', 'NoCompression', 'Optimal', 'SmallestSize')]
        [System.IO.Compression.CompressionLevel]
        $CompressionLevel = 'Optimal',

        [switch]
        $IncludeBaseDirectory
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            if ($PSCmdlet.ShouldProcess(@($DestiantionArchive, $CompressionLevel, $IncludeBaseDirectory.IsPresent), $CmdletName)) {
                [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory, $DestinationArchive, $CompressionLevel, $IncludeBaseDirectory.IsPresent)
            }
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        }
    }
}

<#
    Out-ZipFile
#>
function Out-ZipFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [Alias('Destination')]
        [string]
        $DestinationDirectory,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [Alias('Source')]
        [string]
        $SourceArchive,

        [switch]
        $Overwrite
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($SourceArchive, $DestinationDirectory, $Overwrite.IsPresent)
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        }
    }
}
