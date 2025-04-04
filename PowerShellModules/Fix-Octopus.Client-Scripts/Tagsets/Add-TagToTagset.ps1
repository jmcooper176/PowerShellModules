Add-Type -Path "C:\Tools\Octopus.Client.dll"

$apikey = '' #Your Octopus API Key
$octopusURI = '' #Your Octopus instance URL

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI, $apiKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

$tagset = $repository.TagSets.FindByName("MyTagset")

$newtag = New-Object -TypeName Octopus.Client.Model.TagResource

$newtag.Name = "MyNewTag"
$newtag.Color = "#232323"
#Modify any other properties of $newTag here

$tagset.Tags.Add($newtag) #You might wanna double check that a tag with that name doesn't exist here.

$repository.TagSets.Modify($tagset)
