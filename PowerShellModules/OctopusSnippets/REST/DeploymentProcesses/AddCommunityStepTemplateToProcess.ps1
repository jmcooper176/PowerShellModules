<#
 =============================================================================
<copyright file="AddCommunityStepTemplateToProcess.ps1" company="U.S. Office of Personnel
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
This file "AddCommunityStepTemplateToProcess.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$targetRole = "octofx-web"

$spaceName = "Default"
$projectName = "A project"
$communityStepTemplateName = "Run Octopus Deploy Runbook"

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get community step templates
$communityActionTemplatesList = Invoke-RestMethod -Uri "$octopusURL/api/communityactiontemplates?skip=0&take=2000" -Headers $header 

Write-Information -MessageData "Checking if $communityStepTemplateName is installed in Space $spaceName"
$installStepTemplate = $true
$stepTemplatesList = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/actiontemplates?skip=0&take=2000&partialName=$([uri]::EscapeDataString($communityStepTemplateName))" -Headers $header 
foreach ($stepTemplate in $stepTemplatesList.Items) {
    
    
    if ($null -eq $stepTemplate.CommunityActionTemplateId) {
        Write-Information -MessageData "The step template $($stepTemplate.Name) is not a community step template, moving on."
        continue
    }

    if ($stepTemplate.Name.ToLower().Trim() -eq $communityStepTemplateName.ToLower().Trim()) {
        Write-Information -MessageData "The step template $($stepTemplate.Name) matches $communityStepTemplateName.  No need to install the step template."

        $communityActionTemplate = $communityActionTemplatesList.Items | Where-Object -FilterScript { $_.Id -eq $stepTemplate.CommunityActionTemplateId }                

        if ($null -eq $communityActionTemplate) {
            Write-Information -MessageData "Unable to find the community step template in the library, skipping the version check."
            $installStepTemplate = $false
            break
        }

        if ($communityActionTemplate.Version -eq $stepTemplate.Version) {
            Write-Information -MessageData "The step template $($stepTemplate.Name) is on version $($stepTemplate.Version) while the matching community template is on version $($communityActionTemplate.Version).  The versions match.  Leaving the step template alone."
            $installStepTemplate = $false
        }
        else {
            Write-Information -MessageData "The step template $($stepTemplate.Name) is on version $($stepTemplate.Version) while the matching community template is on version $($communityActionTemplate.Version).  Updating the step template."

            $actionTemplate = Invoke-RestMethod -Method Put -Uri "$octopusURL/api/communityactiontemplates/$($communityActionTemplate.Id)/installation/$($space.Id)" -Headers $header 
            Write-Information -MessageData "Succesfully updated the step template.  The version is now $($actionTemplate.Version)"

            $installStepTemplate = $false
        }
        
        break
    }
}

if ($installStepTemplate -eq $true) {
    $communityActionTemplateToInstall = $null
    foreach ($communityStepTemplate in $communityActionTemplatesList.Items) {
        if ($communityStepTemplate.Name.ToLower().Trim() -eq $communityStepTemplateName.ToLower().Trim()) {
            $communityActionTemplateToInstall = $communityStepTemplate
            break
        }
    }

    if ($null -eq $communityActionTemplateToInstall) {
        Write-Information -MessageData "Unable to find $communityStepTemplateName.  Please either re-sync the community library or check the names.  Exiting." -ForegroundColor Red
        exit 1
    }

    Write-Information -MessageData "Installing the step template $communityStepTemplateName to $($space.Name)."
    $actionTemplate = Invoke-RestMethod -Method Post -Uri "$octopusURL/api/communityactiontemplates/$($communityActionTemplateToInstall.Id)/installation/$($space.Id)" -Headers $header 
    Write-Information -MessageData "Succesfully installed the step template.  The Id of the new action template is $($actionTemplate.Id)"
}
else {
    foreach ($stepTemplate in $stepTemplatesList.Items) {
        if ($stepTemplate.Name.ToLower().Trim() -eq $communityStepTemplateName.ToLower().Trim()) {
            $actionTemplate = $stepTemplate
            break
        }
    }
}


# Get project
$projects = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/projects?partialName=$([uri]::EscapeDataString($projectName))&skip=0&take=100" -Headers $header 
$project = $projects.Items | Where-Object -FilterScript { $_.Name -eq $projectName }

# Get deployment process
$deploymentProcess = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/deploymentprocesses/$($project.DeploymentProcessId)" -Headers $header)

# Get current steps
$steps = $deploymentProcess.Steps

# Check existing steps for step template based on Id
foreach ($step in $steps) {
    if ($step.Actions[0].Properties.'Octopus.Action.Template.Id' -eq $actionTemplate.Id) {
        Write-Warning -Message "Community step template '$communityStepTemplateName' already exists in project, exiting"
        break;
    }
}

$ActionProperties = @{
    'Octopus.Action.Script.ScriptSource' = $actionTemplate.Properties.'Octopus.Action.Script.ScriptSource'
    'Octopus.Action.Script.Syntax'       = $actionTemplate.Properties.'Octopus.Action.Script.Syntax'
    'Octopus.Action.Script.ScriptBody'   = $actionTemplate.Properties.'Octopus.Action.Script.ScriptBody'
    'Octopus.Action.Template.Id'         = $actionTemplate.Id
    'Octopus.Action.Template.Version'    = $actionTemplate.Version
}

# Add parameters with a default value
foreach ($parameter in $actionTemplate.Parameters) {
    if (-not $ActionProperties.ContainsKey($parameter.Name)) {
        if (-not [string]::IsNullOrWhitespace($parameter.DefaultValue)) {
            $ActionProperties | Add-Member -NotePropertyName $parameter.Name -NotePropertyValue $parameter.DefaultValue
        }
    }
    else {
        Write-Information -MessageData "ActionProperty already has a value for $($parameter.Name)"
    }
}

# Add the step
$steps += @{
    Name               = "$communityStepTemplateName"
    Properties         = @{
        'Octopus.Action.TargetRoles' = $targetRole
    }
    Condition          = "Success"
    StartTrigger       = "StartAfterPrevious"
    PackageRequirement = "LetOctopusDecide"
    Actions            = @(
        @{
            ActionType                    = $actionTemplate.ActionType
            Name                          = "$communityStepTemplateName"
            Environments                  = @()
            ExcludedEnvironments          = @()
            Channels                      = @()
            TenantTags                    = @()
            Properties                    = $ActionProperties
            Packages                      = $actionTemplate.Packages
            IsDisabled                    = $false
            WorkerPoolId                  = ""
            WorkerPoolVariable            = ""
            Container                     = @{
                "FeedId" = $null
                "Image"  = $null
            }
            CanBeUsedForProjectVersioning = $false
            IsRequired                    = $false
        }
    )
}

# Convert steps to json
$deploymentProcess.Steps = $steps
$jsonPayload = $deploymentProcess | ConvertTo-Json -Depth 10

# Update deployment process
Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/deploymentprocesses/$($project.DeploymentProcessId)" -Headers $header -Body $jsonPayload