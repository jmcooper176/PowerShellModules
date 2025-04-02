<#
 =============================================================================
<copyright file="ListDeploymentsAsXml.ps1" company="U.S. Office of Personnel
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
This file "ListDeploymentsAsXml.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

$ErrorActionPreference = "Stop";

if (($PSVersionTable.PSVersion.Major -gt 7) -or ($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion.Minor -ge 2)) {
    $PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
}

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

# Define working variables
$octopusURL = "https://your.octopus.app"
$octopusAPIKey = "API-KEY"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"

# Define the file path
$filePath = "/path/to/output.xml"

# Helper functions
function Get-Name {
    param (
        [string]$Id,
        [array]$list
    )

    if ([string]::IsNullOrWhiteSpace($Id)) {
        return $null
    }
    else {
        $item = $list | Where-Object -FilterScript { $_.Id -ieq $Id }
        if ($null -ne $item) {
            return $item.Name
        }
        else {
            return $null
        }
    }
}

# Get space
Write-Output "Retrieving space '$($spaceName)'"
$spaces = Invoke-RestMethod -Uri "$octopusURL/api/spaces?partialName=$([uri]::EscapeDataString($spaceName))&skip=0&take=100" -Headers $header 
$space = $spaces.Items | Where-Object -FilterScript { $_.Name -ieq $spaceName }

# Get all project groups
Write-Output "Retrieving all project groups"
$projectGroups = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/projectgroups" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $projectGroups += $response.Items
} while ($response.Links.'Page.Next')

# Get all projects
Write-Output "Retrieving all projects"
$projects = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/projects" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $projects += $response.Items
} while ($response.Links.'Page.Next')

# Get all environments
Write-Output "Retrieving all environments"
$environments = @()
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/environments" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    $environments += $response.Items
} while ($response.Links.'Page.Next')

Write-Output "Dumping all deployments"

# Create a FileStream and XmlWriterSettings
$fileStream = [System.IO.FileStream]::new($filePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
$xmlWriterSettings = [System.Xml.XmlWriterSettings]::new()
$xmlWriterSettings.Indent = $true

# Create the XmlWriter
$xml = [System.Xml.XmlWriter]::Create([System.IO.StreamWriter]::new($fileStream), $xmlWriterSettings)
$xml.WriteStartElement("Deployments")

# Initialize a HashSet to track seen deployments and releases
$deploymentsSeenBefore = [System.Collections.Generic.HashSet[string]]::new()
$releasesSeenBefore = @{}
$response = $null
do {
    $uri = if ($response) { $octopusURL + $response.Links.'Page.Next' } else { "$octopusURL/api/$($space.Id)/deployments" }
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
    
    foreach ($deployment in $response.Items) {
        if ($deploymentsSeenBefore.Contains($deployment.Id)) {
            continue
        }
        # Get the release for this deployment
        [PsCustomObject]$release = $null
        if ($releasesSeenBefore.ContainsKey($deployment.ReleaseId)) {
            $release = $releasesSeenBefore[$deployment.ReleaseId]
        }
        else {
            $release = Invoke-RestMethod -Uri "$octopusURL/api/$($space.Id)/releases/$($deployment.ReleaseId)" -Headers $header
            $releasesSeenBefore.Add($deployment.ReleaseId, $release) | Out-Null
        }
       
        $deploymentsSeenBefore.Add($deployment.Id) | Out-Null

        $xml.WriteStartElement("Deployment")
        $xml.WriteElementString("Environment", (Get-Name $deployment.EnvironmentId $environments))
        $xml.WriteElementString("Project", (Get-Name $deployment.ProjectId $projects))
        $xml.WriteElementString("ProjectGroup", (Get-Name $deployment.ProjectGroupId $projectGroups))
        $xml.WriteElementString("Created", ([DateTime]$deployment.Created).ToString("s"))
        $xml.WriteElementString("Name", $deployment.Name)
        $xml.WriteElementString("Id", $deployment.Id)
        $xml.WriteElementString("ReleaseNotes", $release.ReleaseNotes)
        $xml.WriteEndElement()
    }

    Write-Output ("Wrote {0:n0} of {1:n0} deployments..." -f $deploymentsSeenBefore.Count, $response.TotalResults)

} while ($response.Links.'Page.Next')

# End the XML document and flush the writer
$xml.WriteEndElement()
$xml.Flush()
$xml.Close()
$fileStream.Close()

$stopwatch.Stop()
Write-Output "Completed execution in $($stopwatch.Elapsed)"