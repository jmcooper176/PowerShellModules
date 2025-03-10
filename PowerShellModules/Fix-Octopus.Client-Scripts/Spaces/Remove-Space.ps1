# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'

$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$spaceName = "New Space"

$space = $repository.Spaces.FindByName($spaceName)

if ($null -eq $space) {
    Write-Information -MessageData "The space $spaceName does not exist."
    exit
}

try {
    $space.TaskQueueStopped = $true

    $repository.Spaces.Modify($space) | Out-Null
    $repository.Spaces.Delete($space) | Out-Null
} catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
