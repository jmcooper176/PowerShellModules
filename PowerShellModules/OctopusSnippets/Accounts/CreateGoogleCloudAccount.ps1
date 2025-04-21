<#
 =============================================================================
<copyright file="CreateGoogleCloudAccount.ps1" company="John Merryweather Cooper
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
This file "CreateGoogleCloudAccount.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# Note: This script will only work with Octopus 2021.2 and higher.
# It also requires version 11.3.3355 or higher of the Octopus.Client library

# You can get this dll from NuGet
# https://www.nuget.org/packages/Octopus.Client/
Add-Type -Path 'path\to\Octopus.Client.dll'
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$spaceName = "Default"

# Octopus Account name
$accountName = "My Google Cloud Account"

# Octopus Account Description
$accountDescription = "A Google Cloud account for my project"

# Tenant Participation e.g. Tenanted, or, Untenanted, or TenantedOrUntenanted
$accountTenantParticipation = "Untenanted"

# Google Cloud JSON key file
$jsonKeyPath = "/path/to/jsonkeyfile.json"

# (Optional) Tenant tags e.g.: "AWS Region/California"
$accountTenantTags = @()
# (Optional) Tenant Ids e.g.: "Tenants-101"
$accountTenantIds = @()
# (Optional) Environment Ids e.g.: "Environments-1"
$accountEnvironmentIds = @()

if(-not (Test-Path $jsonKeyPath)) {
    Write-Warning -Message "The Json Key file was not found at '$jsonKeyPath'."
    return
}
else {
    $jsonContent = Get-Content -Path $jsonKeyPath
    $jsonKeyBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($jsonContent))
}

$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)
$client = New-Object -TypeName Octopus.Client.OctopusClient($endpoint)

try
{
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Create Google Cloud Account object
    $googleCloudAccount = New-Object -TypeName Octopus.Client.Model.Accounts.GoogleCloudAccountResource
    $googleCloudAccount.Name = $accountName
    $googleCloudAccount.Description = $accountDescription

    $jsonKeySensitiveValue = New-Object -TypeName Octopus.Client.Model.SensitiveValue
    $jsonKeySensitiveValue.NewValue = $jsonKeyBase64
    $jsonKeySensitiveValue.HasValue = $True
    $googleCloudAccount.JsonKey = $jsonKeySensitiveValue

    $googleCloudAccount.TenantedDeploymentParticipation = [Octopus.Client.Model.TenantedDeploymentMode]::$accountTenantParticipation
    $googleCloudAccount.TenantTags = New-Object -TypeName Octopus.Client.Model.ReferenceCollection $accountTenantTags
    $googleCloudAccount.TenantIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection $accountTenantIds
    $googleCloudAccount.EnvironmentIds = New-Object -TypeName Octopus.Client.Model.ReferenceCollection $accountEnvironmentIds

    # Create account
    $repositoryForSpace.Accounts.Create($googleCloudAccount)
}
catch
{
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
}
