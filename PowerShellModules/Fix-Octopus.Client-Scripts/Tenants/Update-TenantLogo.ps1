# Main script starts towards the end of the file.

function Invoke-OctopusLogoUpload
{
    [CmdletBinding()]
    PARAM
    (
        [string][parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$InFile,
        [string]$ContentType,
        [Uri][parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Uri,
        [string][parameter(Mandatory = $true)]$ApiKey
    )
    BEGIN
    {
        if (-not (Test-Path -LiteralPath $InFile -PathType Leaf))
        {
            $errorMessage = ("File {0} missing or unable to read." -f $InFile)

            $newObjectSplat = @{
                TypeName = System.Management.Automation.ErrorRecord
                ArgumentList = @(
                    [System.IO.FileNotFoundException]::new($InFile, ("File {0} missing or unable to read." -f $InFile)),
                    'ObjectNotFound',
                    "InvokeOctopusLogoUpload-FileNotFoundException-01",
                    $InFile
                )
            }

            $errorRecord = New-Object @newObjectSplat
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        if (-not $ContentType)
        {
            Add-Type -AssemblyName System.Web

            $mimeType = [System.Web.MimeMapping]::GetMimeMapping($InFile)

            if ($mimeType)
            {
                $ContentType = $mimeType
            }
            else
            {
                $ContentType = "application/octet-stream"
            }
        }
    }
    PROCESS
    {
        Add-Type -AssemblyName System.Net.Http

        $httpClientHandler = New-Object -TypeName System.Net.Http.HttpClientHandler

        $httpClient = New-Object -TypeName System.Net.Http.HttpClient -ArgumentList $httpClientHandler
        $httpClient.DefaultRequestHeaders.Add("X-Octopus-ApiKey", $ApiKey)

        $packageFileStream = New-Object -TypeName System.IO.FileStream -ArgumentList @($InFile, [System.IO.FileMode]::Open)

        $contentDispositionHeaderValue = New-Object -TypeName System.Net.Http.Headers.ContentDispositionHeaderValue -ArgumentList "form-data"
        $contentDispositionHeaderValue.Name = "fileData"
        $contentDispositionHeaderValue.FileName = (Split-Path $InFile -leaf)

        $streamContent = New-Object -TypeName System.Net.Http.StreamContent -ArgumentList $packageFileStream
        $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
        $streamContent.Headers.ContentType = New-Object -TypeName System.Net.Http.Headers.MediaTypeHeaderValue -ArgumentList $ContentType

        $content = New-Object -TypeName System.Net.Http.MultipartFormDataContent
        $content.Add($streamContent)

        try
        {
            $response = $httpClient.PostAsync($Uri, $content).Result

            if (!$response.IsSuccessStatusCode)
            {
                $responseBody = $response.Content.ReadAsStringAsync().Result
                $errorMessage = "Status code {0}. Reason {1}. Server reported the following message: {2}." -f $response.StatusCode, $response.ReasonPhrase, $responseBody

                throw [System.Net.Http.HttpRequestException] $errorMessage
            }

            return $response.Content.ReadAsStringAsync().Result
        }
        catch [Exception]
        {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            $PSCmdlet.ThrowTerminatingError($Error[0])
        }
        finally
        {
            if($null -ne $httpClient)
            {
                $httpClient.Dispose()
            }

            if($null -ne $response)
            {
                $response.Dispose()
            }
        }
    }
    END { }
}

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'

# Octopus variables
$octopusUri = "https://your.octopus.url"
# API Key
$apiKey = "API-AKEY"
# Enter tenant name
$tenantName = 'MyTenant'
$spaceName="Default"

# any supported image format
$imageFilePath = "C:\temp\logo.png"

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint -ArgumentList $octopusURI, $apiKey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository -ArgumentList $endpoint

# Get Space
$space = $repository.Spaces.FindByName($spaceName)
Write-Information -MessageData "Using Space named $($space.Name) with id $($space.Id)"

# Create space specific repository
$repositoryForSpace = [Octopus.Client.OctopusRepositoryExtensions]::ForSpace($repository, $space)

# Get tenant Id
$tenant = $repositoryForSpace.Tenants.FindByName($tenantName)

$uri = "$($octopusUri)/api/$($space.Id)/tenants/$($tenant.Id)/logo"
Invoke-OctopusLogoUpload -Uri $uri -InFile $imageFilePath -ApiKey $apiKey
