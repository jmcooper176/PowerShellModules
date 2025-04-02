<#
 =============================================================================
<copyright file="DuplicateTenantVariablesToAnotherEnvironment.ps1" company="U.S. Office of Personnel
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
This file "DuplicateTenantVariablesToAnotherEnvironment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$baseUrl = "YOUR URL"
$apiKey = "YOUR API KEY"
$spaceId = "YOUR SPACE ID"
$projectNameToDuplicate = "To Do - Linux"
$sourceEnvironmentName = "Test"
$destinationEnvironmentName = "Production"

$header = New-Object -TypeName "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("X-Octopus-ApiKey", $apiKey)

$tenantList = Invoke-RestMethod "$baseUrl/api/$SpaceId/tenants?skip=0&take=1000000" -Headers $header
$projectList = Invoke-RestMethod "$baseUrl/api/$SpaceId/projects?skip=0&take=1000000" -Headers $header
$environmentList = Invoke-RestMethod "$baseUrl/api/$SpaceId/environments?skip=0&take=1000000" -Headers $header

$projectInfo = @($projectList.Items | Where-Object -FilterScript {$_.Name -eq $projectNameToDuplicate })

if ($projectInfo.Length -le 0)
{
    Write-Information -MessageData "Project Name $projectNameToDuplicate not found, exiting"
    exit 1
}
else
{
    Write-Information -MessageData "Project found"
}

$sourceEnvironment = @($environmentList.Items | Where-Object -FilterScript {$_.Name -eq $sourceEnvironmentName })
$destinationEnvironment = @($environmentList.Items | Where-Object -FilterScript {$_.Name -eq $destinationEnvironmentName })

if ($sourceEnvironment.Length -le 0 -or $destinationEnvironment.Length -le 0)
{
    Write-Information -MessageData "Unable to find the environment information, please check name and try again, exiting"
    Exit 1
}
else
{
    Write-Information -MessageData "Environments found"
}

$projectId = $projectInfo[0].Id
$sourceEnvironmentId = $sourceEnvironment[0].Id
$destinationEnvironmentId = $destinationEnvironment[0].Id

foreach ($tenant in $tenantList.Items)
{
    $tenantId = $tenant.Id
    $tenantProjectLink = $tenant.ProjectEnvironments.$projectId    
    
    if ($null -eq $tenantProjectLink)
    {
        Write-Information -MessageData "$($tenant.Name) is not assigned to $projectNameToDuplicate skipping"  
        continue     
    }

    if ($tenantProjectLink.Contains($sourceEnvironmentId) -eq $false -or $tenantProjectLink.Contains($destinationEnvironmentId) -eq $false)
    {
        Write-Information -MessageData "$($tenant.Name) is not linked to both the source and destination environment, skipping"  
        continue  
    }

    $tenantVariables = Invoke-RestMethod "$baseUrl/api/$SpaceId/tenants/$tenantId/variables" -Headers $header

    Write-Information -MessageData "Overwriting $destinationEnvironmentName variables with $sourceEnvironmentName for $($tenant.Name)"
    $tenantVariables.ProjectVariables.$projectId.Variables.$destinationEnvironmentId = $tenantVariables.ProjectVariables.$projectId.Variables.$sourceEnvironmentId
    
    $bodyAsJson = $tenantVariables | ConvertTo-Json -Depth 10
    $tenantVariables = Invoke-RestMethod "$baseUrl/api/$SpaceId/tenants/$tenantId/variables" -Method Post -Headers $header -Body $bodyAsJson
}
