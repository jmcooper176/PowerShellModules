<#
 =============================================================================
<copyright file="TestActiveDirectoryIntegration.ps1" company="U.S. Office of Personnel
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
This file "TestActiveDirectoryIntegration.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# This will test your active directory integration within Octopus Deploy itself.  
$octopusURL = "https://yourinstance.com"
$octopusAPIKey = "YOUR API KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$userNameToLookUp = "NAME TO SEARCH FOR" # Bob
$expectedMatch = "EXACT MATCH TO FIND" # Bob.Walker@mydomain.local

$directoryServicesResults = Invoke-RestMethod -Method GET -Uri "$octopusURL/api/externalusers/directoryServices?partialName=$([System.Web.HTTPUtility]::UrlEncode($userNameToLookUp))" -Headers $header

$foundUser = $false
foreach ($identity in $directoryServicesResults.Identities)
{
    if ($identity.IdentityProviderName -eq "Active Directory")
    {
        $claimList = $identity.Claims | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -Property "Name"

        foreach ($claimName in $claimList)
        {                  
            $claimName = $claimName.Name
            $claim = $identity.Claims.$ClaimName
            
            if ($claim.Value.ToLower() -eq $expectedMatch.Tolower() -and $claim.IsIdentifyingClaim -eq $true)
            {
                $foundUser = $true
                break
            }
        }

        if ($foundUser)
        {
            break
        }
    }
}

if ($foundUser)
{
    Write-Information -MessageData "Successfully found the user $userNameToLookUp by matching $expectedMatch"
}
else 
{
    Write-Information -MessageData "Unable to find user $UserNameToLookup with the claim $expectedMatch"
}