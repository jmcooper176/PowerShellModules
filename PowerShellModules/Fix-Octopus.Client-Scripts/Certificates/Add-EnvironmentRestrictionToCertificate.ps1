# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
# Load Octopus Client assembly
Add-Type -Path 'path\to\Octopus.Client.dll'

# Provide credentials for Octopus
$apikey = 'API-YOURAPIKEY'
$octopusURI = 'https://youroctourl'

# Working variables
$spaceName = "Default"
$certificateName = "My-Certificate-Name"
$environmentName = "EnvironmentName"

# Create repository object
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI, $apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try {
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get current certificate

    $currentCertificate = $repositoryForSpace.Certificates.FindAll() | Where-Object -Property Name -EQ $certificateName | Where-Object -Property Archived -EQ $null  # Octopus supports multiple certificates of the same name.  The FindByName() method returns the first one it finds, so it is not useful in this scenario

    # Check to see if multiple certificates were returned
    if ($currentCertificate -is [array]) {
        # throw error
        throw "Multiple certificates returned!"
    }

    # Get environment
    $environment = $repositoryForSpace.Environments.FindByName($environmentName)

    if ($currentCertificate.EnvironmentIds -notcontains $environment.Id) {
        Write-Information -MessageData "Certificate doesnt contain environment restriction for $($environmentName) ($($environment.Id))"
        # Add environment restriction
        $currentCertificate.EnvironmentIds.Add($environment.Id)

        # Update certificate
        Write-Information -MessageData "Updating certificate"
        $repositoryForSpace.Certificates.Modify($currentCertificate)
    }
    else {
        Write-Information -MessageData "Certificate already contains environment restriction for $($environmentName) ($($environment.Id))"
    }
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
