<#
 =============================================================================
<copyright file="DeploymentsByMachineReport.ps1" company="John Merryweather Cooper
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
This file "DeploymentsByMachineReport.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Add support for TLS 1.2 + TLS 1.3
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls13

# Fix ANSI Color on PWSH Core issues when displaying objects
if (($PSVersionTable.PSVersion.Major -gt 7) -or ($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion.Minor -ge 2)) {
    $PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
}

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-XXXX"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"

# Only get the last 4 hours of deployments
$now = Get-Date
$deploymentsFrom = $now.AddHours(-4).ToString("yyyy-MM-ddTHH:mm:ss")
$deploymentsTo = $now.ToString("yyyy-MM-ddTHH:mm:ss")

$eventsFrom = $([System.Web.HTTPUtility]::UrlEncode($deploymentsFrom))
$eventsTo = $([System.Web.HTTPUtility]::UrlEncode($deploymentsTo))

# Project filters
$projectNames = @("Project 1", "Project 2")

# Environment filters
$environmentNames = @("Development", "Test")

$csvExportPath = "" # /path/to/export.csv

# Validation that variable have been updated. Do not update the values here - they must stay as "https://your.octopus.app"
# and "API-XXXX", as this is how we check that the variables above were updated.
if ($octopusURL -eq "https://your.octopus.app" -or $octopusAPIKey -eq "API-XXXX") {
    Write-Information -MessageData "You must replace the placeholder variables with values specific to your Octopus instance"
    exit 1
}

# Get space
Write-Output "Retrieving space '$($spaceName)'"
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -ieq $spaceName }

# cache certain resources as they are retrieved if enabled
$cacheItems = $true

$releases = @()
$deployments = @()
$serverTasks = @()
$serverTaskDetails = @()

# Cache all environments
Write-Output "Retrieving all environments"
$environments = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/environments" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $environments += $response.Items
} while ($response.Links.'Page.Next')

# Cache all tenants
Write-Output "Retrieving all tenants"
$tenants = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/tenants" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $tenants += $response.Items
} while ($response.Links.'Page.Next')

# Cache all machines
Write-Output "Retrieving all machines"
$machines = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/machines" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $machines += $response.Items
} while ($response.Links.'Page.Next')

# Cache all projects
Write-Output "Retrieving all projects"
$projects = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/projects" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $projects += $response.Items
} while ($response.Links.'Page.Next')

# Return the cached release or retrieve it, cache it and then return it.
function Get-Release {
    param ($releaseId)

    $release = @($releases | Where-Object -FilterScript { $_.Id -ieq $releaseId }) | Select-Object -First 1
    if ($null -ieq $release) {
        $release = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/releases/$($releaseId)" -Headers $header
        if ($cacheItems) {
            $releases += $release
        }
    }

    return $release
}

function Get-Deployment {
    param ($deploymentId)

    $deployment = @($deployments | Where-Object -FilterScript { $_.Id -ieq $deploymentId }) | Select-Object -First 1
    if ($null -ieq $deployment) {
        $deployment = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/deployments/$($deploymentId)" -Headers $header
        if ($cacheItems) {
            $deployments += $deployment
        }
    }

    return $deployment
}

function Get-ServerTask {
    param ($taskId)

    $serverTask = @($serverTasks | Where-Object -FilterScript { $_.Id -ieq $taskId }) | Select-Object -First 1
    if ($null -ieq $serverTask) {
        $serverTask = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/tasks/$($taskId)" -Headers $header
        if ($cacheItems) {
            $serverTasks += $serverTask
        }
    }

    return $serverTask
}

function Get-ServerTaskDetails {
    param ($taskId)

    $serverTaskDetail = @($serverTaskDetails | Where-Object -FilterScript { $_.Id -ieq $taskId }) | Select-Object -First 1
    if ($null -ieq $serverTask) {
        $serverTaskDetail = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/tasks/$($taskId)/details?verbose=false&tail=50&ranges=" -Headers $header
        if ($cacheItems) {
            $serverTaskDetails += $serverTaskDetail
        }
    }

    return $serverTaskDetail
}

$eventsUrl = "$octopusURL/api/events?includeSystem=false&spaces=$($space.Id)&eventCategories=DeploymentStarted&documentTypes=Deployments&from=$eventsFrom&to=$eventsTo"

# Check for optional projects filter
if ($projectNames.Length -gt 0) {
    Write-Verbose -Message "Filtering events to projects '$($projectNames -Join ",")'"
    $filteredProjects = @($projects | Where-Object -FilterScript { $projectNames -icontains $_.Name } | ForEach-Object -Process { "$($_.Id)" })
    $projectsOperator = $filteredProjects -Join ","
    $eventsUrl += "&projects=$projectsOperator"
}
# Check for optional environments filter
if ($environmentNames.Length -gt 0) {
    Write-Verbose -Message "Filtering events to environments '$($environmentNames -Join ",")'"
    $filteredEnvironments = @($environments | Where-Object -FilterScript { $environmentNames -icontains $_.Name } | ForEach-Object -Process { "$($_.Id)" })
    $environmentsOperator = $filteredEnvironments -Join ","
    $eventsUrl += "&environments=$environmentsOperator"
}

# Get events
Write-Output "Retrieving deployment events from '$($deploymentsFrom)' to '$($deploymentsTo)'"
$events = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { $eventsUrl }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $events += $response.Items
} while ($response.Links.'Page.Next')

$results = @()

foreach ($event in $events) {
    Write-Verbose -Message "Working on event $($event.Id)"
    # Get related document Ids
    $releaseId = $event.RelatedDocumentIds | Where-Object -FilterScript { $_ -like "Releases-*" } | Select-Object -First 1
    $projectId = $event.RelatedDocumentIds | Where-Object -FilterScript { $_ -like "Projects*" } | Select-Object -First 1
    $deploymentId = $event.RelatedDocumentIds | Where-Object -FilterScript { $_ -like "Deployments*" } | Select-Object -First 1
    $environmentId = $event.RelatedDocumentIds | Where-Object -FilterScript { $_ -like "Environments*" } | Select-Object -First 1
    $taskId = $event.RelatedDocumentIds | Where-Object -FilterScript { $_ -like "ServerTasks*" } | Select-Object -First 1

    # Get objects
    $project = $projects | Where-Object -FilterScript { $_.Id -ieq $projectId }
    $environment = $environments | Where-Object -FilterScript { $_.Id -ieq $environmentId }
    $release = Get-Release -ReleaseId $releaseId
    $deployment = Get-Deployment -DeploymentId $deploymentId
    $task = Get-ServerTask -TaskId $TaskId
    $taskDetails = Get-ServerTaskDetails -TaskId $taskId
    $activityLogs = $taskDetails.ActivityLogs | Select-Object -First 1

    $tenantName = ""

    if (-not [string]::IsNullOrWhitespace($deployment.TenantId)) {
        $tenantName = ($tenants | Where-Object -FilterScript { $_.Id -ieq $deployment.TenantId }).Name
    }

    $deployedToMachines = $deployment.DeployedToMachineIds

    foreach ($machineId in $deployedToMachines) {
        $machineName = ($machines | Where-Object -FilterScript { $_.Id -ieq $machineId }).Name
        $machineStatus = [string]::Empty
        $stepDetails = [string]::Empty

        # Each stepLog could have a .Status property of "Skipped", "Pending", "Success" or "Failed".
        $stepLogs = $activityLogs.Children
        foreach ($stepLog in $stepLogs) {
            # There should be at least one child-entry per machine, including when doing a rolling deployment
            $firstMatchingFailedLogEntryForMachine = $stepLog.Children | Where-Object -FilterScript { $_.Name -ieq $machineName -and $_.Status -ieq "Failed" } | Select-Object -First 1
            if ($null -ne $firstMatchingFailedLogEntryForMachine) {
                Write-Verbose -Message "Found a failed step for machine '$machineName' - $($stepLog.Name)"
                $machineStatus = "Fail"
                $stepDetails = "Failed—$($stepLog.Name)"
                break;
            }
            $firstMatchingPendingLogEntryForMachine = $stepLog.Children | Where-Object -FilterScript { $_.Name -ieq $machineName -and $_.Status -ieq "Pending" }
            if ($null -ne $firstMatchingPendingLogEntryForMachine) {
                Write-Verbose -Message "Found a pending step for machine '$machineName' - $($stepLog.Name)"
                $machineStatus = "Fail"
                $stepDetails = "Pending—$($stepLog.Name)"
                break;
            }

            # If you don't want a skipped step to indicate a failure, remove this block of code.
            $firstMatchingSkippedLogEntryForMachine = $stepLog.Children | Where-Object -FilterScript { $_.Name -ieq $machineName -and $_.Status -ieq "Skipped" } | Select-Object -First 1
            if ($null -ne $firstMatchingSkippedLogEntryForMachine) {
                Write-Verbose -Message "Found a skipped step for machine '$machineName' - $($stepLog.Name)"
                $machineStatus = "Fail"
                $stepDetails = "Skipped—$($stepLog.Name)"
                break;
            }
        }

        if ([string]::IsNullOrWhiteSpace($machineStatus)) {
            $machineStatus = "Pass"
        }

        $result = [PsCustomObject]@{
            Project          = $project.Name
            Release          = $release.Version
            Environment      = $environment.Name
            Tenant           = $tenantName
            DeploymentTarget = $machineName
            MachineStatus    = $machineStatus
            StepDetails      = $stepDetails
            StartTime        = $task.StartTime
            CompletedTime    = $task.CompletedTime
        }
        $results += $result
    }
}

if ($results.Count -gt 0) {
    Write-Output ""
    Write-Output "Found $($results.Count) results:"
    if (![string]::IsNullOrWhiteSpace($csvExportPath)) {
        Write-Output "Exporting results to CSV file: $csvExportPath"
        $results | Export-Csv -Path $csvExportPath -NoTypeInformation
    }
    else {
        $results | Sort-Object -Property Project, Release, Environment, QueueTime | Format-Table -Property * | Out-String -Width 1000
    }
}

$stopwatch.Stop()
Write-Output "Completed report execution in $($stopwatch.Elapsed)"
