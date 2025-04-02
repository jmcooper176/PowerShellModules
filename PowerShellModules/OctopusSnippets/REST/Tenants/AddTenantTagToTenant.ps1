<#
 =============================================================================
<copyright file="AddTenantTagToTenant.ps1" company="U.S. Office of Personnel
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
This file "AddTenantTagToTenant.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusServerUrl = "https://"  #PUT YOUR SERVER LOCATION HERE. (e.g. http://localhost)
$ApiKey = "API-"   #PUT YOUR API KEY HERE
$SpaceName = "Default" #PUT THE NAME OF THE SPACE THAT HOUSES THE TENANTS HERE
$spaceId = ((Invoke-RestMethod -Method Get -Uri "$OctopusServerUrl/api/spaces/all" -Headers @{"X-Octopus-ApiKey" = "$ApiKey" }) | Where-Object -FilterScript {$_.Name -eq $spaceName}).Id

$listOfTenants = "TenantOne","TenantTwo" #PUT TENANTS THAT NEED TAGS ADDED TO THEM HERE
$tagstoAdd = "Test Set/Blah","Test Set/Second Blah","Soft Drink Companies/Soft Drink Companies" #PUT TAGSET/TAG HERE TO ADD TO TENANTS ABOVE 

foreach ($tenant in $listOfTenants){
    $tenantsSearch = (Invoke-RestMethod -Method Get -Uri "$OctopusServerUrl/api/$($spaceid)/tenants?name=$tenant" -Headers @{"X-Octopus-ApiKey" = "$ApiKey" })
    $tenant = $tenantsSearch.Items | Select-Object -First 1
    foreach ($tag in $tagstoAdd){
        $tenant.TenantTags += $tag
    }
   
    Invoke-RestMethod -Method PUT -Uri "$OctopusServerUrl/api/$($spaceid)/tenants/$($tenant.Id)" -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -body ($tenant | ConvertTo-Json)
    

}
