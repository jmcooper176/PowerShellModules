# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path "C:\Octo\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"

$spaceName = "default"
$feedName = "nuget.org"
$feedURI = "https://api.nuget.org/v3/index.json"
$downloadAttempts = 5
$downloadRetryBackoffSeconds = 10
# Set to $True to use the Extended API.
$useExtendedApi = $False
# Optional
$feedUsername = ""
$feedPassword = ""

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

try
{
    # Get space id
    $space = $repository.Spaces.FindByName($spaceName)
    Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

    # Create space specific repository
    $repositoryForSpace = [Octopus.Client.OctopusRepositoryExtensions]::ForSpace($repository, $space)

    # Set new feed resource
    $feedResource = New-Object -TypeName Octopus.Client.Model.NuGetFeedResource
    $feedResource.SpaceId = $space.Id
    $feedResource.Name = $feedName
    $feedResource.FeedUri = $feedURI
    $feedResource.DownloadAttempts = $downloadAttempts
    $feedResource.DownloadRetryBackoffSeconds = $downloadRetryBackoffSeconds
    $feedResource.EnhancedMode = $useExtendedApi

    if(-not ([string]::IsNullOrEmpty($feedUsername)))
    {
        $feedResource.Username = $feedUsername
    }
    if(-not ([string]::IsNullOrEmpty($feedPassword)))
    {
        $feedResource.Password = $feedPassword
    }

    # Create new feed
    $feed = $repositoryForSpace.Feeds.Create($feedResource)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
