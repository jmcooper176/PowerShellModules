<#
 =============================================================================
<copyright file="FindUnusedTargets.ps1" company="John Merryweather Cooper
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
This file "FindUnusedTargets.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$octopusUrl = "https://local.octopusdemos.app" ## Octopus URL to look at
$octopusApiKey = "YOUR API KEY" ## API key of user who has permissions to view all spaces, cancel tasks, and resubmit runbooks runs and deployments
$daysSinceLastDeployment = 90 ## The number of days since the last deployment to be considered unused.  Any target without a deployment in the last [90] days is considered inactive.
$includeMachineLists = $false;  ## If true, all machines in each category will get listed out to the console.  If false, just a summary of information will be included.

$unsupportedCommunicationStyles = @("None")
$tentacleCommunicationStyles = @("TentaclePassive")

function Invoke-OctopusApi
{
    param
    (
        $octopusUrl,
        $endPoint,
        $spaceId,
        $apiKey,
        $method,
        $item   
    )

    $octopusUrlToUse = $OctopusUrl
    if ($OctopusUrl.EndsWith("/"))
    {
        $octopusUrlToUse = $OctopusUrl.Substring(0, $OctopusUrl.Length - 1)
    }

    if ([string]::IsNullOrWhiteSpace($spaceId))
    {
        $url = "$octopusUrlToUse/api/$EndPoint"
    }
    else
    {
        $url = "$octopusUrlToUse/api/$spaceId/$EndPoint"    
    }  

    try
    {        
        if ($null -ne $item)
        {
            $body = $item | ConvertTo-Json -Depth 10
            Write-Verbose -Message $body

            Write-Information -MessageData "Invoking $method $url"
            return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -Body $body -ContentType 'application/json; charset=utf-8' 
        }

        Write-Verbose -Message "No data to post or put, calling bog standard invoke-restmethod for $url"
        $result = Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -ContentType 'application/json; charset=utf-8'

        return $result               
    }
    catch
    {
        if ($null -ne $_.Exception.Response)
        {
            if ($_.Exception.Response.StatusCode -eq 401)
            {
                Write-Error -Message "Unauthorized error returned from $url, please verify API key and try again" -ErrorAction Continue
            }
            elseif ($_.Exception.Response.statusCode -eq 403)
            {
                Write-Error -Message "Forbidden error returned from $url, please verify API key and try again" -ErrorAction Continue
            }
            else
            {
                $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
                Write-Error -Message "Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )" -ErrorAction Continue
            }
        }
        else
        {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
        }
    }

    Throw $_.Exception
}

function Update-CategorizedMachines
{
    param (
        $categorizedMachines,
        $space
    )

    $machineList = Invoke-OctopusApi -octopusUrl $octopusUrl -apiKey $octopusApiKey -endPoint "machines?skip=0&take=10000" -spaceId $space.Id -method "GET"    

    foreach ($machine in $machineList.Items)
    {
        $categorizedMachines.TotalMachines += 1

        if ($unsupportedCommunicationStyles -contains $machine.Endpoint.CommunicationStyle)
        {
            $categorizedMachines.NotCountedMachines += $machine
            continue
        }

        if ($tentacleCommunicationStyles -contains $machine.Endpoint.CommunicationStyle)
        {
            $duplicateTentacle = $categorizedMachines.ListeningTentacles | Where-Object -FilterScript {$_.Thumbprint -eq $machine.Thumbprint -and $_.EndPoint.Uri -eq $machine.Endpoint.Uri }

            if ($null -ne $duplicateTentacle)
            {
                $categorizedMachines.DuplicateTentacles += $machine
                $categorizedMachines.ActiveMachines -= 1
            }

            $categorizedMachines.ListeningTentacles += $machine
        }        

        if ($machine.IsDisabled -eq $true)
        {
            $categorizedMachines.DisabledMachines += $machine
            continue
        }

        $categorizedMachines.ActiveMachines += 1

        if ($machine.HealthStatus -eq "Unavailable")
        {
            $categorizedMachines.OfflineMachines += $machine            
        }

        $deploymentsList = Invoke-OctopusApi -octopusUrl $octopusUrl -apiKey $octopusApiKey -endPoint "machines/$($machine.Id)/tasks?skip=0" -spaceId $space.Id -method "GET"

        if ($deploymentsList.Items.Count -le 0)
        {
            $categorizedMachines.UnusedMachines += $machine
            continue
        }

        $deploymentDate = [datetime]::Parse($deploymentsList.Items[0].CompletedTime)
        $deploymentDate = $deploymentDate.ToUniversalTime()

        $dateDiff = $currentUtcTime - $deploymentDate

        if ($dateDiff.TotalDays -gt $daysSinceLastDeployment)
        {
            $categorizedMachines.OldMachines += $machine                        
        }                 
    }
}

$currentUtcTime = $(Get-Date).ToUniversalTime()

$categorizedMachines = @{
    NotCountedMachines = @()
    DisabledMachines = @()
    ActiveMachines = 0
    OfflineMachines = @()
    UnusedMachines = @()
    OldMachines = @()
    TotalMachines = 0
    ListeningTentacles = @()
    DuplicateTentacles = @()
}

# Need to check the Octopus Server version for spaces feature
Write-Information -MessageData "Checking Octopus Server version..."
$apiInfo = Invoke-OctopusApi -octopusUrl $octopusUrl -apiKey $octopusApiKey -endPoint $null -method "GET"
$version = $apiInfo.Version
$versionParts = $apiInfo.Version.Split(".")

if ($versionParts[0] -ge 2019) {
    Write-Information -MessageData "Octopus Server version $version supports spaces, checking all spaces."
    $spaceList = Invoke-OctopusApi -octopusUrl $octopusUrl -apiKey $octopusApiKey -endPoint "spaces?skip=0&take=1000" -spaceId $null -method "GET"
    foreach ($space in $spaceList.Items)
    {    
        Update-CategorizedMachines -categorizedMachines $categorizedMachines -space $space
    }
} else {
    Write-Information -MessageData "Octopus Server version $version doesn't use spaces."
    Update-CategorizedMachines -categorizedMachines $categorizedMachines
}

Write-Information -MessageData "This instance has a total of $($categorizedMachines.TotalMachines) targets across all spaces."
Write-Information -MessageData "There are $($categorizedMachines.NotCountedMachines.Count) cloud regions which are not counted."
Write-Information -MessageData "There are $($categorizedMachines.DisabledMachines.Count) disabled machines that are not counted."
Write-Information -MessageData "There are $($categorizedMachines.DuplicateTentacles.Count) duplicate listening tentacles that are not counted (assuming you are using 2019.7.3+)."
Write-Information -MessageData ""
Write-Information -MessageData "This leaves you with $($categorizedMachines.ActiveMachines) active targets being counted against your license (this script is excluding the $($categorizedMachines.DuplicateTentacles.Count) duplicates in that active count)."
Write-Information -MessageData "Of that combined number, $($categorizedMachines.OfflineMachines.Count) are showing up as offline."
Write-Information -MessageData "Of that combined number, $($categorizedMachines.UnusedMachines.Count) have never had a deployment."
Write-Information -MessageData "Of that combined number, $($categorizedMachines.OldMachines.Count) haven't done a deployment in over $daysSinceLastDeployment days."

if ($includeMachineLists -eq $true){
    Write-Information -MessageData "Offline Targets"
    Foreach ($target in $categorizedMachines.OfflineMachines)
    {
        Write-Information -MessageData " -  $($target.Name)"
    }

    Write-Information -MessageData "No Deployment Ever Targets"
    Foreach ($target in $categorizedMachines.UnusedMachines)
    {
        Write-Information -MessageData " -  $($target.Name)"
    }

    Write-Information -MessageData " No deployments in the last $daysSinceLastDeployment days"
    Foreach ($target in $categorizedMachines.OldMachines)
    {
        Write-Information -MessageData " -  $($target.Name)"
    }
}
