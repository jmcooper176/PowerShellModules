# Load octopus.client assembly
# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path "path\to\Octopus.Client.dll"

# Working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"
$spaceName = "Default"
$feedName = "Octopus Server (built-in)"
$packageId = "Your-PackageId"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space id
    $space = $repository.Spaces.FindByName($spaceName)
    Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

    # Create space specific repository
    $repositoryForSpace = $client.ForSpace($space)

    # Get feed
    $feed = $repositoryForSpace.Feeds.FindByName($feedName)
    [string]$path = $feed.Links["SearchPackageVersionsTemplate"]

    # Make Generic List method
    $method = $client.GetType().GetMethod("List").MakeGenericMethod([Octopus.Client.Model.PackageResource])

    # Set path parameters for call
    $pathParameters = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,Object]'
    $pathParameters.Add("PackageId",$packageId)

    # Set generic method parameters
    [Object[]] $parameters = $path, $pathParameters

    # Invoke the List method
    $results = $method.Invoke($client, $parameters)

    # Print results
    foreach($result in $results.Items)
    {
        Write-Information -MessageData "Package: $($result.PackageId) with version: $($result.Version)"
    }
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
