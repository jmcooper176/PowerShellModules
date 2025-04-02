<#
 =============================================================================
<copyright file="CheckUserRoles.ps1" company="U.S. Office of Personnel
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
<date>Created:  2025-2-25</date>
<summary>
This file "CheckUserRoles.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Check that the built-in User Roles in your Octopus instance have the same permissions assigned as a new install of Octopus by checking it against a new install of Octopus.

# the "clean" instance of Octopus, to use as the desired state.
$desiredStateOctopusURL = "https://initial-state-octopus-instance/"
$desiredStateOctopusAPIKey = "API-xxxxx"
$desiredStateHeader = @{ "X-Octopus-ApiKey" = $desiredStateOctopusAPIKey }

# the Octopus instance you'd like to check
$octopusURL = "http://your-octopus-instance/"
$octopusAPIKey = "API-xxxx"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

try
{
    Write-Information -MessageData "====== Starting comparison ======="

    # Get user roles from desired state (unchanged from initial install) instance of Octopus
    $desiredStateUserRoles = (Invoke-RestMethod -Method Get -Uri "$desiredStateOctopusURL/api/userroles/all" -Headers $desiredStateHeader) | Where-Object -FilterScript {$_.CanBeDeleted -eq $false} 
    
    # Get user roles to check
    $userRoles = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/userroles/all" -Headers $header) | Where-Object -FilterScript {$_.CanBeDeleted -eq $false} 
    

    foreach ($userRole in $userRoles) {
        $dsUserRole = $desiredStateUserRoles | Where-Object -FilterScript { $_.Id -eq $userRole.Id }

        $comparisonResult = Compare-Object -ReferenceObject $dsUserRole.GrantedSpacePermissions -DifferenceObject $userRole.GrantedSpacePermissions 

        if ($comparisonResult.Length -gt 0){
            
            Write-Information -MessageData "$($userRole.Name): "

            foreach ($result in $comparisonResult) {
                if ($result.SideIndicator -eq "<="){
                    Write-Information -MessageData "      - $($result.InputObject)  MISSING"
                } else {
                    Write-Information -MessageData "      - $($result.InputObject)  ADDED"
                }
            }
        }
    }

    Write-Information -MessageData "====== Comparison complete. ======="

}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
