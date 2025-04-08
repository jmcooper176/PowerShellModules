<#
 =============================================================================
<copyright file="show-all-scheduled-project-triggers.ps1" company="John Merryweather Cooper
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
This file "show-all-scheduled-project-triggers.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";
<#
Produces output for all project scheduled triggers on an Octopus instance in the following format:

[{
    "ProjectName": "Artifactory Sample Management",
    "Timezone": "UTC",
    "ActionType": "RunRunbook",
    "MonthlyScheduleType": "DateOfMonth",
    "StartTime": "2021-03-15T06:00:00Z",
    "FilterType": "DaysPerMonthSchedule",
    "RunbookId": "Runbooks-1081",
    "DateOfMonth": "30",
    "SpaceName": "Octopus Admin"
  },
  {
    "StartTime": "2021-02-15T07:00:00Z",
    "DaysOfWeek": [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday"
    ],
    "SpaceName": "Octopus Admin",
    "RunbookId": "Runbooks-1082",
    "ProjectName": "Artifactory Sample Management",
    "ActionType": "RunRunbook",
    "FilterType": "OnceDailySchedule",
    "Timezone": "UTC"
  },
  {
    "FilterType": "CronExpressionSchedule",
    "ActionType": "RunRunbook",
    "RunbookId": "Runbooks-26",
    "CronExpression": "0 0 * * * *",
    "SpaceName": "Monitoring",
    "ProjectName": "Monitoring and Remediation with Runbooks"
  }]
#>

$octopusURL = "https://youroctopus.instance.app/"
$octopusAPIKey = "API-xxxxxx"

$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$triggers = New-Object -TypeName 'System.Collections.ArrayList';

# Get spaces
$spaces = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header
    
foreach ($space in $spaces) {
    try {
        # Get projects
        $projects = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) 

        foreach ($project in $projects) {
            
            # Get project triggers
            $projectTriggers = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/triggers" -Headers $header

            # Loop through triggers
            foreach ($projectTrigger in $projectTriggers.Items)
            {
                if ($projectTrigger.Filter.FilterType -eq "MachineFilter"){
                    continue;
                }

                if ($projectTrigger.Filter.FilterType -eq "CronExpressionSchedule") {
                    $triggers.Add(@{
                        SpaceName = $space.Name;
                        ProjectName = $project.Name;
                        ActionType = $projectTrigger.Action.ActionType;
                        RunbookId = $projectTrigger.Action.RunbookId;
                        FilterType = $projectTrigger.Filter.FilterType;
                        CronExpression = $projectTrigger.Filter.CronExpression;
                    })
                } 
                
                If ($projectTrigger.Filter.FilterType -eq "OnceDailySchedule"){
                    $triggers.Add(@{
                        SpaceName = $space.Name;
                        ProjectName = $project.Name;
                        ActionType = $projectTrigger.Action.ActionType;
                        RunbookId = $projectTrigger.Action.RunbookId;
                        FilterType = $projectTrigger.Filter.FilterType;
                        StartTime = $projectTrigger.Filter.StartTime;
                        DaysOfWeek = $projectTrigger.Filter.DaysOfWeek;
                        Timezone = $projectTrigger.Filter.Timezone;
                    })
                }
                If ($projectTrigger.Filter.FilterType -eq "DaysPerMonthSchedule"){
                    $triggers.Add(@{
                        SpaceName = $space.Name;
                        ProjectName = $project.Name;
                        ActionType = $projectTrigger.Action.ActionType;
                        RunbookId = $projectTrigger.Action.RunbookId;
                        FilterType = $projectTrigger.Filter.FilterType;
                        StartTime = $projectTrigger.Filter.StartTime;
                        DateOfMonth = $projectTrigger.Filter.DateOfMonth;
                        MonthlyScheduleType = $projectTrigger.Filter.MonthlyScheduleType;
                        Timezone = $projectTrigger.Filter.Timezone;
                    })
                }
                
            }
        }
    }
    catch {
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    }
}

# Write out to a file.
($triggers | ConvertTo-Json) > out.json
