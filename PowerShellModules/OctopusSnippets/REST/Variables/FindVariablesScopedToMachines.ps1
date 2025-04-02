<#
 =============================================================================
<copyright file="FindVariablesScopedToMachines.ps1" company="U.S. Office of Personnel
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
This file "FindVariablesScopedToMachines.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusUrl = "https://YOUR INSTANCE URL"
$OctopusApiKey = "YOUR API KEY"

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
    
    if ([string]::IsNullOrWhiteSpace($SpaceId))
    {
        $url = "$OctopusUrl/api/$EndPoint"
    }
    else
    {
        $url = "$OctopusUrl/api/$spaceId/$EndPoint"    
    }  
    
    if ([string]::IsNullOrWhiteSpace($method))
    {
    	$method = "GET"
    }

    try
    {
        if ($null -eq $item)
        {
            Write-Verbose -Message "No data to post or put, calling bog standard invoke-restmethod for $url"
            return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -ContentType 'application/json; charset=utf-8' -TimeoutSec 60
        }

        $body = $item | ConvertTo-Json -Depth 10
        Write-Verbose -Message $body

        Write-Verbose -Message "Invoking $method $url"
        return Invoke-RestMethod -Method $method -Uri $url -Headers @{"X-Octopus-ApiKey" = "$ApiKey" } -Body $body -ContentType 'application/json; charset=utf-8' -TimeoutSec 60
    }
    catch
    {
        Write-Information -MessageData "There was an error making a $method call to $url.  All request information (JSON body specifically) are logged as verbose.  Please check that for more information." -ForegroundColor Red

        if ($null -ne $_.Exception.Response)
        {
            if ($_.Exception.Response.StatusCode -eq 401)
            {
                Write-Information -MessageData "Unauthorized error returned from $url, please verify API key and try again" -ForegroundColor Red
            }
            elseif ($_.ErrorDetails.Message)
            {                
                Write-Information -MessageData -Message "Error calling $url StatusCode: $($_.Exception.Response) $($_.ErrorDetails.Message)" -ForegroundColor Red
                Write-Information -MessageData $_.Exception -ForegroundColor Red
            }            
            else 
            {
                Write-Information -MessageData $_.Exception -ForegroundColor Red
            }
        }
        else
        {
            Write-Information -MessageData $_.Exception -ForegroundColor Red
        }

        Exit 1
    }    
}

$spacesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "spaces?skip=0&take=1000" -spaceId $null -apiKey $OctopusApiKey -item $null -method "GET"

$foundVariables = @()

foreach ($space in $spacesList.Items)
{
    Write-Information -MessageData "Checking all projects in $($space.Name)"

    $projectList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "projects?skip=0&take=1000" -spaceId $space.Id -apiKey $OctopusApiKey -item $null -method "GET"
    foreach ($project in $projectList.Items)
    {
        Write-Information -MessageData "Checking project $($project.Name) variables"
        $variablesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "variables/$($project.VariableSetId)" -spaceId $space.Id -apiKey $OctopusApiKey -item $null -method "GET"
        foreach ($variable in $variablesList.Variables)
        {
            if (Get-Member -InputObject $variable.Scope -Name "Machine" -MemberType Properties)
            {
                Write-Information -MessageData "Found a machine-scoped variable"
                $foundVariables += "Variable $($variable.Name) in project $($project.Name) in space $($space.Name) has machine scoping."
            }
        }
    }

    $libraryVariableSetList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "libraryvariablesets?contentType=Variables&skip=0&take=1000" -spaceId $space.Id -apiKey $OctopusApiKey -item $null -method "GET"
    foreach ($libraryVariableSet in $libraryVariableSetList.Items)
    {
        Write-Information -MessageData "Checking library variable set $($libraryVariableSet.Name) variables"
        $variablesList = Invoke-OctopusApi -OctopusUrl $octopusUrl -endPoint "variables/$($libraryVariableSet.VariableSetId)" -spaceId $space.Id -apiKey $OctopusApiKey -item $null -method "GET"
        foreach ($variable in $variablesList.Variables)
        {
            if (Get-Member -InputObject $variable.Scope -Name "Machine" -MemberType Properties)
            {
                Write-Information -MessageData "Found a machine-scoped variable"
                $foundVariables += "Variable $($variable.Name) in library variable set $($libraryVariableSet.Name) in space $($space.Name) has machine scoping."
            }
        }
    }
}

foreach ($item in $foundVariables)
{
    Write-Information -MessageData $item
}