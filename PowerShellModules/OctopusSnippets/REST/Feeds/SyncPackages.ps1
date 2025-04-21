<#
 =============================================================================
<copyright file="SyncPackages.ps1" company="John Merryweather Cooper
">
    Copyright © 2025, John Merryweather Cooper.
    All Rights Reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:

       1. Redistributions of source code must retain the above
          copyright notice, this list of conditions and the following
          disclaimer.

       2. Redistributions in binary form must reproduce the above
          copyright notice, this list of conditions and the following
          disclaimer in the documentation and/or other materials
          provided with the distribution.

       3. Neither the name of the copyright holder nor the names of
          its contributors may be used to endorse or promote products
          derived from this software without specific prior written
          permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
</copyright>
<author>John Merryweather Cooper</author>
<date>Created:  2025-2-25</date>
<summary>
This file "SyncPackages.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

#
# This script is designed to be used in conjunction with an export created using the Project Export/Import feature within Octopus.
# - See https://octopus.com/docs/projects/export-import for details on the feature usage
# - See https://octopus.com/docs/octopus-rest-api/examples/feeds/synchronize-packages for example usages
#
[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("FileVersions", "LatestVersion", "AllVersions")]
    [string] $VersionSelection = "FileVersions",

    [Parameter(Mandatory, HelpMessage="See https://octopus.com/docs/octopus-rest-api/examples/feeds/synchronize-packages#usage for example file list structure.")]
    [string] $PackageListFilePath,

    [Parameter(Mandatory)]
    [string] $SourceUrl,

    [Parameter()]
    [string] $SourceDownloadUrl = $null,

    [Parameter(Mandatory)]
    [string] $SourceApiKey,

    [Parameter()]
    [string] $SourceSpace = "Default",

    [Parameter(Mandatory)]
    [string] $DestinationUrl,

    [Parameter(Mandatory)]
    [string] $DestinationApiKey,

    [Parameter()]
    [string] $DestinationSpace = "Default",

    [Parameter(HelpMessage="Optional cut-off date for a package's published date to be included in the synchronization. Expected data-type is a Date object e.g. 2020-12-16T19:31:25.650+00:00")]
    $CutoffDate = $null
)

function Push-Package([string] $fileName, $package) {
    Write-Information "Package $fileName does not exist in destination"

    if ($null -eq $SourceDownloadUrl) {
        $sourceUrl = $sourceOctopusURL + $package.Links.Raw
    }else {
        $sourceUrl = $SourceDownloadUrl + $package.Links.Raw
    }

    Write-Verbose -Message "Downloading $fileName from $sourceUrl..."
    $download = $sourceHttpClient.GetStreamAsync($sourceUrl).GetAwaiter().GetResult()

    $contentDispositionHeaderValue = New-Object -TypeName.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
    $contentDispositionHeaderValue.Name = "fileData"
    $contentDispositionHeaderValue.FileName = $fileName

    $streamContent = New-Object -TypeName.Net.Http.StreamContent $download
    $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
    $contentType = "multipart/form-data"
    $streamContent.Headers.ContentType = New-Object -TypeName.Net.Http.Headers.MediaTypeHeaderValue $contentType

    $content = New-Object -TypeName.Net.Http.MultipartFormDataContent
    $content.Add($streamContent)

    # Upload package
    Write-Verbose -Message "Uploading $fileName to $destinationOctopusURL/api/$destinationSpaceId..."
    $upload = $destinationHttpClient.PostAsync("$destinationOctopusURL/api/$destinationSpaceId/packages/raw?replace=false", $content)
    while (-not $upload.AsyncWaitHandle.WaitOne(10000)) {
        Write-Verbose -Message "Uploading $fileName..."
    }

    $streamContent.Dispose()
}

function Skip-Package([string] $filename, $package, $cutoffDate) {
    if ($null -eq $cutoffDate) {
        return $false;
    }

    if ($package.Published -lt $cutoffDate) {
        Write-Warning -Message "$filename was published on $($package.Published), which is earlier than the specified cut-off date, and will be skipped"
        return $true;
    }

    return $false
}

function Get-Packages([string] $packageId, [int] $batch, [int] $skip) {
    $getPackagesToSyncUrl = "$sourceOctopusURL/api/$sourceSpaceId/packages?nugetPackageId=$($package.Id)&take=$batch&skip=$skip"
    Write-Information -MessageData "Fetching packages from $getPackagesToSyncUrl"
    $packagesResponse = Invoke-RestMethod -Method Get -Uri "$getPackagesToSyncUrl" -Headers $sourceHeader
    return $packagesResponse;
}

function Get-PackageExists([string] $filename, $package) {
    Write-Information -MessageData "Checking if $fileName exists in destination..."
    $checkForExistingPackageURL = "$destinationOctopusURL/api/$destinationSpaceId/packages/packages-$($package.Id).$($pkg.Version)"
    $statusCode = 500

    try {
        if ($PSVersionTable.PSVersion.Major -lt 6) {
            $checkForExistingPackageResponse = Invoke-WebRequest -Method Get -Uri $checkForExistingPackageURL -Headers $destinationHeader -ErrorAction Stop
        }
        else {
            $checkForExistingPackageResponse = Invoke-WebRequest -Method Get -Uri $checkForExistingPackageURL -Headers $destinationHeader -SkipHttpErrorCheck
        }
        $statusCode = [int]$checkForExistingPackageResponse.BaseResponse.StatusCode
    }
    catch [System.Net.WebException] {
        $statusCode = [int]$_.Exception.Response.StatusCode
    }
    if ($statusCode -ne 404) {
        if ($statusCode -eq 200) {
            Write-Verbose -Message "Package $fileName already exists on the destination. Skipping."
            return $true;
        }
        else {
            Write-Error -Message "Unexpected status code $($statusCode) returned from $checkForExistingPackageURL"
        }
    }
    return $false;
}

# This script syncs packages from the built-in feed between two spaces.
# The spaces can be on the same Octopus instance, or in different instances

$ErrorActionPreference = "Stop"

# ******* Variables to be specified before running ********

# Source Octopus instance details and credentials
$sourceOctopusURL = $sourceUrl
$sourceOctopusAPIKey = $sourceApiKey
$sourceSpaceName = $sourceSpace

# Destination Octopus instance details and credentials
$destinationOctopusURL = $destinationUrl
$destinationOctopusAPIKey = $destinationApiKey
$destinationSpaceName = $destinationSpace

# *****************************************************

# Get spaces
$sourceHeader = @{ "X-Octopus-ApiKey" = $sourceOctopusAPIKey }
$sourceSpaceId = ((Invoke-RestMethod -Method Get -Uri "$sourceOctopusURL/api/spaces/all" -Headers $sourceHeader) | Where-Object -FilterScript { $_.Name -eq $sourceSpaceName }).Id

$destinationHeader = @{ "X-Octopus-ApiKey" = $destinationOctopusAPIKey }
$destinationSpaceId = ((Invoke-RestMethod -Method Get -Uri "$destinationOctopusURL/api/spaces/all" -Headers $destinationHeader) | Where-Object -FilterScript { $_.Name -eq $destinationSpaceName }).Id

# Create HTTP clients
$httpClientTimeoutInMinutes = 60
if (-not('System.Net.Http.HttpClient' -as [type])) {
    try {
        Write-Warning -Message "System.Net.Http.HttpClient type not found. Trying to load System.Net.Http assembly"
        Add-Type -AssemblyName System.Net.Http
    }
    catch {
        Write-Error -Message "Can't load required System.Net.Http Assembly!"
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
        throw $Error[0]
    }
}
$sourceHttpClient = New-Object -TypeName.Net.Http.HttpClient
$sourceHttpClient.DefaultRequestHeaders.Add("X-Octopus-ApiKey", $sourceOctopusAPIKey)
$sourceHttpClient.Timeout = New-TimeSpan -Minutes $httpClientTimeoutInMinutes

$destinationHttpClient = New-Object -TypeName.Net.Http.HttpClient
$destinationHttpClient.DefaultRequestHeaders.Add("X-Octopus-ApiKey", $destinationOctopusAPIKey)
$destinationHttpClient.Timeout = New-TimeSpan -Minutes $httpClientTimeoutInMinutes

$totalSyncedPackageCount = 0
$totalSyncedPackageSize = 0

Write-Information -MessageData "Syncing packages between $sourceOctopusURL and $destinationOctopusURL"

$packages = Get-Content -Path $PackageListFilePath | ConvertFrom-Json

# Iterate supplied package IDs
foreach ($package in $packages) {
    Write-Information -MessageData "Syncing $($package.Id) packages (published after $cutoffDate)"
    $processedPackageCount = 0
    $skip = 0;
    $batchSize = 100;

    if ($VersionSelection -eq 'AllVersions') {
        do {
            $packagesResponse = Get-Packages $package.Id $batchSize $skip
            foreach ($pkg in $packagesResponse.Items) {
                Write-Information -MessageData "Processing $($pkg.PackageId).$($pkg.Version)"
                $fileName = "$($pkg.PackageId).$($pkg.Version)$($pkg.FileExtension)"

                if (-not (Skip-Package $fileName $pkg $CutoffDate)) {
                    if (Get-PackageExists $fileName $package) {
                        $processedPackageCount++
                        continue;
                    }
                    else {
                        Push-Package $fileName $pkg
                        $processedPackageCount++
                        $totalSyncedPackageCount++
                        $totalSyncedPackageSize += $pkg.PackageSizeBytes
                    }
                }
                else {
                    $processedPackageCount++
                }
            }

            $skip = $skip + $packagesResponse.Items.Count
        } while ($packagesResponse.Items.Count -eq $batchSize)
    }
    elseif ($VersionSelection -eq 'LatestVersion') {
        $packagesResponse = Get-Packages $package.Id 1 0
        $pkg = $packagesResponse.Items | Select-Object -First 1
        if ($null -ne $pkg) {
            $fileName = "$($pkg.PackageId).$($pkg.Version)$($pkg.FileExtension)"
            if (-not (Skip-Package $fileName $pkg $CutOffDate)) {
                if (Get-PackageExists $fileName $package) {
                    $processedPackageCount++
                    continue;
                }
                else {
                    Push-Package $fileName $pkg
                    $processedPackageCount++
                    $totalSyncedPackageCount++
                    $totalSyncedPackageSize += $pkg.PackageSizeBytes
                }
            }
        }
    }
    elseif ($VersionSelection -eq "FileVersions") {
        $versions = $package.Versions;

        do {
            $packagesResponse = Get-Packages $package.Id $batchSize $skip
            foreach ($pkg in $packagesResponse.Items) {
                if ($versions.Contains($pkg.Version)) {
                    Write-Information -MessageData "Processing $($pkg.PackageId).$($pkg.Version)"
                    $fileName = "$($pkg.PackageId).$($pkg.Version)$($pkg.FileExtension)"

                    if (-not (Skip-Package $fileName $pkg $CutoffDate)) {
                        if (Get-PackageExists $fileName $package) {
                            $processedPackageCount++
                            continue;
                        }
                        else {
                            Push-Package $fileName $pkg
                            $processedPackageCount++
                            $totalSyncedPackageCount++
                            $totalSyncedPackageSize += $pkg.PackageSizeBytes
                        }
                    }
                    else {
                        $processedPackageCount++
                    }
                }
            }

            $skip = $skip + $packagesResponse.Items.Count
        } while ($packagesResponse.Items.Count -eq $batchSize)
    }

    Write-Information -MessageData "$fileName sync complete. $processedPackageCount/$($packagesResponse.TotalResults)"
}

Write-Information -MessageData "Sync complete.  $totalSyncedPackageCount packages ($("{0:n2}" -f ($totalSyncedPackageSize/1MB)) megabytes) were copied." -ForegroundColor Green
