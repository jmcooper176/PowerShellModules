<#
 =============================================================================
<copyright file="BulkAddTenantsToProject.ps1" company="John Merryweather Cooper
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
This file "BulkAddTenantsToProject.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusUrl = "YOUR URL"
$octopusApiKey = "YOUR API KEY"
$spaceName = "YOUR SPACE NAME"
$projectName = "PROJECT NAME TO ADD"
$environmentNameList =  "ENVIRONMENTS TO TIE TO" # "Development,Test"
$tenantTag = "TENANT TAG TO FILTER ON" #Format = [Tenant Tag Set Name]/[Tenant Tag] "Tenant Type/Customer"
$whatIf = $false # Set to true to test out changes before making them
$maxNumberOfTenants = 1 # The max number of tenants you wish to change in this run

$cachedResults = @{}

function Write-OctopusVerbose
{
    param ($message)

    Write-Verbose -Message $message
}

function Write-OctopusInformation
{
    param ($message)

    Write-Information -MessageData $message
}

function Write-OctopusSuccess
{
    param ($message)

    Write-Information -MessageData $message
}

function Write-OctopusWarning
{
    param ($message)

    Write-Warning -Message "$message"
}

function Write-OctopusCritical
{
    param ($message)

    Write-Error -Message "$message"
}

function Invoke-OctopusApi
{
    param
    (
        $octopusUrl,
        $endPoint,
        $spaceId,
        $apiKey,
        $method,
        $item,
        $ignoreCache
    )

    $octopusUrlToUse = $OctopusUrl
    if ($OctopusUrl.EndsWith("/"))
    {
        $octopusUrlToUse = $OctopusUrl.Substring(0, $OctopusUrl.Length - 1)
    }

    if ([string]::IsNullOrWhiteSpace($SpaceId))
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
            Write-OctopusVerbose $body

            Write-OctopusInformation "Invoking $method $url"
            return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -Body $body -ContentType 'application/json; charset=utf-8'
        }

        if (($null -eq $ignoreCache -or $ignoreCache -eq $false) -and $method.ToUpper().Trim() -eq "GET")
        {
            Write-OctopusVerbose "Checking to see if $url is already in the cache"
            if ($cachedResults.ContainsKey($url) -eq $true)
            {
                Write-OctopusVerbose "$url is already in the cache, returning the result"
                return $cachedResults[$url]
            }
        }
        else
        {
            Write-OctopusVerbose "Ignoring cache."
        }

        Write-OctopusVerbose "No data to post or put, calling bog standard invoke-restmethod for $url"
        $result = Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -ContentType 'application/json; charset=utf-8'

        if ($cachedResults.ContainsKey($url) -eq $true)
        {
            $cachedResults.Remove($url)
        }
        Write-OctopusVerbose "Adding $url to the cache"
        $cachedResults.add($url, $result)

        return $result
    }
    catch
    {
        if ($null -ne $_.Exception.Response)
        {
            if ($_.Exception.Response.StatusCode -eq 401)
            {
                Write-OctopusCritical "Unauthorized error returned from $url, please verify API key and try again"
            }
            elseif ($_.Exception.Response.statusCode -eq 403)
            {
                Write-OctopusCritical "Forbidden error returned from $url, please verify API key and try again"
            }
            else
            {
                Write-OctopusVerbose -Message "Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )"
            }
        }
        else
        {
            Write-OctopusVerbose $_.Exception
        }
    }

    $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
    Throw $Error[0]
}

function Get-OctopusItemByName
{
    param (
        $itemName,
        $itemType,
        $endpoint,
        $spaceId,
        $defaultUrl,
        $octopusApiKey
    )

    Write-OctopusInformation "Attempting to find $itemType with the name of $itemName"

    $itemList = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint "$($endPoint)?partialName=$([uri]::EscapeDataString($itemName))&skip=0&take=100" -spaceId $spaceId -apiKey $octopusApiKey -method "GET"
    $item = Get-FilteredOctopusItem -itemList $itemList -itemName $itemName

    Write-OctopusInformation "Successfully found $itemName with id of $($item.Id)"

    return $item
}

function Get-FilteredOctopusItem
{
    param (
        $itemList,
        $itemName
    )

    if ($itemList.Items.Count -eq 0)
    {
        Write-OctopusCritical "Unable to find $itemName.  Exiting with an exit code of 1."
        Exit 1
    }

    $item = $itemList.Items | Where-Object -FilterScript { $_.Name -eq $itemName}

    if ($null -eq $item)
    {
        Write-OctopusCritical "Unable to find $itemName.  Exiting with an exit code of 1."
        exit 1
    }

    return $item
}

function Test-OctopusObjectHasProperty
{
    param (
        $objectToTest,
        $propertyName
    )

    $hasProperty = Get-Member -InputObject $objectToTest -Name $propertyName -MemberType Properties

    if ($hasProperty)
    {
        Write-OctopusVerbose "$propertyName property found."
        return $true
    }
    else
    {
        Write-OctopusVerbose "$propertyName property missing."
        return $false
    }
}

function Add-PropertyIfMissing
{
    param (
        $objectToTest,
        $propertyName,
        $propertyValue,
        $overwriteIfExists)

    if ((Test-OctopusObjectHasProperty -objectToTest $objectToTest -propertyName $propertyName) -eq $false)
    {
        $objectToTest | Add-Member -MemberType NoteProperty -Name $propertyName -Value $propertyValue
    }
}

#https://local.octopusdemos.app/api/Spaces-102/tenants/tag-test?tags=Tenant%20Type%2FCustomer
$space = Get-OctopusItemByName -itemName $spaceName -itemType "Space" -endpoint "spaces" -spaceId $null -defaultUrl $octopusUrl -octopusApiKey $octopusApiKey
$spaceId = $space.Id

$project = Get-OctopusItemByName -itemName $projectName -itemType "Project" -endpoint "projects" -spaceId $spaceId -defaultUrl $octopusUrl -octopusApiKey $octopusApiKey
$projectId = $project.Id

$splitEnvironmentlist = $environmentNameList -split ","
$environmentList = @()
foreach ($environmentName in $splitEnvironmentlist)
{
    $environment = Get-OctopusItemByName -itemName $environmentName -itemType "Environment" -endpoint "environments" -spaceId $spaceId -defaultUrl $octopusUrl -octopusApiKey $octopusApiKey
    $environmentList += $environment.Id
}

$tenantList = Invoke-OctopusApi -octopusUrl $octopusUrl -apiKey $octopusApiKey -endPoint "tenants?tags=$([uri]::EscapeDataString($tenantTag))&skip=0&take=10000" -spaceId $spaceId -method "GET" -item $null -ignoreCache $false
Write-OctopusInformation "Found $($tenantList.Items.Count) tenants matching the tenant tag $tenantTag"

$changeReport = @()
$itemsChanged = 1
foreach ($tenant in $tenantList.Items)
{
    Write-OctopusInformation "Checking to see if $($tenant.Name) is assigned to $($project.Name)"
    $tenantChanged = $false
    if ((Test-OctopusObjectHasProperty -objectToTest $tenant.ProjectEnvironments -propertyName $projectId) -eq $false)
    {
        Write-OctopusInformation "The project $($project.Name) is not assigned to $($project.Name), adding it"
        $changeReport += "Added $($project.Name) to $($tenant.Name) with environment ids $environmentList"

        Add-PropertyIfMissing -objectToTest $tenant.ProjectEnvironments -propertyName $projectId -propertyValue $environmentList
        $tenantChanged = $true
    }
    else
    {
        Write-OctopusInformation "Project $($project.Name) is assigned to the $($tenant.Name), let's make sure it has the environments as well"
        foreach ($environmentId in $environmentList)
        {
            if ($tenant.ProjectEnvironments.$projectId -notcontains $environmentId)
            {
                $changeReport += "Added $environmentId to $($project.Name) association for $($tenant.Name)"
                Write-OctopusInformation "Environment $environmentId is not assigned to $($project.Name) for $($tenant.Name), adding it"
                $tenant.ProjectEnvironments.$projectId += $environmentId
                $tenantChanged = $true
            }
        }
    }

    if ($tenantChanged -eq $false)
    {
        continue
    }

    if ($whatIf -eq $false)
    {
        Invoke-OctopusApi -endPoint "tenants/$($tenant.Id)" -spaceId $spaceId -apiKey $octopusApiKey -method "PUT" -item $tenant -ignoreCache $true -octopusUrl $octopusUrl
    }
    else
    {
        Write-OctopusInformation "What if set to true, skipping saving"
    }

    $itemsChanged += 1
    if ($itemsChanged -gt $maxNumberOfTenants)
    {
        Write-OctopusInformation "Max number of tenants to change has been reached, exiting loop"
        break
    }
}

Write-OctopusInformation "Change Report:"
foreach ($item in $changeReport)
{
    Write-OctopusInformation "  $item"
}
