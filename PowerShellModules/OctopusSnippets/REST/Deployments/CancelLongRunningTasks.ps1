<#
 =============================================================================
<copyright file="CancelLongRunningTasks.ps1" company="John Merryweather Cooper
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
This file "CancelLongRunningTasks.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusURL = $OctopusParameters["Global.Base.Url"]
$APIKey = $OctopusParameters["Global.Api.Key"]
$CurrentSpaceId = $OctopusParameters["Octopus.Space.Id"]
$MaxRunTime = 15

$header = @{ "X-Octopus-ApiKey" = $APIKey }

Write-Information -MessageData "Getting list of all spaces"
$spaceList = (Invoke-RestMethod "$OctopusUrl/api/Spaces?skip=0&take=100000" -Headers $header)
$cancelledTask = $false
$cancelledTaskList = ""

foreach ($space in $spaceList.Items)
{
    $spaceId = $space.Id
    if ($spaceId -ne $CurrentSpaceId)
    {
        Write-Information -MessageData "Checking $spaceId for running tasks (looking for executing tasks only)"
        $taskList = (Invoke-RestMethod" $OctopusUrl/api/tasks?skip=0&states=Executing&spaces=$spaceId&take=100000" -Headers $header)
        $taskCount = $taskList.TotalResults

        Write-Information -MessageData "Found $taskCount currently running tasks"
        foreach ($task in $taskList.Items)
        {
            $taskId = $task.Id
            $taskDescription = $task.Description

            if ($task.Name -eq "Deploy"){
                # With auto deployment triggers enabled, the start time of the task cannot be trusted, need to find the events for the most recent deployment started
                $eventList = (Invoke-RestMethod "$OctopusUrl/api/events?regardingAny=$taskId&spaces=$spaceId&includeSystem=true" -Headers $header)
                foreach ($event in $eventList.Items){
                    if ($event.Category -eq "DeploymentStarted"){
                        $startTime = (Get-Date $event.Occurred)

                        # We found the most recent deployment event started we are curious about, stop looping through
                        break;
                    }
                }
            }
            else{
                $startTime = (Get-Date $task.StartTime)
            }

            $currentTime = Get-Date
            $dateDiff = $currentTime - $startTime

            Write-Information -MessageData "The task $taskDescription has been running for $dateDiff"

            if ($dateDiff.TotalMinutes -gt $MaxRunTime){
                Write-Highlight "The task $taskDescription has been running for over $MaxRunTime minutes, this indicates a problem, let's cancel it"

                Invoke-RestMethod "$OctopusUrl/api/tasks/$taskId/cancel" -Headers $header -Method Post

                $cancelledTask = $true
                $cancelledTaskList += $taskDescription + "
                "
            }
        }
    }
}

Set-OctopusVariable -name "CancelledTask" -value $cancelledTask
Set-OctopusVariable -name "CancelledTaskList" -value $cancelledTaskList
