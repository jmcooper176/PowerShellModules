<#
 =============================================================================
<copyright file="UpdateScriptModule.ps1" company="U.S. Office of Personnel
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
This file "UpdateScriptModule.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$octopusUrl = "https://local.octopusdemos.app"
$octopusApiKey = "YOUR API KEY"
$spaceName = "Default" 
$scriptModuleName = "Hello World"
$updatedScript = @"
function Say-Hello()
{
    Write-Output "Hello, API SCRIPT!"
}
"@

$cachedResults = @{}

function Write-OctopusVerbose
{
    param ($message)
    
    Write-Information -MessageData $message  
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
                $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
            }
        }
        else
        {
            $Error | ForEach-Object -Process { Write-Error -ErrorRecord $_ -ErrorAction Continue }
        }
    }

    Write-Error -Message "There was an error calling the Octopus API please check the log for more details" -ErrorAction Continue
    throw $Error[0]
}

function Get-OctopusItemList
{
    param (
        $itemType,
        $endpoint,        
        $spaceId,
        $octopusUrl,
        $octopusApiKey
    )

    if ($null -ne $spaceId) 
    {
        Write-OctopusVerbose "Pulling back all the $itemType in $spaceId"
    }
    else
    {
        Write-OctopusVerbose "Pulling back all the $itemType for the entire instance"
    }
    
    if ($endPoint -match "\?+")
    {
        $endpointWithParams = "$($endPoint)&skip=0&take=10000"
    }
    else
    {
        $endpointWithParams = "$($endPoint)?skip=0&take=10000"
    }

    $itemList = Invoke-OctopusApi -octopusUrl $octopusUrl -endPoint $endpointWithParams -spaceId $spaceId -apiKey $octopusApiKey -method "GET"
    
    if ($itemList -is [array])
    {
        Write-OctopusVerbose "Found $($itemList.Length) $itemType."

        return ,$itemList        
    }
    else
    {
        Write-OctopusVerbose "Found $($itemList.Items.Length) $itemType."

        return ,$itemList.Items
    }
}

function Get-OctopusItemByName
{
    param (
        $itemType,
        $itemName,
        $endPoint,
        $spaceId,
        $octopusUrl,
        $octopusApiKey
    )

    $itemList = Get-OctopusItemList -endpoint "$($endpoint)?partialName=$([uri]::EscapeDataString($itemName))" -itemType $itemType -spaceId $spaceId -octopusUrl $octopusUrl -octopusApiKey $octopusApiKey

    $filteredItem = $itemList | Where-Object -FilterScript { $_.Name.ToLower().Trim() -eq $itemName.ToLower().Trim() }

    if ($null -eq $filteredItem)
    {
        Write-OctopusInformation "Unable to find the $itemType $itemName"
        exit 1
    }
    
    return $filteredItem
}

$space = Get-OctopusItemByName -endPoint "spaces" -itemType "Space" -itemName $spaceName -spaceId $null -octopusUrl $octopusUrl -octopusApiKey $octopusApiKey
$matchingLibraryVariableSet = Get-OctopusItemByName -endPoint "libraryvariablesets?contentType=ScriptModule" -itemType "Script Module" -itemName $scriptModuleName -spaceId $($space.Id) -octopusUrl $octopusUrl -octopusApiKey $octopusApiKey
$variablesToUpdate = Invoke-OctopusApi -endPoint "variables/$($matchingLibraryVariableSet.VariableSetId)" -octopusUrl $octopusUrl -apiKey $octopusApiKey -method "GET" -spaceId $($space.Id)

foreach ($variable in $variablesToUpdate.Variables)
{
    Write-Information -MessageData "Checking to see if $($variable.Name) matches Octopus.Script.Module[$scriptModuleName]"
    if ($variable.Name.ToLower().Trim() -eq "Octopus.Script.Module[$scriptModuleName]".ToLower().Trim())
    {
        Write-Information -MessageData "Found the variable containing the script to update"
        $variable.Value = $updatedScript
    }
}

Write-Information -MessageData "Found matching variable set, updating"
$updatedVariableSet = Invoke-OctopusApi -spaceId $($space.Id) -endPoint "variables/$($matchingLibraryVariableSet.VariableSetId)" -method "PUT" -apiKey $octopusApiKey -item $variablesToUpdate -octopusUrl $octopusUrl