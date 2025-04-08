<#
 =============================================================================
<copyright file="GetBuildInformationForAllPackagesInRunbook.ps1" company="John Merryweather Cooper
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
This file "GetBuildInformationForAllPackagesInRunbook.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

$OctopusApiKey = $OctopusParameters["Octopus.ApiKey"]
$OctopusServerUrl = $OctopusParameters["Octopus.Web.ServerUri"]
$header = @{ "X-Octopus-ApiKey" = $OctopusApiKey }
$spaceId = $OctopusParameters["Octopus.Space.Id"]

# Get all PackageIds from deployment
$packageIdKeys = $OctopusParameters.Keys | Where-Object -FilterScript { $_ -match "^Octopus\.Action.*\.PackageId$" }  | ForEach-Object -Process { $_ } | Sort-Object -Property * -Unique
$packageBuildInfos = @()

foreach ($packageIdKey in $packageIdKeys) {
    $packageVersionKey = $packageIdKey -Replace ".PackageID", ".PackageVersion"
    $packageId = $OctopusParameters[$packageIdKey]
    $packageVersion = $OctopusParameters[$packageVersionKey]

    # It's possible to have multiple packages of the same version.
    $existingPackageBuildInfo = $packageBuildInfos | Where-Object -FilterScript { $_.PackageId -eq $packageId -and $_.PackageVersion -eq $packageVersion } | Select-Object -First 1
    if ($null -eq $existingPackageBuildInfo) {
        
        Write-Information -MessageData "Getting build info for $packageId - ($packageVersion)"
        $buildInfoResults = (Invoke-RestMethod -Method Get -Uri "$OctopusServerUrl/api/$($spaceId)/build-information?packageId=$([uri]::EscapeDataString($packageId))&filter=$([uri]::EscapeDataString($packageVersion))" -Headers $header)
    
        if ($buildInfoResults.Items.Count -gt 0) {
            Write-Information -MessageData "Build Info found for $packageId - ($packageVersion)"

            if ($buildInfoResults.Items.Count -gt 1) {
                Write-Warning -Message "Multiple build information found for $packageId - ($packageVersion), taking first result."
            }

            $buildInformation = ($buildInfoResults.Items | Select-Object -First 1)

            $packageBuildInfos += @{
                PackageId        = $packageId
                PackageVersion   = $packageVersion
                BuildInformation = $buildInformation
            };
        }
    }
}

foreach ($package in $packageBuildInfos) {
    $buildInfoJson = $package.BuildInformation | ConvertTo-Json -Depth 10 -Compress
    Write-Information -MessageData "Setting Build info variable for $($package.PackageId) - ($($package.PackageVersion))"
    Write-Verbose -Message "BuildInformation is: $buildInfoJson"
    Set-OctopusVariable -name "BuildInformation_$($package.PackageId)_$($package.PackageVersion)" -value "$buildInfoJson"
}

Write-Highlight "Found $($packageBuildInfos.Count) build information records."
