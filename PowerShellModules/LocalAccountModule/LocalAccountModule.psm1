<#
 =============================================================================
<copyright file="LocalAccountModule.psm1" company="John Merryweather Cooper
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
This file "LocalAccountModule.psm1" is part of "LocalAccountModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

function Test-LocalGroupMember {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Member,

        [ValidateNotNullOrEmpty()]
        [string]
        $Name = 'Administrators'
    )

    $Member | ForEach-Object -Process {
        try {
            $members = Get-LocalGroupMember -Name $Name -Member $_ -ErrorAction stop | Measure-Object
            $members.Count -eq 1
        }
        catch {
            Write-Warning -Message ("Local User or Group '{0}' is NOT found." -f $_)
            $false
        }
    }

    <#
    .SYNOPSIS
    Test Member for membership in local group Name.

    .DESCRIPTION
    Function that tests Member for membership in local group Name.

    .PARAMETER Member
    The user or group to be evaluated for membership in local group
    Name.  More than one user or group can be provided, separated by
    commas.

    This parameter is mandatory.  This parameter may not be null
    or empty.

    .PARAMETER Name
    The name of the local group.  Defaults to 'Administrators'.

    This parameter may not be null or empty.

    .EXAMPLE
    PS> Test-LocalGroupMember -Member Administrator -Name Administrators
    True

    .EXAMPLE
    PS> Test-LocalGroupMember -Member Administrator,xyz -Name Administrators
    True
    False

    .INPUTS
    None.  You cannot pipe objects to Test-LocalGroupMember.

    .OUTPUTS
    System.Boolean.  Each Name is matched by its corresponding boolean
    result.

    .LINK
    Get-LocalGroupMember

    .LINK
    Measure-Object

    .NOTES
    Copyright © 2022 WellSky.  All Rights Reserved.
#>
}
