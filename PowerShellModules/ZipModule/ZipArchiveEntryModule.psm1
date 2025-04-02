<#
 =============================================================================
<copyright file="ZipArchiveEntryModule.psm1" company="John Merryweather Cooper
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
<date>Created:  2024-9-12</date>
<summary>
This file "ZipArchiveEntryModule.psm1" is part of "ZipModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<##########################################
    Get-Archive
##########################################>
function Get-Archive {
    [CmdletBinding()]
    [OutputType([System.IO.Compression.ZipArchive])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression
    }

    PROCESS {
        $Entry.Archive | Write-Output
    }
}

<##########################################
    Get-CompressedLength
##########################################>
function Get-CompressedLength {
    [CmdletBinding()]
    [OutputType([long])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        $Entry.CompressedLength | Write-Output
    }
}

<##########################################
    Get-Crc32
##########################################>
function Get-Crc32 {
    [CmdletBinding()]
    [OutputType([uint32])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        $Entry.Crc32 | Write-Output
    }
}

<##########################################
    Get-Entry
##########################################>
function Get-Entry {
    [CmdletBinding()]
    [OutputType([System.IO.Compression.ZipArchiveEntry])]
    param (
        [Parameter(Mandatory)]
        [System.IO.Compression.ZipArchive]
        $Archive,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "EntryName '{0}' is not a valid path leaf")]
        [string]
        [Alias('FullName')]
        $EntryName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        if (Test-Entry -Archive $Archive -EntryName $EntryName) {
            $Archive.GetEntry($EntryName) | Write-Output
        } else {
            $null | Write-Output
        }
    }
}

<##########################################
    Get-Length
##########################################>
function Get-Length {
    [CmdletBinding()]
    [OutputType([long])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        $Entry.CompressedLength | Write-Output
    }
}

<##########################################
    Get-Name
##########################################>
function Get-Name {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        $Entry.Name | Write-Output
    }
}

<##########################################
    Get-Path
##########################################>
function Get-Path {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        $Entry.FullName | Write-Output
    }
}

<##########################################
    New-Entry
##########################################>
function New-Entry {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'UsingCreateEntry')]
    [OutputType([System.IO.Compression.ZipArchiveEntry])]
    param (
        [Parameter(Mandatory)]
        [System.IO.Compression.ZipArchive]
        [Alias('Destination')]
        $Archive,

        [Parameter(Mandatory, ParameterSetName = 'UsingCreateEntryFromFile')]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "SourceFileName '{0}' is not a valid path leaf")]
        [Alias('FileName', 'FullName')]
        [string]
        $SourceFileName,

        [Parameter(Mandatory, ParameterSetName = 'UsingCreateEntryFromFile')]
        [Parameter(Mandatory, ParameterSetName = 'UsingCreateEntry', ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "EntryName '{0}' is not a valid path leaf")]
        [string]
        [Alias('Name', 'RelativeName')]
        $EntryName,

        [ValidateSet('Fastest', 'NoCompression', 'Optimal', 'SmallestSize')]
        [System.IO.Compression.CompressionLevel]
        $CompressionLevel = 'Optimal'
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            if ($PSCmdlet.ParameterSetName -eq 'UsingCreateEntryFromFile') {
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Archive, $SourceFileName, $EntryName, $CompressionLevel) | Write-Output
            } else {
                $Archive.CreateEntry($EntryName, $CompressionLevel) | Write-Output
            }
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        }
    }
}

<##########################################
    Open-Entry
##########################################>
function Open-Entry {
    [CmdletBinding()]
    [OutputType([System.IO.Stream])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            $Entry.Open() | Write-Output
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        }
    }
}

<##########################################
    Remove-Entry
##########################################>
function Remove-Entry {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            if ($PSCmdlet.ShouldProcess($Entry.FullName, $CmdletName)) {
                $Entry.Delete() | Out-Null
            }
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        }
    }
}

<##########################################
    Test-Entry
##########################################>
function Test-Entry {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [System.IO.Compression.ZipArchive]
        $Archive,

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -IsValid },
            ErrorMessage = "EntryName '{0}' is not a valid path leaf")]
        [string]
        [Alias('FullName')]
        $EntryName
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            [bool]($null -ne $Archive.GetEntry($EntryName)) | Write-Output
        } catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $false | Write-Output
        }
    }
}

<##########################################
    Test-IsEncrypted
##########################################>
function Test-IsEncrypted {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.Compression.ZipArchiveEntry]
        $Entry
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        $Entry.IsEncrypted | Write-Output
    }
}
