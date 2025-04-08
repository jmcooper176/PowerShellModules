<#
 =============================================================================
<copyright file="BulkConvertMultipleProjectsToVersionControl.ps1" company="John Merryweather Cooper
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
This file "BulkConvertMultipleProjectsToVersionControl.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

# Octopus URL
$OctopusURL = "https://your.octopus.app"
$OctopusAPIKey = "API-KEY"
$Header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

# Working variables
$SpaceName = "Your-Space-Name"

# Provide the username/org for the Git repo
$username = "your-git-user-or-org-name"
# Provide the name of the Git Credential in the Octopus Library to use.
$credentialName = "Your-Git-Credentials"
# Provide the name of the Repo to place all files in.
$repo = "repo-name"
# Set default branch to use for conversion
$defaultBranch = "main"
# Set to $True to continue conversion if a project fails to convert due to an error
$continueOnConversionError = $False

# Set to $False to actually perform updates
$WhatIf = $False

# Optional,  Project names. Use this list to limit the projects that are worked on
#$ProjectNames = @("Project 1", "Project 2", "Project Y")
$ProjectNames = @()
#$ProjectExclusionList = @("Project X")
$ProjectExclusionList = @()

# Git url
#$gitUrl = "https://$($username)@bitbucket.org/$($username)/$($repo.ToLowerInvariant()).git" # BitBucket example HTTPS url
$gitUrl = "https://github.com/$username/$repo"

Write-Information -MessageData "WhatIf is set to: $WhatIf" -ForegroundColor Blue

# Get space
$Spaces = Invoke-RestMethod -Uri "$OctopusURL/api/spaces?partialName=$([uri]::EscapeDataString($SpaceName))&skip=0&take=100" -Headers $Header 
$Space = $Spaces.Items | Where-Object -FilterScript { $_.Name -eq $SpaceName }
$spaceId = $Space.Id
if ($null -eq $SpaceName) {
    throw "Couldn't find space '$SpaceName' in Octopus instance: $OctopusURL"
}

# Get Library Git Credential
$credentials = @()
$response = $null
do {
    $uri = if ($response) { $OctopusURL + $response.Links.'Page.Next' } else { "$OctopusURL/api/$($spaceId)/git-credentials" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Header
    $credentials += $response.Items
} while ($response.Links.'Page.Next')

$credential = $credentials | Where-Object -FilterScript { $_.Name -eq $credentialName }

if ($null -eq $credential) {
    throw "Couldn't find Git credentials '$credentialName' in Octopus instance: $OctopusURL"
}

# Get projects
Write-Output "Retrieving projects from $($OctopusURL)"
$projects = @()
$response = $null
do {
    $uri = if ($response) { $OctopusURL + $response.Links.'Page.Next' } else { "$OctopusURL/api/$($SpaceId)/projects" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Header
    $projects += $response.Items
} while ($response.Links.'Page.Next')

if ($ProjectNames.Length -gt 0) {    
    Write-Output "Filtering list of projects to work on."
    $projects = ($projects | Where-Object -FilterScript { $ProjectNames -icontains $_.Name })
}
else {
   
    $ContinueResult = Read-Host "Working on ALL projects to convert to GIT. Please type y/yes to confirm."

    if ($ContinueResult -ieq "y" -or $ContinueResult -ieq "yes") {
        Write-Information -MessageData "User confirmed to continue working on ALL projects..." -ForegroundColor Yellow
    }
    else {
        Write-Warning -Message "User aborted conversion process."
        Exit 0
    }
}

if ($ProjectExclusionList.Length -gt 0) {
    Write-Output "Excluding $($ProjectExclusionList.Length) project(s) from the conversion process"
    Write-Warning -Message "Projects excluded: $(@($ProjectExclusionList | ForEach-Object -Process { "$_" }) -Join ",")"
    $projects = $projects | Where-Object -FilterScript { $ProjectExclusionList -inotcontains $_.Name }
}

# Check we have projects to work on
if ($projects.Length -eq 0) {
    Write-Warning -Message "No projects to work on, exiting"
    Exit 0
}

Write-Output "Number of projects to work on: $($projects.Length)"
foreach ($project in $projects) {
    if ($project.IsVersionControlled -eq $True) {
        Write-Warning -Message "Project '$($project.Name)' is already configured for version control, skipping."
        continue;
    }
    else {
        $projectName = $project.Name
        $projectSlug = $projectName.ToLowerInvariant().Replace(" ", "-")
        $projectId = $project.Id
        if ($WhatIf -eq $True) {
            Write-Information -MessageData "WHATIF: Would've converted project tenant '$($projectName)' to use version control." -ForegroundColor Yellow
        }
        else {
            Write-Output "Updating project '$($projectName)' to use version control"
            $body = @{
                CommitMessage          = "Initial commit of deployment process for $projectName"
                VersionControlSettings = @{
                    BasePath        = ".octopus/$projectSlug"
                    ConversionState = @{
                        VariablesAreInGit = $false
                    }
                    Credentials     = @{
                        Id   = $credential.Id
                        Type = "Reference"
                    }
                    DefaultBranch   = $defaultBranch
                    Type            = "VersionControlled"
                    Url             = $gitUrl
                }
            } | ConvertTo-Json
            
            try {
                Write-Output "Making request to $OctopusURL/api/$spaceId/projects/$projectId/git/convert"
                Invoke-RestMethod -Uri "$OctopusURL/api/$spaceId/projects/$projectId/git/convert" -Headers $Header -Method Post -Body $body | Out-Null
            }
            catch {
                Write-Warning -Message "Error caught converting project '$projectName' to version control: $($_.Exception.Message)"
                if ($continueOnConversionError -eq $False) {
                    throw
                }
            }
        }
    }
}
