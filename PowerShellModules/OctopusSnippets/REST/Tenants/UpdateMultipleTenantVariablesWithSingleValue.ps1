<#
 =============================================================================
<copyright file="UpdateMultipleTenantVariablesWithSingleValue.ps1" company="U.S. Office of Personnel
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
This file "UpdateMultipleTenantVariablesWithSingleValue.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaceName = "Default" # Name of the Space
$tenantName = "TenantName" # The tenant name
$variableTemplateName = "ProjectTemplateName" # Choose the template Name
$newValue = "NewValue" # Choose a new variable value, assumes same per environment
$NewValueIsBoundToOctopusVariable=$False # Choose $True if the $newValue is an Octopus variable e.g. #{SomeValue}

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object -FilterScript {$_.Name -eq $spaceName}

# Get Tenant
$tenantsSearch = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants?name=$tenantName" -Headers $header)
$tenant = $tenantsSearch.Items | Select-Object -First 1

# Get Tenant Variables
$variables = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/tenants/$($tenant.Id)/variables" -Headers $header)

# Get project templates
$projects = $variables.ProjectVariables | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty "Name"

# Loop through each project template
foreach ($projectKey in $projects)
{
    # Get connected project
    $project = $variables.ProjectVariables.$projectKey
    $projectName = $project.ProjectName
    Write-Information -MessageData "Working on Project: $projectName ($projectKey)"

    # Get Project template ID
    $variableTemplate = ($project.Templates | Where-Object Name -eq $variableTemplateName | Select-Object -First 1)
    
    
    if($null -ne $variableTemplate) {

        $variableTemplateId = $variableTemplate.Id
        $variableTemplateIsSensitiveControlType = $variableTemplate.DisplaySettings.{Octopus.ControlType} -eq "Sensitive"

        Write-Information -MessageData "Found templateId for Template: $variableTemplateName = $variableTemplateId"
        $projectConnectedEnvironments = $project.Variables | Get-Member | Where-Object -FilterScript {$_.MemberType -eq "NoteProperty"} | Select-Object -ExpandProperty "Name"

        # Loop through each of the connected environments variables
        foreach($envKey in $projectConnectedEnvironments) {
            # Check for Environment project template entry, and add if not present
            if($null -eq $project.Variables.$envKey.$variableTemplateId) {
                $project.Variables.$envKey | Add-Member -MemberType NoteProperty -Name $variableTemplateId -Value $newValue
            }

            # Check sensitive control types differently
            if($variableTemplateIsSensitiveControlType -eq $True) {
                # If $newValue denotes an octopus variable e.g. #{SomeVar}, treat it as if it were text
                if($NewValueIsBoundToOctopusVariable -eq $True) {      
                    Write-Information -MessageData "Adding in new text value (treating as octopus variable) in Environment '$envKey' for $variableTemplateName"             
                    $project.Variables.$envKey.$variableTemplateId = $newValue
                }    
                else {
                    $newSensitiveValue = [PsCustomObject]@{
                        HasValue = $True
                        NewValue = $newValue
                    }
                    Write-Information -MessageData "Adding in new sensitive value = '********' in Environment '$envKey' for $variableTemplateName"
                    $project.Variables.$envKey.$variableTemplateId = $newSensitiveValue
                }
            } 
            else {
                Write-Information -MessageData "Adding in new value = $newValue in Environment '$envKey' for $variableTemplateName"
                $project.Variables.$envKey.$variableTemplateId = $newValue
            }       
        }
    }
    else {
        Write-Information -MessageData "Couldnt find project template: $variableTemplateName for project $projectName"
    }
}
# Update the variables with the new value
Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/tenants/$($tenant.Id)/variables" -Headers $header -Body ($variables | ConvertTo-Json -Depth 10)