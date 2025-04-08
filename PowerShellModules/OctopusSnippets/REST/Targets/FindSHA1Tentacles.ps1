<#
 =============================================================================
<copyright file="FindSHA1Tentacles.ps1" company="John Merryweather Cooper
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
This file "FindSHA1Tentacles.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusBaseURL = "https://your.octopus.app"
$octopusAPIKey = "API-YOURAPIKEY"
$headers = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

try {
    # Get space id
    $spaces = Invoke-RestMethod -Method Get -Uri "$octopusBaseURL/api/spaces/all" -Headers $headers -ErrorVariable octoError

    $spaces | ForEach-Object -Process {
        $spaceId = $_.Id
        $spaceName = $_.Name
        Write-Information -MessageData "Searching Space named $spaceName with id $spaceId"

        # Create space specific url
        $octopusSpaceUrl = "$octopusBaseURL/api/$spaceId"

        # Get tentacles
        try {
            $targets = Invoke-RestMethod -Method Get -Uri "$octopusSpaceUrl/machines/all" -Headers $headers -ErrorVariable octoError
            $workers = Invoke-RestMethod -Method Get -Uri "$octopusSpaceUrl/workers/all" -Headers $headers -ErrorVariable octoError

            Write-Information -MessageData "Targets and workers with sha1RSA certificates in Space $spaceName"
            ($targets + $workers) | Where-Object -FilterScript { $_.Endpoint -and $_.Endpoint.CertificateSignatureAlgorithm -and $_.Endpoint.CertificateSignatureAlgorithm -eq "sha1RSA" } |
                ForEach-Object -Process {
                    Write-Information -MessageData "`t$($_.Name)"
                }
        }
        catch {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            Write-Error -Message "Error searching Space $spaceName. This could be a permission issue." -ErrorAction Continue
            Write-Error -Message "Error message is $($octoError.Message)" -ErrorAction Continue
        }
    }
}
catch {
    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    Write-Error -Message "There was an error during the request: $($octoError.Message)" -ErrorAction Continue
    throw $Error[0]
}
