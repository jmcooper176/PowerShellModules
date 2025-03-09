# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "default"
$packageFile = "path\to\package"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint
$fileStream = $null

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Create new package resource
    $package = New-Object -TypeName Octopus.Client.Model.PackageResource

    # Create filestream object
    $fileStream = New-Object -TypeName System.IO.FileStream -ArgumentList $packageFile, [System.IO.FileMode]::Open

    # Push package
    $repositoryForSpace.BuiltInPackageRepository.PushPackage($packageFile, $fileStream)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
finally
{
    if ($null -ne $fileStream)
    {
        $fileStream.Close()
    }
}
