<#
 =============================================================================
<copyright file="ProcessModule.psm1" company="John Merryweather Cooper">
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
This file "ProcessModule.psm1" is part of "ProcessModule".
</summary>
<remarks>description</remarks>
=============================================================================
#>

function Add-Account {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]
        $Members
    )

    BEGIN {
        $cmdletName = Initialize-PSCmdlet -MyInvocation $MyInvocation
    }

    PROCESS {
        $Members | ForEach-Object -Process {
            $item = $_

            if (-not (Test-ADAccountExist -NtAccount $item)) {
                Write-Warning -Message ("Skipping non-existant {0}" -f $item)
                continue
            }
            elseif (Test-LocalGroupMember -Member $item) {
                Write-Verbose -Message ("Skipping {0}" -f $item)
                continue
            }

            if ($PSCmdlet.ShouldProcess("Adding account '$($item)' to local group 'Administrators'", $CmdletName)) {
                Add-LocalGroupMember -Group 'Administrators' -Member $item -ErrorAction Stop
            }
            else {
                Write-Information -MessageData ("Add-LocalGroupMember -Group 'Administrators' -Member {0} -ErrorAction Stop" -f $item) -InformationAction Continue
            }
        }
    }

    <#
        .SYNOPSIS
        Processes Active Directory users and groups to add to the local
        'Administrators' group.

        .DESCRIPTION
        Function processing the Active Directory users and groups to add to
        the local 'Administrators' group.

        .PARAMETER Members
        The Active Directory users and groups to add to the 'Administrators'
        local group.

        .PARAMETER Fake
        Switch, if present, causes the function to take no action, but
        instead display the actions it would have taken with each $item of
        $Members.
    #>
}

function Test-ADAccountExist {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'UsingSamAccountName')]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'UsingNtAccountName')]
        [string]
        $NtAccount
    )

    if ($PSCmdlet.ParameterSetName -eq 'UsingSamAccountName') {
        try {
            $members = Get-ADObject -Filter { ((objectClass -eq User) -or (objectClass -eq Group)) -and (SamAccountName -eq $Name) } -ErrorAction stop | Measure-Object
            $members.Count -eq 1
        }
        catch {
            $false
        }
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'UsingNtAccountName') {
        if (-not $NtAccount.contains("\")) {
            $false
        }

        $server, $identity = $NtAccount.Split("\", 2)

        try {
            $members = Get-ADObject -Filter { ((objectClass -eq User) -or (objectClass -eq Group)) -and (SamAccountName -eq $identity) } -Server $server -ErrorAction stop | Measure-Object
            $members.Count -eq 1
        }
        catch {
            $false
        }
    }
    <#
    .SYNOPSIS
    Test whether an NTAccount name exists in Active Directory.

    .DESCRIPTION
    Function that tests whether an NTAccount name exists in Active Directory.
#>
}

function Test-LocalGroupMember {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Member,

        [ValidateNotNullOrEmpty()]
        [string]
        $Group = 'Administrators'
    )

    try {
        (Get-LocalGroupMember -Group $Group | Where-Object -Property Name -EQ -Value $Member | Measure-Object | Select-Object -ExpandProperty Count) -ge 1
    }
    catch {
        $false
    }
    <#
    .SYNOPSIS
    Test whether Member is already a member of local group
    Administrators.

    .DESCRIPTION
    Function tests whether Member is already a member of Group.  Group
    defaults to 'Administrators'.
#>
}
