<#
 =============================================================================
<copyright file="UpdateMultipleTenantVariablesWithSingleValue.ps1" company="John Merryweather Cooper
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
This file "UpdateMultipleTenantVariablesWithSingleValue.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'Octopus.Client.dll' 

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"

$spaceName = "Default" # Name of the Space
$tenantName = "TenantName" # The tenant name
$variableTemplateName = "ProjectTemplateName" # Choose the template Name
$newValue = "NewValue" # Choose a new variable value, assumes same per environment
$NewValueIsBoundToOctopusVariable=$False # Choose $True if the $newValue is an Octopus variable e.g. #{SomeValue}

$endpoint = New-Object -TypeName.Client.OctopusServerEndpoint $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName.Client.OctopusRepository $endpoint
$client = New-Object -TypeName.Client.OctopusClient $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $spaceRepository = $client.ForSpace($space)

    # Get Tenant
    $tenant = $spaceRepository.Tenants.FindByName($tenantName)
    
    # Get Tenant Variables
    $variables = $spaceRepository.Tenants.GetVariables($tenant)

    # Loop through each Project Template
    foreach($projectKey in $variables.ProjectVariables.Keys)
    {
        # Get connected project
        $project = $variables.ProjectVariables[$projectKey]
        $projectName = $project.ProjectName
        Write-Information -MessageData "Working on Project: $projectName ($projectKey)"
        
        # Get Project template ID
        $variableTemplate = ($project.Templates | Where-Object Name -eq $variableTemplateName | Select-Object -First 1)
        $variableTemplateId = $variableTemplate.Id
        $variableTemplateIsSensitiveControlType = $variableTemplate.DisplaySettings["Octopus.ControlType"] -eq "Sensitive"

        if($null -ne $variableTemplateId) {

            Write-Information -MessageData "Found templateId for Template: $variableTemplateName = $variableTemplateId"

            # Loop through each of the connected environments variables
            foreach($envKey in $project.Variables.Keys) {
                                        
                # Set null value in case not set
                $project.Variables[$envKey][$variableTemplateId] = $null

                # Check sensitive control types differently
                if($variableTemplateIsSensitiveControlType -eq $True) {
                    
                    # If $newValue denotes an octopus variable e.g. #{SomeVar}, treat it as if it were text
                    if($NewValueIsBoundToOctopusVariable -eq $True) {      
                        Write-Information -MessageData "Adding in new text value (treating as octopus variable) in Environment '$envKey' for $variableTemplateName"             
                        $project.Variables[$envKey][$variableTemplateId] = New-Object -TypeName.Client.Model.PropertyValueResource $newValue
                    }    
                    else {
                        Write-Information -MessageData "Adding in new sensitive value = '********' in Environment '$envKey' for $variableTemplateName"
                        $sensitiveValue = New-Object -TypeName.Client.Model.SensitiveValue 
                        $sensitiveValue.HasValue = $True
                        $sensitiveValue.NewValue = $newValue
                        $project.Variables[$envKey][$variableTemplateId] = $sensitiveValue
                    }
                } 
                else {
                    Write-Information -MessageData "Adding in new value = $newValue in Environment '$envKey' for $variableTemplateName"
                    $project.Variables[$envKey][$variableTemplateId] = New-Object -TypeName.Client.Model.PropertyValueResource $newValue
                }
            }
        }
        else {
            Write-Information -MessageData "Couldnt find project template: $variableTemplateName for project $projectName"
        }
    }

    # Update the variables with the new value
    $spaceRepository.Tenants.ModifyVariables($tenant, $variables) | Out-Null
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}