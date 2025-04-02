<#
 =============================================================================
<copyright file="CreateEnvironmentScopedVariables.ps1" company="U.S. Office of Personnel
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
This file "CreateEnvironmentScopedVariables.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$baseUri = "http://output.url"           # the address of your octopus server

$apiKey = "API-APIKEYAPIKEYAPIKEY"           # an api-key from an account with permissions to create
                                             # variables on the environment you specify

$projectName = "Project Name" # If you don't know your project Id add your project name here
                              # and the script will print out your project Id on the first run,
                              # then you can add it below

$projectId = ""               # set this if you know it, the script will run faster if it has
                              # a projectId, otherwise it will look up the project using its name

$environment = "Production"   # the name of the environment you want to scope the variables to

$variablesToAdd = "First", "Second", "Third"  #all the variables you want to createe

function Get-OctopusResource([string]$uri) {
    Write-Information -MessageData "[GET]: $uri"
    return Invoke-RestMethod -Method Get -Uri "$baseUri/$uri" -Headers $headers
}

function Put-OctopusResource([string]$uri, [object]$resource) {
    Write-Information -MessageData "[PUT]: $uri"
    Invoke-RestMethod -Method Put -Uri "$baseUri/$uri" -Body $($resource | ConvertTo-Json -Depth 10) -Headers $headers
}

$headers = @{"X-Octopus-ApiKey" = $apiKey}

If(!$projectId){
    # if we don't have a project Id find the project by name
    $projects = Get-OctopusResource "/api/Projects/all"
    $project = $projects | Where-Object -FilterScript { $_.Name -eq $projectName -or $_.Slug -eq $projectName } | Select-Object -First 1
    $projectId = $project.Id
    Write-Information -MessageData your project Id is $project.Id
} Else {
    # look up the project by its Id
    # can also get by project 'slug' which for "Project Name" would be "project-name"
    $project = Get-OctopusResource "/api/Projects/$projectId"
}

$variableSet = Get-OctopusResource $project.Links.Variables
$environmentObj = $variableSet.ScopeValues.Environments | Where-Object -FilterScript { $_.Name -eq $environment } | Select-Object -First 1

$variablesToAdd | ForEach-Object -Process {
    $variable = @{
        Name = $_
        Value = "#### to be entered ####"
        Type = 'String'
        Scope = @{
            Environment = @(
                $environmentObj.Id
            )
        }
    }
    $variableSet.Variables += $variable
}

Put-OctopusResource $variableSet.Links.Self $variableSet
