<#
 =============================================================================
<copyright file="FindUsage.ps1" company="U.S. Office of Personnel
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
This file "FindUsage.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusURL = "YOUR URL" #example: https://samples.octopus.app
$SpaceName = "YOUR SPACE NAME"
$APIKey = "YOUR API KEY"
$header = @{ "X-Octopus-ApiKey" = $APIKey }

$spaceResults = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/spaces" -Headers $header
$spaceToUse = $null

foreach ($space in $spaceResults.Items)
{
    if ($space.Name -eq $SpaceName)
    {
        $spaceToUse = $space
        break
    }
}

$spaceId = $space.Id
Write-Information -MessageData "The space-id for $spaceName is $spaceId"

Write-Information -MessageData "Getting all environments"
$environments = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/environments?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all tenants"
$tenants = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/tenants?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all projects"
$projects = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/projects?skip=0&take=100000" -Headers $header
$channels = @{}
$projectVariables = @{}
$deploymentProcess = @{}
$projectTriggers = @{}

Write-Information -MessageData "Getting all runbooks"
$runbooks = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/runbooks?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all library variable sets"
$libraryVariableSets = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/libraryvariablesets?skip=0&take=100000" -Headers $header
$libraryVariableSetVariables = @{}

Write-Information -MessageData "Getting all machines"
$machines = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/machines?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all lifecycles"
$lifecycles = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/lifecycles?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all accounts"
$accounts = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/accounts?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all certificates"
$certs = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/certificates?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all subscriptions"
$subscriptions = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/subscriptions?skip=0&take=100000" -Headers $header

Write-Information -MessageData "Getting all teams"
$teams = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/teams?skip=0&take=100000" -Headers $header
$scopedUserRoles = @{}

$environmentsNotUsed = @()
$tenantsNotUsed = @()

Write-Information -MessageData "Looping through all environments to find it's usage"
foreach ($environment in $environments.Items)
{
    $environmentIsUsed = $false
    Write-Information -MessageData "Environment: $($environment.Name)"

    Write-Information -MessageData "     Library Variable Set Usage:"
    foreach ($libraryVariableSet in $libraryVariableSets.Items)
    {
        $variableSetId = $($libraryVariableSet.Id)
        if ($null -eq $libraryVariableSetVariables[$variableSetId])
        {
            $libraryVariableSetVariablesValues = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/variables/variableset-$variableSetId" -Headers $header
            $libraryVariableSetVariables.$($libraryVariableSet.Id) = $libraryVariableSetVariablesValues
        }

        $variables = $libraryVariableSetVariables[$($libraryVariableSet.Id)]

        foreach ($variable in $variables.Variables)
        {
            if (Get-Member -InputObject $variable.Scope -Name "Environment" -MemberType Properties)
            {
                if (@($variable.Scope.Environment) -contains $($environment.Id))
                {
                    $environmentIsUsed = $true
                    Write-Information -MessageData "          Used in the variable $($variable.Name) in the library set $($libraryVariableSet.Name)"
                }
            }
        }
    }

    Write-Information -MessageData "     Project Usage:"
    foreach ($project in $projects.Items)
    {
        if ($null -eq $channels[$($project.Id)])
        {
            $projectChannels = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/projects/$($project.Id)/channels?skip=0&take=10000" -Headers $header
            $channels.$($project.Id) = $projectChannels
        }

        $channelsToQuery = $channels.$($project.Id)

        foreach ($channel in $channelsToQuery.Items)
        {
            $lifecycleId = $channel.LifecycleId
            if ($null -eq $lifecycleId)
            {
                $lifecycleId = $project.LifecycleId
            }

            $lifecycle = $lifecycles.Items | Where-Object -FilterScript {$_.Id -eq $lifecycleId}
            foreach ($phase in $lifecycle.Phases)
            {
                if (@($phase.AutomaticDeploymentTargets) -contains $($environment.Id) -or @($phase.OptionalDeploymentTargets) -contains $($environment.Id))
                {
                    $environmentIsUsed = $true
                    Write-Information -MessageData "          Used in the phase $($phase.Name) in the lifecycle $($lifecycle.Name) referenced by the project $($project.Name) in the channel $($channel.Name)"
                }
            }
        }

        if ($null -eq $projectVariables[$($project.Id)])
        {
            $projectVariableValues = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/variables/variableSet-$($project.Id)" -Headers $header
            $projectVariables.$($project.Id) = $projectVariableValues
        }

        $variables = $projectVariables[$($project.Id)]

        foreach ($variable in $variables.Variables)
        {
            if (Get-Member -InputObject $variable.Scope -Name "Environment" -MemberType Properties)
            {
                if (@($variable.Scope.Environment) -contains $($environment.Id))
                {
                    $environmentIsUsed = $true
                    Write-Information -MessageData "          Used in the variable $($variable.Name) in the project variable set for $($project.Name)"
                }
            }
        }

        if ($null -eq $deploymentProcess[$($project.Id)])
        {
            $projectDeploymentProcess = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/deploymentprocesses/deploymentprocess-$($project.Id)" -Headers $header
            $deploymentProcess.$($project.Id) = $projectDeploymentProcess
        }

        $deploymentProcessToCheck = $deploymentProcess[$($project.Id)]

        foreach ($step in $deploymentProcessToCheck.Steps)
        {
            foreach ($action in $step.Actions)
            {
                if (@($action.Environments) -contains $($environment.Id) -or @($action.ExcludedEnvironments) -contains $($environment.Id))
                {
                    $environmentIsUsed = $true
                    Write-Information -MessageData "          Used in the step $($action.Name) in the deployment process for $($project.Name)"
                }
            }

        }

        if ($null -eq $projectTriggers[$($project.Id)])
        {
            $projectTriggerResult = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/projects/$($project.Id)/triggers?skip=0&take=10000" -Headers $header
            $projectTriggers.$($project.Id) = $projectTriggerResult
        }

        $projectTriggersToCheck = $projectTriggers[$($project.Id)]

        foreach ($trigger in $projectTriggersToCheck.Items)
        {
            if (@($trigger.Action.EnvironmentId) -eq $($environment.Id))
            {
                $environmentIsUsed = $true
                Write-Information -MessageData "          Used in the trigger $($trigger.Name) for $($project.Name)"
            }
        }

        foreach ($tenant in $tenants.Items)
        {

            if (Get-Member -InputObject $tenant.ProjectEnvironments -Name $($project.Id) -MemberType Properties)
            {
                if (@($tenant.ProjectEnvironments.$($project.Id)) -contains $($environment.Id))
                {
                    $environmentIsUsed = $true
                    Write-Information -MessageData "          Referenced by tenant $($tenant.Name) for $($project.Name)"
                }
            }
        }
    }

    Write-Information -MessageData "     Runbook Usage:"
    foreach ($runbook in $runbooks.Items)
    {
        if (Get-Member -InputObject $runbook -Name "Environments" -MemberType Properties)
        {
            if (@($runbook.Environments) -contains $($environment.Id))
            {
                $environmentIsUsed = $true
                Write-Information -MessageData "         Referenced by runbook $($runbook.Name) in the settings"
            }
        }


        if ($null -eq $deploymentProcess[$($runbook.Id)])
        {
            $projectDeploymentProcess = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/runbookProcesses/RunbookProcess-$($runbook.Id)" -Headers $header
            $deploymentProcess.$($runbook.Id) = $projectDeploymentProcess
        }

        $deploymentProcessToCheck = $deploymentProcess[$($runbook.Id)]

        foreach ($step in $deploymentProcessToCheck.Steps)
        {
            foreach ($action in $step.Actions)
            {
                if (@($action.Environments) -contains $($environment.Id) -or @($action.ExcludedEnvironments) -contains $($environment.Id))
                {
                    $environmentIsUsed = $true
                    Write-Information -MessageData "         Used in the step $($action.Name) in the deployment process for the runbook $($runbook.Name)"
                }
            }

        }
    }

    Write-Information -MessageData "     Machine Usage:"
    foreach ($machine in $machines.Items)
    {
        if (@($machine.EnvironmentIds) -contains $($environment.Id))
        {
            $environmentIsUsed = $true
            Write-Information -MessageData "         Referenced by machine $($machine.Name)"
        }
    }

    Write-Information -MessageData "     Account Usage:"
    foreach ($account in $accounts.Items)
    {
        if (@($account.EnvironmentIds) -contains $($environment.Id))
        {
            $environmentIsUsed = $true
            Write-Information -MessageData "         Referenced by account $($account.Name)"
        }
    }

    Write-Information -MessageData "     Certificate Usage:"
    foreach ($cert in $certs.Items)
    {
        if (@($certs.EnvironmentIds) -contains $($environment.Id))
        {
            $environmentIsUsed = $true
            Write-Information -MessageData "         Referenced by certificate $($cert.Name)"
        }
    }

    Write-Information -MessageData "     Subscription Usage:"
    foreach ($subscription in $subscriptions.Items)
    {
        if (@($subscription.EventNotificationSubscription.Filter.Environments) -contains $($environment.Id))
        {
            $environmentIsUsed = $true
            Write-Information -MessageData "         Referenced by subscription $($subscription.Name)"
        }
    }

    Write-Information -MessageData "     Team Usage:"
    foreach ($team in $teams.Items)
    {
        if ($null -eq $scopedUserRoles[$($team.Id)])
        {
            $teamScopedUserRoles = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/teams/$($team.Id)/scopeduserroles?skip=0&take=10000" -Headers $header
            $scopedUserRoles.$($team.Id) = $teamScopedUserRoles
        }

        $scopedRolesToCheck = $scopedUserRoles[$($team.Id)]

        foreach ($userRoles in $scopedRolesToCheck.Items)
        {
            if (@($userRoles.EnvironmentIds) -contains $($environment.Id))
            {
                $environmentIsUsed = $true
                Write-Information -MessageData "         Used in the team $($team.Name)"
            }
        }
    }

    $deployments = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/deployments?environments=$($environment.Id)" -Headers $header
    if ($deployments.Items.Count -gt 0)
    {
        $environmentIsUsed = $true
        Write-Information -MessageData "     Used in $($deployments.TotalResults) deployments"
    }
    else
    {
        Write-Information -MessageData "     Not used in any deployments"
    }

    if ($environmentIsUsed -eq $false)
    {
        $environmentsNotUsed += $environment.Name
    }
}

Write-Information -MessageData "Looping through all tenants to find it's usage"
foreach ($tenant in $tenants.Items)
{
    $tenantIsUsed = $false

    Write-Information -MessageData "Tenant: $($Tenant.Name)"
    Write-Information -MessageData "     Project Usage:"
    $tenant.ProjectEnvironments.PSObject.Properties | ForEach-Object -Process {
        foreach ($project in $projects.Items)
        {
            if ($project.Id -eq $_.Name)
            {
                $tenantIsUsed = $true
                Write-Information -MessageData "         Tied to project $($project.Name)"
            }
        }
    }

    Write-Information -MessageData "     Machine Usage:"
    foreach ($machine in $machines.Items)
    {
        if (@($machine.TenantIds) -contains $($tenant.Id))
        {
            $tenantIsUsed = $true
            Write-Information -MessageData "         Referenced by machine $($machine.Name)"
        }
    }

    Write-Information -MessageData "     Subscription Usage:"
    foreach ($subscription in $subscriptions.Items)
    {
        if (@($subscription.EventNotificationSubscription.Filter.Tenants) -contains $($tenant.Id))
        {
            $tenantIsUsed = $true
            Write-Information -MessageData "         Referenced by subscription $($subscription.Name)"
        }
    }

    Write-Information -MessageData "     Account Usage:"
    foreach ($account in $accounts.Items)
    {
        if (@($account.TenantIds) -contains $($tenant.Id))
        {
            $tenantIsUsed = $true
            Write-Information -MessageData "         Referenced by account $($account.Name)"
        }
    }

    Write-Information -MessageData "     Certificate Usage:"
    foreach ($cert in $certs.Items)
    {
        if (@($certs.TenantIds) -contains $($environment.Id))
        {
            $tenantIsUsed = $true
            Write-Information -MessageData "         Referenced by certificate $($cert.Name)"
        }
    }

    Write-Information -MessageData "     Team Usage:"
    foreach ($team in $teams.Items)
    {
        if ($null -eq $scopedUserRoles[$($team.Id)])
        {
            $teamScopedUserRoles = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/teams/$($team.Id)/scopeduserroles?skip=0&take=10000" -Headers $header
            $scopedUserRoles.$($team.Id) = $teamScopedUserRoles
        }

        $scopedRolesToCheck = $scopedUserRoles[$($team.Id)]

        foreach ($userRoles in $scopedRolesToCheck.Items)
        {
            if (@($userRoles.TenantIds) -contains $($tenant.Id))
            {
                $tenantIsUsed = $true
                Write-Information -MessageData "         Used in the team $($team.Name)"
            }
        }
    }

    $deployments = Invoke-RestMethod -Method Get -Uri "$OctopusUrl/api/$spaceId/deployments?tenants=$($tenant.Id)" -Headers $header
    if ($deployments.Items.Count -gt 0)
    {
        $tenantIsUsed = $true
        Write-Information -MessageData "     Used in $($deployments.TotalResults) deployments"
    }
    else
    {
        Write-Information -MessageData "     Not used in any deployments"
    }

    if ($tenantIsUsed -eq $false)
    {
        $tenantsNotUsed += $Tenant.Name
    }
}

Write-Information -MessageData ""
Write-Information -MessageData ""
Write-Information -MessageData ""
Write-Information -MessageData "Environments Not Used:"
Foreach ($environment in $environmentsNotUsed)
{
    Write-Information -MessageData "    $environment"
}

Write-Information -MessageData ""
Write-Information -MessageData ""
Write-Information -MessageData ""
Write-Information -MessageData "Tenants Not Used:"
Foreach ($tenant in $tenantsNotUsed)
{
    Write-Information -MessageData "    $tenant"
}
