<#
 =============================================================================
<copyright file="CreateLifecycle.ps1" company="U.S. Office of Personnel
Management">
    Copyright © 2025, U.S. Office of Personnel Management.
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
This file "CreateLifecycle.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

function Get-OctopusItems
{
    # Define parameters
    param (
        $OctopusUri,
        $ApiKey,
        $SkipCount = 0
    )
    
    # Define working variables
    $items = @()
    $skipQueryString = ""
    $headers = @{"X-Octopus-ApiKey"="$ApiKey"}

    # Check to see if there there is already a querystring
    if ($octopusUri.Contains("?"))
    {
        $skipQueryString = "&skip="
    }
    else
    {
        $skipQueryString = "?skip="
    }

    $skipQueryString += $SkipCount
    
    # Get intial set
    $resultSet = Invoke-RestMethod -Uri "$($OctopusUri)$skipQueryString" -Method GET -Headers $headers

    # Check to see if it returned an item collection
    if ($resultSet.Items)
    {
        # Store call results
        $items += $resultSet.Items
    
        # Check to see if resultset is bigger than page amount
        if (($resultSet.Items.Count -gt 0) -and ($resultSet.Items.Count -eq $resultSet.ItemsPerPage))
        {
            # Increment skip count
            $SkipCount += $resultSet.ItemsPerPage

            # Recurse
            $items += Get-OctopusItems -OctopusUri $OctopusUri -ApiKey $ApiKey -SkipCount $SkipCount
        }
    }
    else
    {
        return $resultSet
    }
    

    # Return results
    return $items
}

$apikey = 'API-YourAPIKey' # Get this from your profile
$OctopusUrl = 'https://YourURL' # Your Octopus Server address
$spaceName = "Default"

# Create headers for API calls
$headers = @{"X-Octopus-ApiKey"="$ApiKey"}

$lifecycleName = "MyLifecycle"

# Get space
$space = (Get-OctopusItems -OctopusUri "$octopusURL/api/spaces" -ApiKey $ApiKey) | Where-Object -FilterScript {$_.Name -eq $spaceName}

# Get lifecycles
$lifecycles = Get-OctopusItems -OctopusUri "$octopusURL/api/$($space.Id)/lifecycles" -ApiKey $apikey

# Check to see if lifecycle already exists
if ($null -eq ($lifecycles | Where-Object -FilterScript {$_.Name -eq $lifecycleName}))
{
    # Create payload
    $jsonPayload = @{
        Id = $null
        Name = $lifecycleName
        SpaceId = $space.Id
        Phases = @()
        ReleaseRetentionPolicy = @{
            ShouldKeepForever = $true
            QuantityToKeep = 0
            Unit = "Days"
        }
        TentacleRetentionPolicy = @{
            ShouldKeepForever = $true
            QuantityToKeep = 0
            Unit = "Days"
        }
        Links = $null
    }

    # Create new lifecycle
    Invoke-RestMethod -Method Post -Uri "$OctopusUrl/api/$($space.Id)/lifecycles" -Body ($jsonPayload | ConvertTo-Json -Depth 10) -Headers $headers
}
else
{
    Write-Information -MessageData "$lifecycleName already exists."
}