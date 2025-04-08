<#
 =============================================================================
<copyright file="CreateReleaseAndDeployToSingleTenant.ps1" company="John Merryweather Cooper
">
    Copyright © 2025, John Merryweather Cooper.
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
This file "CreateReleaseAndDeployToSingleTenant.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

##CONFIG##

$apiKey = "" #Octopus API Key
$OctopusURL = "" #Octopus URL
 
$ProjectName = "" #project name
$EnvironmentName = "" #environment name
$TenantID = "" #tenant ID, can be found in /api/tenants

##PROCESS##

$Header =  @{ "X-Octopus-ApiKey" = $apiKey }
 
#Getting Environment, Project and Tenant By Name
$Project = Invoke-WebRequest -Uri "$OctopusURL/api/projects/$ProjectName" -Headers $Header| ConvertFrom-Json
 
$Environment = Invoke-WebRequest -Uri "$OctopusURL/api/Environments/all" -Headers $Header| ConvertFrom-Json

$Environment = $Environment | Where-Object -FilterScript {$_.name -eq $EnvironmentName}

$Tenant = Invoke-WebRequest -Uri "$OctopusURL/api/Tenants/$TenantID" -Headers $Header| ConvertFrom-Json

#Getting Deployment Template to get Next version 
$dt = Invoke-WebRequest -Uri "$OctopusURL/api/deploymentprocesses/deploymentprocess-$($Project.id)/template" -Headers $Header | ConvertFrom-Json 
 
#Creating Release
$ReleaseBody =  @{ Projectid = $Project.Id
            version = $dt.nextversionincrement } | ConvertTo-Json
 
$r = Invoke-WebRequest -Uri $OctopusURL/api/releases -Method Post -Headers $Header -Body $ReleaseBody | ConvertFrom-Json
 
#Creating deployment
$DeploymentBody = @{ 
            ReleaseID = $r.Id #mandatory
            EnvironmentID = $Environment.id #mandatory
              TenantID = $Tenant.id #mandatory
            } | ConvertTo-Json
          
$d = Invoke-WebRequest -Uri $OctopusURL/api/deployments -Method Post -Headers $Header -Body $DeploymentBody
