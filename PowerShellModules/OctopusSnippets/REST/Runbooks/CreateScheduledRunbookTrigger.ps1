<#
 =============================================================================
<copyright file="CreateScheduledRunbookTrigger.ps1" company="John Merryweather Cooper
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
This file "CreateScheduledRunbookTrigger.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaceName = "Default"
$projectName = "MyProject"
$runbookName = "MyRunbook"

# Specify runbook trigger name
$runbookTriggerName = "RunbookTriggerName"

# Specify runbook trigger description
$runbookTriggerDescription = "RunbookTriggerDescription"

# Specify which environments the runbook should run in
$runbookEnvironmentNames = @("Development")

# What timezone do you want the trigger scheduled for
$runbookTriggerTimezone = "GMT Standard Time"

# Remove any days you don't want to run the trigger on
$runbookTriggerDaysOfWeekToRun = @("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

# Specify the start time to run the runbook each day in the format yyyy-MM-ddTHH:mm:ss.fffZ
# See https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings?view=netframework-4.8

$runbookTriggerStartTime = "2021-07-22T09:00:00.000Z"

# Script variables
$runbookEnvironmentIds = @()

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get project
$projects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($projectName))&skip=0&take=100" -Headers $header 
$project = $projects.Items | Where-Object -FilterScript { $_.Name -eq $projectName }

# Get runbook
$runbooks = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/runbooks?partialName=$([uri]::EscapeDataString($runbookName))&skip=0&take=100" -Headers $header 
$runbook = $runbooks.Items | Where-Object -FilterScript { $_.Name -eq $runbookName }

# Get environments for runbook trigger
foreach($runbookEnvironmentName in $runbookEnvironmentNames) {
    $environments = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/environments?partialName=$([uri]::EscapeDataString($runbookEnvironmentName))&skip=0&take=100" -Headers $header 
    $environment = $environments.Items | Where-Object -FilterScript { $_.Name -eq $runbookEnvironmentName } | Select-Object -First 1
    $runbookEnvironmentIds += $environment.Id
}

# Create a runbook trigger
$body = @{
    ProjectId = $project.Id;
    Name = $runbookTriggerName;
    Description = $runbookTriggerDescription;
    IsDisabled = $False;
    Filter = @{
        Timezone = $runbookTriggerTimezone;
        FilterType = "OnceDailySchedule";
        DaysOfWeek = @($runbookTriggerDaysOfWeekToRun);
        StartTime = $runbookTriggerStartTime;
    };
    Action = @{
        ActionType = "RunRunbook";
        RunbookId = $runbook.Id;
        EnvironmentIds = @($runbookEnvironmentIds);
    };
}

# Convert body to JSON
$body = $body | ConvertTo-Json -Depth 10

# Create runbook scheduled trigger
$runbookScheduledTrigger = Invoke-RestMethod -Method Post -Uri "$octopusURL/api/$($space.Id)/projecttriggers" -Body $body -Headers $header 

Write-Information -MessageData "Created runbook trigger: $($runbookScheduledTrigger.Id) ($runbookTriggerName)"