<#
 =============================================================================
<copyright file="GetUsageCounts.ps1" company="John Merryweather Cooper
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
This file "GetUsageCounts.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

# You must replace the string "https://yourinstance" with the URL to your Octopus instance.
$OctopusDeployUrl = "https://yourinstance"

# You must replace the string "API-XXXX" with an API key able to access your Octopus instance.
# See the documentation at https://octopus.com/docs/octopus-rest-api/how-to-create-an-api-key for instructions
# on generating an API key.
$OctopusDeployApiKey = "API-XXXX"

# Validation that variable have been updated. Do not update the values here - they must stay as "https://yourinstance"
# and "API-XXXX", as this is how we check that the variables above were updated.
if ($OctopusDeployUrl -eq "https://yourinstance" -or $OctopusDeployApiKey -eq "API-XXXX") {
    Write-Information -MessageData "You must replace the placeholder variables with values specific to your Octopus instance"
    exit 1
}

## To avoid nuking your instance, this script will pull back 50 items at a time and count them.  It is designed to run on instances as far back as 3.4.

function Get-OctopusUrl
{
    param (
        $EndPoint,
        $SpaceId,
        $OctopusUrl
    )

    $octopusUrlToUse = $OctopusUrl
    if ($OctopusUrl.EndsWith("/"))
    {
        $octopusUrlToUse = $OctopusUrl.Substring(0, $OctopusUrl.Length - 1)
    }

    if ($EndPoint -match "/api")
    {
        if (!$EndPoint.StartsWith("/api"))
        {
            $EndPoint = $EndPoint.Substring($EndPoint.IndexOf("/api"))
        }

        return "$octopusUrlToUse$EndPoint"
    }

    if ([string]::IsNullOrWhiteSpace($SpaceId))
    {
        return "$octopusUrlToUse/api/$EndPoint"
    }

    return "$octopusUrlToUse/api/$spaceId/$EndPoint"
}

function Invoke-OctopusApi
{
    param
    (
        $endPoint,
        $spaceId,
        $octopusUrl,        
        $apiKey
    )    

    try
    {        
        $url = Get-OctopusUrl -EndPoint $endPoint -SpaceId $spaceId -OctopusUrl $octopusUrl

        Write-Information -MessageData "Invoking $url"
        return Invoke-RestMethod -Method Get -Uri $url -Headers @{"X-Octopus-ApiKey" = "$apiKey" } -ContentType 'application/json; charset=utf-8' -TimeoutSec 60        
    }
    catch
    {
        $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
        Write-Error -Message "There was an error making a Get call to the $url.  Please check that for more information." -ErrorAction Continue

        if ($null -ne $_.Exception.Response)
        {
            if ($_.Exception.Response.StatusCode -eq 401)
            {
                Write-Error -Message "Unauthorized error returned from $url, please verify API key and try again" -ErrorAction Continue
            }
            elseif ($_.ErrorDetails.Message)
            {
                Write-Error -Message "Error calling $url StatusCode: $($_.Exception.Response) $($_.ErrorDetails.Message)" -ErrorAction Continue
                Write-Error -Message $_.Exception -ErrorAction Continue
            }
            else
            {
                Write-Error -Message $_.Exception -ErrorAction Continue
            }
        }
        else
        {
            Write-Error -Message $_.Exception -ErrorAction Continue
        }

        Write-Error -Message "Stopping the script from proceeding" -ErrorAction Continue
        throw $Error[0]
    }    
}

function Get-OctopusObjectCount
{
    param
    (
        $endPoint,
        $spaceId,
        $octopusUrl,        
        $apiKey
    )

    $itemCount = 0
    $currentPage = 1
    $pageSize = 50
    $skipValue = 0
    $haveReachedEndOfList = $false

    while ($haveReachedEndOfList -eq $false)
    {
        $currentEndPoint = "$($endPoint)?skip=$skipValue&take=$pageSize"

        $itemList = Invoke-OctopusApi -endPoint $currentEndPoint -spaceId $spaceId -octopusUrl $octopusUrl -apiKey $apiKey

        foreach ($item in $itemList.Items)
        {
            if ($null -ne (Get-Member -InputObject $item -Name "IsDisabled" -MemberType Properties))
            {          
                if ($item.IsDisabled -eq $false)
                {
                    $itemCount += 1
                }
            }
            else 
            {
                $itemCount += 1    
            }
        }

        if ($currentPage -lt $itemList.NumberOfPages)
        {
            $skipValue = $currentPage * $pageSize
            $currentPage += 1

            Write-Information -MessageData "The endpoint $endpoint has reported there are $($itemList.NumberOfPages) pages.  Setting the skip value to $skipValue and re-querying"
        }
        else
        {
            $haveReachedEndOfList = $true    
        }
    }
    
    return $itemCount
}

function Get-OctopusDeploymentTargetsCount
{
    param
    (
        $spaceId,
        $octopusUrl,        
        $apiKey
    )

    $targetCount = @{
        TargetCount = 0 
        ActiveTargetCount = 0
        UnavailableTargetCount = 0        
        DisabledTargets = 0
        ActiveListeningTentacleTargets = 0
        ActivePollingTentacleTargets = 0
        ActiveSshTargets = 0        
        ActiveKubernetesCount = 0
        ActiveAzureWebAppCount = 0
        ActiveAzureServiceFabricCount = 0
        ActiveAzureCloudServiceCount = 0
        ActiveOfflineDropCount = 0    
        ActiveECSClusterCount = 0
        ActiveCloudRegions = 0  
        ActiveFtpTargets = 0
        DisabledListeningTentacleTargets = 0
        DisabledPollingTentacleTargets = 0
        DisabledSshTargets = 0        
        DisabledKubernetesCount = 0
        DisabledAzureWebAppCount = 0
        DisabledAzureServiceFabricCount = 0
        DisabledAzureCloudServiceCount = 0
        DisabledOfflineDropCount = 0    
        DisabledECSClusterCount = 0
        DisabledCloudRegions = 0  
        DisabledFtpTargets = 0            
    }

    $currentPage = 1
    $pageSize = 50
    $skipValue = 0
    $haveReachedEndOfList = $false

    while ($haveReachedEndOfList -eq $false)
    {
        $currentEndPoint = "machines?skip=$skipValue&take=$pageSize"

        $itemList = Invoke-OctopusApi -endPoint $currentEndPoint -spaceId $spaceId -octopusUrl $octopusUrl -apiKey $apiKey

        foreach ($item in $itemList.Items)
        {
            $targetCount.TargetCount += 1

            if ($item.IsDisabled -eq $true)
            {
                $targetCount.DisabledTargets += 1                  

                if ($item.EndPoint.CommunicationStyle -eq "None")
                {
                    $targetCount.DisabledCloudRegions += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "TentacleActive")
                {
                    $targetCount.DisabledPollingTentacleTargets += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "TentaclePassive")
                {
                    $targetCount.DisabledListeningTentacleTargets += 1
                }
                # Cover newer k8s agent and traditional worker-API approach
                elseif ($item.EndPoint.CommunicationStyle -ilike "Kubernetes*")
                {
                    $targetCount.DisabledKubernetesCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "AzureWebApp")
                {
                    $targetCount.DisabledAzureWebAppCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "Ssh")
                {
                    $targetCount.DisabledSshTargets += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "Ftp")
                {
                    $targetCount.DisabledFtpTargets += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "AzureCloudService")
                {
                    $targetCount.DisabledAzureCloudServiceCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "AzureServiceFabricCluster")
                {
                    $targetCount.DisabledAzureServiceFabricCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "OfflineDrop")
                {
                    $targetCount.DisabledOfflineDropCount += 1
                }
                else
                {
                    $targetCount.DisabledECSClusterCount += 1
                }
            }
            else
            {
                if ($item.HealthStatus -eq "Healthy" -or $item.HealthStatus -eq "HealthyWithWarnings")
                {
                    $targetCount.ActiveTargetCount += 1
                }
                else
                {
                    $targetCount.UnavailableTargetCount += 1    
                }

                if ($item.EndPoint.CommunicationStyle -eq "None")
                {
                    $targetCount.ActiveCloudRegions += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "TentacleActive")
                {
                    $targetCount.ActivePollingTentacleTargets += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "TentaclePassive")
                {
                    $targetCount.ActiveListeningTentacleTargets += 1
                }
                # Cover newer k8s agent and traditional worker-API approach
                elseif ($item.EndPoint.CommunicationStyle -ilike "Kubernetes*")
                {
                    $targetCount.ActiveKubernetesCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "AzureWebApp")
                {
                    $targetCount.ActiveAzureWebAppCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "Ssh")
                {
                    $targetCount.ActiveSshTargets += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "Ftp")
                {
                    $targetCount.ActiveFtpTargets += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "AzureCloudService")
                {
                    $targetCount.ActiveAzureCloudServiceCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "AzureServiceFabricCluster")
                {
                    $targetCount.ActiveAzureServiceFabricCount += 1
                }
                elseif ($item.EndPoint.CommunicationStyle -eq "OfflineDrop")
                {
                    $targetCount.ActiveOfflineDropCount += 1
                }
                else
                {
                    $targetCount.ActiveECSClusterCount += 1
                }
            }                                
        }

        if ($currentPage -lt $itemList.NumberOfPages)
        {
            $skipValue = $currentPage * $pageSize
            $currentPage += 1

            Write-Information -MessageData "The endpoint $endpoint has reported there are $($itemList.NumberOfPages) pages.  Setting the skip value to $skipValue and re-querying"
        }
        else
        {
            $haveReachedEndOfList = $true    
        }
    }
    
    return $targetCount
}

# Add support for TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls13

$ObjectCounts = @{
    ProjectCount = 0
    TenantCount = 0        
    TargetCount = 0 
    DisabledTargets = 0
    ActiveTargetCount = 0
    UnavailableTargetCount = 0
    ActiveListeningTentacleTargets = 0
    ActivePollingTentacleTargets = 0
    ActiveSshTargets = 0        
    ActiveKubernetesCount = 0
    ActiveAzureWebAppCount = 0
    ActiveAzureServiceFabricCount = 0
    ActiveAzureCloudServiceCount = 0
    ActiveOfflineDropCount = 0    
    ActiveECSClusterCount = 0
    ActiveCloudRegions = 0
    ActiveFtpTargets = 0 
    DisabledListeningTentacleTargets = 0
    DisabledPollingTentacleTargets = 0
    DisabledSshTargets = 0        
    DisabledKubernetesCount = 0
    DisabledAzureWebAppCount = 0
    DisabledAzureServiceFabricCount = 0
    DisabledAzureCloudServiceCount = 0
    DisabledOfflineDropCount = 0    
    DisabledECSClusterCount = 0
    DisabledCloudRegions = 0  
    DisabledFtpTargets = 0             
    WorkerCount = 0
    ListeningTentacleWorkers = 0
    PollingTentacleWorkers = 0
    SshWorkers = 0
    ActiveWorkerCount = 0
    UnavailableWorkerCount = 0
    WindowsLinuxMachineCount = 0
    LicensedTargetCount = 0
    LicensedWorkerCount = 0
}

Write-Information -MessageData "Getting Octopus Deploy Version Information"
$apiInformation = Invoke-OctopusApi -endPoint "/api" -spaceId $null -octopusUrl $OctopusDeployUrl -apiKey $OctopusDeployApiKey
$splitVersion = $apiInformation.Version -split "\."
$OctopusMajorVersion = [int]$splitVersion[0]
$OctopusMinorVersion = [int]$splitVersion[1]

$hasLicenseSummary = $OctopusMajorVersion -ge 4
$hasSpaces = $OctopusMajorVersion -ge 2019
$hasWorkers = ($OctopusMajorVersion -eq 2018 -and $OctopusMinorVersion -ge 7) -or $OctopusMajorVersion -ge 2019

$spaceIdList = @()
if ($hasSpaces -eq $true)
{
    $OctopusSpaceList = Invoke-OctopusApi -endPoint "spaces?skip=0&take=10000" -octopusUrl $OctopusDeployUrl -spaceId $null -apiKey $OctopusDeployApiKey
    foreach ($space in $OctopusSpaceList.Items)
    {
        $spaceIdList += $space.Id
    }
}
else
{
    $spaceIdList += $null    
}

if ($hasLicenseSummary -eq $true)
{
    Write-Information -MessageData "Checking the license summary for this instance"
    $licenseSummary = Invoke-OctopusApi -endPoint "licenses/licenses-current-status" -octopusUrl $OctopusDeployUrl -spaceId $null -apiKey $OctopusDeployApiKey

    if ($null -ne (Get-Member -InputObject $licenseSummary -Name "NumberOfMachines" -MemberType Properties))
    {
        $ObjectCounts.LicensedTargetCount = $licenseSummary.NumberOfMachines
    }
    else
    {
        foreach ($limit in $licenseSummary.Limits)
        {
            if ($limit.Name -eq "Targets")
            {
                Write-Information -MessageData "Your instance is currently using $($limit.CurrentUsage) Targets"
                $ObjectCounts.LicensedTargetCount = $limit.CurrentUsage
            }

            if ($limit.Name -eq "Workers")
            {
                Write-Information -MessageData "Your instance is currently using $($limit.CurrentUsage) Workers"
                $ObjectCounts.LicensedWorkerCount = $limit.CurrentUsage
            }
        }
    }
}


foreach ($spaceId in $spaceIdList)
{    
    Write-Information -MessageData "Getting project counts for $spaceId"
    $activeProjectCount = Get-OctopusObjectCount -endPoint "projects" -spaceId $spaceId -octopusUrl $OctopusDeployUrl -apiKey $OctopusDeployApiKey

    Write-Information -MessageData "$spaceId has $activeProjectCount active projects."
    $ObjectCounts.ProjectCount += $activeProjectCount

    Write-Information -MessageData "Getting tenant counts for $spaceId"
    $activeTenantCount = Get-OctopusObjectCount -endPoint "tenants" -spaceId $spaceId -octopusUrl $OctopusDeployUrl -apiKey $OctopusDeployApiKey

    Write-Information -MessageData "$spaceId has $activeTenantCount tenants."
    $ObjectCounts.TenantCount += $activeTenantCount

    Write-Information -MessageData "Getting Infrastructure Summary for $spaceId"
    $infrastructureSummary = Get-OctopusDeploymentTargetsCount -spaceId $spaceId -octopusUrl $OctopusDeployUrl -apiKey $OctopusDeployApiKey

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.TargetCount) targets"
    $ObjectCounts.TargetCount += $infrastructureSummary.TargetCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveTargetCount) Healthy Targets"
    $ObjectCounts.ActiveTargetCount += $infrastructureSummary.ActiveTargetCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledTargets) Disabled Targets"
    $ObjectCounts.DisabledTargets += $infrastructureSummary.DisabledTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.UnavailableTargetCount) Unhealthy Targets"
    $ObjectCounts.UnavailableTargetCount += $infrastructureSummary.UnavailableTargetCount    

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveListeningTentacleTargets) Active Listening Tentacles Targets"
    $ObjectCounts.ActiveListeningTentacleTargets += $infrastructureSummary.ActiveListeningTentacleTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActivePollingTentacleTargets) Active Polling Tentacles Targets"
    $ObjectCounts.ActivePollingTentacleTargets += $infrastructureSummary.ActivePollingTentacleTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveCloudRegions) Active Cloud Region Targets"
    $ObjectCounts.ActiveCloudRegions += $infrastructureSummary.ActiveCloudRegions

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveOfflineDropCount) Active Offline Packages"
    $ObjectCounts.ActiveOfflineDropCount += $infrastructureSummary.ActiveOfflineDropCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveSshTargets) Active SSH Targets"
    $ObjectCounts.ActiveSshTargets += $infrastructureSummary.ActiveSshTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveSshTargets) Active Kubernetes Targets"
    $ObjectCounts.ActiveKubernetesCount += $infrastructureSummary.ActiveKubernetesCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveAzureWebAppCount) Active Azure Web App Targets"
    $ObjectCounts.ActiveAzureWebAppCount += $infrastructureSummary.ActiveAzureWebAppCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveAzureServiceFabricCount) Active Azure Service Fabric Cluster Targets"
    $ObjectCounts.ActiveAzureServiceFabricCount += $infrastructureSummary.ActiveAzureServiceFabricCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveAzureCloudServiceCount) Active (Legacy) Azure Cloud Service Targets"
    $ObjectCounts.ActiveAzureCloudServiceCount += $infrastructureSummary.ActiveAzureCloudServiceCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveECSClusterCount) Active ECS Cluster Targets"
    $ObjectCounts.ActiveECSClusterCount += $infrastructureSummary.ActiveECSClusterCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveFtpTargets) Active FTP Targets"
    $ObjectCounts.ActiveFtpTargets += $infrastructureSummary.ActiveFtpTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledListeningTentacleTargets) Disabled Listening Tentacles Targets"
    $ObjectCounts.DisabledListeningTentacleTargets += $infrastructureSummary.DisabledListeningTentacleTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledPollingTentacleTargets) Disabled Polling Tentacles Targets"
    $ObjectCounts.DisabledPollingTentacleTargets += $infrastructureSummary.DisabledPollingTentacleTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledCloudRegions) Disabled Cloud Region Targets"
    $ObjectCounts.DisabledCloudRegions += $infrastructureSummary.DisabledCloudRegions

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledOfflineDropCount) Disabled Offline Packages"
    $ObjectCounts.DisabledOfflineDropCount += $infrastructureSummary.DisabledOfflineDropCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledSshTargets) Disabled SSH Targets"
    $ObjectCounts.DisabledSshTargets += $infrastructureSummary.DisabledSshTargets

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.ActiveSshTargets) Disabled Kubernetes Targets"
    $ObjectCounts.DisabledKubernetesCount += $infrastructureSummary.DisabledKubernetesCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledAzureWebAppCount) Disabled Azure Web App Targets"
    $ObjectCounts.DisabledAzureWebAppCount += $infrastructureSummary.DisabledAzureWebAppCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledAzureServiceFabricCount) Disabled Azure Service Fabric Cluster Targets"
    $ObjectCounts.DisabledAzureServiceFabricCount += $infrastructureSummary.DisabledAzureServiceFabricCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledAzureCloudServiceCount) Disabled (Legacy) Azure Cloud Service Targets"
    $ObjectCounts.DisabledAzureCloudServiceCount += $infrastructureSummary.DisabledAzureCloudServiceCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledECSClusterCount) Disabled ECS Cluster Targets"
    $ObjectCounts.DisabledECSClusterCount += $infrastructureSummary.DisabledECSClusterCount

    Write-Information -MessageData "$spaceId has $($infrastructureSummary.DisabledFtpTargets) Disabled FTP Targets"
    $ObjectCounts.DisabledFtpTargets += $infrastructureSummary.DisabledFtpTargets

    if ($hasWorkers -eq $true)
    {
        Write-Information -MessageData "Getting worker information for $spaceId"
        $workerPoolSummary = Invoke-OctopusApi -endPoint "workerpools/summary" -spaceId $spaceId -octopusUrl $OctopusDeployUrl -apiKey $OctopusDeployApiKey 

        Write-Information -MessageData "$spaceId has $($workerPoolSummary.TotalMachines) Workers"
        $ObjectCounts.WorkerCount += $workerPoolSummary.TotalMachines

        Write-Information -MessageData "$spaceId has $($workerPoolSummary.MachineHealthStatusSummaries.Healthy) Healthy Workers"
        $ObjectCounts.ActiveWorkerCount += $workerPoolSummary.MachineHealthStatusSummaries.Healthy
    
        Write-Information -MessageData "$spaceId has $($workerPoolSummary.MachineHealthStatusSummaries.HasWarnings) Healthy with Warning Workers"
        $ObjectCounts.ActiveWorkerCount += $workerPoolSummary.MachineHealthStatusSummaries.HasWarnings
    
        Write-Information -MessageData "$spaceId has $($workerPoolSummary.MachineHealthStatusSummaries.Unhealthy) Unhealthy Workers"
        $ObjectCounts.UnavailableWorkerCount += $workerPoolSummary.MachineHealthStatusSummaries.Unhealthy
    
        Write-Information -MessageData "$spaceId has $($workerPoolSummary.MachineHealthStatusSummaries.Unknown) Workers with a Status of Unknown"
        $ObjectCounts.UnavailableWorkerCount += $workerPoolSummary.MachineHealthStatusSummaries.Unknown
        
        Write-Information -MessageData "$spaceId has $($workerPoolSummary.MachineEndpointSummaries.TentaclePassive) Listening Tentacles Workers"
        $ObjectCounts.ListeningTentacleWorkers += $workerPoolSummary.MachineEndpointSummaries.TentaclePassive

        Write-Information -MessageData "$spaceId has $($workerPoolSummary.MachineEndpointSummaries.TentacleActive) Polling Tentacles Workers"
        $ObjectCounts.PollingTentacleWorkers += $workerPoolSummary.MachineEndpointSummaries.TentacleActive        

        if ($null -ne (Get-Member -InputObject $workerPoolSummary.MachineEndpointSummaries -Name "Ssh" -MemberType Properties))
        {
            Write-Information -MessageData "$spaceId has $($workerPoolSummary.MachineEndpointSummaries.TentacleActive) SSH Targets Workers"
            $ObjectCounts.SshWorkers += $workerPoolSummary.MachineEndpointSummaries.Ssh
        }
    }
}

Write-Information -MessageData "Calculating Windows and Linux Machine Count"
$ObjectCounts.WindowsLinuxMachineCount = $ObjectCounts.ActivePollingTentacleTargets + $ObjectCounts.ActiveListeningTentacleTargets + $ObjectCounts.ActiveSshTargets

if ($hasLicenseSummary -eq $false)
{
    $ObjectCounts.LicensedTargetCount = $ObjectCounts.TargetCount - $ObjectCounts.ActiveCloudRegions - $ObjectCounts.DisabledTargets    
}

# Get node information
$nodeInfo = Invoke-OctopusApi -endPoint "octopusservernodes" -octopusUrl $OctopusDeployUrl -spaceId $null -apiKey $OctopusDeployApiKey

Write-Information -MessageData "The item counts are as follows:"
Write-Information -MessageData "    Instance ID: $($apiInformation.InstallationId)"
Write-Information -MessageData "    Server Version: $($apiInformation.Version)"
Write-Information -MessageData "    Number of Server Nodes: $($nodeInfo.TotalResults)"
Write-Information -MessageData "    Licensed Target Count: $($ObjectCounts.LicensedTargetCount) (these are active targets de-duped across the instance if running a modern version of Octopus)" -ForegroundColor Green
Write-Information -MessageData "    Project Count: $($ObjectCounts.ProjectCount)"
Write-Information -MessageData "    Tenant Count: $($ObjectCounts.TenantCount)" 
Write-Information -MessageData "    Machine Counts (Active Linux and Windows Tentacles and SSH Connections): $($ObjectCounts.WindowsLinuxMachineCount)" 
Write-Information -MessageData "    Deployment Target Count: $($ObjectCounts.TargetCount)"
Write-Information -MessageData "        Active and Available Targets: $($ObjectCounts.ActiveTargetCount)" -ForegroundColor Green
Write-Information -MessageData "        Active but Unavailable Targets: $($ObjectCounts.UnavailableTargetCount)" -ForegroundColor Yellow
Write-Information -MessageData "        Active Target Breakdown"
Write-Information -MessageData "            Listening Tentacle Target Count: $($ObjectCounts.ActiveListeningTentacleTargets)"
Write-Information -MessageData "            Polling Tentacle Target Count: $($ObjectCounts.ActivePollingTentacleTargets)"
Write-Information -MessageData "            SSH Target Count: $($ObjectCounts.ActiveSshTargets)"
Write-Information -MessageData "            Kubernetes Target Count: $($ObjectCounts.ActiveKubernetesCount)"
Write-Information -MessageData "            Azure Web App Target Count: $($ObjectCounts.ActiveAzureWebAppCount)"
Write-Information -MessageData "            Azure Service Fabric Cluster Target Count: $($ObjectCounts.ActiveAzureServiceFabricCount)"
Write-Information -MessageData "            Azure (Legacy) Cloud Service Target Count: $($ObjectCounts.ActiveAzureCloudServiceCount)"
Write-Information -MessageData "            AWS ECS Cluster Target Count: $($ObjectCounts.ActiveECSClusterCount)"
Write-Information -MessageData "            Offline Target Count: $($ObjectCounts.ActiveOfflineDropCount)"
Write-Information -MessageData "            Cloud Region Target Count: $($ObjectCounts.ActiveCloudRegions)"
Write-Information -MessageData "            Ftp Target Count: $($ObjectCounts.ActiveFtpTargets)"
Write-Information -MessageData "        Disabled Targets Targets: $($ObjectCounts.DisabledTargets)" -ForegroundColor Red
Write-Information -MessageData "        Disabled Target Breakdown"
Write-Information -MessageData "            Listening Tentacle Target Count: $($ObjectCounts.DisabledListeningTentacleTargets)"
Write-Information -MessageData "            Polling Tentacle Target Count: $($ObjectCounts.DisabledPollingTentacleTargets)"
Write-Information -MessageData "            SSH Target Count: $($ObjectCounts.DisabledSshTargets)"
Write-Information -MessageData "            Kubernetes Target Count: $($ObjectCounts.DisabledKubernetesCount)"
Write-Information -MessageData "            Azure Web App Target Count: $($ObjectCounts.DisabledAzureWebAppCount)"
Write-Information -MessageData "            Azure Service Fabric Cluster Target Count: $($ObjectCounts.DisabledAzureServiceFabricCount)"
Write-Information -MessageData "            Azure (Legacy) Cloud Service Target Count: $($ObjectCounts.DisabledAzureCloudServiceCount)"
Write-Information -MessageData "            AWS ECS Cluster Target Count: $($ObjectCounts.DisabledECSClusterCount)"
Write-Information -MessageData "            Offline Target Count: $($ObjectCounts.DisabledOfflineDropCount)"
Write-Information -MessageData "            Cloud Region Target Count: $($ObjectCounts.DisabledCloudRegions)"
Write-Information -MessageData "            Ftp Target Count: $($ObjectCounts.DisabledFtpTargets)"
Write-Information -MessageData "    Worker Count: $($ObjectCounts.WorkerCount)"
Write-Information -MessageData "        Active Workers: $($ObjectCounts.ActiveWorkerCount)" 
Write-Information -MessageData "        Unavailable Workers: $($ObjectCounts.UnavailableWorkerCount)"
Write-Information -MessageData "        Worker Breakdown"
Write-Information -MessageData "            Listening Tentacle Target Count: $($ObjectCounts.ListeningTentacleWorkers)"
Write-Information -MessageData "            Polling Tentacle Target Count: $($ObjectCounts.PollingTentacleWorkers)"
Write-Information -MessageData "            SSH Target Count: $($ObjectCounts.SshWorkers)"
