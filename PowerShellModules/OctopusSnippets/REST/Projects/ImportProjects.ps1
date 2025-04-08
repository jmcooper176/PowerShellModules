<#
 =============================================================================
<copyright file="ImportProjects.ps1" company="John Merryweather Cooper
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
This file "ImportProjects.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

###
# NOTE: This script makes use of an API endpoint introduced in Octopus 2021.1 for the Export/Import Projects feature
# Using this script in earlier versions of Octopus will not work.
# # See https://octopus.com/docs/projects/export-import for details.
###
$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app/"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

# Provide the space name where the export task ran.
$sourceSpaceName = "Export-Space"
# Provide the space name for the projects to be imported into.
$destinationSpaceName = "Default"
# Provide the Export Server task id to use as the source for import e.g. ServerTasks-12345
$exportTaskId = ""
# Provide a password for the import zip file
$importTaskPassword = ""
# Wait for the import task to finish?
$importTaskWaitForFinish = $True
# Provide a timeout for the imports task to be canceled.
$importTaskCancelInSeconds=300

$octopusURL = $octopusURL.TrimEnd('/')

# Get Source Space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($sourceSpaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $sourceSpaceName }
$exportTaskSpaceId = $space.Id

# Get Destination Space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($destinationSpaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $destinationSpaceName }
$importTaskSpaceId = $space.Id

$importBody = @{
    ImportSource = @{
        Type = "space";
        SpaceId = $exportTaskSpaceId;
        TaskId = $exportTaskId;
    };
    Password = @{
        HasValue = $True;
        NewValue = $importTaskPassword;
    };
}

$importBodyAsJson = $importBody | ConvertTo-Json
$importBodyPostUrl = "$octopusURL/api/$($importTaskSpaceId)/projects/import-export/import"
Write-Information -MessageData "Kicking off import run by posting to $importBodyPostUrl"
Write-Verbose -Message "Payload: $importBodyAsJson"
$importResponse = Invoke-RestMethod $importBodyPostUrl -Method POST -Headers $header -Body $importBodyAsJson
$importServerTaskId = $importResponse.TaskId
Write-Information -MessageData "The task id of the new task is $importServerTaskId"
Write-Information -MessageData "Import task was successfully invoked, you can access the task: $octopusURL/app#/$importTaskSpaceId/tasks/$importServerTaskId"

if ($importTaskWaitForFinish -eq $true)
{
    Write-Information -MessageData "The setting to wait for completion was set, waiting until task has finished"
    $startTime = Get-Date
    $currentTime = Get-Date
    $dateDifference = $currentTime - $startTime
    $taskStatusUrl = "$octopusURL/api/$importTaskSpaceId/tasks/$importServerTaskId"
    $numberOfWaits = 0    
    While ($dateDifference.TotalSeconds -lt $importTaskCancelInSeconds)
    {
        Write-Information -MessageData "Waiting 5 seconds to check status"
        Start-Sleep -Seconds 5
        $taskStatusResponse = Invoke-RestMethod $taskStatusUrl -Headers $header        
        $taskStatusResponseState = $taskStatusResponse.State
        if ($taskStatusResponseState -eq "Success")
        {
            Write-Information -MessageData "The task has finished with a status of Success"
            exit 0
        }
        elseif($taskStatusResponseState -eq "Failed" -or $taskStatusResponseState -eq "Canceled")
        {
            Write-Information -MessageData "The task has finished with a status of $taskStatusResponseState status, completing"
            exit 1            
        }
        $numberOfWaits += 1
        if ($numberOfWaits -ge 10)
        {
            Write-Information -MessageData "The task state is currently $taskStatusResponseState"
            $numberOfWaits = 0
        }
        else
        {
            Write-Information -MessageData "The task state is currently $taskStatusResponseState"
        }  
        $startTime = $taskStatusResponse.StartTime
        if ($null -eq $startTime -or [string]::IsNullOrWhiteSpace($startTime) -eq $true)
        {        
            Write-Information -MessageData "The task is still queued, let's wait a bit longer"
            $startTime = Get-Date
        }
        $startTime = [DateTime]$startTime
        $currentTime = Get-Date
        $dateDifference = $currentTime - $startTime        
    }
    Write-Information -MessageData "The cancel timeout has been reached, cancelling the import task"
    Invoke-RestMethod "$octopusURL/api/$importTaskSpaceId/tasks/$importTaskSpaceId/cancel" -Headers $header -Method Post | Out-Null
    Write-Information -MessageData "Exiting with an error code of 1 because we reached the timeout"
    exit 1
}