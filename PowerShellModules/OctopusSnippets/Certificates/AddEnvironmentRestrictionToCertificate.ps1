<#
 =============================================================================
<copyright file="AddEnvironmentRestrictionToCertificate.ps1" company="John Merryweather Cooper
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
This file "AddEnvironmentRestrictionToCertificate.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

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
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint $octopusURI, $apikey
$repository = New-Object -TypeName Octopus.Client.OctopusRepository $endpoint
$client = New-Object -TypeName Octopus.Client.OctopusClient $endpoint

try {
    # Get space
    $space = $repository.Spaces.FindByName($spaceName)
    $repositoryForSpace = $client.ForSpace($space)

    # Get current certificate

    $currentCertificate = $repositoryForSpace.Certificates.FindAll() | Where-Object -FilterScript { ($_.Name -eq $certificateName) -and ($null -eq $_.Archived) } # Octopus supports multiple certificates of the same name.  The FindByName() method returns the first one it finds, so it is not useful in this scenario

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
