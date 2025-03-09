<#
 =============================================================================
<copyright file="COutModule.psm1" company="John Merryweather Cooper">
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
<date>Created:  2025-1-27</date>
<summary>
This file "COutModule.psm1" is part of "COutModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

<#
    Write-StdOut
#>
function Write-StdOut {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingMessage')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]]
        $Message,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFormatString')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Format,

        [Parameter(ParameterSetName = 'UsingFormatString')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]
        $ArgumentList,

        [switch]
        $NoNewLine
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($NoNewLine.IsPresent) {
            if ($PSCmdlet.ParameterSetName -eq 'UsingFormatString') {
                [Console]::Out::Write($Format, $ArgumentList)
            }
            else {
                $Message | ForEach-Object -Process { [Console]::Out::Write($_) }
            }
        }
        else {
            if ($PSCmdlet.ParameterSetName -eq 'UsingFormatString') {
                [Console]::Out::WriteLine($Format, $ArgumentList)
            }
            else {
                $Message | ForEach-Object -Process { [Console]::Out::WriteLine($_) }
            }
        }
    }
}

<#
    Write-StdErr
#>
function Write-StdErr {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingMessage')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Message,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'UsingFormatString')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Format,

        [Parameter(ParameterSetName = 'UsingFormatString')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [object[]]
        $ArgumentList,

        [switch]
        $NoNewLine
    )

    BEGIN {
        $CmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        if ($NoNewLine.IsPresent) {
            if ($PSCmdlet.ParameterSetName -eq 'UsingFormatString') {
                [Console]::Error::Write($Format, $ArgumentList)
            }
            else {
                [Console]::Error::Write($Message)
            }
        }
        else {
            if ($PSCmdlet.ParameterSetName -eq 'UsingFormatString') {
                [Console]::Error::WriteLine($Format, $ArgumentList)
            }
            else {
                [Console]::Error::WriteLine($Message)
            }
        }
    }
}
