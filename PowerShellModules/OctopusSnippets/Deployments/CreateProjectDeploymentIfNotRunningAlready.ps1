<#
 =============================================================================
<copyright file="CreateProjectDeploymentIfNotRunningAlready.ps1" company="John Merryweather Cooper
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
This file "CreateProjectDeploymentIfNotRunningAlready.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -AssemblyName 'Octopus.Client'

$octopusURL = 'http://youroctopusserver' # Your Octopus Server address
$apikey = 'API-xxxxx'  # Get this from your profile
$projectName = 'ChildProject' # The name of the project that you want to create a deployment for 
$environmentName = 'Development' # The environment you want to deploy to
$spaceName = "Default"  # The space that the $projectName is in

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURL,$apikey 
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint
$Header =  @{ "X-Octopus-ApiKey" = $apiKey }

# Getting space
$spaces = (Invoke-WebRequest -Uri "$OctopusURL/api/spaces?skip=0" -Method Get -Headers $header -UseBasicParsing).content | ConvertFrom-Json
$spaceId = ($spaces.Items | Where-Object{($_.Name -eq $spaceName)}).Id

# Getting environment
$Environment = Invoke-WebRequest -Uri "$OctopusURL/api/Environments/all" -Headers $Header| ConvertFrom-Json
 
$Environment = $Environment | Where-Object{$_.name -eq $environmentName}

If($Environment.count -eq 0){
    throw "Environment not found: $environmentName"
}

# See if any running tasks for project
$tasks = (Invoke-WebRequest -Uri "$OctopusURL/api/tasks?skip=0&environment=$($environment.Id)&spaces=$spaceId&includeSystem=false" -Method Get -Headers $header -UseBasicParsing).content | ConvertFrom-Json

$tasksForProjAndEnv = ($tasks.Items | Where-Object{($_.IsCompleted -eq $false) -and ($_.Description.tolower() -like "*$($projectName.tolower())*")} |  Select-Object -First 1000)

if ((($tasksForProjAndEnv -is [array]) -and ($tasksForProjAndEnv.length -ge 2))  -or (($tasksForProjAndEnv -isnot [array]) -and ( $tasksForProjAndEnv))) {
    Write-output "Job already running, will not run: $projectName"
    exit
}

Write-output "Creating deployment for: $projectName"
    
#--- Will only continue if no running deployment for project.

# Getting Project
Try{
    $Project = Invoke-WebRequest -Uri "$OctopusURL/api/projects/$ProjectName" -Headers $Header -ErrorAction Ignore| ConvertFrom-Json
    }
Catch{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    Throw $Error[0]
}


# Getting Release - latest

$release = ((Invoke-WebRequest -Uri "$OctopusURL/api/projects/$($Project.Id)/releases" -Headers $Header).content | ConvertFrom-Json).items | Select-Object -First 1
If($release.count -eq 0){
    throw "No releases found for project: $ProjectName"
}

$deployment = New-Object -TypeName Octopus.Client.Model.DeploymentResource
$deployment.ReleaseId = $release.Id
$deployment.ProjectId = $release.ProjectId
$deployment.EnvironmentId = $environment.Id

# Create deployment
$repository.Deployments.Create($deployment)


