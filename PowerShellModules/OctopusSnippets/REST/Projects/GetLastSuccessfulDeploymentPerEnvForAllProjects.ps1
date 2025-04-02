<#
 =============================================================================
<copyright file="GetLastSuccessfulDeploymentPerEnvForAllProjects.ps1" company="U.S. Office of Personnel
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
This file "GetLastSuccessfulDeploymentPerEnvForAllProjects.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

##CONFIG
$octopusURL = "https://YOUR_OCTOPUS_SERVER" #Octopus URL
$octopusAPIKey = "API-1234123412341234" #Octopus API Key
$spaceName = "Default"

##PROCESS##
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}
$projects = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects?take=2000000" -Headers $header).items

foreach ($project in $projects)
{
    Write-Information -MessageData "`nChecking Project: $($project.Name)"
    $ProjectDashboardReleases = (Invoke-WebRequest -Uri $octopusURL/api/progression/$($project.Id) -Method Get -Headers $header).content | ConvertFrom-Json
    foreach ($environment in $ProjectDashboardReleases.Environments)
    {
        $LastSuccessfulRelease = $ProjectDashboardReleases.Releases.Deployments.$($environment.Id) | Where-Object -FilterScript {$_.state -eq "Success"} | Select-Object -First 1
        Write-Output "Last Successful Release in $($environment.Name): `t$($LastSuccessfulRelease.CompletedTime)"
    }
}

