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

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

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
        $variableTemplate = ($project.Templates | Where-Object -Property Name -EQ $variableTemplateName | Select-Object -First 1)
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
                        $project.Variables[$envKey][$variableTemplateId] = New-Object -TypeName Octopus.Client.Model.PropertyValueResource -ArgumentList $newValue
                    }
                    else {
                        Write-Information -MessageData "Adding in new sensitive value = '********' in Environment '$envKey' for $variableTemplateName"
                        $sensitiveValue = New-Object -TypeName Octopus.Client.Model.SensitiveValue
                        $sensitiveValue.HasValue = $True
                        $sensitiveValue.NewValue = $newValue
                        $project.Variables[$envKey][$variableTemplateId] = $sensitiveValue
                    }
                }
                else {
                    Write-Information -MessageData "Adding in new value = $newValue in Environment '$envKey' for $variableTemplateName"
                    $project.Variables[$envKey][$variableTemplateId] = New-Object -TypeName Octopus.Client.Model.PropertyValueResource -ArgumentList $newValue
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
