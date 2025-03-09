# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$azureServicePrincipalName = "MyAzureAccount"
$azureResourceGroupName = "MyResourceGroup"
$azureWebAppName = "MyAzureWebApp"
$spaceName = "default"
$environmentNames = @("Development", "Production")
$roles = @("MyRole")

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get environment ids
    $environments = $repositoryForSpace.Environments.FindAll() | Where-Object -FilterScript {$environmentNames -contains $_.Name}

    # Get Azure account
    $azureAccount = $repositoryForSpace.Accounts.FindByName($azureServicePrincipalName)

    # Create new Azure Web App object
    $azureWebAppTarget = New-Object -TypeName Octopus.Client.Model.Endpoints.AzureWebAppEndpointResource
    $azureWebAppTarget.AccountId = $azureAccount.Id
    $azureWebAppTarget.ResourceGroupName = $azureResourceGroupName
    $azureWebAppTarget.WebAppName = $azureWebAppName

    # Create new machine object
    $machine = New-Object -TypeName Octopus.Client.Model.MachineResource
    $machine.Endpoint = $azureWebAppTarget
    $machine.Name = $azureWebAppName

    # Add Environments
    foreach ($environment in $environments)
    {
        # Add to target
        $machine.EnvironmentIds.Add($environment.Id)
    }

    # Add roles
    foreach ($role in $roles)
    {
        $machine.Roles.Add($role)
    }

    # Add to machine to space
    $repositoryForSpace.Machines.Create($machine)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
