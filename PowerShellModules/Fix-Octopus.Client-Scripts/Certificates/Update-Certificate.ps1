# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load Octopus Client assembly
Add-Type -Path 'path\to\Octopus.Client.dll'

# Provide credentials for Octopus
$apikey = 'API-YOURAPIKEY'
$octopusURI = 'https://youroctourl'
$spaceName = "default"

# Create repository object
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI,$apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get current certificate
    $certificateName = "MyCertificate"
    $currentCertificate = $repositoryForSpace.Certificates.FindAll() | Where-Object -FilterScript {($_.Name -eq $certificateName) -and ($null -eq $_.Archived)} # Octopus supports multiple certificates of the same name.  The FindByName() method returns the first one it finds, so it is not useful in this scenario

    # Check to see if multiple certificates were returned
    if ($currentCertificate -is [array])
    {
        # throw error
        throw "Multiple certificates returned!"
    }

    # Get replacement certificate
    $replacementPfxPath = "path\to\replacement\file.pfx"
    $pfxBase64 = [Convert]::ToBase64String((Get-Content -LiteralPath $replacementPfxPath -Encoding Byte))
    $pfxPassword = "PFX-file-password"

    # Replace certificate
    $replacementCertificate = $repositoryForSpace.Certificates.Replace($currentCertificate, $pfxBase64, $pfxPassword);
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
