<#
 =============================================================================
<copyright file="GetWorkersUsedInTasks.ps1" company="U.S. Office of Personnel
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
This file "GetWorkersUsedInTasks.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

<#
Get a list of the worker machines that have been used in tasks.

Outputs a carat separated file with the following headings: 
"TaskId","TaskName","TaskDescription","Started","Ended","MessageText","WorkerName","WorkerPool"

NB - assumes worker machine name has no spaces.

#>

# Define working variables
$octopusURL = "https://my.octopus.url"
$octopusAPIKey = ""
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaceName = "Default"
$skip = 0
$take = 30
$maxTasksToCheck = 100

Set-Content "./OutputWorkers.csv" -Value $null

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }
$spaceId = $space.Id

$continueTasks = $true;
$taskProperties = [System.Collections.ArrayList]::new();
$taskProperties.Add(@("TaskId","TaskName","TaskDescription","Started","Ended","MessageText","WorkerName","WorkerPool"))

function Get-WorkerInfo($activityLogElement){
    foreach ($logChild1 in $activityLogElement.Children) {
        foreach ($logElement in $logChild1.LogElements) {
            if ($logElement.MessageText -clike 'Leased worker*') {

                # Get worker detail from the message
                $splitMessage = $logElement.MessageText.Split(' ')
                $workerName = $splitMessage[2]
                $workerPoolItemSection = $splitMessage.Length - 5
                $workerPoolAndLease = ($splitMessage | Select-Object -Last $workerPoolItemSection) -join " "
                $workerPoolName = $workerPoolAndLease.Split('(')[0]

                $taskProperties.Add(@(
                        $task.Id,
                        $task.Name,
                        $task.Description,
                        $task.StartTime,
                        $task.CompletedTime,
                        $logElement.MessageText,
                        $workerName,
                        $workerPoolName)
                )
            }
        }
    }
}


while ($continueTasks -eq $true -and $skip -lt $maxTasksToCheck){
            
    Write-Information -MessageData "skip: $($skip)"
    # Get tasks
    $tasks = Invoke-RestMethod -Uri "$octopusURL/api/tasks?skip=$($skip)&take=$($take)&spaces=$($spaceId)&includeSystem=false&name=deploy,runbookrun" -Headers $header 
    $taskItems = $tasks.Items 

    if ($taskItems.Count -eq 0){
        $continueTasks = $false;
    } else {

        foreach ($task in $taskItems) {
            #Write-Information -MessageData $task.Id $task.Description
            
            # Get task detail
            $taskDetail = Invoke-RestMethod -Uri "$octopusURL/api/tasks/$($task.Id)/details?verbose=true" -Headers $header 

            foreach ($activityLog in $taskDetail.ActivityLogs) {
                foreach ($activityLogChild1 in $activityLog.Children) {
                    Get-WorkerInfo $activityLogChild1

                    foreach ($activityLogChild2 in $activityLogChild1.Children) {
                        Get-WorkerInfo $activityLogChild2            
                    }
                        
                }
            }
        }
    }
    
    foreach ($arr in $taskProperties) {
        $arr -join '^' | Add-Content "./OutputWorkers.csv"
    }

    $taskProperties = [System.Collections.ArrayList]::new();
    $skip += $take

} 



