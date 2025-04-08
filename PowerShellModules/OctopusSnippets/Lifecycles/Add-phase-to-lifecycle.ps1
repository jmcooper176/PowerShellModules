<#
 =============================================================================
<copyright file="Add-phase-to-lifecycle.ps1" company="John Merryweather Cooper
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
This file "Add-phase-to-lifecycle.ps1" is part of "OctopusSnippets".
</summary>
<remarks>description</remarks>
=============================================================================
#>

Add-Type -Path 'path\to\Octopus.Client.dll'

$server = "YourServerURL"
$apikey = "API-KEY"
$SpaceName = ""
$LifecycleName = "" # Lifecycle to add the new phase to
$PhaseName = "" # Name of the new phase to create
$EnvironmentName = "" # Name of the environment to add to the phase

# Create endpoint and client
$endpoint = New-Object -TypeName Octopus.Client.OctopusServerEndpoint($server, $apikey)
$client = New-Object -TypeName Octopus.Client.OctopusClient($endpoint)

# Get default repository and get space by name
$repository = $client.ForSystem()
$space = $repository.Spaces.FindByName($SpaceName)

# Get space specific repository and get all projects in space
$repo = $client.ForSpace($space)

# We need to grab the entire Lifecycle object as all changes to it must be saved as an entire complete Lifecycle object.
$lifecycle = $repo.Lifecycles.FindByName($LifecycleName) # Lifecycle name to add a phase to.
# We need the Environment-id to tell the phase which environment to associate with it.
$Environment = $repo.Environments.FindByName($EnvironmentName).Id # Environment name to add to phase.

# Create new $phase object and add requisite values.
$phase = New-Object -TypeName Octopus.Client.Model.PhaseResource
$phase.Name = $PhaseName # Rename what you want.
$phase.OptionalDeploymentTargets.Add($Environment)
$phase.MinimumEnvironmentsBeforePromotion = 0

# Phase's retention Policy
#$phase.ReleaseRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(0,[Octopus.Client.Model.RetentionUnit]::Items) #Unlimmited Releases
$phase.ReleaseRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(2,[Octopus.Client.Model.RetentionUnit]::Days) #2 days
#$phase.TentacleRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(0,[Octopus.Client.Model.RetentionUnit]::Items)
$phase.TentacleRetentionPolicy = [Octopus.Client.Model.RetentionPeriod]::new(2,[Octopus.Client.Model.RetentionUnit]::Days) #2 days

# Add this $phase object to our $lifecycle object.
$lifecycle.Phases.Add($phase)

# Modify the Lifecycle with our new $lifecycle object containing our new phase.
$client.Repository.Lifecycles.Modify($lifecycle)
