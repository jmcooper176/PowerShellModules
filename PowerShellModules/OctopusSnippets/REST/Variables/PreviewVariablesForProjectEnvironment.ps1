<#
 =============================================================================
<copyright file="PreviewVariablesForProjectEnvironment.ps1" company="U.S. Office of Personnel
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
This file "PreviewVariablesForProjectEnvironment.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$OctopusUrl = "" # example https://myoctopus.something.com
$APIKey = ""  # example API-XXXXXXXXXXXXXXXXXXXXXXXXXXX
$environmentName = "Development"
$spaceName = "Default"
$projectName = ""

$header = @{ "X-Octopus-ApiKey" = $APIKey }

## First we need to find the space
$spaceList = Invoke-RestMethod "$OctopusUrl/api/spaces?Name=$spaceName" -Headers $header
$spaceFilter = @($spaceList.Items | Where-Object -FilterScript {$_.Name -eq $spaceName})
$spaceId = $spaceFilter[0].Id
Write-Information -MessageData "The spaceId for Space Name $spaceName is $spaceId"

## Next, let's find the environment
$environmentList = Invoke-RestMethod "$OctopusUrl/api/$spaceId/environments?skip=0&take=1000&name=$environmentName" -Headers $header
$environmentFilter = @($environmentList.Items | Where-Object -FilterScript {$_.Name -eq $environmentName})
$environmentId = $environmentFilter[0].Id
Write-Information -MessageData "The environmentId for Environment Name $environmentName in space $spaceName is $environmentId"

## Then, let's find the project
$projects = Invoke-RestMethod  -UseBasicParsing -Uri "$OctopusUrl/api/$spaceId/projects/all?skip=0&take=1000&name=$projectName&" -Headers $header
$projectFilter = @($projects | Where-Object -FilterScript {$_.Name -eq $projectName})
$projectId = $projectFilter[0].Id
Write-Information -MessageData "The projectId for Project Name $projectName in space $spaceName is $projectId"

## Finally, get the evaluated variables for the provided scope
$evaluatedVariables = (Invoke-RestMethod -UseBasicParsing -Uri "$OctopusURL/api/$spaceId/variables/preview?project=$projectId&environment=$environmentId" -Headers $header).Variables

Write-Information -MessageData "Printing evaluated variables for Project Name $projectName and Environment Name $environmentName"
$evaluatedVariables
