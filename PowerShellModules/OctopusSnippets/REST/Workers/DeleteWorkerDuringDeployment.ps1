<#
 =============================================================================
<copyright file="DeleteWorkerDuringDeployment.ps1" company="U.S. Office of Personnel
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
This file "DeleteWorkerDuringDeployment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusURL = YOUR OCTOPUS SERVER
$APIKey = API KEY WITH PERMISSIONS TO CANCEL DEPLOYMENTS, RETRY DEPLOYMENTS AND DELETE WORKERS
$workerName = "*YOUR WORKER MACHINE NAME*"
$workerMatchName = "*$workerName*"

$header = @{ "X-Octopus-ApiKey" = $APIKey }

Write-Information -MessageData "Getting list of all spaces"
$spaceList = (Invoke-WebRequest -Uri "$OctopusUrl/api/Spaces?skip=0&take=100000" -Headers $header).content | ConvertFrom-Json
$cancelledDeploymentList = @()

#Cancel any deployments for the worker
foreach ($space in $spaceList.Items)
{
    $spaceId = $space.Id
    Write-Information -MessageData "Checking $spaceId for running tasks (looking for executing tasks only)"
    $taskList = (Invoke-WebRequest -Uri "$OctopusUrl/api/tasks?skip=0&states=Executing&spaces=$spaceId&take=100000" -Headers $header).content | ConvertFrom-Json
    $taskCount = $taskList.TotalResults

    Write-Information -MessageData "Found $taskCount currently running tasks"
    foreach ($task in $taskList.Items)
    {
        $taskId = $task.Id            

        if ($task.Name -eq "Deploy"){
            # The running task is a deployment, get the details including all the logs                
            $taskDetails = (Invoke-WebRequest -Uri "$OctopusUrl/api/tasks/$taskId/details?verbose=true&tail=1000" -Headers $header).content | ConvertFrom-Json
            $activityLogs = $taskDetails.ActivityLogs

            foreach($activity in $activityLogs)
            {
                $childrenList = $activity.Children
                
                foreach ($child in $childrenList)
                {
                    Write-Information -MessageData $child                        
                    if ($child.Status -eq "Running")
                    {
                        $grandchildList = $child.Children
                        foreach($grandchild in $grandchildList)
                        {
                            if ($grandchild.Name -eq "Worker")
                            {
                                $logElements = $grandchild.LogElements
                                foreach($log in $logElements)
                                {     
                                    Write-Information -MessageData $log.MessageText                                   
                                    if ($log.MessageText -like $workerMatchName)
                                    {
                                        Write-Information -MessageData "$taskId is currently running on the worker we want to delete, going to cancel it"
                                        $cancelledDeploymentList += @{
                                            SpaceId = $taskDetails.Task.SpaceId
                                            DeploymentId = $taskDetails.Task.Arguments.DeploymentId
                                        }
                                        Invoke-WebRequest -Uri "$OctopusUrl/api/tasks/$taskId/cancel" -Headers $header -Method Post
                                        break;
                                    }
                                }                                    
                            }
                        }                                                        
                    }
                }
            }
        }                        
    }
}

$cancelledDeploymentsCount = $cancelledDeployments.Count
Write-Information -MessageData "This process caused me to cancel $cancelledDeploymentsCount deployments, going to delete the worker and retry them"

foreach ($space in $spaceList.Items)
{
    $spaceId = $space.Id
    Write-Information -MessageData "Finding the workers which match the name"
    $workerList = (Invoke-WebRequest -Uri "$OctopusUrl/api/$spaceId/workers?name=$workerName&skip=0&take=100000" -Headers $header).content | ConvertFrom-Json
    foreach($worker in $workerList.Items)
    {
        $worker.IsDisabled = $true;
        $workerId = $worker.Id
        $workerBodyAsJson = $worker | ConvertTo-Json

        Write-Information -MessageData "Updating $workerId"
        $workerDisabledResponse = (Invoke-WebRequest -Uri "$OctopusUrl/api/$spaceId/workers/$workerId" -Headers $header -Method Put -Body $workerBodyAsJson -ContentType "applicaiton/json").content | ConvertFrom-Json

        Write-Information -MessageData "Worker disabled response is $workerDisabledResponse"
    }
}

## Retry logic for the cancelled deployments
foreach ($cancelledDeployment in $cancelledDeploymentList)
{
    Write-Information -MessageData $cancelledDeployment.DeploymentId

    $deploymentSpaceId = $cancelledDeployment.SpaceId    
    $deploymentId = $cancelledDeployment.DeploymentId

    $deploymentInfo = (Invoke-WebRequest -Uri "$OctopusUrl/api/$deploymentSpaceId/Deployments/$deploymentId" -Headers $header -Method GET) | ConvertFrom-Json

    $bodyRaw = @{
        EnvironmentId = $deploymentInfo.EnvironmentId
        ExcludedMachineIds = $deploymentInfo.ExcludedMachineIds
        ForcePackageDownload = $deploymentInfo.ForcePackageDownload
        ForcePackageRedeployment = $deploymentInfo.ForcePackageRedeployment
        FormValues = $deploymentInfo.FormValues
        QueueTime = $null
        QueueTimeExpiry = $null
        ReleaseId = $deploymentInfo.ReleaseId
        SkipActions = $deploymentInfo.SkipActions
        SpecificMachineIds = $deploymentInfo.SpecificMachineIds
        TenantId = $deploymentInfo.TenantId
        UseGuidedFailure = $deploymentInfo.UseGuidedFailure
    } 

    $bodyAsJson = $bodyRaw | ConvertTo-Json

    $redeployment = (Invoke-WebRequest -Uri "$OctopusURL/api/$deploymentSpaceId/deployments" -Headers $header -Method Post -Body $bodyAsJson -ContentType "application/json").content | ConvertFrom-Json
    $taskId = $redeployment.TaskId
    Write-Information -MessageData "Starting the deployment again after cancelling, it has a task id of $taskId"
}