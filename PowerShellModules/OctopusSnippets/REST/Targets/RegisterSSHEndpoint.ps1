<#
 =============================================================================
<copyright file="RegisterSSHEndpoint.ps1" company="John Merryweather Cooper
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
This file "RegisterSSHEndpoint.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

$spaceName = "Default"
$sshTargetName = "SSH target Name"
$sshHostnameOrIpAddress = "127.0.0.1"
$sshPort = "22"
$sshFingerPrint = "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"
# Account name to use to authenticate
$accountName = "Account name"

# List of environment names
$environmentNames = @("Development", "Test")
$environmentIds = @()

# List of target-roles to add
$roles = @("MyRole")
# Target tenant deployment participation - select either "Tenanted", "Untenanted", or "TenantedOrUntenanted"
$tenantedDeploymentParticipation = "Untenanted"

# List of Tenant names to connect to the target
$tenantNames = @()
$tenantIds = @()

# Get space
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -eq $spaceName }

# Get environment Ids
$environments = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/environments/all" -Headers $header) | Where-Object -FilterScript { $environmentNames -contains $_.Name }
foreach ($environment in $environments) {
  $environmentIds += $environment.Id
}

# Get tenants
$allTenants = (Invoke-RestMethod -Method Get -Uri "$octopusUrl/api/$($space.Id)/tenants/all" -Headers $header)

foreach ($tenantName in $tenantNames) {
  # Exchange tenant name for tenant ID
  $tenant = $allTenants | Where-Object -FilterScript { $_.name -eq $tenantName }

  # Associate tenant ID to deployment target
  $tenantIds += ($tenant.Id)
}

# Get account
$accounts = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/accounts?partialName=$([uri]::EscapeDataString($accountName))&skip=0&take=100" -Headers $header 
$account = $accounts.Items | Where-Object -FilterScript { $_.Name -eq $accountName }

$sshTarget = @{
  Name                            = $sshTargetName
  IsDisabled                      = $False
  HealthStatus                    = "Unknown"
  IsInProcess                     = $True
  Endpoint                        = @{
    CommunicationStyle = "Ssh"
    Name               = ""
    Uri                = "ssh://$($sshHostnameOrIpAddress):$($sshPort)/"
    Host               = $sshHostnameOrIpAddress
    Port               = $sshPort
    Fingerprint        = $sshFingerPrint
    DotNetCorePlatform = "linux-x64"
    HostKeyAlgorithm   = "ssh-ed25519"
    AccountId          = $account.Id
  }
  TenantedDeploymentParticipation = $tenantedDeploymentParticipation
  EnvironmentIds                  = $environmentIds
  Roles                           = $roles
  TenantIds                       = $tenantIds
}

$machine = Invoke-RestMethod "$OctopusUrl/api/$($space.Id)/machines" -Headers $header -Method Post -Body ($sshTarget | ConvertTo-Json -Depth 10)
Write-Information -MessageData "Created machine $($machine.Id)"