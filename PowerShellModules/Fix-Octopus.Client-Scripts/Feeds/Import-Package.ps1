# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Octopus variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "Default"
$packageName = "packageName"
$packageVersion = "1.0.0.0"
$outputFolder = "C:\Temp\"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get package
    $package = $repositoryForSpace = $repositoryForSpace.BuiltInPackageRepository.GetPackage($packageName, $packageVersion)

    # Download Package
    $filePath = [System.IO.Path]::Combine($outputFolder, "$($package.PackageId).$($package.Version)$($package.FileExtension)")
    Invoke-RestMethod -Method Get -Uri "$octopusURL/$($package.Links.Raw)" -Headers $header -OutFile $filePath
    Write-Information -MessageData "Downloaded file to $filePath"
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
