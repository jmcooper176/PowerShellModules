<#
 =============================================================================
<copyright file="ZipModule.psm1" company="John Merryweather Cooper
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
This file "ZipModule.psm1" is part of "ZipModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<###########################################
    Expand-Entry
##########################################>
function Expand-Entry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.IO.Compress.ZipArchiveEntry[]]
        $Entry,

        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container },
            ErrorMessage = "Folder '{0}' is not a valid path container")]
        [string]
        $Folder
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            $Entry | ForEach-Object -Process {
                [IO.Compression.ZipFileExtensions]::ExtractToFile($_.FullName, (Join-Path -Path $Folder -ChildPath $_.Name))
            }
        } catch {
            $Error | Write-Exception -RecommendedAction "Fail processing because entry extraction is required"
        }
    }
}

<###########################################
    Get-Entry
##########################################>
function Get-Entry {
    [CmdletBinding()]
    [OutputType([System.IO.Compress.ZipArchiveEntry[]])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'UsingPath', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf },
            ErrorMessage = "Path '{0}' is not a valid path leaf")]
        [string]
        $Path)

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation

        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }

    PROCESS {
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
            $zip.Entries | Write-Output
        } catch {
            $Error | Write-Exception -RecommendedAction "Fail processing because getting entry(s) is required"
        } finally {
            $zip.Dispose()
        }
    }
}
