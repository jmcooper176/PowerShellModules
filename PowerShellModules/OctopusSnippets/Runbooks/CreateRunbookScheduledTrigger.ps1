<#
 =============================================================================
<copyright file="CreateRunbookScheduledTrigger.ps1" company="John Merryweather Cooper
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
This file "CreateRunbookScheduledTrigger.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"

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
$runbookTriggerDaysOfWeekToRun = [Octopus.Client.Model.DaysOfWeek]::Monday -bor [Octopus.Client.Model.DaysOfWeek]::Tuesday -bor [Octopus.Client.Model.DaysOfWeek]::Wednesday -bor [Octopus.Client.Model.DaysOfWeek]::Thursday -bor [Octopus.Client.Model.DaysOfWeek]::Friday -bor [Octopus.Client.Model.DaysOfWeek]::Saturday -bor [Octopus.Client.Model.DaysOfWeek]::Sunday

# Specify the start time to run the runbook each day in the format yyyy-MM-ddTHH:mm:ss.fffZ
# See https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings?view=netframework-4.8

$runbookTriggerStartTime = "2021-07-22T09:00:00.000Z"

# Script variables
$runbookEnvironmentIds = @()

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient $endpoint

# Get space
$space = $repository.Spaces.FindByName($spaceName)
$repositoryForSpace = $client.ForSpace($space)

# Get project
$project = $repositoryForSpace.Projects.FindByName($projectName);

# Get runbook
$runbook = $repositoryForSpace.Runbooks.FindByName($runbookName);

foreach($environmentName in $runbookEnvironmentNames) {
    $environment = $repositoryForSpace.Environments.FindByName($environmentName);
    $runbookEnvironmentIds += $environment.Id
}

$runbookScheduledTrigger = New-Object -TypeName Octopus.Client.Model.ProjectTriggerResource

$runbookScheduledTriggerFilter = New-Object -TypeName Octopus.Client.Model.Triggers.ScheduledTriggers.OnceDailyScheduledTriggerFilterResource
$runbookScheduledTriggerFilter.Timezone = $runbookTriggerTimezone
$runbookScheduledTriggerFilter.StartTime = (Get-Date -Date $runbookTriggerStartTime)
$runbookScheduledTriggerFilter.DaysOfWeek = $runbookTriggerDaysOfWeekToRun

$runbookScheduledTriggerAction = New-Object -TypeName Octopus.Client.Model.Triggers.RunRunbookActionResource
$runbookScheduledTriggerAction.RunbookId = $runbook.Id
$runbookScheduledTriggerAction.EnvironmentIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection($runbookEnvironmentIds)

$runbookScheduledTrigger.ProjectId = $project.Id
$runbookScheduledTrigger.Name = $runbookTriggerName
$runbookScheduledTrigger.Description = $runbookTriggerDescription
$runbookScheduledTrigger.IsDisabled = $False
$runbookScheduledTrigger.Filter = $runbookScheduledTriggerFilter
$runbookScheduledTrigger.Action = $runbookScheduledTriggerAction

$createdRunbookTrigger = $repositoryForSpace.ProjectTriggers.Create($runbookScheduledTrigger);
Write-Information -MessageData "Created runbook trigger: $($createdRunbookTrigger.Id) ($runbookTriggerName)"
