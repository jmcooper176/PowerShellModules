# Load octopus.client assembly
Add-Type -Path "path\to\Octopus.Client.dll"

# Define working variables
$octopusURL = "https://youroctourl"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "Default"
$tagsetName = "Upgrade Ring"
$tagsetDescription = "Describes which upgrade ring the tenant belongs to"

# Optional Tags to add in the format "Tag name", "Tag Color"
$optionalTags = @{}
$optionalTags.Add("Early Adopter", "#ECAD3F")
$optionalTags.Add("Stable", "#36A766")

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURL, $octopusAPIKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient -ArgumentList $endpoint

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Create or modify tagset
    $tagsetEditor = $repositoryForSpace.TagSets.CreateOrModify($tagsetName, $tagsetDescription)

    # Add optional tags
    if($optionalTags.Count -gt 0)
    {
        foreach ($tagName in $optionalTags.Keys) {
            $tagsetEditor.AddOrUpdateTag($tagName, "", $optionalTags.Item($tagName))
        }
    }
    $tagsetEditor.Save()
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
