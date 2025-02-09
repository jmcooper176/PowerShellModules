<#
 =============================================================================
<copyright file="ListDictionary.psm1" company="U.S. Office of Personnel
Management">
    Copyright (c) 2022-2025, John Merryweather Cooper.
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
This file "ListDictionary.psm1" is part of "ContainersModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#requires -version 7.4

#
# ListDictionary.psm1 - class ListDictionary
#

class ListDictionary : System.Collections.Specialized.ListDictionary {
    <#
        Public Properties
    #>
    [string]$ClassName

    <#
        Hidden Properties
    #>
    hidden [System.Collections.Specialized.ListDictionary]$Instance

    <#
        Constructors
    #>
    ListDictionary() {
        $this.Instance = [System.Collections.Specialized.ListDictionary]::new()
    }

    <#
        Public Methods
    #>
    [void]Add([object]$key, [object]$value) {
        $this.Instance.Add($key, $value)
    }

    [void]Clear() {
        $this.Instance.Clear()
    }

    [bool]Contains([object]$key) {
        return $this.Instance.Contains($key)
    }

    [bool]ContainsKey([object]$key) {
        return $this.Instance.ContainsKey($key)
    }

    [bool]ContainsValue([object]$value) {
        return $this.Instance.ContainsValue($value)
    }

    [void]Remove([object]$key) {
        $this.Instance.Remove($key)
    }
}

<#
    Import-Module supporting Constructor
#>
function New-ListDictionary {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([ListDictionary])]
    param ()

    $CmdletName = Initialize-PSCmdlet -Invocation $MyInvocation

    if ($PSCmdlet.ShouldProcess("[ListDictionary] with default constructor", $CmdletName)) {
        [ListDictionary]::new() | Write-Output
    }
}

# Initialize this type with TypeAccelerator
$registerTypeAcceleratorSlat = @{
    ExportableType = ([System.Type[]]@([ListDictionary]))
    InvocationInfo = $MyInvocation
}

Register-TypeAccelerator @registerTypeAcceleratorSlat
