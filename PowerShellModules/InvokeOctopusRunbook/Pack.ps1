<#
 =============================================================================
<copyright file="Pack.ps1" company="U.S. Office of Personnel
Management">
    Copyright © 2025, U.S. Office of Personnel Management.
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
<date>Created:  2025-2-19</date>
<summary>
This file "Pack.ps1" is part of "InvokeOctopusRunbook".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# Pack.ps1
#

[CmdletBinding()]
param (
    [ValidateRange(0, 65534)]
    [int]
    $Major = 1,

    [ValidateRange(0, 65534)]
    [int]
    $Minor = 1
)

Set-StrictMode -Version 3.0
$ScriptName = $MyInvocation.MyCommand.Name

$version = New-FileVersion -Major $Major -Minor $Minor

& nuget pack Package.nuspec -Version $version.ToString()

if ($LASTEXITCODE -eq 0) {
    Write-Information -MessageData "$($ScriptName) : Packing of Version '$($Version)' successful" -InformationAction Continue
}
else {
    Write-Warning -Message "$($ScriptName) : Packing of Version '$($Version)' returned a non-zero code"
}
