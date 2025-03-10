# Load octopus.client assembly
Add-Type -Path "Octopus.Client.dll"
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"

$spaceName = "Default"
$environmentName = "Development"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

# Get space id
$space = $repository.Spaces.FindByName($spaceName)
Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

# Create space specific repository
$repositoryForSpace = [Octopus.Client.OctopusRepositoryExtensions]::ForSpace($repository, $space)

# Get environment
$environment = $repositoryForSpace.Environments.FindByName($environmentName)

# Get deployments to environment
$projects = @()
$environments = @($environment.Id)
$deployments = New-Object -TypeName System.Collections.Generic.List[System.Object]

$repositoryForSpace.Deployments.Paginate($projects, $environments, {param($page)
    Write-Information -MessageData "Found $($page.Items.Count) deployments.";
    $deployments.AddRange($page.Items)
    return $True
})

Write-Information -MessageData "Retrieved $($deployments.Count) deployments to environment $($environmentName)"
