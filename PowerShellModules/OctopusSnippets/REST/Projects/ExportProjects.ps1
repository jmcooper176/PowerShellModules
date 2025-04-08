<#
 =============================================================================
<copyright file="ExportProjects.ps1" company="John Merryweather Cooper
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
This file "ExportProjects.ps1" is part of "OctopusSnippets".
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

# Provide the space name for the projects to export.
$spaceName = "Default"
# Provide a list of project names to export.
$projectNames = @("Project A", "Project B")
# Provide a password for the export zip file
$exportTaskPassword = ""
# Wait for the export task to finish?
$exportTaskWaitForFinish = $True
# Provide a timeout for the export task to be canceled.
$exportTaskCancelInSeconds=300

$octopusURL = $octopusURL.TrimEnd('/')

# Get Space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }
$exportTaskSpaceId = $space.Id

$exportTaskProjectIds = @()

if (![string]::IsNullOrWhiteSpace($projectNames)) {
    @(($projectNames -Split "`n").Trim()) | ForEach-Object -Process {
        if (![string]::IsNullOrWhiteSpace($_)) {
            Write-Verbose -Message "Working on: '$_'"
            $projectName = $_.Trim()
            if([string]::IsNullOrWhiteSpace($projectName)) {
                throw "Project name is empty'"
            }
            $projects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($projectName))&skip=0&take=100" -Headers $header 
            $project = $projects.Items | Where-Object -FilterScript { $_.Name -eq $projectName }
            $exportTaskProjectIds += $project.Id
        }
    }
}

$exportBody = @{
    IncludedProjectIds = $exportTaskProjectIds;
    Password = @{
        HasValue = $True;
        NewValue = $exportTaskPassword;
    }
}

$exportBodyAsJson = $exportBody | ConvertTo-Json
$exportBodyPostUrl = "$octopusURL/api/$($exportTaskSpaceId)/projects/import-export/export"
Write-Information -MessageData "Kicking off export run by posting to $exportBodyPostUrl"
Write-Verbose -Message "Payload: $exportBodyAsJson"
$exportResponse = Invoke-RestMethod $exportBodyPostUrl -Method POST -Headers $header -Body $exportBodyAsJson
$exportServerTaskId = $exportResponse.TaskId
Write-Information -MessageData "The task id of the new task is $exportServerTaskId"
Write-Information -MessageData "Export task was successfully invoked, you can access the task: $octopusURL/app#/$exportTaskSpaceId/tasks/$exportServerTaskId"

if ($exportTaskWaitForFinish -eq $true)
{
    Write-Information -MessageData "The setting to wait for completion was set, waiting until task has finished"
    $startTime = Get-Date
    $currentTime = Get-Date
    $dateDifference = $currentTime - $startTime
    $taskStatusUrl = "$octopusURL/api/$exportTaskSpaceId/tasks/$exportServerTaskId"
    $numberOfWaits = 0    
    While ($dateDifference.TotalSeconds -lt $exportTaskCancelInSeconds)
    {
        Write-Information -MessageData "Waiting 5 seconds to check status"
        Start-Sleep -Seconds 5
        $taskStatusResponse = Invoke-RestMethod $taskStatusUrl -Headers $header        
        $taskStatusResponseState = $taskStatusResponse.State
        if ($taskStatusResponseState -eq "Success")
        {
            Write-Information -MessageData "The task has finished with a status of Success"
            $artifactsUrl= "$octopusURL/api/$exportTaskSpaceId/artifacts?regarding=$exportServerTaskId"
            Write-Information -MessageData "Checking for artifacts from $artifactsUrl"
            $artifacts = Invoke-RestMethod $artifactsUrl -Method GET -Headers $header
            $exportArtifact = $artifacts.Items | Where-Object -FilterScript { $_.Filename -like "Octopus-Export-*.zip"} 
            Write-Information -MessageData "Export task successfully completed, you can download the export archive: $octopusURL$($exportArtifact.Links.Content)"
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
    Write-Information -MessageData "The cancel timeout has been reached, cancelling the export task"
    Invoke-RestMethod "$octopusURL/api/$exportTaskSpaceId/tasks/$exportTaskSpaceId/cancel" -Headers $header -Method Post | Out-Null
    Write-Information -MessageData "Exiting with an error code of 1 because we reached the timeout"
    exit 1
}