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

# Load assembly
Add-Type -Path 'C:\Octopus.Client\Octopus.Client.dll'

# Declare variables
$octopusUrl = "YOUR URL"
$octopusApiKey = "YOUR API KEY"
$spaceName = "YOUR SPACE NAME"
$projectName = "PROJECT NAME TO ADD"
$environmentNameList =  "ENVIRONMENTS TO TIE TO" # "Development,Test"
$tenantTag = "TENANT TAG TO FILTER ON" #Format = [Tenant Tag Set Name]/[Tenant Tag] "Tenant Type/Customer"
$whatIf = $false # Set to true to test out changes before making them
$maxNumberOfTenants = 1 # The max number of tenants you wish to change in this run
$tenantsUpdated = 0

# Create client object
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($octopusURL, $octopusAPIKey)
$repository = New-Object -TypeName Octopus.Client.OctopusRepository($endpoint)
$client = New-Object -TypeName Octopus.Client.OctopusClient($endpoint)

$space = $repository.Spaces.FindByName($spaceName)
$client = $client.ForSpace($space)

# Get project
$project = $client.Projects.FindByName($projectName)

# Get reference to environments
$environments = @()
foreach ($environmentName in $environmentNameList)
{
    $environment = $client.Environments.FindByName($environmentName)

    if ($null -ne $environment)
    {
        $environments += $environment
    }
    else
    {
        Write-Warning -Message "Environment $environmentName not found!"
    }
}

# Get tenants by tag
$tenants = $client.Tenants.FindAll("", @($tenantTag), 1000)

# Loop through returned tenants
foreach ($tenant in $tenants)
{
    $tenantUpdated = $false
    if (($null -eq $tenant.ProjectEnvironments) -or ($tenant.ProjectEnvironments.Count -eq 0))
    {
        # Add project/environments
        $tenant.ConnectToProjectAndEnvironments($project, $environments)
        $tenantUpdated = $true
    }
    else
    {
        # Get existing project connections
        $projectEnvironments = $tenant.ProjectEnvironments | Where-Object -FilterScript {$_.Keys -eq $project.Id}
        
        # Compare environment list
        $missingEnvironments = @()
        foreach ($environment in $environments)
        {
            if ($projectEnvironments.ContainsValue($environment.Id) -eq $false)
            {
                #$missingEnvironments += $environment.Id
                $tenant.ProjectEnvironments[$project.Id].Add($environment.Id)
                $tenantUpdated = $true
            }
        }
    }

    if ($tenantUpdated)
    {
        if ($whatIf)
        {
            $tenant
        }
        else
        {
            # Update tenenat
            $client.Tenants.Modify($tenant)
        }

        $tenantsUpdated ++
    }
    

    if ($tenantsUpdated -ge $maxNumberOfTenants)
    {
        # We out!
        break
    }
}
